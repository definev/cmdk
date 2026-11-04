import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  group('Item lifecycle and state', () {
    testWidgets('mounted item matches search and becomes visible', (
      tester,
    ) async {
      final controller = CommandController();
      var showItem = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Command(
                controller: controller,
                child: Column(
                  children: [
                    const CommandInput(),
                    CommandList(
                      children: [
                        if (showItem)
                          const CommandItem(value: 'b', child: Text('B')),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => setState(() => showItem = true),
                      child: const Text('Mount'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();

      controller.setSearch('b');
      await tester.pump();
      expect(find.text('B'), findsNothing);

      await tester.tap(find.text('Mount'));
      await tester.pump();
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('unmounting selected item moves selection to first available', (
      tester,
    ) async {
      final controller = CommandController();
      var showA = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Command(
                controller: controller,
                child: Column(
                  children: [
                    CommandList(
                      children: [
                        if (showA)
                          const CommandItem(
                            key: ValueKey('a'),
                            value: 'a',
                            child: Text('A'),
                          ),
                        const CommandItem(
                          key: ValueKey('b'),
                          value: 'b',
                          child: Text('B'),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => setState(() => showA = false),
                      child: const Text('UnmountA'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();
      expect(controller.selectedValue, 'a');

      await tester.tap(find.text('UnmountA'));
      await tester.pump();
      await tester.pump(); // wait for post-frame selection update

      expect(controller.selectedValue, 'b');
      expect(find.text('A'), findsNothing);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('selected value does not change when mounting new items', (
      tester,
    ) async {
      final controller = CommandController();
      var showMore = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Command(
                controller: controller,
                child: Column(
                  children: [
                    const CommandList(
                      children: [
                        CommandItem(value: 'first', child: Text('First')),
                        CommandItem(value: 'second', child: Text('Second')),
                      ],
                    ),
                    if (showMore)
                      const CommandItem(value: 'third', child: Text('Third')),
                    GestureDetector(
                      onTap: () => setState(() => showMore = true),
                      child: const Text('MountMore'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();

      controller.selectValue('second');
      expect(controller.selectedValue, 'second');

      await tester.tap(find.text('MountMore'));
      await tester.pump();
      await tester.pump();

      expect(controller.selectedValue, 'second');
    });

    testWidgets('forceMount keeps item rendered even with no match', (
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
                CommandItem(
                  value: 'item1',
                  forceMount: true,
                  child: Text('Always Visible'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      controller.setSearch('completely_unmatched_query');
      await tester.pump();

      expect(find.text('Always Visible'), findsOneWidget);
    });
  });
}
