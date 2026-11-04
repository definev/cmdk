import 'package:cmdk/cmdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scroll navigation ensure visible', () {
    testWidgets(
      'keyboard navigation scrolls bidirectionally and keeps items fully visible',
      (tester) async {
        final scrollController = ScrollController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 120, // Exactly 3 items of 40px fit in the viewport
                child: Command(
                  focusNode: focusNode,
                  autofocus: true,
                  child: CommandList(
                    scrollController: scrollController,
                    children: List.generate(
                      10,
                      (i) => CommandItem(
                        value: 'item_$i',
                        child: SizedBox(
                          height: 40,
                          child: Text('item_$i'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(scrollController.offset, 0.0);

        // Down arrow to item 1 (40..80) -> within viewport 0..120
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 0.0);

        // Down arrow to item 2 (80..120) -> within viewport 0..120
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 0.0);

        // Down arrow to item 3 (120..160) -> below viewport. Must scroll down just enough to reveal bottom
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 40.0);

        // Down arrow to item 4 (160..200) -> offset 80.0
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 80.0);

        // Down arrow to item 5 (200..240) -> offset 120.0
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 120.0);

        // Up arrow to item 4 (160..200) -> already fully visible inside viewport 120..240
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 120.0);

        // Up arrow to item 3 (120..160) -> already fully visible inside viewport 120..240
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 120.0);

        // Up arrow to item 2 (80..120) -> above viewport! Must scroll UP to reveal top at 80.0
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 80.0);

        // Up arrow to item 1 (40..80) -> above viewport! Must scroll UP to 40.0
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 40.0);

        // Up arrow to item 0 (0..40) -> above viewport! Must scroll UP to 0.0
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(scrollController.offset, 0.0);
      },
    );

    testWidgets('programmatic selectValue scrolls item into view bidirectionally', (
      tester,
    ) async {
      final scrollController = ScrollController();
      final controller = CommandController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 300,
              height: 150,
              child: Command(
                controller: controller,
                child: CommandList(
                  scrollController: scrollController,
                  children: List.generate(
                    20,
                    (i) => CommandItem(
                      value: 'item_$i',
                      child: SizedBox(
                        height: 40,
                        child: Text('item_$i'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Jump to item 10 (400..440) -> viewport 150 -> offset 440 - 150 = 290.0
      controller.selectValue('item_10');
      await tester.pumpAndSettle();
      expect(scrollController.offset, 290.0);

      // Jump to item 5 (200..240) -> above viewport 290..440 -> offset becomes 200.0
      controller.selectValue('item_5');
      await tester.pumpAndSettle();
      expect(scrollController.offset, 200.0);

      // Jump to item 6 (240..280) -> within viewport 200..350 -> offset does not change
      controller.selectValue('item_6');
      await tester.pumpAndSettle();
      expect(scrollController.offset, 200.0);
    });

    testWidgets(
      'reveals group header when selecting first item of a group or Meta + Up',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final scrollController = ScrollController();
        final focusNode = FocusNode();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 150,
                child: Command(
                  focusNode: focusNode,
                  autofocus: true,
                  child: CommandList(
                    scrollController: scrollController,
                    children: [
                      CommandGroup(
                        heading: const SizedBox(
                          height: 30,
                          child: Text('Group 1'),
                        ),
                        children: List.generate(
                          5,
                          (i) => CommandItem(
                            value: 'g1_item$i',
                            child: SizedBox(
                              height: 40,
                              child: Text('G1 Item $i'),
                            ),
                          ),
                        ),
                      ),
                      CommandGroup(
                        heading: const SizedBox(
                          height: 30,
                          child: Text('Group 2'),
                        ),
                        children: List.generate(
                          5,
                          (i) => CommandItem(
                            value: 'g2_item$i',
                            child: SizedBox(
                              height: 40,
                              child: Text('G2 Item $i'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Group 1 header: 0..30
        // G1 items (5 * 40 = 200): 30..230
        // Group 2 header: 230..260
        // G2 items:
        //  g2_item0: 260..300
        //  g2_item1: 300..340
        //  g2_item2: 340..380
        //  g2_item3: 380..420
        //  g2_item4: 420..460

        final controller = CommandScope.of(
          tester.element(find.byType(CommandList)),
        );

        // 1. Jump to bottom item g2_item4 (offset 460 - 150 = 310.0)
        controller.selectValue('g2_item4');
        await tester.pumpAndSettle();
        expect(scrollController.offset, 310.0);

        // 2. Select first item of Group 2: g2_item0
        // MUST reveal Group 2 header (230..260), so scroll offset must be 230.0 (not 260.0)!
        controller.selectValue('g2_item0');
        await tester.pumpAndSettle();
        expect(scrollController.offset, 230.0);

        // 3. Jump to bottom item g2_item4 again
        controller.selectValue('g2_item4');
        await tester.pumpAndSettle();
        expect(scrollController.offset, 310.0);

        // 4. Meta + Up should navigate to first item (g1_item0) and scroll to minScrollExtent (0.0)
        // to reveal Group 1 header and top of the list!
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pumpAndSettle();
        expect(controller.selectedValue, 'g1_item0');
        expect(scrollController.offset, 0.0);

        // 5. Meta + Down should navigate to last item (g2_item4) and scroll to maxScrollExtent (310.0)
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pumpAndSettle();
        expect(controller.selectedValue, 'g2_item4');
        expect(scrollController.offset, 310.0);
        debugDefaultTargetPlatformOverride = null;
      },
    );

    testWidgets(
      'jumping to action near viewport edge or during overscroll does not fail short and reveals item intact',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final scrollController = ScrollController();
        final controller = CommandController();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 300,
                height: 150,
                child: Command(
                  controller: controller,
                  child: CommandList(
                    scrollController: scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    children: List.generate(
                      20,
                      (i) => CommandItem(
                        value: 'item_$i',
                        child: SizedBox(
                          height: 40,
                          child: Text('item_$i'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Viewport height: 150
        // Total content height: 10 (top padding) + 20 * 40 (800) + 20 (bottom padding) = 830
        // maxScrollExtent = 830 - 150 = 680

        // Simulate being in overscroll at top (pixels = -30.0)
        scrollController.jumpTo(-30.0);
        expect(scrollController.offset, -30.0);

        // User intends to jump to item_3 (at Y: 10 + 3 * 40 = 130..170)
        // Bottom of item_3 is at 170. Viewport is 150.
        // Must NOT fail short even though pixels (-30.0) < minScrollExtent (0.0)!
        controller.selectValue('item_3');
        await tester.pumpAndSettle();
        // revealEnd = (170 - 150) + bottomPadding(20) = 40.0
        expect(scrollController.offset, 40.0);

        // Simulate being in overscroll at bottom (pixels = 710.0, maxScrollExtent is 680)
        scrollController.jumpTo(710.0);
        expect(scrollController.offset, 710.0);

        // User intends to jump to item_10 (at Y: 10 + 10 * 40 = 410..450)
        // Must NOT fail short even though pixels (710.0) > maxScrollExtent (680.0)!
        controller.selectValue('item_10');
        await tester.pumpAndSettle();
        // revealStart = 410.0 - topPadding(10) = 400.0
        expect(scrollController.offset, 400.0);

        // Jump to the last item: item_19
        // Must reveal to maxScrollExtent (680.0) so the last item and 20px bottom padding are completely intact!
        controller.selectValue('item_19');
        await tester.pumpAndSettle();
        expect(scrollController.offset, 680.0);

        debugDefaultTargetPlatformOverride = null;
      },
    );
  });
}
