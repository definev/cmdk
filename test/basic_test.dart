import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  group('Basic behavior', () {
    testWidgets('item value is derived from Text child', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            child: CommandList(
              children: [
                CommandItem(child: Text('Apple')),
                CommandItem(child: Text('Banana')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('explicit item value is preferred over child text',
        (tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            onValueChange: (v) => selectedValue = v,
            child: const CommandList(
              children: [
                CommandItem(
                    value: 'custom_apple', child: Text('Display Apple')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(selectedValue, 'custom_apple');
    });

    testWidgets('first item is selected by default', (tester) async {
      String? selected;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            onValueChange: (v) => selected = v,
            child: const CommandList(
              children: [
                CommandItem(value: 'first', child: Text('First')),
                CommandItem(value: 'second', child: Text('Second')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(selected, 'first');
    });

    testWidgets('items filter when typing into CommandInput', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            child: Column(
              children: [
                CommandInput(),
                CommandList(
                  children: [
                    CommandItem(value: 'apple', child: Text('Apple')),
                    CommandItem(value: 'banana', child: Text('Banana')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);

      await tester.enterText(find.byType(CommandInput), 'b');
      await tester.pump();

      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('items filter when searching by keywords', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            child: Column(
              children: [
                CommandInput(),
                CommandList(
                  children: [
                    CommandItem(
                      value: 'item1',
                      keywords: ['fruit', 'citrus'],
                      child: Text('Orange'),
                    ),
                    CommandItem(
                      value: 'item2',
                      keywords: ['vehicle'],
                      child: Text('Car'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(CommandInput), 'citrus');
      await tester.pump();

      expect(find.text('Orange'), findsOneWidget);
      expect(find.text('Car'), findsNothing);
    });

    testWidgets('empty component renders when there are no results',
        (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            child: Column(
              children: [
                CommandInput(),
                CommandList(
                  children: [
                    CommandEmpty(child: Text('No results.')),
                    CommandItem(value: 'apple', child: Text('Apple')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No results.'), findsNothing);
      expect(find.text('Apple'), findsOneWidget);

      await tester.enterText(find.byType(CommandInput), 'xyz');
      await tester.pump();

      expect(find.text('No results.'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('item onSelect is called on tap', (tester) async {
      var selected = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            child: CommandList(
              children: [
                CommandItem(
                  value: 'item',
                  onSelect: () => selected = true,
                  child: const Text('Item'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Item'));
      await tester.pump();

      expect(selected, isTrue);
    });
  });
}
