import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  group('Props and configuration', () {
    testWidgets('results do not filter when shouldFilter is false',
        (tester) async {
      final controller = CommandController(shouldFilter: false);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandItem(value: 'a', child: Text('A')),
                CommandItem(value: 'b', child: Text('B')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      controller.setSearch('z');
      await tester.pump();

      // Because shouldFilter is false, both items remain visible
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('results match against custom filter function', (tester) async {
      // Custom filter only matches if query is exact prefix
      double prefixFilter(String value, String search,
          [List<String>? keywords]) {
        return value.toLowerCase().startsWith(search.toLowerCase()) ? 1.0 : 0.0;
      }

      final controller = CommandController(filter: prefixFilter);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandItem(value: 'ant', child: Text('Ant')),
                CommandItem(value: 'anteater', child: Text('Anteater')),
                CommandItem(value: 'elephant', child: Text('Elephant')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      controller.setSearch('ant');
      await tester.pump();

      expect(find.text('Ant'), findsOneWidget);
      expect(find.text('Anteater'), findsOneWidget);
      expect(find.text('Elephant'), findsNothing);
    });

    testWidgets('controlled value sets selected item', (tester) async {
      String? selectedInScope;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            value: 'anteater',
            child: Column(
              children: [
                CommandStateSelector<String?>(
                  selector: (state) => state.selectedValue,
                  builder: (context, val) {
                    selectedInScope = val;
                    return Text('Selected: $val');
                  },
                ),
                const CommandList(
                  children: [
                    CommandItem(value: 'ant', child: Text('Ant')),
                    CommandItem(value: 'anteater', child: Text('Anteater')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(selectedInScope, 'anteater');
    });

    testWidgets('defaultValue sets initial selection', (tester) async {
      String? selectedInScope;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            defaultValue: 'item2',
            child: Column(
              children: [
                CommandStateSelector<String?>(
                  selector: (state) => state.selectedValue,
                  builder: (context, val) {
                    selectedInScope = val;
                    return Text('Selected: $val');
                  },
                ),
                const CommandList(
                  children: [
                    CommandItem(value: 'item1', child: Text('Item 1')),
                    CommandItem(value: 'item2', child: Text('Item 2')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(selectedInScope, 'item2');
    });

    testWidgets('CommandStateSelector updates when selected slice changes',
        (tester) async {
      final controller = CommandController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: Column(
              children: [
                CommandStateSelector<String>(
                  selector: (state) => state.search,
                  builder: (context, search) {
                    return Text('Current Search: $search');
                  },
                ),
                const CommandList(
                  children: [
                    CommandItem(value: 'first', child: Text('First')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Current Search: '), findsOneWidget);

      controller.setSearch('flutter');
      await tester.pump();

      expect(find.text('Current Search: flutter'), findsOneWidget);
    });
  });
}
