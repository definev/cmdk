import 'package:flutter/widgets.dart';

/// A widget that animates its size when its child's size changes.
/// Mirrors the `--cmdk-list-height` CSS variable animation from cmdk.
class CommandListSizer extends StatefulWidget {
  const CommandListSizer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
    this.enabled = true,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  @override
  State<CommandListSizer> createState() => _CommandListSizerState();
}

class _CommandListSizerState extends State<CommandListSizer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedSize(
      duration: widget.duration,
      curve: widget.curve,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: widget.child,
    );
  }
}
