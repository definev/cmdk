import 'package:flutter/widgets.dart';
import 'scope.dart';

/// A separator between items or groups.
///
/// Automatically hides when search query is non-empty unless [alwaysRender] is `true`.
class CommandSeparator extends StatelessWidget {
  const CommandSeparator({
    super.key,
    this.alwaysRender = false,
    this.color = const Color(0xFFE5E5E5),
    this.height = 1.0,
    this.padding,
    this.child,
  });

  /// Whether to render even when a search query is active.
  final bool alwaysRender;

  /// Default divider line color if [child] is not specified.
  final Color color;

  /// Default divider line thickness if [child] is not specified.
  final double height;

  /// Optional padding around the separator.
  final EdgeInsetsGeometry? padding;

  /// Optional custom separator widget.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    return ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final isSearchEmpty = controller.search.isEmpty;

          if (!alwaysRender && !isSearchEmpty) {
            return const SizedBox.shrink();
          }

          Widget content = child ??
              Container(
                height: height,
                color: color,
              );

          if (padding != null) {
            content = Padding(padding: padding!, child: content);
          }

          return content;
        });
  }
}
