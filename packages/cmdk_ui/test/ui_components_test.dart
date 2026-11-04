import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;

void main() {
  group('Scrollbar Adapters', () {
    testWidgets('materialCommandScrollbarBuilder renders Material Scrollbar', (
      tester,
    ) async {
      await tester.pumpWidget(
        material.MaterialApp(
          theme: material.ThemeData(
            splashFactory: material.NoSplash.splashFactory,
          ),
          home: material.Scaffold(
            body: Command(
              child: CommandList(
                scrollbarBuilder: materialCommandScrollbarBuilder(),
                children: [
                  for (var i = 0; i < 20; i++)
                    CommandItem(value: 'item_$i', child: Text('Item $i')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(material.Scrollbar), findsOneWidget);
    });

    testWidgets('cupertinoCommandScrollbarBuilder renders CupertinoScrollbar', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: Command(
              child: CommandList(
                scrollbarBuilder: cupertinoCommandScrollbarBuilder(),
                children: [
                  for (var i = 0; i < 20; i++)
                    CommandItem(value: 'item_$i', child: Text('Item $i')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(cupertino.CupertinoScrollbar), findsOneWidget);
    });

    testWidgets(
      'adaptiveCommandScrollbarBuilder renders platform appropriate scrollbar',
      (tester) async {
        await tester.pumpWidget(
          material.MaterialApp(
            theme: material.ThemeData(
              splashFactory: material.NoSplash.splashFactory,
            ),
            home: material.Scaffold(
              body: Command(
                child: CommandList(
                  scrollbarBuilder: adaptiveCommandScrollbarBuilder(),
                  children: [
                    for (var i = 0; i < 20; i++)
                      CommandItem(value: 'item_$i', child: Text('Item $i')),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byWidgetPredicate(
            (w) => w is material.Scrollbar || w is cupertino.CupertinoScrollbar,
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'rawCommandScrollbarBuilder renders RawScrollbar with custom styles',
      (tester) async {
        await tester.pumpWidget(
          WidgetsApp(
            color: const Color(0xFF000000),
            pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
              pageBuilder: (context, _, __) => builder(context),
            ),
            home: Command(
              child: CommandList(
                scrollbarBuilder: rawCommandScrollbarBuilder(
                  thumbColor: const Color(0xFF333333),
                  thickness: 8.0,
                  radius: const Radius.circular(4.0),
                ),
                children: [
                  for (var i = 0; i < 20; i++)
                    CommandItem(value: 'item_$i', child: Text('Item $i')),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scrollbar = tester.widget<RawScrollbar>(
          find.byType(RawScrollbar),
        );
        expect(scrollbar.thumbColor, const Color(0xFF333333));
        expect(scrollbar.thickness, 8.0);
        expect(scrollbar.radius, const Radius.circular(4.0));
      },
    );

    testWidgets('CommandScrollbar widget wraps child with RawScrollbar', (
      tester,
    ) async {
      final controller = ScrollController();
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
            pageBuilder: (context, _, __) => builder(context),
          ),
          home: RawScrollbar(
            controller: controller,
            thumbColor: const Color(0xFF555555),
            thickness: 6.0,
            child: SingleChildScrollView(
              controller: controller,
              child: const SizedBox(height: 1000),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final scrollbar = tester.widget<RawScrollbar>(find.byType(RawScrollbar));
      expect(scrollbar.thumbColor, const Color(0xFF555555));
      expect(scrollbar.thickness, 6.0);
    });
  });

  group('Adaptive Input Adapter', () {
    testWidgets('adaptiveCommandInputBuilder builds without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        material.MaterialApp(
          theme: material.ThemeData(
            splashFactory: material.NoSplash.splashFactory,
          ),
          home: material.Scaffold(
            body: Command(
              child: CommandInput(
                editorBuilder: adaptiveCommandInputBuilder(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);
    });
  });

  group('Mobile Bottom Sheet', () {
    testWidgets(
      'showCommandModalBottomSheet displays sheet and handles drag handle',
      (tester) async {
        await tester.pumpWidget(
          material.MaterialApp(
            theme: material.ThemeData(
              splashFactory: material.NoSplash.splashFactory,
            ),
            home: material.Scaffold(
              body: Builder(
                builder: (context) => material.ElevatedButton(
                  onPressed: () {
                    showCommandModalBottomSheet<void>(
                      context: context,
                      builder: (context) => const CommandBottomSheet(
                        child: Command(
                          child: Column(
                            children: [
                              CommandInput(),
                              CommandList(
                                children: [
                                  CommandItem(
                                    value: 'action',
                                    child: Text('Action 1'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(CommandBottomSheet), findsOneWidget);
        expect(find.text('Action 1'), findsOneWidget);
      },
    );
  });

  group('Dialog Helpers', () {
    testWidgets('showMaterialCommandDialog opens Material dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        material.MaterialApp(
          theme: material.ThemeData(
            splashFactory: material.NoSplash.splashFactory,
          ),
          home: material.Scaffold(
            body: Builder(
              builder: (context) => material.ElevatedButton(
                onPressed: () {
                  showMaterialCommandDialog<void>(
                    context: context,
                    builder: (context) => const Text('Dialog Content'),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      expect(find.text('Dialog Content'), findsOneWidget);
    });

    testWidgets('showCupertinoCommandDialog opens Cupertino dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: Builder(
              builder: (context) => cupertino.CupertinoButton(
                onPressed: () {
                  showCupertinoCommandDialog<void>(
                    context: context,
                    builder: (context) =>
                        const Text('Cupertino Dialog Content'),
                  );
                },
                child: const Text('Show Cupertino'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show Cupertino'));
      await tester.pumpAndSettle();
      expect(find.text('Cupertino Dialog Content'), findsOneWidget);
    });
  });
}
