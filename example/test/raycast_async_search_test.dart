import 'dart:async';

import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:example/clones/raycast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final _mainInput = find.byWidgetPredicate(
  (widget) =>
      widget is EditableText &&
      widget.focusNode.debugLabel == 'RaycastMainInput',
);
final _loading = find.byKey(const ValueKey('raycast-search-loading'));
final _gradient = find.byKey(const ValueKey('raycast-search-gradient'));
final _motion = find.byKey(const ValueKey('raycast-search-gradient-motion'));

Finder _item(String value) => find.byWidgetPredicate(
  (widget) => widget is CommandItem && widget.value == value,
);

Future<void> _mount(
  WidgetTester tester, {
  Future<List<String>> Function(String)? search,
  ValueChanged<String>? onSelect,
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TapRegionSurface(
          child: Center(
            child: SizedBox(
              width: 640,
              child: RaycastCMDK(search: search, onCommandSelect: onSelect),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _toggleActions(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('pending uses the red gradient and locks stale activation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final response = Completer<List<String>>();
    final activations = <String>[];
    await _mount(
      tester,
      search: (_) => response.future,
      onSelect: activations.add,
    );
    expect(_loading, findsNothing);
    final viewport = tester.getSize(find.byType(CommandList).first);

    await tester.enterText(_mainInput, 'Slack');
    // Exercise the callback guard before disabled metadata is rebuilt.
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_loading, findsOneWidget);
    expect(_gradient, findsOneWidget);
    expect(find.text('Searching apps and commands'), findsNothing);
    expect(
      find.bySemanticsLabel('Searching apps and commands'),
      findsOneWidget,
    );
    expect(tester.widget<CommandItem>(_item('Linear')).disabled, isTrue);
    final before = tester.widget<Transform>(_motion).transform.storage[12];
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester.widget<Transform>(_motion).transform.storage[12],
      isNot(before),
    );

    await tester.tap(find.text('Linear'));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.tap(find.text('Actions'));
    await _toggleActions(tester);
    expect(find.text('Show in Finder'), findsNothing);
    expect(activations, isEmpty);
    expect(tester.getSize(find.byType(CommandList).first), viewport);

    response.complete(['Slack']);
    await tester.pumpAndSettle();
    expect(_loading, findsNothing);
    expect(_item('Linear'), findsNothing);
    expect(tester.widget<CommandItem>(_item('Slack')).disabled, isFalse);
    expect(tester.widget<EditableText>(_mainInput).focusNode.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activations, ['Slack']);
    await tester.pumpAndSettle();
    semantics.dispose();
  });

  testWidgets('reduced motion keeps the pending gradient static', (
    tester,
  ) async {
    final response = Completer<List<String>>();
    await _mount(tester, search: (_) => response.future, reduceMotion: true);
    await tester.enterText(_mainInput, 'Slack');
    await tester.pump();
    expect(_gradient, findsOneWidget);
    expect(_motion, findsNothing);
    final rect = tester.getRect(_gradient);
    expect(rect.height, 1);
    expect(rect.width, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getRect(_gradient), rect);
    response.complete(['Slack']);
    await tester.pumpAndSettle();
    expect(_gradient, findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('debounce invokes only the latest query', (tester) async {
    final queries = <String>[];
    await _mount(
      tester,
      search: (query) async {
        queries.add(query);
        return ['Slack'];
      },
    );
    await tester.enterText(_mainInput, 'S');
    await tester.pump(const Duration(milliseconds: 150));
    await tester.enterText(_mainInput, 'Slack');
    await tester.pump(const Duration(milliseconds: 199));
    expect(queries, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(queries, ['Slack']);
  });

  testWidgets('late responses cannot replace newer results', (tester) async {
    final requests = <String, Completer<List<String>>>{};
    await _mount(
      tester,
      search: (query) => (requests[query] = Completer<List<String>>()).future,
    );
    await tester.enterText(_mainInput, 'Sl');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(_mainInput, 'YouTube');
    await tester.pump(const Duration(milliseconds: 200));
    requests['YouTube']!.complete(['YouTube']);
    await tester.pumpAndSettle();
    requests['Sl']!.complete(['Slack']);
    await tester.pumpAndSettle();
    expect(_item('YouTube'), findsOneWidget);
    expect(_item('Slack'), findsNothing);
    expect(_loading, findsNothing);
  });

  testWidgets('stale errors are ignored while a new query is debouncing', (
    tester,
  ) async {
    final old = Completer<List<String>>();
    await _mount(
      tester,
      search: (query) => query == 'Sl' ? old.future : Future.value(['YouTube']),
    );
    await tester.enterText(_mainInput, 'Sl');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(_mainInput, 'YouTube');
    old.completeError(StateError('stale request'));
    await tester.pump();
    expect(find.text('Retry'), findsNothing);
    expect(_loading, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(_item('YouTube'), findsOneWidget);
  });

  testWidgets('clearing restores the catalog and invalidates pending results', (
    tester,
  ) async {
    final response = Completer<List<String>>();
    await _mount(tester, search: (_) => response.future);
    await tester.enterText(_mainInput, 'Slack');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(_mainInput, '');
    await tester.pumpAndSettle();
    expect(_loading, findsNothing);
    expect(_item('Linear'), findsOneWidget);
    expect(tester.widget<CommandItem>(_item('Linear')).disabled, isFalse);
    response.complete([]);
    await tester.pumpAndSettle();
    expect(_item('Linear'), findsOneWidget);
    expect(find.text('No results found.'), findsNothing);
  });

  testWidgets(
    'failure retains disabled rows; retry can publish an empty result',
    (tester) async {
      final requests = <Completer<List<String>>>[];
      await _mount(
        tester,
        search: (_) {
          final response = Completer<List<String>>();
          requests.add(response);
          return response.future;
        },
      );
      final viewport = tester.getSize(find.byType(CommandList).first);
      await tester.enterText(_mainInput, 'missing');
      await tester.pump(const Duration(milliseconds: 200));
      requests.first.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(_loading, findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      expect(tester.widget<CommandItem>(_item('Linear')).disabled, isTrue);
      expect(find.text('No results found.'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(_loading, findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      requests.last.complete([]);
      await tester.pumpAndSettle();
      expect(find.text('No results found.'), findsOneWidget);
      expect(_item('Linear'), findsNothing);
      expect(tester.getSize(find.byType(CommandList).first), viewport);

      await tester.enterText(_mainInput, 'Slack');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('No results found.'), findsNothing);
      expect(tester.getSize(find.byType(CommandList).first), viewport);
      requests.last.complete(['Slack']);
      await tester.pumpAndSettle();
      expect(_item('Slack'), findsOneWidget);
    },
  );

  testWidgets(
    'new results select the first displayed row and clearing selects Linear',
    (tester) async {
      final response = Completer<List<String>>();
      final activations = <String>[];
      await _mount(
        tester,
        search: (_) => response.future,
        onSelect: activations.add,
      );
      await tester.tap(find.text('Slack'));
      await tester.pumpAndSettle();
      expect(activations, ['Slack']);
      await tester.enterText(_mainInput, 'apps');
      await tester.pump(const Duration(milliseconds: 200));
      response.complete(['Clipboard History', 'Figma', 'Slack']);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(activations, ['Slack', 'Figma']);
      await tester.tap(find.text('Slack'));
      await tester.pumpAndSettle();
      expect(activations.last, 'Slack');

      await tester.enterText(_mainInput, '');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(activations.last, 'Linear');
    },
  );

  testWidgets('disposal cancels debounce and ignores in-flight completions', (
    tester,
  ) async {
    var calls = 0;
    final response = Completer<List<String>>();
    Future<List<String>> search(String _) {
      calls++;
      return response.future;
    }

    await _mount(tester, search: search);
    await tester.enterText(_mainInput, 'Slack');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 250));
    expect(calls, 0);
    await _mount(tester, search: search);
    await tester.enterText(_mainInput, 'Slack');
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls, 1);
    await tester.pumpWidget(const SizedBox());
    response.completeError(StateError('disposed request'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
