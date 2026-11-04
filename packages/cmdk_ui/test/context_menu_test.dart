import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;

void main() {
  final inputs = <String, Widget Function(EditableTextContextMenuBuilder)>{
    'headless input': (builder) => CommandInput(contextMenuBuilder: builder),
    'headless builder': (builder) => CommandInput(
      editorBuilder: defaultCommandInputEditorBuilder(
        contextMenuBuilder: builder,
      ),
    ),
    'Material input': (builder) => CommandInput(
      contextMenuBuilder: builder,
      editorBuilder: materialCommandInputBuilder(),
    ),
    'Material builder': (builder) => CommandInput(
      editorBuilder: materialCommandInputBuilder(contextMenuBuilder: builder),
    ),
    'Cupertino input': (builder) => CommandInput(
      contextMenuBuilder: builder,
      editorBuilder: cupertinoCommandInputBuilder(),
    ),
    'Cupertino builder': (builder) => CommandInput(
      editorBuilder: cupertinoCommandInputBuilder(contextMenuBuilder: builder),
    ),
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android])
      'adaptive input $platform': (builder) => AdaptiveCommandInput(
        platform: platform,
        contextMenuBuilder: builder,
      ),
    'adaptive builder': (builder) => CommandInput(
      editorBuilder: adaptiveCommandInputBuilder(contextMenuBuilder: builder),
    ),
  };

  for (final entry in inputs.entries) {
    testWidgets('${entry.key} opens a custom menu and edits the selection', (
      tester,
    ) async {
      final command = CommandController();
      await tester.pumpWidget(
        material.MaterialApp(
          theme: material.ThemeData(
            splashFactory: material.NoSplash.splashFactory,
          ),
          home: material.Scaffold(
            body: Command(
              controller: command,
              child: entry.value(
                (context, state) => Align(
                  alignment: Alignment.topRight,
                  child: material.TextButton(
                    onPressed: () {
                      final value = state.textEditingValue;
                      state.userUpdateTextEditingValue(
                        TextEditingValue(
                          text: value.text.replaceRange(
                            value.selection.start,
                            value.selection.end,
                            'custom',
                          ),
                          selection: TextSelection.collapsed(
                            offset: value.selection.start + 6,
                          ),
                        ),
                        SelectionChangedCause.toolbar,
                      );
                      state.hideToolbar();
                    },
                    child: const Text('Replace selection'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'search query');
      final state = tester.state<EditableTextState>(find.byType(EditableText));
      state.widget.controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 6,
      );
      await tester.pump();
      expect(state.showToolbar(), isTrue);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Replace selection'));
      await tester.pumpAndSettle();

      expect(state.widget.controller.text, 'custom query');
      expect(command.search, 'custom query');
      expect(find.text('Replace selection'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
