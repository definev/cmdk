import 'package:flutter/widgets.dart';
import 'scope.dart';

/// Renders automatically when there are no matching results for the search query.
class CommandEmpty extends StatelessWidget {
  const CommandEmpty({
    super.key,
    this.builder,
    this.padding,
    this.child,
  });

  /// Custom builder receiving the current search string.
  final Widget Function(BuildContext context, String search)? builder;

  /// Optional padding around the empty state widget.
  final EdgeInsetsGeometry? padding;

  /// Default child widget to display.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.filteredCount > 0) {
          return const SizedBox.shrink();
        }

        Widget content = builder != null
            ? builder!(context, controller.search)
            : child ?? const SizedBox.shrink();

        if (padding != null) {
          content = Padding(padding: padding!, child: content);
        }

        return Semantics(
          liveRegion: true,
          child: content,
        );
      },
    );
  }
}
