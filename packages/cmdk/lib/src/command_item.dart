import 'package:flutter/rendering.dart';
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
    this.spacing,
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

  /// Optional spacing above this item if preceded by another visible item.
  /// If null, defaults to [CommandGroup.spacing] or [CommandList.spacing].
  final double? spacing;

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
    _controller?.registerItem(
      ItemEntry(
        id: _id,
        value: _value,
        keywords: List.unmodifiable(widget.keywords),
        groupId: groupScope?.groupId,
        disabled: widget.disabled,
        forceMount: widget.forceMount || (groupScope?.forceMount ?? false),
        order: position?.order ?? const [],
        onSelect: widget.onSelect,
      ),
    );
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
        final scrollable = Scrollable.maybeOf(context);
        if (scrollable == null || !scrollable.position.hasPixels) return;
        final position = scrollable.position;

        final renderObject = context.findRenderObject();
        if (renderObject is! RenderBox || !renderObject.attached) return;

        final viewport = RenderAbstractViewport.maybeOf(renderObject);
        if (viewport == null) return;

        final visible = _controller!.visibleItems;
        final isFirstGlobalItem =
            visible.isNotEmpty && visible.first.id == _entryId;
        final isLastGlobalItem =
            visible.isNotEmpty && visible.last.id == _entryId;

        double? target;

        if (isFirstGlobalItem) {
          // Meta + Up or navigating to the first item: scroll all the way to top to show list padding & first header
          target = position.minScrollExtent;
        } else if (isLastGlobalItem) {
          // Meta + Down or navigating to the last item: scroll all the way to bottom to show list padding & last item
          target = position.maxScrollExtent;
        } else {
          final groupScope = CommandGroupScope.maybeOf(context);
          RenderBox? groupBox;
          if (groupScope != null) {
            ItemEntry? firstInGroup;
            for (final item in visible) {
              if (item.groupId == groupScope.groupId) {
                firstInGroup = item;
                break;
              }
            }
            if (firstInGroup?.id == _entryId) {
              final groupContext =
                  groupScope.groupKey?.currentContext ??
                  groupScope.headerKey?.currentContext;
              final box = groupContext?.findRenderObject();
              if (box is RenderBox && box.attached) {
                groupBox = box;
              }
            }
          }

          final listScope = CommandListScope.maybeOf(context);
          final listPadding =
              listScope?.padding?.resolve(
                Directionality.maybeOf(context) ?? TextDirection.ltr,
              ) ??
              EdgeInsets.zero;

          final itemRevealStart = viewport
              .getOffsetToReveal(renderObject, 0.0)
              .offset;
          final revealStart =
              (groupBox != null
                  ? viewport.getOffsetToReveal(groupBox, 0.0).offset
                  : itemRevealStart) -
              listPadding.top;
          final revealEnd =
              viewport.getOffsetToReveal(renderObject, 1.0).offset +
              listPadding.bottom;

          if (revealStart < revealEnd) {
            // Region is taller than viewport: align leading edge (show header/top)
            target = revealStart;
          } else if (position.pixels < revealEnd) {
            // Below viewport: scroll down just enough to reveal item bottom
            target = revealEnd;
          } else if (position.pixels > revealStart) {
            // Above viewport: scroll up just enough to reveal header (or item top)
            target = revealStart;
          }
        }

        if (target != null) {
          final clamped = target.clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          );
          if ((clamped - position.pixels).abs() > 0.5) {
            position.jumpTo(clamped);
          }
        }
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

        final listScope = CommandListScope.maybeOf(context);
        final effectiveSpacing =
            widget.spacing ?? groupScope?.spacing ?? listScope?.spacing ?? 0.0;

        var topPadding = 0.0;
        if (effectiveSpacing > 0) {
          final targetGroupId = groupScope?.groupId;
          final myIndex = controller.visibleItems.indexWhere(
            (i) => i.id == _entryId,
          );
          if (myIndex > 0) {
            for (var i = myIndex - 1; i >= 0; i--) {
              final prev = controller.visibleItems[i];
              if (targetGroupId != null) {
                if (prev.groupId == targetGroupId) {
                  topPadding = effectiveSpacing;
                  break;
                }
              } else {
                if (prev.groupId == null) {
                  topPadding = effectiveSpacing;
                  break;
                }
              }
            }
          }
        }

        // Keep the widget tree shape stable across builds to avoid element remounting.
        content = Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: content,
        );

        return Semantics(
          selected: isSelected,
          enabled: !widget.disabled,
          button: true,
          child: content,
        );
      },
    );
  }
}
