import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

      // Initially actions submenu is closed
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

      // Press Escape to close actions submenu
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Show in Finder'), findsNothing);
      expect(find.text('Add to Favorites'), findsNothing);
    });

    testWidgets('RaycastCMDK actions submenu filters action items dynamically',
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
    });

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
      expect(find.text('vercel/website'), findsNothing);

      // Press Enter to activate 'Search Projects...'
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 50));

      // Now on Projects page
      expect(find.text('vercel/website'), findsOneWidget);

      // Press Backspace with empty search to pop page
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump(const Duration(milliseconds: 50));

      // Returned to Home page
      expect(find.text('Search Projects...'), findsWidgets);
      expect(find.text('vercel/website'), findsNothing);
    });

    testWidgets('CmdkExampleApp navigates themes using Meta + Arrow shortcuts',
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
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(LinearCMDK), findsOneWidget);
      expect(find.byType(RaycastCMDK), findsNothing);

      // Prev theme: Meta + ArrowLeft -> Back to Raycast
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RaycastCMDK), findsOneWidget);
      expect(find.byType(LinearCMDK), findsNothing);
    });
  });
}
