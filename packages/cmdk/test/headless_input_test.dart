import 'package:cmdk/cmdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  final content = Align(
    alignment: Alignment.topCenter,
    child: SizedBox(width: 360, height: 600, child: child),
  );
  return WidgetsApp(
    color: const Color(0xFF000000),
    pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
      pageBuilder: (context, _, __) => builder(context),
    ),
    home: content,
  );
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

  void testHeadless(String description, WidgetTesterCallback callback) =>
      testWidgets(
        description,
        callback,
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );

  group('headless editor', () {
    for (final customPlaceholder in [false, true]) {
      testHeadless(
        'placeholder does not resize the editor (custom: $customPlaceholder)',
        (tester) async {
          final command = CommandController();
          addTearDown(command.dispose);
          await tester.pumpWidget(
            _app(
              DefaultTextStyle(
                style: const TextStyle(fontSize: 20, height: 1.5),
                child: _menu(
                  command,
                  CommandInput(
                    placeholder: 'A long search placeholder ' * 10,
                    placeholderWidget: customPlaceholder
                        ? const SizedBox(height: 80, child: Text('Search'))
                        : null,
                    style: const TextStyle(fontSize: 15),
                    placeholderStyle: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final field = find.byType(CommandInput);
          final editor = find.byType(EditableText);
          final fieldRect = tester.getRect(field);
          final editorRect = tester.getRect(editor);
          expect(fieldRect.height, editorRect.height);

          await tester.enterText(editor, 'Search');
          await tester.pump();
          expect(tester.getRect(field), fieldRect);
          expect(tester.getRect(editor), editorRect);
          await tester.enterText(editor, '');
          await tester.pump();
          expect(tester.getRect(field), fieldRect);
          expect(tester.getRect(editor), editorRect);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testHeadless('command keyboard defaults and overrides reach the IME', (
      tester,
    ) async {
      final command = CommandController();
      await tester.pumpWidget(
        _app(_menu(command, const CommandInput())),
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

      await tester.pumpWidget(
        _app(
          _menu(
            command,
            const CommandInput(
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
      expect(_editable(tester).smartDashesType, SmartDashesType.enabled);
      expect(_editable(tester).smartQuotesType, SmartQuotesType.enabled);
      expect(_editable(tester).textCapitalization, TextCapitalization.words);
    });

    testHeadless('Search keeps focus; composing Search never activates', (
      tester,
    ) async {
      final command = CommandController();
      var selected = 0;
      await tester.pumpWidget(
        _app(
          _menu(
            command,
            const CommandInput(),
            onSelect: () => selected++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CommandInput));
      await tester.pumpAndSettle();
      expect(_editable(tester).focusNode.hasFocus, isTrue);

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'a',
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange(start: 0, end: 1),
        ),
      );
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(selected, 0);
      expect(_editable(tester).focusNode.hasFocus, isTrue);

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'a',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(_editable(tester).focusNode.hasFocus, isTrue);
    });

    testHeadless('optional unfocus applies only to enabled soft submission', (
      tester,
    ) async {
      final command = CommandController();
      var selected = 0;
      await tester.pumpWidget(
        _app(
          _menu(
            command,
            const CommandInput(unfocusOnSubmit: true),
            onSelect: () => selected++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CommandInput));
      await tester.pumpAndSettle();

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'z',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(selected, 0);
      expect(_editable(tester).focusNode.hasFocus, isTrue);

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'a',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(selected, 1);
      expect(_editable(tester).focusNode.hasFocus, isFalse);
    });

    testHeadless(
      'controlled rejection waits for IME commit without feedback',
      (tester) async {
        final requests = <String>[];
        await tester.pumpWidget(
          _app(
            Command(
              search: '',
              onSearchChange: requests.add,
              child: const CommandInput(),
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
      },
    );

    testHeadless(
      'accepted Vietnamese composing edits preserve editing value',
      (tester) async {
        var query = '';
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) => _app(
              Command(
                search: query,
                onSearchChange: (value) => setState(() => query = value),
                child: const Column(
                  children: [
                    CommandInput(),
                    CommandList(
                      children: [
                        CommandItem(value: 'tiếng', child: Text('Tiếng')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CommandInput));
        await tester.pumpAndSettle();

        tester.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: 'tie',
            selection: TextSelection.collapsed(offset: 3),
            composing: TextRange(start: 0, end: 3),
          ),
        );
        await tester.pump();
        expect(_editable(tester).controller.text, 'tie');

        tester.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: 'tiê',
            selection: TextSelection.collapsed(offset: 3),
            composing: TextRange(start: 0, end: 3),
          ),
        );
        await tester.pump();
        expect(_editable(tester).controller.text, 'tiê');

        tester.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: 'tiến',
            selection: TextSelection.collapsed(offset: 4),
            composing: TextRange(start: 0, end: 4),
          ),
        );
        await tester.pump();
        expect(_editable(tester).controller.text, 'tiến');

        tester.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: 'tiếng',
            selection: TextSelection.collapsed(offset: 5),
          ),
        );
        await tester.pump();
        expect(query, 'tiếng');
        expect(_editable(tester).controller.text, 'tiếng');
      },
    );

    testHeadless('focus loss reconciles a deferred authoritative query', (
      tester,
    ) async {
      var query = 'alpha';
      final focusNode = FocusNode();
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => _app(
            Column(
              children: [
                Command(
                  search: query,
                  child: const Column(
                    children: [
                      CommandInput(),
                      CommandList(
                        children: [
                          CommandItem(value: 'alpha', child: Text('Alpha')),
                        ],
                      ),
                    ],
                  ),
                ),
                Focus(
                  focusNode: focusNode,
                  child: const SizedBox(width: 10, height: 10),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CommandInput));
      await tester.pumpAndSettle();

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'alphav',
          selection: TextSelection.collapsed(offset: 6),
          composing: TextRange(start: 5, end: 6),
        ),
      );
      await tester.pump();
      expect(_editable(tester).controller.text, 'alphav');

      focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(_editable(tester).controller.text, 'alpha');
    });

    testHeadless('submission lets an action transfer focus', (tester) async {
      final command = CommandController();
      final outsideNode = FocusNode();
      await tester.pumpWidget(
        _app(
          Column(
            children: [
              _menu(
                command,
                const CommandInput(),
                onSelect: () => outsideNode.requestFocus(),
              ),
              Focus(
                focusNode: outsideNode,
                child: const SizedBox(width: 10, height: 10),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CommandInput));
      await tester.pumpAndSettle();
      expect(_editable(tester).focusNode.hasFocus, isTrue);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(outsideNode.hasFocus, isTrue);
      expect(_editable(tester).focusNode.hasFocus, isFalse);
    });
  });

  group('defaultCommandInputEditorBuilder appearance setup', () {
    testWidgets('allows configuring cursorColor and cursorWidth directly', (
      tester,
    ) async {
      final command = CommandController();
      await tester.pumpWidget(
        _app(
          _menu(
            command,
            CommandInput(
              cursorColor: const Color(0xFF000000),
              cursorWidth: 1.5,
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

  group('CommandList scrollbarBuilder', () {
    testWidgets('invokes scrollbarBuilder with controller and child', (
      tester,
    ) async {
      ScrollController? capturedController;
      await tester.pumpWidget(
        _app(
          Command(
            child: CommandList(
              scrollbarBuilder: (context, child, controller) {
                capturedController = controller;
                return RawScrollbar(
                  controller: controller,
                  thumbVisibility: true,
                  child: child,
                );
              },
              children: [
                for (var i = 0; i < 20; i++)
                  CommandItem(
                    value: 'item_$i',
                    child: Text('Item $i'),
                  ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RawScrollbar), findsOneWidget);
      expect(capturedController, isNotNull);
    });
  });
}
