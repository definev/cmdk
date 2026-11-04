import 'package:cmdk/cmdk.dart';
import 'package:cmdk_ui/cupertino.dart';
import 'package:cmdk_ui/material.dart';
// Exercise the SDK adapters across the package's supported Flutter range.
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Editor {
  headless,
  material,
  cupertino;

  CommandInputEditorBuilder? get builder => switch (this) {
    headless => null,
    material => materialCommandInputBuilder(),
    cupertino => cupertinoCommandInputBuilder(),
  };

  TargetPlatform get platform =>
      this == cupertino ? TargetPlatform.iOS : TargetPlatform.android;
}

Widget _app(_Editor editor, Widget child) {
  final content = Align(
    alignment: Alignment.topCenter,
    child: SizedBox(width: 360, height: 600, child: child),
  );
  return switch (editor) {
    _Editor.material => material.MaterialApp(
      theme: material.ThemeData.dark().copyWith(
        splashFactory: material.NoSplash.splashFactory,
      ),
      home: material.Scaffold(body: content),
    ),
    _Editor.cupertino => cupertino.CupertinoApp(
      theme: const cupertino.CupertinoThemeData(brightness: Brightness.dark),
      home: cupertino.CupertinoPageScaffold(child: content),
    ),
    _Editor.headless => WidgetsApp(
      color: const Color(0xFF000000),
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        pageBuilder: (context, _, __) => builder(context),
      ),
      home: content,
    ),
  };
}

Widget _menu(
  CommandController controller,
  CommandInput input, {
  VoidCallback? onSelect,
}) => Command(
  controller: controller,
  child: Column(
    children: [
      input,
      CommandList(
        children: [
          CommandItem(
            value: 'a',
            onSelect: onSelect,
            child: const Text('Result'),
          ),
        ],
      ),
    ],
  ),
);

EditableText _editable(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

Future<void> _selectWorkspace(WidgetTester tester) async {
  final state = tester.state<EditableTextState>(find.byType(EditableText));
  final position = state.renderEditable.localToGlobal(
    state.renderEditable
        .getLocalRectForCaret(const TextPosition(offset: 7))
        .center,
  );
  await tester.tapAt(position);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tapAt(position);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    String? clipboard;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          switch (call.method) {
            case 'Clipboard.setData':
              clipboard =
                  (call.arguments as Map<Object?, Object?>)['text'] as String;
              return null;
            case 'Clipboard.getData':
              return clipboard == null ? null : {'text': clipboard};
            case 'Clipboard.hasStrings':
              return {'value': clipboard?.isNotEmpty ?? false};
            default:
              return null;
          }
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  for (final editor in _Editor.values) {
    void testEditor(String description, WidgetTesterCallback callback) =>
        testWidgets(
          description,
          callback,
          variant: TargetPlatformVariant.only(editor.platform),
        );

    group(editor.name, () {
      testEditor('command keyboard defaults and overrides reach the IME', (
        tester,
      ) async {
        final command = CommandController();
        await tester.pumpWidget(
          _app(
            editor,
            _menu(command, CommandInput(editorBuilder: editor.builder)),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.testTextInput.setClientArgs!['autocorrect'], isFalse);
        expect(
          tester.testTextInput.setClientArgs!['enableSuggestions'],
          isTrue,
        );
        expect(_editable(tester).smartDashesType, SmartDashesType.disabled);
        expect(_editable(tester).smartQuotesType, SmartQuotesType.disabled);
        expect(_editable(tester).textCapitalization, TextCapitalization.none);
        if (editor != _Editor.headless) {
          expect(_editable(tester).keyboardAppearance, Brightness.dark);
        }

        await tester.pumpWidget(
          _app(
            editor,
            _menu(
              command,
              CommandInput(
                editorBuilder: editor.builder,
                autocorrect: true,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.words,
                smartDashesType: SmartDashesType.enabled,
                smartQuotesType: SmartQuotesType.enabled,
                keyboardAppearance: Brightness.light,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(_editable(tester).autocorrect, isTrue);
        // Flutter sends these options when the next IME session is attached.
        final focus = _editable(tester).focusNode;
        focus.unfocus();
        await tester.pump();
        focus.requestFocus();
        await tester.pumpAndSettle();
        expect(tester.testTextInput.setClientArgs!['autocorrect'], isTrue);
        expect(
          tester.testTextInput.setClientArgs!['enableSuggestions'],
          isFalse,
        );
        expect(_editable(tester).textCapitalization, TextCapitalization.words);
        expect(_editable(tester).keyboardAppearance, Brightness.light);
      });

      testEditor('Search keeps focus; composing Search never activates', (
        tester,
      ) async {
        final command = CommandController(shouldFilter: false);
        var calls = 0;
        await tester.pumpWidget(
          _app(
            editor,
            _menu(
              command,
              CommandInput(editorBuilder: editor.builder),
              onSelect: () => calls++,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        expect(calls, 1);
        expect(_editable(tester).focusNode.hasPrimaryFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);

        const composing = TextEditingValue(
          text: 'tiế',
          selection: TextSelection.collapsed(offset: 3),
          composing: TextRange(start: 0, end: 3),
        );
        tester.testTextInput.updateEditingValue(composing);
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        expect(calls, 1);
        expect(_editable(tester).controller.value, composing);
        expect(_editable(tester).focusNode.hasPrimaryFocus, isTrue);

        tester.testTextInput.updateEditingValue(
          composing.copyWith(composing: TextRange.empty),
        );
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        expect(calls, 2);
      });

      testEditor('optional unfocus applies only to enabled soft submission', (
        tester,
      ) async {
        final command = CommandController(search: 'missing');
        var calls = 0;
        await tester.pumpWidget(
          _app(
            editor,
            _menu(
              command,
              CommandInput(
                editorBuilder: editor.builder,
                unfocusOnSubmit: true,
              ),
              onSelect: () => calls++,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        expect(calls, 0);
        expect(_editable(tester).focusNode.hasPrimaryFocus, isTrue);
        command.setSearch('a');
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        expect(calls, 1);
        expect(_editable(tester).focusNode.hasFocus, isFalse);
      });

      testEditor('controlled rejection waits for IME commit without feedback', (
        tester,
      ) async {
        final requests = <String>[];
        await tester.pumpWidget(
          _app(
            editor,
            Command(
              search: '',
              onSearchChange: requests.add,
              child: CommandInput(editorBuilder: editor.builder),
            ),
          ),
        );
        await tester.pumpAndSettle();
        const composing = TextEditingValue(
          text: 'tiế',
          selection: TextSelection.collapsed(offset: 3),
          composing: TextRange(start: 0, end: 3),
        );
        tester.testTextInput.updateEditingValue(composing);
        await tester.pumpAndSettle();
        expect(_editable(tester).controller.value, composing);
        expect(requests, ['tiế']);

        // The commit changes only composing, not the query text.
        tester.testTextInput.updateEditingValue(
          composing.copyWith(composing: TextRange.empty),
        );
        await tester.pumpAndSettle();
        expect(_editable(tester).controller.text, '');
        expect(requests, ['tiế']);
        expect(_editable(tester).focusNode.hasPrimaryFocus, isTrue);
      });

      testEditor('accepted Vietnamese composing edits preserve editing value', (
        tester,
      ) async {
        var query = '';
        final changes = <String>[];
        await tester.pumpWidget(
          _app(
            editor,
            StatefulBuilder(
              builder: (context, update) => Command(
                search: query,
                onSearchChange: (value) => update(() => query = value),
                child: CommandInput(
                  editorBuilder: editor.builder,
                  onValueChange: changes.add,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final text in ['tie', 'tiế', 'tiếng']) {
          final value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
            composing: TextRange(start: 0, end: text.length),
          );
          tester.testTextInput.updateEditingValue(value);
          await tester.pumpAndSettle();
          expect(_editable(tester).controller.value, value);
          expect(query, text);
        }
        final committed = _editable(tester).controller.value.copyWith(
          composing: TextRange.empty,
          selection: const TextSelection(baseOffset: 4, extentOffset: 1),
        );
        tester.testTextInput.updateEditingValue(committed);
        await tester.pumpAndSettle();
        expect(_editable(tester).controller.value, committed);
        expect(changes, ['tie', 'tiế', 'tiếng']);
      });

      testEditor('focus loss reconciles a deferred authoritative query', (
        tester,
      ) async {
        final command = CommandController();
        final focus = FocusNode();
        await tester.pumpWidget(
          _app(
            editor,
            _menu(
              command,
              CommandInput(editorBuilder: editor.builder, focusNode: focus),
            ),
          ),
        );
        await tester.pumpAndSettle();
        const composing = TextEditingValue(
          text: 'tie',
          selection: TextSelection.collapsed(offset: 3),
          composing: TextRange(start: 0, end: 3),
        );
        tester.testTextInput.updateEditingValue(composing);
        command.setSearch('external');
        await tester.pumpAndSettle();
        expect(_editable(tester).controller.value, composing);
        focus.unfocus();
        await tester.pumpAndSettle();
        expect(_editable(tester).controller.text, 'external');
        expect(_editable(tester).controller.value.composing, TextRange.empty);
        await tester.pumpWidget(const SizedBox());
        focus.dispose();
      });

      if (editor != _Editor.headless) {
        testEditor('suffix clear shares the editor tap region', (tester) async {
          final command = CommandController(search: 'workspace');
          final text = TextEditingController();
          final changes = <String>[];
          await tester.pumpWidget(
            _app(
              editor,
              _menu(
                command,
                CommandInput(
                  controller: text,
                  editorBuilder: editor.builder,
                  onValueChange: changes.add,
                  suffix: GestureDetector(
                    onTap: text.clear,
                    child: const SizedBox(
                      key: ValueKey('clear'),
                      width: 48,
                      height: 48,
                      child: Center(child: Text('Clear')),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          // Mouse clicks normally dismiss an editor when outside its tap region.
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer();
          await mouse.down(
            tester.getCenter(find.byKey(const ValueKey('clear'))),
          );
          await mouse.up();
          await mouse.removePointer();
          await tester.pumpAndSettle();
          expect(text.text, '');
          expect(command.search, '');
          expect(changes, ['']);
          expect(_editable(tester).focusNode.hasPrimaryFocus, isTrue);
          await tester.pumpWidget(const SizedBox());
          text.dispose();
        });

        testEditor('submission lets an action transfer focus', (tester) async {
          final destination = FocusNode();
          final command = CommandController();
          await tester.pumpWidget(
            _app(
              editor,
              Command(
                controller: command,
                actions: {
                  CommandActivateIntent: CallbackAction<CommandActivateIntent>(
                    onInvoke: (_) {
                      destination.requestFocus();
                      return null;
                    },
                  ),
                },
                child: Column(
                  children: [
                    CommandInput(editorBuilder: editor.builder),
                    Focus(focusNode: destination, child: const Text('Next')),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle();
          expect(destination.hasPrimaryFocus, isTrue);
          expect(_editable(tester).focusNode.hasFocus, isFalse);
          await tester.pumpWidget(const SizedBox());
          destination.dispose();
        });

        testEditor('query replacement preserves directional text selection', (
          tester,
        ) async {
          final command = CommandController(search: 'open workspace');
          final changes = <String>[];
          await tester.pumpWidget(
            _app(
              editor,
              _menu(
                command,
                CommandInput(
                  editorBuilder: editor.builder,
                  onValueChange: changes.add,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final text = _editable(tester).controller;
          text.selection = const TextSelection(
            baseOffset: 12,
            extentOffset: 2,
            affinity: TextAffinity.upstream,
            isDirectional: true,
          );
          command.setSearch('shorter');
          await tester.pumpAndSettle();
          expect(
            text.selection,
            const TextSelection(
              baseOffset: 7,
              extentOffset: 2,
              affinity: TextAffinity.upstream,
              isDirectional: true,
            ),
          );
          expect(changes, isEmpty);
        });

        testEditor('word selection and Copy do not publish query edits', (
          tester,
        ) async {
          final command = CommandController(search: 'open workspace');
          final changes = <String>[];
          await tester.pumpWidget(
            _app(
              editor,
              _menu(
                command,
                CommandInput(
                  editorBuilder: editor.builder,
                  onValueChange: changes.add,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await _selectWorkspace(tester);
          final text = _editable(tester).controller;
          expect(text.selection.textInside(text.text), 'workspace');
          expect(_editable(tester).showSelectionHandles, isTrue);
          await tester.tap(find.text('Copy'));
          await tester.pumpAndSettle();
          expect(
            (await Clipboard.getData(Clipboard.kTextPlain))!.text,
            'workspace',
          );
          expect(command.search, 'open workspace');
          expect(changes, isEmpty);
        });

        testEditor('native Paste updates query once and preserves focus', (
          tester,
        ) async {
          final command = CommandController(search: 'open workspace');
          final changes = <String>[];
          await Clipboard.setData(const ClipboardData(text: 'settings'));
          await tester.pumpWidget(
            _app(
              editor,
              _menu(
                command,
                CommandInput(
                  editorBuilder: editor.builder,
                  onValueChange: changes.add,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await _selectWorkspace(tester);
          await tester.tap(find.text('Paste'));
          await tester.pumpAndSettle();
          expect(command.search, 'open settings');
          expect(changes, ['open settings']);
          expect(_editable(tester).focusNode.hasPrimaryFocus, isTrue);
        });

        testEditor('menu navigation works through native editor focus', (
          tester,
        ) async {
          final command = CommandController();
          var calls = 0;
          await tester.pumpWidget(
            _app(
              editor,
              Command(
                controller: command,
                child: Column(
                  children: [
                    CommandInput(editorBuilder: editor.builder),
                    CommandList(
                      children: [
                        const CommandItem(value: 'a', child: Text('A')),
                        CommandItem(
                          value: 'b',
                          onSelect: () => calls++,
                          child: const Text('B'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();
          expect(command.selectedValue, 'b');
          expect(calls, 1);
          expect(_editable(tester).focusNode.hasPrimaryFocus, isTrue);
        });

        testEditor('appearance props flow from CommandInput to editor', (
          tester,
        ) async {
          final command = CommandController();
          await tester.pumpWidget(
            _app(
              editor,
              _menu(
                command,
                CommandInput(
                  editorBuilder: editor.builder,
                  cursorColor: const Color(0xFF123456),
                  cursorWidth: 5.0,
                  cursorHeight: 24.0,
                  cursorRadius: const Radius.circular(3.0),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final editable = _editable(tester);
          expect(editable.cursorColor, const Color(0xFF123456));
          expect(editable.cursorWidth, 5.0);
          expect(editable.cursorHeight, 24.0);
          expect(editable.cursorRadius, const Radius.circular(3.0));
        });
      }
    });
  }

  group('materialCommandInputBuilder appearance setup', () {
    testWidgets('allows configuring cursorColor and cursorWidth directly', (
      tester,
    ) async {
      final command = CommandController();
      await tester.pumpWidget(
        _app(
          _Editor.material,
          _menu(
            command,
            CommandInput(
              cursorColor: const Color(0xFF000000),
              cursorWidth: 2.0,
              editorBuilder: materialCommandInputBuilder(
                cursorColor: const Color(0xFFFF0000),
                cursorWidth: 6.0,
                cursorHeight: 28.0,
                cursorRadius: const Radius.circular(4.0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final textField = tester.widget<material.TextField>(
        find.byType(material.TextField),
      );
      expect(textField.cursorColor, const Color(0xFFFF0000));
      expect(textField.cursorWidth, 6.0);
      expect(textField.cursorHeight, 28.0);
      expect(textField.cursorRadius, const Radius.circular(4.0));

      final editable = _editable(tester);
      expect(editable.cursorColor, const Color(0xFFFF0000));
      expect(editable.cursorWidth, 6.0);
    });
  });

  group('cupertinoCommandInputBuilder appearance setup', () {
    testWidgets('allows configuring cursorColor and cursorWidth directly', (
      tester,
    ) async {
      final command = CommandController();
      await tester.pumpWidget(
        _app(
          _Editor.cupertino,
          _menu(
            command,
            CommandInput(
              cursorColor: const Color(0xFF000000),
              cursorWidth: 2.0,
              editorBuilder: cupertinoCommandInputBuilder(
                cursorColor: const Color(0xFF00FF00),
                cursorWidth: 4.5,
                cursorHeight: 22.0,
                cursorRadius: const Radius.circular(5.0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final cupertinoField = tester.widget<cupertino.CupertinoTextField>(
        find.byType(cupertino.CupertinoTextField),
      );
      expect(cupertinoField.cursorColor, const Color(0xFF00FF00));
      expect(cupertinoField.cursorWidth, 4.5);
      expect(cupertinoField.cursorHeight, 22.0);
      expect(cupertinoField.cursorRadius, const Radius.circular(5.0));

      final editable = _editable(tester);
      expect(editable.cursorColor, const Color(0xFF00FF00));
      expect(editable.cursorWidth, 4.5);
    });
  });

  group('defaultCommandInputEditorBuilder appearance setup', () {
    testWidgets('allows configuring cursorColor and cursorWidth directly', (
      tester,
    ) async {
      final command = CommandController();
      await tester.pumpWidget(
        _app(
          _Editor.headless,
          _menu(
            command,
            CommandInput(
              cursorColor: const Color(0xFF000000),
              cursorWidth: 2.0,
              editorBuilder: defaultCommandInputEditorBuilder(
                cursorColor: const Color(0xFF0000FF),
                cursorWidth: 7.0,
                cursorHeight: 25.0,
                cursorRadius: const Radius.circular(6.0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final editable = _editable(tester);
      expect(editable.cursorColor, const Color(0xFF0000FF));
      expect(editable.cursorWidth, 7.0);
      expect(editable.cursorHeight, 25.0);
      expect(editable.cursorRadius, const Radius.circular(6.0));
    });
  });
}
