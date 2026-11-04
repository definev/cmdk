import 'package:flutter/widgets.dart';

/// Accessible loading progress indicator for asynchronous command menus.
class CommandLoading extends StatelessWidget {
  const CommandLoading({
    super.key,
    this.progress,
    this.label = 'Loading...',
    this.padding,
    this.child,
  });

  /// Optional estimated progress (0 to 100).
  final double? progress;

  /// Accessible label for screen readers.
  final String label;

  /// Optional padding.
  final EdgeInsetsGeometry? padding;

  /// Custom loading widget.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget content =
        child ??
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.0,
            color: Color(0xFF888888),
          ),
        );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Semantics(
      label: label,
      value: progress != null ? '${progress!.toStringAsFixed(0)}%' : null,
      child: content,
    );
  }
}
