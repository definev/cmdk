import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:example/clones/liquid_glass.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Finder input(String name) => find.byWidgetPredicate(
  (widget) => widget is EditableText && widget.focusNode.debugLabel == name,
);

Future<void> mountPalette(
  WidgetTester tester, {
  bool highContrast = false,
  bool reduceMotion = false,
  double width = 640,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        highContrast: highContrast,
        disableAnimations: reduceMotion,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TapRegionSurface(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: width),
              child: LiquidGlassCMDK(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> toggleActions(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('uses Linear width and list limits, shrinking after search', (
    tester,
  ) async {
    await mountPalette(tester, width: 1000);
    final palette = find.byType(LiquidGlassCMDK);
    final list = find.byType(CommandList).first;
    expect(tester.getSize(list).width, lessThanOrEqualTo(640));
    // The viewport extends under the 62px header and 48px footer overlays.
    expect(tester.getSize(list).height - 62 - 48, lessThanOrEqualTo(300));
    final paletteRect = tester.getRect(palette);
    final listRect = tester.getRect(list);
    expect(listRect.left, closeTo(paletteRect.left, 1.0));
    expect(listRect.right, closeTo(paletteRect.right, 1.0));
    expect(listRect.top, closeTo(paletteRect.top, 1.0));
    expect(listRect.bottom, closeTo(paletteRect.bottom, 1.0));
    final fullHeight = tester.getSize(palette).height;
    await tester.enterText(input('LiquidGlassMainInput'), 'Ghostty');
    await tester.pumpAndSettle();
    expect(tester.getSize(palette).height, lessThan(fullHeight));
    await toggleActions(tester);
    expect(find.text('Copy Name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('results scroll behind the fixed input and footer overlays', (
    tester,
  ) async {
    await mountPalette(tester);
    final main = input('LiquidGlassMainInput');
    final footer = find.byKey(const ValueKey('liquid-glass-footer'));
    final list = find.byType(CommandList).first;
    final firstItem = find.byWidgetPredicate(
      (widget) => widget is CommandItem && widget.value == 'Disk Usage',
    );
    final inputRect = tester.getRect(main);
    final footerRect = tester.getRect(footer);
    expect(tester.getTopLeft(firstItem).dy, greaterThan(inputRect.bottom));

    await tester.drag(list, const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(tester.getRect(main), inputRect);
    expect(tester.getRect(footer), footerRect);
    expect(tester.getTopLeft(firstItem).dy, lessThan(inputRect.bottom));

    final controller = CommandScope.of(tester.element(firstItem));
    controller.selectValue('Ghostty');
    await tester.pumpAndSettle();
    controller.selectValue('Disk Usage');
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(firstItem).dy, greaterThan(inputRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorite shortcut adds selected item to Favorites group', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await mountPalette(tester);
    expect(find.text('Favorites'), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Disk Usage'), findsOneWidget);
    expect(find.text('Ghostty'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'pointer popover animates from its trigger and reverses on close',
    (tester) async {
      await mountPalette(tester);
      await tester.tap(find.text('Actions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final motion = find.byKey(const ValueKey('liquid-glass-actions-motion'));
      final transform = tester.widget<Transform>(motion);
      expect(transform.alignment, Alignment.bottomRight);
      expect(transform.transform.storage[0], lessThan(1));
      expect(transform.transform.storage[0], greaterThanOrEqualTo(0.97));

      await tester.pumpAndSettle();
      await tester.tap(input('LiquidGlassMainInput'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      expect(motion, findsOneWidget);
      await tester.pumpAndSettle();
      expect(motion, findsNothing);
      expect(
        tester
            .widget<EditableText>(input('LiquidGlassMainInput'))
            .focusNode
            .hasPrimaryFocus,
        isTrue,
      );
    },
  );

  testWidgets('reduced motion fades the popover without scaling', (
    tester,
  ) async {
    await mountPalette(tester, reduceMotion: true);
    await tester.tap(find.text('Actions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    final motion = find.byKey(const ValueKey('liquid-glass-actions-motion'));
    expect(tester.widget<Transform>(motion).transform.storage[0], 1);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(motion, findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('search, actions filtering, Escape, and focus restoration', (
    tester,
  ) async {
    await mountPalette(tester);
    final main = input('LiquidGlassMainInput');
    await tester.enterText(main, 'Ghostty');
    await tester.pumpAndSettle();
    expect(find.text('Disk Usage'), findsNothing);
    expect(find.text('Ghostty', skipOffstage: true), findsWidgets);

    await toggleActions(tester);
    final actions = input('LiquidGlassActionsInput');
    expect(
      tester.widget<EditableText>(actions).focusNode.hasPrimaryFocus,
      isTrue,
    );
    await tester.enterText(actions, 'Copy');
    await tester.pumpAndSettle();
    expect(find.text('Copy Name'), findsOneWidget);
    expect(find.text('Add to Favorites'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(actions, findsNothing);
    expect(tester.widget<EditableText>(main).focusNode.hasPrimaryFocus, isTrue);
    expect(tester.widget<EditableText>(main).controller.text, 'Ghostty');
  });

  testWidgets('copy uses the selected command and returns focus', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await mountPalette(tester);
    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy Name'));
    await tester.pumpAndSettle();
    expect(copied, 'Disk Usage');
    expect(input('LiquidGlassActionsInput'), findsNothing);
    expect(
      tester
          .widget<EditableText>(input('LiquidGlassMainInput'))
          .focusNode
          .hasPrimaryFocus,
      isTrue,
    );
  });

  testWidgets('last result scrolls completely above the footer', (
    tester,
  ) async {
    await mountPalette(tester);
    final item = find.byWidgetPredicate(
      (widget) =>
          widget is CommandItem && widget.value == 'Configure New Session',
    );
    final controller = CommandScope.of(tester.element(item));
    controller.selectValue('Configure New Session');
    await tester.pumpAndSettle();
    final footer = find.byKey(const ValueKey('liquid-glass-footer'));
    expect(
      tester.getBottomLeft(item).dy,
      lessThanOrEqualTo(tester.getTopLeft(footer).dy),
    );
  });

  testWidgets('narrow panel, high contrast, and reduced motion remain usable', (
    tester,
  ) async {
    await mountPalette(
      tester,
      width: 320,
      highContrast: true,
      reduceMotion: true,
    );
    await toggleActions(tester);
    expect(find.text('Copy Name'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await toggleActions(tester);
    expect(input('LiquidGlassActionsInput'), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
