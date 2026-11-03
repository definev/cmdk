import 'package:cmdk/cmdk.dart';
import 'package:example/clones/framer.dart';
import 'package:example/clones/raycast.dart';
import 'package:example/clones/styler_variants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mix/mix.dart';

void main() {
  group('Styler Variant Extension & Mix Variant API', () {
    testWidgets(
        'onSelected on BoxStyler activates when WidgetState.selected is present',
        (tester) async {
      final boxStyle = BoxStyler()
          .color(const Color(0xFF000000))
          .onSelected(BoxStyler().color(const Color(0xFF0091FF)));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WidgetStateProvider(
            states: const {WidgetState.selected},
            child: Box(
              style: boxStyle,
              child: const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
                of: find.byType(Box), matching: find.byType(Container))
            .first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, const Color(0xFF0091FF));
    });

    testWidgets(
        'onSelected on BoxStyler remains base color when not selected',
        (tester) async {
      final boxStyle = BoxStyler()
          .color(const Color(0xFF161618))
          .onSelected(BoxStyler().color(const Color(0xFF0091FF)));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WidgetStateProvider(
            states: const {},
            child: Box(
              style: boxStyle,
              child: const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find
            .descendant(
                of: find.byType(Box), matching: find.byType(Container))
            .first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, const Color(0xFF161618));
    });

    testWidgets(
        'Nested StyledText inherits selected state from WidgetStateProvider automatically',
        (tester) async {
      final titleStyle = TextStyler()
          .color(const Color(0xFFEDEDED))
          .onSelected(TextStyler().color(const Color(0xFFFFFFFF)));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: WidgetStateProvider(
            states: const {WidgetState.selected},
            child: StyledText('Item Title', style: titleStyle),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, const Color(0xFFFFFFFF));
    });

    testWidgets(
        'NamedVariant with applyVariants applies variant style correctly',
        (tester) async {
      final badgeStyle = BoxStyler()
          .color(const Color(0xFF2B2C33))
          .variant(copiedVariant, BoxStyler().color(const Color(0x3310B981)));

      // When copied is false
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Box(
            style: badgeStyle.applyVariants([]),
            child: const SizedBox(width: 28, height: 28),
          ),
        ),
      );

      var container = tester.widget<Container>(
        find
            .descendant(
                of: find.byType(Box), matching: find.byType(Container))
            .first,
      );
      var decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, const Color(0xFF2B2C33));

      // When copied is true
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Box(
            style: badgeStyle.applyVariants([copiedVariant]),
            child: const SizedBox(width: 28, height: 28),
          ),
        ),
      );

      container = tester.widget<Container>(
        find
            .descendant(
                of: find.byType(Box), matching: find.byType(Container))
            .first,
      );
      decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, const Color(0x3310B981));
    });

    testWidgets(
        'CommandItemStateProvider separates hovered and selected states',
        (tester) async {
      final itemStyle = BoxStyler()
          .color(const Color(0x00000000))
          .onHovered(BoxStyler().color(const Color(0xFF242427)))
          .onSelected(BoxStyler().color(const Color(0xFF28282C)));

      // 1. Hovered only: should have hovered color 0xFF242427
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CommandItemStateProvider(
            state: const CommandItemState(
              isSelected: false,
              isHovered: true,
              isDisabled: false,
              score: 1.0,
            ),
            child: Box(style: itemStyle, child: const SizedBox(width: 40, height: 40)),
          ),
        ),
      );

      var container = tester.widget<Container>(
        find.descendant(of: find.byType(Box), matching: find.byType(Container)).first,
      );
      expect((container.decoration as BoxDecoration?)?.color, const Color(0xFF242427));

      // 2. Selected only: should have selected color 0xFF28282C
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CommandItemStateProvider(
            state: const CommandItemState(
              isSelected: true,
              isHovered: false,
              isDisabled: false,
              score: 1.0,
            ),
            child: Box(style: itemStyle, child: const SizedBox(width: 40, height: 40)),
          ),
        ),
      );

      container = tester.widget<Container>(
        find.descendant(of: find.byType(Box), matching: find.byType(Container)).first,
      );
      expect((container.decoration as BoxDecoration?)?.color, const Color(0xFF28282C));

      // 3. Both hovered and selected: selected wins
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CommandItemStateProvider(
            state: const CommandItemState(
              isSelected: true,
              isHovered: true,
              isDisabled: false,
              score: 1.0,
            ),
            child: Box(style: itemStyle, child: const SizedBox(width: 40, height: 40)),
          ),
        ),
      );

      container = tester.widget<Container>(
        find.descendant(of: find.byType(Box), matching: find.byType(Container)).first,
      );
      expect((container.decoration as BoxDecoration?)?.color, const Color(0xFF28282C));
    });

    testWidgets(
        'RaycastCMDK: hover does not change selected item; FramerCMDK: hover changes selected item',
        (tester) async {
      // Test Raycast hover behavior
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: RaycastCMDK(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);

      // Move mouse over "Figma" item
      final figmaFinder = find.text('Figma');
      expect(figmaFinder, findsOneWidget);
      await pointer.moveTo(tester.getCenter(figmaFinder));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // In Raycast, with disablePointerSelection: true, opening actions menu still shows "Linear"
      // Press Meta + K to open actions submenu
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // The actions submenu header displays selected item title: "Linear", NOT "Figma"
      expect(find.text('Linear'), findsWidgets);

      // Close actions menu
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Test Framer: hover DOES change selection and live preview
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: FramerCMDK(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Initially 'Button' preview is visible ('Primary')
      expect(find.text('Primary'), findsOneWidget);

      // In Framer, hover over "Input" item
      final inputFinder = find.text('Input');
      expect(inputFinder, findsOneWidget);
      await pointer.moveTo(tester.getCenter(inputFinder));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // In Framer, live preview for Input is now rendered ('Placeholder')!
      expect(find.text('Placeholder'), findsOneWidget);
    });
  });
}
