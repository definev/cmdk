import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  group('Group behavior', () {
    testWidgets('groups are shown/hidden based on item matches',
        (tester) async {
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

    testWidgets('mounted group still rendered with filter using forceMount',
        (tester) async {
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
  });
}
