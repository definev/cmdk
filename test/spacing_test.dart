import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  group('Spacing in CommandList and CommandGroup', () {
    testWidgets(
      'CommandList spacing applies only between adjacent visible items',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: Command(
              child: CommandList(
                spacing: 8.0,
                children: [
                  CommandItem(
                    value: 'first',
                    child: SizedBox(height: 40.0, child: Text('first')),
                  ),
                  CommandItem(
                    value: 'second',
                    child: SizedBox(height: 40.0, child: Text('second')),
                  ),
                  CommandItem(
                    value: 'third',
                    child: SizedBox(height: 40.0, child: Text('third')),
                  ),
                ],
              ),
            ),
          ),
        );

        final firstFinder = find.text('first');
        final secondFinder = find.text('second');
        final thirdFinder = find.text('third');

        expect(firstFinder, findsOneWidget);
        expect(secondFinder, findsOneWidget);
        expect(thirdFinder, findsOneWidget);

        final firstTop = tester.getTopLeft(firstFinder).dy;
        final secondTop = tester.getTopLeft(secondFinder).dy;
        final thirdTop = tester.getTopLeft(thirdFinder).dy;

        // First item starts at 0, height 40.
        // Second item starts at 40 + 8.0 = 48.0
        // Third item starts at 48 + 40 + 8.0 = 96.0
        expect(secondTop - firstTop, equals(48.0));
        expect(thirdTop - secondTop, equals(48.0));
      },
    );

    testWidgets('Filtering maintains single spacing between remaining items', (
      tester,
    ) async {
      final controller = CommandController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              spacing: 10.0,
              children: [
                CommandItem(
                  value: 'apple',
                  child: SizedBox(height: 50.0, child: Text('apple')),
                ),
                CommandItem(
                  value: 'banana',
                  child: SizedBox(height: 50.0, child: Text('banana')),
                ),
                CommandItem(
                  value: 'apricot',
                  child: SizedBox(height: 50.0, child: Text('apricot')),
                ),
              ],
            ),
          ),
        ),
      );

      // Search for "ap" which matches apple and apricot, hiding banana
      controller.setSearch('ap');
      await tester.pump();

      final appleFinder = find.text('apple');
      final apricotFinder = find.text('apricot');
      final bananaFinder = find.text('banana');

      expect(appleFinder, findsOneWidget);
      expect(apricotFinder, findsOneWidget);
      expect(bananaFinder, findsNothing);

      final appleTop = tester.getTopLeft(appleFinder).dy;
      final apricotTop = tester.getTopLeft(apricotFinder).dy;

      // Distance between apple and apricot is exactly 50.0 + 10.0 = 60.0 (one spacing)
      expect(apricotTop - appleTop, equals(60.0));
    });

    testWidgets('CommandGroup spacing applies within the group', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            child: CommandList(
              children: [
                CommandGroup(
                  heading: Text('Group A'),
                  spacing: 6.0,
                  children: [
                    CommandItem(
                      value: 'item A1',
                      child: SizedBox(height: 30.0, child: Text('item A1')),
                    ),
                    CommandItem(
                      value: 'item A2',
                      child: SizedBox(height: 30.0, child: Text('item A2')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      final a1Finder = find.text('item A1');
      final a2Finder = find.text('item A2');

      final a1Top = tester.getTopLeft(a1Finder).dy;
      final a2Top = tester.getTopLeft(a2Finder).dy;

      expect(a2Top - a1Top, equals(36.0)); // 30 height + 6.0 spacing
    });
  });
}
