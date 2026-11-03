import 'package:flutter/widgets.dart';
import 'collection.dart';
import 'controller.dart';
import 'scope.dart';

/// Groups command items together with an optional heading.
///
/// Hides automatically when all items within the group have a filter score of 0,
/// unless [forceMount] is set to `true`.
class CommandGroup extends StatefulWidget {
  const CommandGroup({
    super.key,
    this.value,
    this.heading,
    this.forceMount = false,
    this.padding,
    this.spacing = 0.0,
    this.topSpacing = 0.0,
    required this.children,
  });

  /// Unique identifier or value for this group. If null, generated automatically.
  final String? value;

  /// Optional heading widget displayed at the top of the group.
  final Widget? heading;

  /// Whether this group is forcibly rendered regardless of filtering.
  final bool forceMount;

  /// Padding around the group.
  final EdgeInsetsGeometry? padding;

  /// Optional spacing between visible items within this group.
  final double spacing;

  /// Optional spacing above this group when preceded by another visible group.
  final double topSpacing;

  /// Child items or widgets.
  final List<Widget> children;

  @override
  State<CommandGroup> createState() => _CommandGroupState();
}

class _CommandGroupState extends State<CommandGroup> {
  late final String _generatedId;
  String get _groupId => widget.value ?? _generatedId;
  CommandController? _controller;

  @override
  void initState() {
    super.initState();
    _generatedId = 'cmdk_group_${identityHashCode(this)}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = CommandScope.of(context);
    if (_controller != controller) {
      _controller?.unregisterGroup(_groupId);
      _controller = controller;
      _controller?.registerGroup(_groupId, forceMount: widget.forceMount);
    }
  }

  @override
  void didUpdateWidget(CommandGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller?.unregisterGroup(oldWidget.value ?? _generatedId);
    }
    if (widget.value != oldWidget.value ||
        widget.forceMount != oldWidget.forceMount) {
      _controller?.registerGroup(_groupId, forceMount: widget.forceMount);
    }
  }

  @override
  void dispose() {
    _controller?.unregisterGroup(_groupId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final visible =
            widget.forceMount || controller.isGroupVisible(_groupId);
        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.heading != null)
              Semantics(header: true, child: widget.heading!),
            CommandCollection(children: widget.children),
          ],
        );
        var topPadding = 0.0;
        if (visible && widget.topSpacing > 0) {
          final visibleGroupIds = <String>[];
          for (final item in controller.visibleItems) {
            if (item.groupId != null &&
                !visibleGroupIds.contains(item.groupId)) {
              visibleGroupIds.add(item.groupId!);
            }
          }
          final groupIndex = visibleGroupIds.indexOf(_groupId);
          if (groupIndex > 0) {
            topPadding = widget.topSpacing;
          }
        }

        // Keep widget tree shape stable across builds to prevent element remounting.
        final resolvedGroupPadding =
            widget.padding?.resolve(
              Directionality.maybeOf(context) ?? TextDirection.ltr,
            ) ??
            EdgeInsets.zero;
        content = Padding(
          padding: resolvedGroupPadding.add(EdgeInsets.only(top: topPadding)),
          child: content,
        );

        return CommandGroupScope(
          groupId: _groupId,
          forceMount: widget.forceMount,
          spacing: widget.spacing,
          child: ExcludeFocus(
            excluding: !visible,
            child: Offstage(offstage: !visible, child: content),
          ),
        );
      },
    );
  }
}
