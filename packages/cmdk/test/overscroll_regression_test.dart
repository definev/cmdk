import 'package:cmdk/cmdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'controlled mode does not jump scroll offset during overscroll at top',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final scrollController = ScrollController();
      String selectedValue = 'Item 0';
      final selectionHistory = <String>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 400,
                height: 200,
                child: Command(
                  value: selectedValue,
                  onValueChange: (v) {
                    selectionHistory.add(v ?? '');
                    setState(() => selectedValue = v ?? '');
                  },
                  child: CommandList(
                    scrollController: scrollController,
                    padding: const EdgeInsets.only(top: 10),
                    children: List.generate(
                      20,
                      (i) => CommandItem(
                        value: 'Item $i',
                        builder: (context, state) {
                          return Container(
                            height: 30,
                            color: state.isSelected
                                ? const Color(0xFF00FF00)
                                : const Color(0xFFFFFFFF),
                            child: Text('Item $i'),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Place mouse directly over Item 1
      final mouseGesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouseGesture.addPointer(location: const Offset(200, 50));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // Drag down to overscroll past the top
      final dragGesture = await tester.startGesture(const Offset(200, 50));
      final offsets = <double>[];
      for (var i = 0; i < 10; i++) {
        await dragGesture.moveBy(const Offset(0, 10));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        offsets.add(scrollController.offset);
      }
      await dragGesture.up();

      // The offsets while dragging down into overscroll should continuously stay negative
      // and NOT jump/snap back to 0.0 during active drag.
      final negativeOffsets = offsets.where((o) => o < 0).toList();
      expect(negativeOffsets, isNotEmpty);
      // Ensure that once negative, it doesn't snap back to 0.0 while dragging
      for (var i = 1; i < negativeOffsets.length; i++) {
        expect(negativeOffsets[i], lessThanOrEqualTo(negativeOffsets[i - 1]));
      }

      debugDefaultTargetPlatformOverride = null;
    },
  );
}
