import 'package:flutter/widgets.dart';
import 'command_score.dart';
import 'controller.dart';
import 'scope.dart';
import 'keyboard.dart';

/// The root command menu widget.
///
/// Provides the [CommandScope], manages focus, and intercepts keyboard shortcuts.
class Command extends StatefulWidget {
  const Command({
    super.key,
    this.controller,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.search,
    this.onSearchChange,
    this.shouldFilter,
    this.filter,
    this.loop,
    this.vimBindings,
    this.disablePointerSelection,
    this.label,
    this.focusNode,
    this.autofocus = false,
    this.onKeyEvent,
    this.shortcuts,
    this.actions,
    required this.child,
  });

  /// Optional external controller. If omitted, [Command] manages its own controller.
  final CommandController? controller;

  /// Controlled selected item value.
  final String? value;

  /// Initial item value when initially rendered (uncontrolled).
  final String? defaultValue;

  /// Callback when selected item value changes.
  final ValueChanged<String?>? onValueChange;

  /// Controlled search query.
  final String? search;

  /// Callback when search query changes.
  final ValueChanged<String>? onSearchChange;

  /// Whether automatic filtering and sorting are enabled. Defaults to `true`.
  final bool? shouldFilter;

  /// Custom filter function. Defaults to [commandScore].
  final CommandFilter? filter;

  /// Whether arrow navigation wraps around at the edges. Defaults to `false`.
  final bool? loop;

  /// Whether Vim key bindings (Ctrl+j/k/n/p) are enabled. Defaults to `true`.
  final bool? vimBindings;

  /// Whether mouse hover/pointer selection is disabled. Defaults to `false`.
  final bool? disablePointerSelection;

  /// Accessible label for screen readers.
  final String? label;

  /// Optional focus node for the command container.
  final FocusNode? focusNode;

  /// Whether the command container should autofocus. Defaults to `false`.
  final bool autofocus;

  /// Optional callback to intercept key events before [Command] processes them.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Replaces the default bindings. Use CommandKeyboardShortcuts.defaults()
  /// as a base to merge or remove individual bindings. An empty map disables
  /// menu shortcuts while preserving ancestor/native text editing shortcuts.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Overrides default actions. Descendant Actions can override these further.
  /// Override actions remain owned by the caller.
  final Map<Type, Action<Intent>>? actions;

  final Widget child;

  @override
  State<Command> createState() => _CommandState();
}

class _CommandState extends State<Command> {
  late CommandController _controller;
  bool _ownsController = false;
  late CommandShortcutManager _shortcutManager;
  final _fallbackFocusNode = FocusNode(debugLabel: 'Command');

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        CommandController(
            value: widget.value ?? widget.defaultValue, search: widget.search);
    _shortcutManager = CommandShortcutManager(
        _controller, () => widget.focusNode ?? _fallbackFocusNode);
    _configure();
  }

  void _configure() {
    _controller.attach(CommandBinding(
        owner: this,
        value: widget.value,
        search: widget.search,
        onValueChange: widget.onValueChange,
        onSearchChange: widget.onSearchChange,
        shouldFilter: widget.shouldFilter,
        filter: widget.filter,
        loop: widget.loop,
        vimBindings: widget.vimBindings,
        disablePointerSelection: widget.disablePointerSelection));
  }

  @override
  void didUpdateWidget(Command oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final previous = _controller;
      final owned = _ownsController;
      previous.detach(this);
      _shortcutManager.dispose();
      _createController();
      if (owned) {
        WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
      }
    } else {
      _configure();
    }
  }

  @override
  void dispose() {
    _shortcutManager.dispose();
    _fallbackFocusNode.dispose();
    _controller.detach(this);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.onKeyEvent != null) {
      final customResult = widget.onKeyEvent!(node, event);
      if (customResult != KeyEventResult.ignored) {
        return customResult;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return CommandScope(
      controller: _controller,
      child: CommandKeyboardScope(
        controller: _controller,
        child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              _shortcutManager.shortcuts = widget.shortcuts ??
                  CommandKeyboardShortcuts.defaults(
                      vimBindings: _controller.vimBindings);
              return Actions(
                  actions: {...commandActions(_controller), ...?widget.actions},
                  child: Shortcuts.manager(
                      manager: _shortcutManager,
                      child: Semantics(
                          label: widget.label ?? 'Command Menu',
                          container: true,
                          child: Focus(
                              focusNode: widget.focusNode ?? _fallbackFocusNode,
                              autofocus: widget.autofocus,
                              onKeyEvent: _handleKeyEvent,
                              child: widget.child))));
            }),
      ),
    );
  }
}
