import 'package:cmdk/cmdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child) => WidgetsApp(
  color: const Color(0xFF000000),
  pageRouteBuilder: <T>(settings, builder) =>
      PageRouteBuilder<T>(pageBuilder: (context, _, __) => builder(context)),
  home: Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: 500, height: 400, child: child),
  ),
);
const entries = CommandList(
  children: [
    CommandGroup(
      value: 'g1',
      children: [
        CommandItem(value: 'a', child: Text('A')),
        CommandItem(value: 'b', child: Text('B')),
      ],
    ),
    CommandGroup(
      value: 'g2',
      children: [
        CommandItem(value: 'c', child: Text('C')),
        CommandItem(value: 'd', child: Text('D')),
      ],
    ),
  ],
);
Widget menu(
  CommandController controller, {
  Widget input = const CommandInput(),
  Map<ShortcutActivator, Intent>? shortcuts,
  Map<Type, Action<Intent>>? actions,
  FocusOnKeyEventCallback? onKeyEvent,
}) => Command(
  controller: controller,
  shortcuts: shortcuts,
  actions: actions,
  onKeyEvent: onKeyEvent,
  child: Column(children: [input, entries]),
);
Future<void> chord(
  WidgetTester t,
  LogicalKeyboardKey key, [
  List<LogicalKeyboardKey> modifiers = const [],
]) async {
  for (final modifier in modifiers) {
    await t.sendKeyDownEvent(modifier);
  }
  await t.sendKeyEvent(key);
  for (final modifier in modifiers.reversed) {
    await t.sendKeyUpEvent(modifier);
  }
  await t.pump();
}

void main() {
  testWidgets('physical navigation, groups, boundaries and input focus', (
    t,
  ) async {
    final controller = CommandController();
    await t.pumpWidget(app(menu(controller)));
    await t.pumpAndSettle();
    final input = t.widget<EditableText>(find.byType(EditableText));
    await chord(t, LogicalKeyboardKey.arrowDown);
    expect(controller.selectedValue, 'b');
    await chord(t, LogicalKeyboardKey.arrowDown, [LogicalKeyboardKey.altLeft]);
    expect(controller.selectedValue, 'c');
    await chord(t, LogicalKeyboardKey.arrowUp, [LogicalKeyboardKey.altRight]);
    expect(controller.selectedValue, 'a');
    await chord(t, LogicalKeyboardKey.end);
    expect(controller.selectedValue, 'd');
    await chord(t, LogicalKeyboardKey.home, [LogicalKeyboardKey.controlRight]);
    expect(controller.selectedValue, 'a');
    expect(input.focusNode.hasPrimaryFocus, isTrue);
  });

  testWidgets('platform profiles match actual Meta events', (t) async {
    final controller = CommandController();
    await t.pumpWidget(app(menu(controller)));
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.arrowDown, [LogicalKeyboardKey.metaLeft]);
    final apple =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    expect(controller.selectedValue, apple ? 'd' : 'a');
  }, variant: TargetPlatformVariant.all());

  testWidgets('Vim bindings update from external controller at runtime', (
    t,
  ) async {
    final controller = CommandController();
    await t.pumpWidget(app(menu(controller)));
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.keyJ, [LogicalKeyboardKey.controlRight]);
    expect(controller.selectedValue, 'b');
    await chord(t, LogicalKeyboardKey.keyN, [
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.altLeft,
    ]);
    expect(controller.selectedValue, 'c');
    controller.vimBindings = false;
    await t.pump();
    await chord(t, LogicalKeyboardKey.keyK, [LogicalKeyboardKey.controlLeft]);
    expect(controller.selectedValue, 'c');
  });

  testWidgets('custom shortcut map replaces defaults and can change live', (
    t,
  ) async {
    final controller = CommandController();
    Widget build(bool custom) => app(
      menu(
        controller,
        shortcuts: custom
            ? {
                const SingleActivator(LogicalKeyboardKey.f2):
                    const CommandNavigateIntent(CommandNavigation.last),
              }
            : null,
      ),
    );
    await t.pumpWidget(build(true));
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.arrowDown);
    expect(controller.selectedValue, 'a');
    await chord(t, LogicalKeyboardKey.f2);
    expect(controller.selectedValue, 'd');
    await t.pumpWidget(build(false));
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.arrowUp);
    expect(controller.selectedValue, 'c');
  });

  testWidgets('descendant Shortcuts override the menu mapping', (t) async {
    final controller = CommandController();
    await t.pumpWidget(
      app(
        menu(
          controller,
          input: const Shortcuts(
            shortcuts: {
              SingleActivator(LogicalKeyboardKey.arrowDown):
                  CommandNavigateIntent(CommandNavigation.last),
            },
            child: CommandInput(),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.arrowDown);
    expect(controller.selectedValue, 'd');
  });

  testWidgets(
    'Actions overrides apply to physical and soft keyboard activation',
    (t) async {
      final controller = CommandController();
      var calls = 0;
      await t.pumpWidget(
        app(
          menu(
            controller,
            input: Actions(
              actions: {
                CommandActivateIntent: CallbackAction<CommandActivateIntent>(
                  onInvoke: (_) {
                    calls++;
                    return null;
                  },
                ),
              },
              child: const CommandInput(),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await chord(t, LogicalKeyboardKey.enter);
      expect(calls, 1);
      await t.testTextInput.receiveAction(TextInputAction.search);
      await t.pump();
      expect(calls, 2);
    },
  );

  testWidgets('root action override is invoked by Actions API', (t) async {
    final controller = CommandController();
    var calls = 0;
    await t.pumpWidget(
      app(
        menu(
          controller,
          actions: {
            CommandNavigateIntent: CallbackAction<CommandNavigateIntent>(
              onInvoke: (_) {
                calls++;
                return null;
              },
            ),
          },
        ),
      ),
    );
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.arrowDown);
    expect(calls, 1);
    expect(controller.selectedValue, 'a');
    final editable = t.widget<EditableText>(find.byType(EditableText));
    Actions.maybeInvoke(
      editable.focusNode.context!,
      const CommandNavigateIntent(CommandNavigation.next),
    );
    expect(calls, 2);
  });

  testWidgets('disabled activation action also disables soft submission', (
    t,
  ) async {
    final controller = CommandController();
    final action = _DisabledActivation();
    await t.pumpWidget(
      app(menu(controller, actions: {CommandActivateIntent: action})),
    );
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.enter);
    await t.testTextInput.receiveAction(TextInputAction.search);
    expect(action.calls, 0);
  });

  testWidgets(
    'navigation repeats, activation does not repeat or submit twice',
    (t) async {
      final controller = CommandController();
      var calls = 0;
      await t.pumpWidget(
        app(
          Command(
            controller: controller,
            child: Column(
              children: [
                const CommandInput(),
                CommandList(
                  children: [
                    CommandItem(
                      value: 'a',
                      onSelect: () => calls++,
                      child: const Text('A'),
                    ),
                    CommandItem(
                      value: 'b',
                      onSelect: () => calls++,
                      child: const Text('B'),
                    ),
                    CommandItem(
                      value: 'c',
                      onSelect: () => calls++,
                      child: const Text('C'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyRepeatEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await t.pump();
      expect(controller.selectedValue, 'c');
      await t.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await t.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
      await t.sendKeyRepeatEvent(LogicalKeyboardKey.enter);
      await t.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await t.pump();
      expect(calls, 1);
      await chord(t, LogicalKeyboardKey.numpadEnter);
      expect(calls, 2);
    },
  );

  testWidgets('IME guard protects remapped shortcuts and descendant managers', (
    t,
  ) async {
    final controller = CommandController();
    var calls = 0;
    await t.pumpWidget(
      app(
        menu(
          controller,
          shortcuts: {
            const SingleActivator(LogicalKeyboardKey.f2):
                const CommandActivateIntent(),
          },
          actions: {
            CommandActivateIntent: CallbackAction<CommandActivateIntent>(
              onInvoke: (_) {
                calls++;
                return null;
              },
            ),
          },
        ),
      ),
    );
    await t.pumpAndSettle();
    t.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'a',
        selection: TextSelection.collapsed(offset: 1),
        composing: TextRange(start: 0, end: 1),
      ),
    );
    await t.pump();
    await chord(t, LogicalKeyboardKey.f2);
    expect(calls, 0);
  });

  testWidgets('modified editing keys are not interpreted as menu navigation', (
    t,
  ) async {
    final controller = CommandController(shouldFilter: false, search: 'hello');
    await t.pumpWidget(app(menu(controller)));
    await t.pumpAndSettle();
    final text = t.widget<EditableText>(find.byType(EditableText)).controller;
    text.selection = const TextSelection.collapsed(offset: 3);
    await chord(t, LogicalKeyboardKey.arrowLeft, [
      LogicalKeyboardKey.shiftLeft,
    ]);
    expect(text.selection, const TextSelection(baseOffset: 3, extentOffset: 2));
    await chord(t, LogicalKeyboardKey.home, [LogicalKeyboardKey.shiftLeft]);
    expect(controller.selectedValue, 'a');
    await chord(t, LogicalKeyboardKey.keyA, [LogicalKeyboardKey.controlLeft]);
    expect(controller.selectedValue, 'a');
    expect(text.selection.isCollapsed, isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('embedded editor and focusable button keep their own shortcuts', (
    t,
  ) async {
    final controller = CommandController();
    final field = FocusNode();
    final button = FocusNode();
    final text = TextEditingController(text: 'hello');
    var pressed = 0;
    await t.pumpWidget(
      app(
        Command(
          controller: controller,
          child: Column(
            children: [
              EditableText(
                controller: text,
                focusNode: field,
                style: const TextStyle(color: Color(0xFF000000)),
                cursorColor: const Color(0xFF000000),
                backgroundCursorColor: const Color(0xFF000000),
              ),
              Actions(
                actions: {
                  ActivateIntent: CallbackAction<ActivateIntent>(
                    onInvoke: (_) {
                      pressed++;
                      return null;
                    },
                  ),
                },
                child: Focus(focusNode: button, child: const Text('Button')),
              ),
              entries,
            ],
          ),
        ),
      ),
    );
    field.requestFocus();
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.end);
    expect(controller.selectedValue, 'a');
    expect(text.selection.extentOffset, 5);
    button.requestFocus();
    await t.pump();
    await chord(t, LogicalKeyboardKey.enter);
    expect(pressed, 1);
    expect(controller.selectedValue, 'a');
    await t.pumpWidget(const SizedBox());
    field.dispose();
    button.dispose();
    text.dispose();
    controller.dispose();
  });

  testWidgets('empty nested menu never navigates the outer menu', (t) async {
    final outer = CommandController();
    final inner = CommandController();
    await t.pumpWidget(
      app(
        Command(
          controller: outer,
          child: Column(
            children: [
              Command(controller: inner, child: const CommandInput()),
              entries,
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.arrowDown);
    expect(outer.selectedValue, 'a');
    expect(inner.selectedValue, isNull);
  });

  testWidgets('root focus and custom interceptor work without an input', (
    t,
  ) async {
    final controller = CommandController();
    var intercept = false;
    final node = FocusNode();
    await t.pumpWidget(
      app(
        Command(
          controller: controller,
          focusNode: node,
          autofocus: true,
          onKeyEvent: (_, event) =>
              intercept ? KeyEventResult.handled : KeyEventResult.ignored,
          child: entries,
        ),
      ),
    );
    await t.pumpAndSettle();
    await chord(t, LogicalKeyboardKey.arrowDown);
    expect(controller.selectedValue, 'b');
    intercept = true;
    await chord(t, LogicalKeyboardKey.arrowDown);
    expect(controller.selectedValue, 'b');
    await t.pumpWidget(const SizedBox());
    node.dispose();
    controller.dispose();
  });
  testWidgets('removing Home and End restores native caret movement', (
    t,
  ) async {
    final controller = CommandController(shouldFilter: false, search: 'hello');
    final shortcuts = CommandKeyboardShortcuts.defaults()
      ..remove(const SingleActivator(LogicalKeyboardKey.home))
      ..remove(const SingleActivator(LogicalKeyboardKey.end));
    await t.pumpWidget(app(menu(controller, shortcuts: shortcuts)));
    await t.pumpAndSettle();
    final text = t.widget<EditableText>(find.byType(EditableText)).controller;
    text.selection = const TextSelection.collapsed(offset: 3);
    await chord(t, LogicalKeyboardKey.home);
    expect(text.selection.extentOffset, 0);
    await chord(t, LogicalKeyboardKey.end);
    expect(text.selection.extentOffset, 5);
    expect(controller.selectedValue, 'a');
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('input suffix retains native button activation', (t) async {
    final controller = CommandController();
    final button = FocusNode();
    var calls = 0;
    await t.pumpWidget(
      app(
        menu(
          controller,
          input: CommandInput(
            suffix: Actions(
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    calls++;
                    return null;
                  },
                ),
              },
              child: Focus(focusNode: button, child: const Text('Suffix')),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    button.requestFocus();
    await t.pump();
    await chord(t, LogicalKeyboardKey.enter);
    expect(calls, 1);
    expect(controller.selectedValue, 'a');
    await t.pumpWidget(const SizedBox());
    button.dispose();
    controller.dispose();
  });

  testWidgets(
    'controller migration and external root focus replacement use current actions',
    (t) async {
      final first = CommandController();
      final second = CommandController();
      final a = FocusNode();
      final b = FocusNode();
      Widget build(CommandController controller, FocusNode focus) => app(
        Command(controller: controller, focusNode: focus, child: entries),
      );
      await t.pumpWidget(build(first, a));
      a.requestFocus();
      await t.pumpAndSettle();
      await chord(t, LogicalKeyboardKey.end);
      expect(first.selectedValue, 'd');
      await t.pumpWidget(build(second, b));
      b.requestFocus();
      await t.pumpAndSettle();
      await chord(t, LogicalKeyboardKey.arrowDown);
      expect(second.selectedValue, 'b');
      expect(first.getSortedValidItems(), isEmpty);
      await t.pumpWidget(const SizedBox());
      a.dispose();
      b.dispose();
      first.dispose();
      second.dispose();
    },
  );
}

class _DisabledActivation extends Action<CommandActivateIntent> {
  int calls = 0;
  @override
  bool isEnabled(CommandActivateIntent intent) => false;
  @override
  Object? invoke(CommandActivateIntent intent) {
    calls++;
    return null;
  }
}
