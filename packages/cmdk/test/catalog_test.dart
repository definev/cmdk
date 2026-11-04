import 'package:cmdk/cmdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: 500, height: 300, child: child),
  ),
);

void main() {
  testWidgets('virtual search, scrolling and activation include unbuilt data', (
    tester,
  ) async {
    final controller = CommandController(
      filter: (value, query, [keywords]) => value == query ? 1 : 0,
    );
    final scroll = ScrollController();
    var activated = -1;
    final catalog = List.generate(
      1000,
      (i) =>
          ItemEntry(id: '$i', value: 'item$i', onSelect: () => activated = i),
    );
    await tester.pumpWidget(
      host(
        Command(
          controller: controller,
          child: CommandList.builder(
            items: catalog,
            scrollController: scroll,
            itemExtent: 40,
            itemBuilder: (context, item, state) => Text(item.value),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('item999'), findsNothing);
    controller.lastItem();
    await tester.pumpAndSettle();
    expect(find.text('item999'), findsOneWidget);
    expect(scroll.offset, greaterThan(0));
    expect(controller.filteredCount, 1000);
    controller.setSearch('item999');
    await tester.pumpAndSettle();
    expect(find.text('item999'), findsOneWidget);
    expect(controller.filteredCount, 1);
    controller.selectCurrent();
    expect(activated, 999);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(controller.getSortedValidItems(), isEmpty);
    scroll.dispose();
    controller.dispose();
  });

  testWidgets('catalog replacements update callbacks and reconcile removal', (
    tester,
  ) async {
    final controller = CommandController();
    var calls = '';
    Widget menu(List<ItemEntry> items) => host(
      Command(
        controller: controller,
        child: CommandList.builder(
          items: items,
          itemExtent: 40,
          itemBuilder: (context, item, state) => Text(item.value),
        ),
      ),
    );
    await tester.pumpWidget(
      menu([
        ItemEntry(id: 'a', value: 'a', onSelect: () => calls = 'old'),
        const ItemEntry(id: 'b', value: 'b'),
      ]),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      menu([
        ItemEntry(id: 'a', value: 'a', onSelect: () => calls = 'new'),
        const ItemEntry(id: 'b', value: 'b'),
      ]),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('a'));
    expect(calls, 'new');
    await tester.pumpWidget(menu([const ItemEntry(id: 'b', value: 'b')]));
    await tester.pumpAndSettle();
    expect(controller.selectedValue, 'b');
    expect(controller.filteredCount, 1);
  });

  testWidgets(
    'ranking wrapped blocks preserves keyed state and keyboard order',
    (tester) async {
      final controller = CommandController(
        filter: (value, search, [keywords]) => value == 'b' ? 1 : .5,
      );
      const a = ValueKey('a-state');
      const b = ValueKey('b-state');
      await tester.pumpWidget(
        host(
          Command(
            controller: controller,
            child: const CommandList(
              children: [
                Padding(
                  key: a,
                  padding: EdgeInsets.all(2),
                  child: CommandItem(value: 'a', child: Text('A')),
                ),
                CommandGroup(
                  heading: Text('Group'),
                  children: [
                    Padding(
                      key: b,
                      padding: EdgeInsets.all(2),
                      child: CommandItem(value: 'b', child: Text('B')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final stateA = tester.state(
        find.descendant(of: find.byKey(a), matching: find.byType(CommandItem)),
      );
      final stateB = tester.state(
        find.descendant(of: find.byKey(b), matching: find.byType(CommandItem)),
      );
      controller.setSearch('x');
      await tester.pumpAndSettle();
      final labels = controller
          .getSortedValidItems()
          .map((item) => item.value)
          .toList();
      final tops = {
        for (final label in ['a', 'b'])
          label: tester.getTopLeft(find.text(label.toUpperCase())).dy,
      };
      expect(tops[labels.first]!, lessThan(tops[labels.last]!));
      expect(
        tester.state(
          find.descendant(
            of: find.byKey(a),
            matching: find.byType(CommandItem),
          ),
        ),
        same(stateA),
      );
      expect(
        tester.state(
          find.descendant(
            of: find.byKey(b),
            matching: find.byType(CommandItem),
          ),
        ),
        same(stateB),
      );
      controller.setSearch('');
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('A')).dy,
        lessThan(tester.getTopLeft(find.text('B')).dy),
      );
    },
  );

  testWidgets(
    'source reordering changes navigation without transferring keyed state',
    (tester) async {
      final controller = CommandController();
      Widget menu(List<String> values) => host(
        Command(
          controller: controller,
          child: CommandList(
            children: [
              for (final value in values)
                CommandItem(
                  key: ValueKey(value),
                  value: value,
                  child: Text(value),
                ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(menu(['a', 'b']));
      await tester.pumpAndSettle();
      final a = tester.state(find.byKey(const ValueKey('a')));
      await tester.pumpWidget(menu(['b', 'a']));
      await tester.pumpAndSettle();
      expect(controller.getSortedValidItems().map((item) => item.value), [
        'b',
        'a',
      ]);
      expect(tester.state(find.byKey(const ValueKey('a'))), same(a));
    },
  );

  testWidgets(
    'controlled parent accepts selection and search without callback feedback',
    (tester) async {
      var value = 'a';
      var search = '';
      var values = 0;
      var searches = 0;
      late CommandController controller;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => Command(
              value: value,
              search: search,
              onValueChange: (next) {
                values++;
                setState(() => value = next ?? '');
              },
              onSearchChange: (next) {
                searches++;
                setState(() => search = next);
              },
              child: Builder(
                builder: (context) {
                  controller = CommandScope.of(context);
                  return const Column(
                    children: [
                      CommandInput(),
                      CommandList(
                        children: [
                          CommandItem(value: 'a', child: Text('A')),
                          CommandItem(value: 'b', child: Text('B')),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.selectedValue, 'b');
      expect(values, 1);
      await tester.enterText(find.byType(EditableText), 'b');
      await tester.pumpAndSettle();
      expect(controller.search, 'b');
      expect(searches, 1);
      expect(values, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'root overrides do not mutate external configuration or callbacks',
    (tester) async {
      var calls = 0;
      final controller = CommandController(
        loop: true,
        onValueChange: (_) => calls++,
      );
      const items = CommandList(
        children: [
          CommandItem(value: 'a', child: Text('A')),
          CommandItem(value: 'b', child: Text('B')),
        ],
      );
      await tester.pumpWidget(
        host(Command(controller: controller, loop: false, child: items)),
      );
      await tester.pumpAndSettle();
      expect(controller.loop, isFalse);
      await tester.pumpWidget(
        host(Command(controller: controller, child: items)),
      );
      await tester.pumpAndSettle();
      expect(controller.loop, isTrue);
      final before = calls;
      controller.nextItem();
      expect(calls, before + 1);
    },
  );

  testWidgets(
    'input controller and focus ownership can change in both directions',
    (tester) async {
      final controller = CommandController();
      final text = TextEditingController();
      final focus = FocusNode();
      var changes = 0;
      Widget menu(bool external) => host(
        Command(
          controller: controller,
          child: CommandInput(
            controller: external ? text : null,
            focusNode: external ? focus : null,
            onValueChange: (_) => changes++,
          ),
        ),
      );
      await tester.pumpWidget(menu(true));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pumpWidget(menu(false));
      await tester.pumpAndSettle();
      final before = changes;
      text.text = 'detached';
      expect(changes, before);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'abc',
      );
      await tester.pumpWidget(menu(true));
      await tester.pumpAndSettle();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).focusNode,
        same(focus),
      );
      await tester.pumpWidget(const SizedBox());
      text.text = 'after disposal';
      expect(tester.takeException(), isNull);
      text.dispose();
      focus.dispose();
      controller.dispose();
    },
  );

  testWidgets('snapshots are immutable historical values', (tester) async {
    final controller = CommandController();
    await tester.pumpWidget(
      host(
        Command(
          controller: controller,
          child: const CommandList(
            children: [CommandItem(value: 'a', child: Text('A'))],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = controller.snapshot;
    expect(controller.snapshot, same(before));
    controller.setSearch('missing');
    expect(before.filteredCount, 1);
    expect(controller.snapshot.filteredCount, 0);
    expect(() => before.scores.clear(), throwsUnsupportedError);
  });
  testWidgets('controlled search rejection restores input without feedback', (
    tester,
  ) async {
    final controller = CommandController();
    final requests = <String>[];
    await tester.pumpWidget(
      host(
        Command(
          controller: controller,
          search: 'a',
          onSearchChange: requests.add,
          child: const CommandInput(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'b');
    await tester.pumpAndSettle();
    expect(controller.search, 'a');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'a',
    );
    expect(requests, ['b']);
  });

  testWidgets('accepted controlled search resets uncontrolled selection', (
    tester,
  ) async {
    final controller = CommandController(
      filter: (value, query, [keywords]) => 1,
    );
    Widget menu(String query) => host(
      Command(
        controller: controller,
        search: query,
        child: const CommandList(
          children: [
            CommandItem(value: 'a', child: Text('A')),
            CommandItem(value: 'b', child: Text('B')),
          ],
        ),
      ),
    );
    await tester.pumpWidget(menu(''));
    await tester.pumpAndSettle();
    controller.nextItem();
    expect(controller.selectedValue, 'b');
    await tester.pumpWidget(menu('query'));
    await tester.pumpAndSettle();
    expect(controller.selectedValue, 'a');
  });
}
