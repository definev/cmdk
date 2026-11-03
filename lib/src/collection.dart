import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'scope.dart';

/// Layout metadata follows the source tree, never the sorted display positions.
class CommandPosition extends InheritedWidget {
  const CommandPosition(
      {super.key, required this.order, this.entry, required super.child});
  final List<int> order;
  final ItemEntry? entry;
  static CommandPosition? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommandPosition>();
  @override
  bool updateShouldNotify(CommandPosition oldWidget) =>
      !listEquals(oldWidget.order, order) || oldWidget.entry != entry;
}

/// Sorts complete child blocks, including custom wrappers, using catalog ranks.
/// Keys belong to source slots so ranking cannot transfer State between rows.
class CommandCollection extends StatelessWidget {
  const CommandCollection({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    final prefix = CommandPosition.maybeOf(context)?.order ?? const <int>[];
    return ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final ordered = controller.visibleItems;
          final ranks = <int, int>{};
          for (var rank = 0; rank < ordered.length; rank++) {
            final order = ordered[rank].order;
            if (order.length > prefix.length &&
                listEquals(order.take(prefix.length).toList(), prefix)) {
              ranks.putIfAbsent(order[prefix.length], () => rank);
            }
          }
          final indices = List.generate(children.length, (i) => i);
          final sortable = indices.where((i) => ranks[i] != null).toList()
            ..sort((a, b) => ranks[a]!.compareTo(ranks[b]!));
          var cursor = 0;
          final display = [
            for (final i in indices) ranks[i] == null ? i : sortable[cursor++]
          ];
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final i in display)
                  CommandPosition(
                      key: _SourceSlotKey(children[i].key ?? i),
                      order: [...prefix, i],
                      child: children[i])
              ]);
        });
  }
}

class _SourceSlotKey extends ValueKey<Object> {
  const _SourceSlotKey(super.value);
}
