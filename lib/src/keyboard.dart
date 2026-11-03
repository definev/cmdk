import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'controller.dart';

/// Movement through the filtered, enabled command results.
enum CommandNavigation { next, previous, first, last, nextGroup, previousGroup }

/// Remappable selection movement, independent of the physical key combination.
class CommandNavigateIntent extends Intent {
  const CommandNavigateIntent(this.navigation);
  final CommandNavigation navigation;
}

/// Activates the selected command. Also used by soft-keyboard submission.
class CommandActivateIntent extends Intent {
  const CommandActivateIntent();
}

/// Default bindings. Pass a modified map to [Command.shortcuts] to remap keys.
abstract final class CommandKeyboardShortcuts {
  static Map<ShortcutActivator, Intent> defaults({
    bool vimBindings = true,
    TargetPlatform? platform,
  }) {
    final apple = switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.macOS || TargetPlatform.iOS => true,
      _ => false,
    };
    final bindings = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const CommandNavigateIntent(CommandNavigation.next),
      const SingleActivator(LogicalKeyboardKey.arrowUp):
          const CommandNavigateIntent(CommandNavigation.previous),
      const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
          const CommandNavigateIntent(CommandNavigation.nextGroup),
      const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
          const CommandNavigateIntent(CommandNavigation.previousGroup),
      const SingleActivator(LogicalKeyboardKey.home):
          const CommandNavigateIntent(CommandNavigation.first),
      const SingleActivator(LogicalKeyboardKey.end):
          const CommandNavigateIntent(CommandNavigation.last),
      const SingleActivator(LogicalKeyboardKey.home, control: true):
          const CommandNavigateIntent(CommandNavigation.first),
      const SingleActivator(LogicalKeyboardKey.end, control: true):
          const CommandNavigateIntent(CommandNavigation.last),
      // Repeats match so the manager can consume them without invoking activation.
      const SingleActivator(LogicalKeyboardKey.enter):
          const CommandActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.numpadEnter):
          const CommandActivateIntent(),
      if (apple) ...{
        const SingleActivator(LogicalKeyboardKey.arrowUp, meta: true):
            const CommandNavigateIntent(CommandNavigation.first),
        const SingleActivator(LogicalKeyboardKey.arrowDown, meta: true):
            const CommandNavigateIntent(CommandNavigation.last),
      },
    };
    if (vimBindings) {
      for (final (key, next) in [
        (LogicalKeyboardKey.keyJ, true),
        (LogicalKeyboardKey.keyN, true),
        (LogicalKeyboardKey.keyK, false),
        (LogicalKeyboardKey.keyP, false),
      ]) {
        bindings[SingleActivator(key, control: true)] = CommandNavigateIntent(
          next ? CommandNavigation.next : CommandNavigation.previous,
        );
        bindings[SingleActivator(
          key,
          control: true,
          alt: true,
        )] = CommandNavigateIntent(
          next ? CommandNavigation.nextGroup : CommandNavigation.previousGroup,
        );
        if (apple) {
          bindings[SingleActivator(
            key,
            control: true,
            meta: true,
          )] = CommandNavigateIntent(
            next ? CommandNavigation.last : CommandNavigation.first,
          );
        }
      }
    }
    return bindings;
  }
}

/// Identity separates nested menus; actions and bindings follow the nearest menu.
class CommandKeyboardScope extends InheritedWidget {
  const CommandKeyboardScope({
    super.key,
    required this.controller,
    required super.child,
  });
  final CommandController controller;
  static CommandKeyboardScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommandKeyboardScope>();
  @override
  bool updateShouldNotify(CommandKeyboardScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Marks the search editor as opting into command navigation.
class CommandInputKeyboardScope extends InheritedWidget {
  const CommandInputKeyboardScope({
    super.key,
    required this.controller,
    required this.textController,
    required super.child,
  });
  final CommandController controller;
  final TextEditingController textController;
  bool get isComposing =>
      textController.value.composing.isValid &&
      !textController.value.composing.isCollapsed;
  static CommandInputKeyboardScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommandInputKeyboardScope>();
  @override
  bool updateShouldNotify(CommandInputKeyboardScope oldWidget) =>
      controller != oldWidget.controller ||
      textController != oldWidget.textController;
}

/// Only guards event routing; Flutter performs activator matching, action lookup,
/// enablement, dispatch and key consumption in super.handleKeypress.
class CommandShortcutManager extends ShortcutManager {
  CommandShortcutManager(this.controller, this.rootFocusNode);
  final CommandController controller;
  final FocusNode Function() rootFocusNode;
  @override
  KeyEventResult handleKeypress(BuildContext context, KeyEvent event) {
    final focused = primaryFocus?.context;
    if (focused == null ||
        CommandKeyboardScope.maybeOf(focused)?.controller != controller) {
      return KeyEventResult.ignored;
    }
    final input = CommandInputKeyboardScope.maybeOf(focused);
    if (input?.controller == controller && input!.isComposing) {
      return KeyEventResult.skipRemainingHandlers;
    }
    // Embedded controls keep their own bindings. Only the menu root and its
    // search editor opt into menu navigation/activation by default.
    if (input?.controller != controller && primaryFocus != rootFocusNode()) {
      return KeyEventResult.ignored;
    }
    if (event is KeyRepeatEvent) {
      for (final entry in shortcuts.entries) {
        if (entry.value is CommandActivateIntent &&
            entry.key.accepts(event, HardwareKeyboard.instance)) {
          return KeyEventResult.handled;
        }
      }
    }
    return super.handleKeypress(context, event);
  }
}

Map<Type, Action<Intent>> commandActions(CommandController controller) => {
  CommandNavigateIntent: _NavigateAction(controller),
  CommandActivateIntent: _ActivateAction(controller),
};

class _NavigateAction extends Action<CommandNavigateIntent> {
  _NavigateAction(this.controller);
  final CommandController controller;
  @override
  bool isEnabled(CommandNavigateIntent intent) =>
      controller.getSortedValidItems().isNotEmpty;
  @override
  Object? invoke(CommandNavigateIntent intent) {
    switch (intent.navigation) {
      case CommandNavigation.next:
        controller.nextItem();
      case CommandNavigation.previous:
        controller.prevItem();
      case CommandNavigation.first:
        controller.firstItem();
      case CommandNavigation.last:
        controller.lastItem();
      case CommandNavigation.nextGroup:
        controller.nextItem(isAlt: true);
      case CommandNavigation.previousGroup:
        controller.prevItem(isAlt: true);
    }
    return null;
  }
}

class _ActivateAction extends Action<CommandActivateIntent> {
  _ActivateAction(this.controller);
  final CommandController controller;
  @override
  bool isEnabled(CommandActivateIntent intent) =>
      controller.selectedItemId != null;
  @override
  Object? invoke(CommandActivateIntent intent) {
    controller.selectCurrent();
    return null;
  }
}
