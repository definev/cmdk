import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  group('Group behavior', () {
    testWidgets('groups are shown/hidden based on item matches', (
      tester,
    ) async {
      final controller = CommandController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandGroup(
                  value: 'Animals',
                  heading: Text('Animals'),
                  children: [
                    CommandItem(value: 'Ant', child: Text('Ant')),
                    CommandItem(value: 'Bear', child: Text('Bear')),
                  ],
                ),
                CommandGroup(
                  value: 'Letters',
                  heading: Text('Letters'),
                  children: [
                    CommandItem(value: 'A', child: Text('A')),
                    CommandItem(value: 'B', child: Text('B')),
                    CommandItem(value: 'Z', child: Text('Z')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Animals'), findsOneWidget);
      expect(find.text('Letters'), findsOneWidget);

      // Search 'z' -> Animals group has no matching items, Letters has 'Z'
      controller.setSearch('z');
      await tester.pump();

      expect(find.text('Animals'), findsNothing);
      expect(find.text('Letters'), findsOneWidget);
      expect(find.text('Z'), findsOneWidget);
    });

    testWidgets('mounted group still rendered with filter using forceMount', (
      tester,
    ) async {
      final controller = CommandController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandGroup(
                  value: 'Letters',
                  heading: Text('Letters'),
                  forceMount: true,
                  children: [
                    CommandItem(value: 'A', child: Text('A')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      controller.setSearch('Giraffe');
      await tester.pump();

      expect(find.text('Letters'), findsOneWidget);
    });

    testWidgets('topSpacing applies only when preceded by another visible group', (
      tester,
    ) async {
      final controller = CommandController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandGroup(
                  value: 'Group1',
                  heading: SizedBox(height: 20.0, child: Text('Group 1')),
                  topSpacing: 12.0,
                  children: [
                    CommandItem(
                      value: 'Item 1',
                      child: SizedBox(height: 30.0, child: Text('Item 1')),
                    ),
                  ],
                ),
                CommandGroup(
                  value: 'Group2',
                  heading: SizedBox(height: 20.0, child: Text('Group 2')),
                  topSpacing: 12.0,
                  children: [
                    CommandItem(
                      value: 'Item 2',
                      child: SizedBox(height: 30.0, child: Text('Item 2')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final g1Finder = find.text('Group 1');
      final g2Finder = find.text('Group 2');

      final g1Top = tester.getTopLeft(g1Finder).dy;
      final g2Top = tester.getTopLeft(g2Finder).dy;

      // Group 1 starts at top (0.0). Group 2 has 20 (heading) + 30 (item) + 12 (topSpacing) = 62.0.
      expect(g1Top, equals(0.0));
      expect(g2Top, equals(62.0));

      // Now filter to only match Item 2 in Group 2 (hiding Group 1)
      controller.setSearch('Item 2');
      await tester.pump();

      expect(find.text('Group 1'), findsNothing);
      expect(find.text('Group 2'), findsOneWidget);

      // Group 2 is now the first visible group, so topSpacing collapses to 0.0!
      final g2TopFiltered = tester.getTopLeft(g2Finder).dy;
      expect(g2TopFiltered, equals(0.0));
    });
  });
}
