import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  group('Arrow keybinds', () {
    testWidgets('arrow up/down changes selected item', (tester) async {
      String? selected;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            onValueChange: (v) => selected = v,
            child: const Column(
              children: [
                CommandInput(autofocus: true),
                CommandList(
                  children: [
                    CommandItem(value: 'first', child: Text('First')),
                    CommandItem(value: 'second', child: Text('Second')),
                    CommandItem(value: 'third', child: Text('Third')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(selected, 'first');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(selected, 'second');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(selected, 'third');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(selected, 'second');
    });

    testWidgets('meta arrow up/down goes to first and last item',
        (tester) async {
      final controller = CommandController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandItem(value: 'first', child: Text('First')),
                CommandItem(value: 'second', child: Text('Second')),
                CommandItem(value: 'third', child: Text('Third')),
                CommandItem(value: 'last', child: Text('Last')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controller.selectedValue, 'first');

      controller.nextItem(isMeta: true);
      expect(controller.selectedValue, 'last');

      controller.prevItem(isMeta: true);
      expect(controller.selectedValue, 'first');
    });

    testWidgets('alt arrow up/down jumps between groups', (tester) async {
      final controller = CommandController();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandGroup(
                  heading: Text('Group 1'),
                  children: [
                    CommandItem(value: 'g1_item1', child: Text('G1 Item 1')),
                    CommandItem(value: 'g1_item2', child: Text('G1 Item 2')),
                  ],
                ),
                CommandGroup(
                  heading: Text('Group 2'),
                  children: [
                    CommandItem(value: 'g2_item1', child: Text('G2 Item 1')),
                    CommandItem(value: 'g2_item2', child: Text('G2 Item 2')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controller.selectedValue, 'g1_item1');

      controller.nextItem(isAlt: true);
      expect(controller.selectedValue, 'g2_item1');

      controller.prevItem(isAlt: true);
      expect(controller.selectedValue, 'g1_item1');
    });

    testWidgets('loop wraps around list when loop is true', (tester) async {
      final controller = CommandController(loop: true);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandItem(value: 'item1', child: Text('Item 1')),
                CommandItem(value: 'item2', child: Text('Item 2')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controller.selectedValue, 'item1');

      controller.prevItem();
      expect(controller.selectedValue, 'item2');

      controller.nextItem();
      expect(controller.selectedValue, 'item1');
    });

    testWidgets('enter key activates selected item', (tester) async {
      var activated = false;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            child: Column(
              children: [
                const CommandInput(autofocus: true),
                CommandList(
                  children: [
                    CommandItem(
                      value: 'item1',
                      onSelect: () => activated = true,
                      child: const Text('Item 1'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(activated, isTrue);
    });
  });

  group('Vim keybinds', () {
    testWidgets('vim jk keys navigate when enabled', (tester) async {
      final controller = CommandController(vimBindings: true);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Command(
            controller: controller,
            child: const CommandList(
              children: [
                CommandItem(value: 'item1', child: Text('Item 1')),
                CommandItem(value: 'item2', child: Text('Item 2')),
                CommandItem(value: 'item3', child: Text('Item 3')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(controller.selectedValue, 'item1');

      controller.nextItem();
      expect(controller.selectedValue, 'item2');

      controller.prevItem();
      expect(controller.selectedValue, 'item1');
    });
  });
}
