import 'package:example/command_dialog_examples.dart';
import 'package:example/command_menu.dart';
import 'package:example/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final presentation in [
    'Material dialog',
    'Cupertino dialog',
    'Bottom sheet',
  ]) {
    testWidgets('$presentation searches, returns a value, and cancels', (
      tester,
    ) async {
      await tester.pumpWidget(const CmdkExampleApp());
      await tester.pumpAndSettle();
      final button = find.byKey(ValueKey(presentation));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      final menu = find.byType(CommandMenu);
      final input = find.descendant(
        of: menu,
        matching: find.byType(EditableText),
      );
      expect(menu, findsOneWidget);
      expect(tester.widget<EditableText>(input).focusNode.hasFocus, isTrue);
      await tester.enterText(input, 'preferences');
      await tester.pumpAndSettle();
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Create Project'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(menu, findsNothing);
      expect(find.text('Open Settings'), findsOneWidget);

      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(input).controller.text, isEmpty);
      await tester.enterText(input, 'no-match');
      await tester.pumpAndSettle();
      expect(find.text('No commands found.'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(menu, findsNothing);
      expect(find.text('Open Settings'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$presentation fits a narrow screen with the keyboard open', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: const Scaffold(body: Center(child: CommandDialogExamples())),
        ),
      );
      await tester.tap(find.byKey(ValueKey(presentation)));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      final menu = find.byType(CommandMenu);
      expect(tester.getBottomRight(menu).dy, lessThanOrEqualTo(360));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Close command menu'));
      await tester.pumpAndSettle();
      expect(menu, findsNothing);
    });
  }
}
