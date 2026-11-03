import 'package:flutter/widgets.dart';
import 'controller.dart';
import 'models.dart';
import 'scope.dart';
import 'collection.dart';

/// State passed to [CommandItem.builder].
class CommandItemState {
  const CommandItemState({
    required this.isSelected,
    required this.isDisabled,
    required this.isHovered,
    required this.score,
  });

  final bool isSelected;
  final bool isDisabled;
  final bool isHovered;
  final double score;
}

/// An individual selectable item within the command menu.
class CommandItem extends StatefulWidget {
  const CommandItem({
    super.key,
    this.value,
    this.keywords = const [],
    this.disabled = false,
    this.forceMount = false,
    this.onSelect,
    this.builder,
    this.child,
  }) : assert(
          value != null || child is Text,
          'CommandItem requires an explicit `value` parameter, or a `Text` widget as `child` to infer the value.',
        );

  /// Unique value for this item. If null, inferred from [child] if it is a [Text] widget.
  final String? value;

  /// Optional keywords/aliases to match against during search.
  final List<String> keywords;

  /// Whether this item is disabled. Disabled items cannot be selected or activated.
  final bool disabled;

  /// Whether to force this item to be rendered regardless of filter results.
  final bool forceMount;

  /// Callback fired when the item is activated (via click/tap or Enter key).
  final VoidCallback? onSelect;

  /// Builder providing item state for custom styling.
  final Widget Function(BuildContext context, CommandItemState state)? builder;

  /// Child widget.
  final Widget? child;

  @override
  State<CommandItem> createState() => _CommandItemState();
}

class _CommandItemState extends State<CommandItem> {
  late final String _id;
  late String _value;
  CommandController? _controller;
  bool _isHovered = false;
  bool _registered = false;
  String get _entryId => CommandPosition.maybeOf(context)?.entry?.id ?? _id;

  @override
  void initState() {
    super.initState();
    _id = 'cmdk_item_${identityHashCode(this)}';
    _value = _resolveValue();
  }

  String _resolveValue() {
    if (widget.value != null && widget.value!.trim().isNotEmpty) {
      return widget.value!.trim();
    }
    if (widget.child is Text) {
      final textData = (widget.child! as Text).data;
      if (textData != null && textData.trim().isNotEmpty) {
        return textData.trim();
      }
    }
    return _id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = CommandScope.of(context);
    final groupScope = CommandGroupScope.maybeOf(context);

    if (_controller != controller) {
      if (_registered) _controller?.unregisterItem(_id);
      _controller?.scrollRequestedId.removeListener(_onScrollRequested);
      _registered = false;
      _controller = controller;
      controller.scrollRequestedId.addListener(_onScrollRequested);
    }
    _register(groupScope);
  }

  void _register(CommandGroupScope? groupScope) {
    _value = _resolveValue();
    final position = CommandPosition.maybeOf(context);
    if (position?.entry != null) {
      if (_registered) _controller?.unregisterItem(_id);
      _registered = false;
      return;
    }
    _registered = true;
    _controller?.registerItem(ItemEntry(
        id: _id,
        value: _value,
        keywords: List.unmodifiable(widget.keywords),
        groupId: groupScope?.groupId,
        disabled: widget.disabled,
        forceMount: widget.forceMount || (groupScope?.forceMount ?? false),
        order: position?.order ?? const [],
        onSelect: widget.onSelect));
  }

  @override
  void didUpdateWidget(CommandItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _register(CommandGroupScope.maybeOf(context));
  }

  @override
  void dispose() {
    _controller?.scrollRequestedId.removeListener(_onScrollRequested);
    if (_registered) _controller?.unregisterItem(_id);
    super.dispose();
  }

  void _onScrollRequested() {
    if (_controller?.scrollRequestedId.value == _entryId && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      });
    }
  }

  void _handleSelect() {
    if (widget.disabled) return;
    _controller?.selectValue(_value);
    widget.onSelect?.call();
  }

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    return ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final groupScope = CommandGroupScope.maybeOf(context);
          final forceMount =
              widget.forceMount || (groupScope?.forceMount ?? false);

          final isVisible = forceMount || controller.isItemVisible(_entryId);
          if (!isVisible) {
            return const SizedBox.shrink();
          }

          final isSelected = controller.selectedValue == _value;
          final score = controller.itemScore(_entryId);

          final itemState = CommandItemState(
            isSelected: isSelected,
            isDisabled: widget.disabled,
            isHovered: _isHovered,
            score: score,
          );

          Widget content = widget.builder != null
              ? widget.builder!(context, itemState)
              : widget.child ?? const SizedBox.shrink();

          content = MouseRegion(
            cursor: widget.disabled
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            onEnter: (_) {
              if (!_isHovered) setState(() => _isHovered = true);
              if (!widget.disabled && !controller.disablePointerSelection) {
                controller.selectValue(_value, scrollIntoView: false);
              }
            },
            onHover: (_) {
              if (!widget.disabled && !controller.disablePointerSelection) {
                controller.selectValue(_value, scrollIntoView: false);
              }
            },
            onExit: (_) {
              if (_isHovered) {
                setState(() => _isHovered = false);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.disabled ? null : _handleSelect,
              child: content,
            ),
          );

          return Semantics(
            selected: isSelected,
            enabled: !widget.disabled,
            button: true,
            child: content,
          );
        });
  }
}
