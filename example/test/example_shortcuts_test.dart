import 'package:cmdk/cmdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/clones/framer.dart';
import '../lib/clones/linear.dart';
import '../lib/clones/raycast.dart';
import '../lib/clones/vercel.dart';
import '../lib/main.dart';

void main() {
  group('Example Shortcut-Action-Command migration', () {
    testWidgets(
      'RaycastCMDK toggles actions submenu via shortcut and closes with Escape',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: RaycastCMDK(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // Initially actions submenu is closed and main input has focus
        final mainInputFinder = find.byWidgetPredicate(
          (w) =>
              w is EditableText && w.focusNode.debugLabel == 'RaycastMainInput',
        );
        expect(mainInputFinder, findsOneWidget);
        expect(
          tester.widget<EditableText>(mainInputFinder).focusNode.hasFocus,
          isTrue,
        );

        expect(find.text('Show in Finder'), findsNothing);
        expect(find.text('Add to Favorites'), findsNothing);

        // Press Meta + K to open actions submenu
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // All 4 reference action items are present
        expect(find.text('Show in Finder'), findsOneWidget);
        expect(find.text('Show Info in Finder'), findsOneWidget);
        expect(find.text('Add to Favorites'), findsOneWidget);
        expect(find.text('Search for actions...'), findsOneWidget);

        // Actions submenu input is automatically focused!
        final actionsInputFinder = find.byWidgetPredicate(
          (w) =>
              w is EditableText &&
              w.focusNode.debugLabel == 'RaycastActionsInput',
        );
        expect(actionsInputFinder, findsOneWidget);
        expect(
          tester.widget<EditableText>(actionsInputFinder).focusNode.hasFocus,
          isTrue,
        );

        // Press Escape to close actions submenu
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.text('Show in Finder'), findsNothing);
        expect(find.text('Add to Favorites'), findsNothing);

        // Focus is automatically restored to main input
        expect(
          tester.widget<EditableText>(mainInputFinder).focusNode.hasFocus,
          isTrue,
        );
        expect(
          tester
              .widget<EditableText>(mainInputFinder)
              .focusNode
              .hasPrimaryFocus,
          isTrue,
        );
      },
    );

    testWidgets(
      'RaycastCMDK closing actions via Meta+K restores primary focus to main CommandInput',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: RaycastCMDK(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        final mainInputFinder = find.byWidgetPredicate(
          (w) =>
              w is EditableText && w.focusNode.debugLabel == 'RaycastMainInput',
        );
        expect(
          tester
              .widget<EditableText>(mainInputFinder)
              .focusNode
              .hasPrimaryFocus,
          isTrue,
        );

        // Open actions menu via Meta + K
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final actionsInputFinder = find.byWidgetPredicate(
          (w) =>
              w is EditableText &&
              w.focusNode.debugLabel == 'RaycastActionsInput',
        );
        expect(actionsInputFinder, findsOneWidget);
        expect(
          tester
              .widget<EditableText>(actionsInputFinder)
              .focusNode
              .hasPrimaryFocus,
          isTrue,
        );

        // Press Meta + K again to toggle close actions menu
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // At 100ms, exit animation is still smoothly running (not abruptly disappeared)
        expect(actionsInputFinder, findsOneWidget);

        // Finish the 200ms exit animation
        await tester.pump(const Duration(milliseconds: 150));

        expect(actionsInputFinder, findsNothing);
        expect(
          tester
              .widget<EditableText>(mainInputFinder)
              .focusNode
              .hasPrimaryFocus,
          isTrue,
        );
      },
    );

    testWidgets(
      'RaycastCMDK actions submenu filters action items dynamically',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: RaycastCMDK(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // Open actions menu
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.text('Show in Finder'), findsOneWidget);
        expect(find.text('Add to Favorites'), findsOneWidget);

        // Type "Finder" into the submenu search input
        await tester.enterText(find.byType(EditableText).last, 'Finder');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // "Show in Finder" and "Show Info in Finder" remain, "Add to Favorites" filtered out
        expect(find.text('Show in Finder'), findsOneWidget);
        expect(find.text('Show Info in Finder'), findsOneWidget);
        expect(find.text('Add to Favorites'), findsNothing);
      },
    );

    testWidgets(
      'RaycastCMDK tapping Actions trigger focuses actions input and selecting item restores focus',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: RaycastCMDK(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        final mainInputFinder = find.byWidgetPredicate(
          (w) =>
              w is EditableText && w.focusNode.debugLabel == 'RaycastMainInput',
        );
        expect(
          tester.widget<EditableText>(mainInputFinder).focusNode.hasFocus,
          isTrue,
        );

        // Tap on the Actions trigger button
        await tester.tap(find.text('Actions'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // Actions submenu input is automatically focused
        final actionsInputFinder = find.byWidgetPredicate(
          (w) =>
              w is EditableText &&
              w.focusNode.debugLabel == 'RaycastActionsInput',
        );
        expect(actionsInputFinder, findsOneWidget);
        expect(
          tester.widget<EditableText>(actionsInputFinder).focusNode.hasFocus,
          isTrue,
        );

        // Tap on an action item
        await tester.tap(find.text('Add to Favorites'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // Actions submenu is closed
        expect(actionsInputFinder, findsNothing);

        // Focus returned to main input
        expect(
          tester.widget<EditableText>(mainInputFinder).focusNode.hasFocus,
          isTrue,
        );
      },
    );

    testWidgets(
      'VercelCMDK navigates to Projects page on Enter and pops on Backspace',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: VercelCMDK(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // Initially on Home page showing Search Projects...
        expect(find.text('Search Projects...'), findsWidgets);
        expect(find.text('flutter/website'), findsNothing);

        // Press Enter to activate 'Search Projects...'
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump(const Duration(milliseconds: 50));

        // Now on Projects page
        expect(find.text('flutter/website'), findsOneWidget);

        // Press Backspace with empty search to pop page
        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.pump(const Duration(milliseconds: 50));

        // Returned to Home page
        expect(find.text('Search Projects...'), findsWidgets);
        expect(find.text('flutter/website'), findsNothing);
      },
    );

    testWidgets('VercelCMDK Backspace deletes text when query is not empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          pageRouteBuilder: <T>(settings, builder) =>
              PageRouteBuilder<T>(pageBuilder: (ctx, _, __) => builder(ctx)),
          home: const VercelCMDK(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Navigate to Projects page
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('flutter/website'), findsOneWidget);

      final editableFinder = find.byType(EditableText);
      await tester.enterText(editableFinder, 'v');
      await tester.pump();
      expect(tester.widget<EditableText>(editableFinder).controller.text, 'v');

      // Send Backspace key event -> should delete 'v' to ''
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(tester.widget<EditableText>(editableFinder).controller.text, '');
      expect(find.text('flutter/website'), findsOneWidget);

      // Send Backspace again with empty input -> should pop to Home page
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();

      expect(find.text('Search Projects...'), findsWidgets);
      expect(find.text('flutter/website'), findsNothing);
    });

    testWidgets(
      'CmdkExampleApp navigates themes using Meta + Arrow shortcuts',
      (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const CmdkExampleApp());
        await tester.pump(const Duration(milliseconds: 50));

        // Starts at Raycast
        expect(find.byType(RaycastCMDK), findsOneWidget);

        // Next theme: Meta + ArrowRight -> Linear
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(LinearCMDK), findsOneWidget);
        expect(find.byType(RaycastCMDK), findsNothing);

        // Next theme: Meta + ArrowRight -> Vercel
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(VercelCMDK), findsOneWidget);

        // Next theme: Meta + ArrowRight -> Framer
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(FramerCMDK), findsOneWidget);

        // Tap background canvas to ensure shortcuts work even when unfocused
        await tester.tapAt(const Offset(20, 20));
        await tester.pump(const Duration(milliseconds: 50));

        // Prev theme: Meta + ArrowLeft -> Back to Vercel
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(VercelCMDK), findsOneWidget);

        // Prev theme: Meta + ArrowLeft -> Back to Linear
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(LinearCMDK), findsOneWidget);

        // Prev theme: Meta + ArrowLeft -> Back to Raycast
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(RaycastCMDK), findsOneWidget);
        expect(find.byType(LinearCMDK), findsNothing);
      },
    );

    testWidgets(
      'RaycastCMDK all items remain completely visible above the pinned Actions footer',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: RaycastCMDK()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final positionedFinder = find.byWidgetPredicate(
          (w) =>
              w is Positioned &&
              w.bottom == 0.0 &&
              w.left == 0.0 &&
              w.right == 0.0,
        );
        final footerBox = tester.renderObject(positionedFinder) as RenderBox;
        final footerTopY = footerBox.localToGlobal(Offset.zero).dy;

        final items = [
          'Linear',
          'Figma',
          'Slack',
          'YouTube',
          'Raycast',
          'Clipboard History',
          'Import Extension',
          'Manage Extensions',
        ];

        for (final item in items) {
          final itemFinder = find.byWidgetPredicate(
            (w) => w is CommandItem && w.value == item,
          );
          final itemContext = tester.element(itemFinder);
          final controller = CommandScope.of(itemContext);
          controller.selectValue(item);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));

          final itemBox = tester.renderObject(itemFinder) as RenderBox;
          final itemBottom =
              itemBox.localToGlobal(Offset.zero).dy + itemBox.size.height;
          final clearance = footerTopY - itemBottom;
          expect(
            clearance,
            greaterThanOrEqualTo(0.0),
            reason: '$item must not be covered by Actions bar',
          );
        }
      },
    );
  });
}
