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

    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets('editing adds no clear or cancel controls ($platform)', (
        tester,
      ) async {
        final controller = CommandController();
        final input = Command(
          controller: controller,
          child: AdaptiveCommandInput(platform: platform),
        );
        await tester.pumpWidget(
          platform == TargetPlatform.iOS
              ? cupertino.CupertinoApp(
                  home: cupertino.CupertinoPageScaffold(child: input),
                )
              : material.MaterialApp(
                  theme: material.ThemeData(
                    splashFactory: material.NoSplash.splashFactory,
                  ),
                  home: material.Scaffold(body: input),
                ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText), 'search text');
        await tester.pumpAndSettle();
        expect(controller.search, 'search text');
        expect(
          find.byIcon(cupertino.CupertinoIcons.clear_thick_circled),
          findsNothing,
        );
        expect(find.byIcon(material.Icons.cancel), findsNothing);
        expect(find.byType(cupertino.CupertinoButton), findsNothing);
        expect(find.byType(material.TextButton), findsNothing);
        await tester.enterText(find.byType(EditableText), '');
        await tester.pumpAndSettle();
        expect(controller.search, isEmpty);
        expect(tester.takeException(), isNull);
      });
    }

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
        tester
            .widget<cupertino.CupertinoTextField>(
              find.byType(cupertino.CupertinoTextField),
            )
            .controller,
        same(textController),
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
