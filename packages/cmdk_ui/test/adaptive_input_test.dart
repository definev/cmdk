import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;

void main() {
  group('AdaptiveCommandInput', () {
    testWidgets('renders Cupertino style on iOS platform', (tester) async {
      await tester.pumpWidget(
        const cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: Command(
              child: AdaptiveCommandInput(
                platform: TargetPlatform.iOS,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(cupertino.CupertinoTextField), findsOneWidget);
      expect(find.byIcon(cupertino.CupertinoIcons.search), findsNothing);
    });

    testWidgets('renders Material style on Android platform', (tester) async {
      await tester.pumpWidget(
        material.MaterialApp(
          theme: material.ThemeData(
            splashFactory: material.NoSplash.splashFactory,
          ),
          home: const material.Scaffold(
            body: Command(
              child: AdaptiveCommandInput(
                platform: TargetPlatform.android,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(material.TextField), findsOneWidget);
      expect(find.byIcon(material.Icons.search), findsNothing);
    });

    testWidgets(
      'clear button appears when text is entered and clears on tap (iOS)',
      (
        tester,
      ) async {
        final controller = CommandController();
        await tester.pumpWidget(
          cupertino.CupertinoApp(
            home: cupertino.CupertinoPageScaffold(
              child: Command(
                controller: controller,
                child: const AdaptiveCommandInput(
                  platform: TargetPlatform.iOS,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially no clear button
        expect(
          find.byIcon(cupertino.CupertinoIcons.clear_thick_circled),
          findsNothing,
        );

        // Enter text
        await tester.enterText(
          find.byType(cupertino.CupertinoTextField),
          'search text',
        );
        await tester.pumpAndSettle();

        expect(controller.search, 'search text');
        expect(
          find.byIcon(cupertino.CupertinoIcons.clear_thick_circled),
          findsOneWidget,
        );

        // Tap clear button
        await tester.tap(
          find.byIcon(cupertino.CupertinoIcons.clear_thick_circled),
        );
        await tester.pumpAndSettle();

        expect(controller.search, '');
        expect(
          find.byIcon(cupertino.CupertinoIcons.clear_thick_circled),
          findsNothing,
        );
      },
    );

    testWidgets(
      'clear button appears when text is entered and clears on tap (Android)',
      (
        tester,
      ) async {
        final controller = CommandController();
        await tester.pumpWidget(
          material.MaterialApp(
            theme: material.ThemeData(
              splashFactory: material.NoSplash.splashFactory,
            ),
            home: material.Scaffold(
              body: Command(
                controller: controller,
                child: const AdaptiveCommandInput(
                  platform: TargetPlatform.android,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially no clear button
        expect(find.byIcon(material.Icons.cancel), findsNothing);

        // Enter text
        await tester.enterText(
          find.byType(material.TextField),
          'flutter command',
        );
        await tester.pumpAndSettle();

        expect(controller.search, 'flutter command');
        expect(find.byIcon(material.Icons.cancel), findsOneWidget);

        // Tap clear button
        await tester.tap(find.byIcon(material.Icons.cancel));
        await tester.pumpAndSettle();

        expect(controller.search, '');
        expect(find.byIcon(material.Icons.cancel), findsNothing);
      },
    );

    testWidgets('cancel button triggers onCancel callback', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: Command(
              child: AdaptiveCommandInput(
                platform: TargetPlatform.iOS,
                showCancelButton: true,
                cancelButtonLabel: 'Dismiss',
                onCancel: () {
                  cancelled = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsOneWidget);
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
    });

    testWidgets('custom prefix and suffix render when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        const cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: Command(
              child: AdaptiveCommandInput(
                platform: TargetPlatform.iOS,
                prefix: Text('CUSTOM_PREFIX'),
                suffix: Text('CUSTOM_SUFFIX'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM_PREFIX'), findsOneWidget);
      expect(find.text('CUSTOM_SUFFIX'), findsOneWidget);
    });

    testWidgets('filled: true applies styled container decoration', (
      tester,
    ) async {
      await tester.pumpWidget(
        material.MaterialApp(
          theme: material.ThemeData(
            splashFactory: material.NoSplash.splashFactory,
          ),
          home: material.Scaffold(
            body: Command(
              child: AdaptiveCommandInput(
                platform: TargetPlatform.android,
                filled: true,
                fillColor: const Color(0xFF123456),
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoratedBox = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(AdaptiveCommandInput),
          matching: find.byType(DecoratedBox),
        ),
      );
      final boxDecoration = decoratedBox.decoration as BoxDecoration;
      expect(boxDecoration.color, const Color(0xFF123456));
      expect(boxDecoration.borderRadius, BorderRadius.circular(16.0));
    });

    testWidgets('synchronizes with external TextEditingController', (
      tester,
    ) async {
      final cmdController = CommandController(search: 'preset query');
      final textController = TextEditingController();
      await tester.pumpWidget(
        cupertino.CupertinoApp(
          home: cupertino.CupertinoPageScaffold(
            child: Command(
              controller: cmdController,
              child: AdaptiveCommandInput(
                controller: textController,
                platform: TargetPlatform.iOS,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Controller and Command sync the preset query
      expect(textController.text, 'preset query');
      expect(
        find.byIcon(cupertino.CupertinoIcons.clear_thick_circled),
        findsOneWidget,
      );

      // Clearing external controller directly
      textController.clear();
      await tester.pumpAndSettle();

      expect(cmdController.search, '');
      expect(
        find.byIcon(cupertino.CupertinoIcons.clear_thick_circled),
        findsNothing,
      );
    });
  });
}
