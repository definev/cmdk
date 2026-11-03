import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

Widget host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: 500, height: 400, child: child),
  ),
);
const items = CommandList(
  children: [
    CommandItem(value: 'a', child: Text('A')),
    CommandItem(value: 'b', child: Text('B')),
  ],
);

void main() {
  testWidgets('R1: idle menu stops notifying after lifecycle settles', (
    t,
  ) async {
    final c = CommandController();
    var notifications = 0;
    c.addListener(() => notifications++);
    await t.pumpWidget(host(Command(controller: c, child: items)));
    for (var i = 0; i < 5; i++) {
      await t.pump();
    }
    final before = notifications;
    for (var i = 0; i < 5; i++) {
      await t.pump();
    }
    expect(
      notifications,
      before,
      reason: 'idle notifications before=$before after=$notifications',
    );
  });
  testWidgets('R2: selector does not rebuild for unchanged slice', (t) async {
    final c = CommandController();
    var builds = 0;
    await t.pumpWidget(
      host(
        Command(
          controller: c,
          child: CommandStateSelector<String>(
            selector: (s) => s.search,
            builder: (context, v) {
              builds++;
              return Text(v);
            },
          ),
        ),
      ),
    );
    final before = builds;
    c.selectValue('a');
    await t.pump();
    expect(builds, before);
  });
  testWidgets('R3: programmatic search updates input', (t) async {
    final c = CommandController();
    await t.pumpWidget(
      host(
        Command(
          controller: c,
          child: const Column(children: [CommandInput(), items]),
        ),
      ),
    );
    await t.pump();
    c.setSearch('b');
    await t.pump();
    expect(
      t.widget<EditableText>(find.byType(EditableText)).controller.text,
      'b',
    );
  });
  testWidgets('R4: controlled value stays authoritative until parent accepts', (
    t,
  ) async {
    late CommandController c;
    await t.pumpWidget(
      host(
        Command(
          value: 'a',
          child: Builder(
            builder: (context) {
              c = CommandScope.of(context);
              return items;
            },
          ),
        ),
      ),
    );
    await t.pump();
    c.nextItem();
    await t.pump();
    expect(c.selectedValue, 'a');
  });
  testWidgets('R5: ranked navigation agrees with rendered order', (t) async {
    final c = CommandController(filter: (v, q, [k]) => v == 'b' ? 1 : 0.5);
    await t.pumpWidget(host(Command(controller: c, child: items)));
    await t.pump();
    c.setSearch('x');
    await t.pump();
    expect(c.selectedValue, 'b');
    expect(
      t.getTopLeft(find.text('B')).dy,
      lessThan(t.getTopLeft(find.text('A')).dy),
    );
  });
  testWidgets('R6: virtual list can navigate to last data item', (t) async {
    final c = CommandController();
    await t.pumpWidget(
      host(
        Command(
          controller: c,
          child: CommandList.builder(
            items: List.generate(
              1000,
              (i) => ItemEntry(id: 'item$i', value: 'item$i'),
            ),
            itemExtent: 50,
            itemBuilder: (ctx, entry, state) => Text(entry.value),
          ),
        ),
      ),
    );
    await t.pump();
    c.lastItem();
    expect(c.selectedValue, 'item999', reason: 'registered=${c.filteredCount}');
  });
  testWidgets('R7: hiding group preserves item state', (t) async {
    final c = CommandController();
    const key = ValueKey('item-state');
    await t.pumpWidget(
      host(
        Command(
          controller: c,
          child: const CommandList(
            children: [
              CommandGroup(
                heading: Text('Group'),
                children: [CommandItem(key: key, value: 'a', child: Text('A'))],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pump();
    final before = t.state(find.byKey(key));
    c.setSearch('z');
    await t.pump();
    final after = t.state(find.byKey(key, skipOffstage: false));
    expect(identical(before, after), isTrue);
  });
  testWidgets('R8: replacing controller unregisters old items', (t) async {
    final a = CommandController();
    final b = CommandController();
    await t.pumpWidget(host(Command(controller: a, child: items)));
    await t.pump();
    await t.pumpWidget(host(Command(controller: b, child: items)));
    await t.pump();
    expect(a.getSortedValidItems(), isEmpty);
  });
  testWidgets('R9: replacing input controller detaches old listener', (
    t,
  ) async {
    final c = CommandController();
    final a = TextEditingController();
    final b = TextEditingController();
    var calls = 0;
    Widget menu(TextEditingController text) => host(
      Command(
        controller: c,
        child: CommandInput(controller: text, onValueChange: (_) => calls++),
      ),
    );
    await t.pumpWidget(menu(a));
    await t.pumpWidget(menu(b));
    final before = calls;
    a.text = 'stale';
    expect(calls, before);
  });
  testWidgets('R10: IME Enter commits composition without activating command', (
    t,
  ) async {
    var calls = 0;
    await t.pumpWidget(
      host(
        Command(
          child: Column(
            children: [
              const CommandInput(),
              CommandList(
                children: [
                  CommandItem(
                    value: 'a',
                    onSelect: () => calls++,
                    child: const Text('A'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pump();
    t.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'a',
        selection: TextSelection.collapsed(offset: 1),
        composing: TextRange(start: 0, end: 1),
      ),
    );
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pump();
    expect(calls, 0);
  });
  testWidgets('R11: external FocusNode still runs input key interceptor', (
    t,
  ) async {
    final node = FocusNode();
    var calls = 0;
    await t.pumpWidget(
      host(
        Command(
          child: Column(
            children: [
              CommandInput(
                focusNode: node,
                onKeyEvent: (node, event) {
                  calls++;
                  return KeyEventResult.handled;
                },
              ),
              items,
            ],
          ),
        ),
      ),
    );
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(calls, greaterThan(0));
  });
  testWidgets(
    'R12: input key interceptor works with internally owned FocusNode',
    (t) async {
      var calls = 0;
      await t.pumpWidget(
        host(
          Command(
            child: Column(
              children: [
                CommandInput(
                  onKeyEvent: (node, event) {
                    calls++;
                    return KeyEventResult.handled;
                  },
                ),
                items,
              ],
            ),
          ),
        ),
      );
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(calls, greaterThan(0));
    },
  );
  testWidgets(
    'R13: external controller configuration survives parent rebuild',
    (t) async {
      final c = CommandController(shouldFilter: false, loop: true);
      await t.pumpWidget(host(Command(controller: c, child: items)));
      await t.pump();
      expect(c.loop, isTrue);
      await t.pumpWidget(host(Command(controller: c, child: items)));
      expect(c.loop, isTrue);
      expect(c.shouldFilter, isFalse);
    },
  );
  testWidgets('R14: updating selector recomputes slice immediately', (t) async {
    final c = CommandController(search: 'query', value: 'a');
    Widget menu(bool search) => host(
      Command(
        controller: c,
        child: CommandStateSelector<String?>(
          selector: (s) => search ? s.search : s.selectedValue,
          builder: (context, v) => Text('slice=$v'),
        ),
      ),
    );
    await t.pumpWidget(menu(true));
    expect(find.text('slice=query'), findsOneWidget);
    await t.pumpWidget(menu(false));
    expect(find.text('slice=a'), findsOneWidget);
  });
  testWidgets('R15: declarative dialog traps focus inside modal', (t) async {
    final background = FocusNode(debugLabel: 'background');
    final inside = FocusNode(debugLabel: 'inside');
    await t.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          pageBuilder: (context, _, __) => builder(context),
        ),
        home: host(
          Stack(
            children: [
              Focus(focusNode: background, child: const Text('Background')),
              CommandDialog(
                open: true,
                child: Focus(
                  focusNode: inside,
                  autofocus: true,
                  child: const Text('Dialog'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await t.pump();
    inside.requestFocus();
    await t.pump();
    var escaped = false;
    for (var i = 0; i < 6; i++) {
      FocusManager.instance.primaryFocus!.nextFocus();
      await t.pump();
      escaped = escaped || background.hasFocus;
    }
    expect(escaped, isFalse);
  });
}
