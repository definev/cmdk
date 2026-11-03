import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cmdk/cmdk.dart';

void main() {
  testWidgets(
    'controlled route follows updates, rejects dismissal and restores focus',
    (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      final background = FocusNode();
      late StateSetter update;
      var open = false;
      var title = 'First';
      var requests = 0;
      await tester.pumpWidget(
        WidgetsApp(
          navigatorKey: navigator,
          color: const Color(0xFF000000),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            pageBuilder: (context, _, __) => builder(context),
          ),
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Column(
                children: [
                  Focus(focusNode: background, child: const Text('Background')),
                  CommandDialog(
                    open: open,
                    onOpenChange: (_) => requests++,
                    child: Text(title),
                  ),
                ],
              );
            },
          ),
        ),
      );
      background.requestFocus();
      await tester.pumpAndSettle();
      update(() => open = true);
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(background.hasFocus, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(
        find.text('First'),
        findsOneWidget,
      ); // Parent rejected the close request.
      await navigator.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(requests, 2);
      expect(find.text('First'), findsOneWidget);
      update(() => title = 'Second');
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);
      update(() => open = false);
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsNothing);
      expect(background.hasFocus, isTrue);
      expect(requests, 2);
      background.dispose();
    },
  );

  testWidgets('unmounting declarative dialog removes only its owned route', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    late StateSetter update;
    var mounted = true;
    await tester.pumpWidget(
      WidgetsApp(
        navigatorKey: navigator,
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          pageBuilder: (context, _, __) => builder(context),
        ),
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return mounted
                ? const CommandDialog(open: true, child: Text('Owned'))
                : const Text('Home');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Owned'), findsOneWidget);
    update(() => mounted = false);
    await tester.pumpAndSettle();
    expect(find.text('Owned'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(navigator.currentState!.canPop(), isFalse);
  });

  testWidgets('dialog gives autofocus to editable input and closes once', (
    tester,
  ) async {
    var requests = 0;
    var open = true;
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          pageBuilder: (context, _, __) => builder(context),
        ),
        home: StatefulBuilder(
          builder: (context, setState) => CommandDialog(
            open: open,
            onOpenChange: (value) {
              requests++;
              setState(() => open = value);
            },
            child: const Command(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommandInput(),
                  CommandList(
                    children: [CommandItem(value: 'a', child: Text('A'))],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode
          .hasPrimaryFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(requests, 1);
    expect(find.byType(EditableText), findsNothing);
  });
  group('CommandDialog', () {
    testWidgets('declarative CommandDialog renders when open', (tester) async {
      var isOpen = true;

      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            pageBuilder: (context, _, __) => builder(context),
          ),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Stack(
                  children: [
                    CommandDialog(
                      open: isOpen,
                      onOpenChange: (open) => setState(() => isOpen = open),
                      child: const Command(
                        child: CommandList(
                          children: [
                            CommandItem(
                              value: 'item1',
                              child: Text('Modal Item 1'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Modal Item 1'), findsOneWidget);

      // Press Escape key to close
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      await tester.pump();
      expect(isOpen, isFalse);
      expect(find.text('Modal Item 1'), findsNothing);
    });

    testWidgets('imperative CommandDialog.show opens and dismisses', (
      tester,
    ) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            pageBuilder: (context, _, __) => builder(context),
          ),
          home: Builder(
            builder: (context) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: GestureDetector(
                  onTap: () {
                    CommandDialog.show<void>(
                      context: context,
                      builder: (ctx) {
                        return const Command(
                          child: CommandList(
                            children: [
                              CommandItem(
                                value: 'dialog_item',
                                child: Text('Dialog Content'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('OpenDialog'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Dialog Content'), findsNothing);

      await tester.tap(find.text('OpenDialog'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Dialog Content'), findsOneWidget);

      // Dismiss with Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Dialog Content'), findsNothing);
    });
  });
}

// Dialog adapters use the same Navigator lifecycle as other Flutter modals.
