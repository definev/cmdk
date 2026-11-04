import 'package:flutter/widgets.dart';
import 'collection.dart';
import 'command_item.dart';
import 'controller.dart';
import 'models.dart';
import 'scope.dart';
import 'render_sizer.dart';

/// Builds a scrollbar around the list content using the active [ScrollController].
typedef CommandScrollbarBuilder =
    Widget Function(
      BuildContext context,
      Widget child,
      ScrollController scrollController,
    );

/// A composable eager list, or a data-backed virtual list.
class CommandList extends StatefulWidget {
  const CommandList({
    super.key,
    this.scrollController,
    this.physics,
    this.padding,
    this.animateHeight = false,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOutCubic,
    this.shrinkWrap = true,
    this.label = 'Suggestions',
    this.spacing = 0.0,
    this.scrollbarBuilder,
    required this.children,
  }) : items = null,
       itemBuilder = null,
       itemExtent = null;

  /// The entire catalog is available to search and navigation before rows mount.
  /// Fixed extent allows scrolling to unbuilt results without estimating heights.
  const CommandList.builder({
    super.key,
    this.scrollController,
    this.physics,
    this.padding,
    this.animateHeight = false,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOutCubic,
    this.shrinkWrap = false,
    this.label = 'Suggestions',
    this.spacing = 0.0,
    this.scrollbarBuilder,
    required List<ItemEntry> this.items,
    required Widget Function(BuildContext, ItemEntry, CommandItemState)
    this.itemBuilder,
    required double this.itemExtent,
  }) : children = const [],
       assert(itemExtent > 0);

  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool animateHeight;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool shrinkWrap;
  final String label;
  final double spacing;
  final CommandScrollbarBuilder? scrollbarBuilder;
  final List<Widget> children;
  final List<ItemEntry>? items;
  final Widget Function(BuildContext, ItemEntry, CommandItemState)? itemBuilder;
  final double? itemExtent;
  @override
  State<CommandList> createState() => _CommandListState();
}

class _CommandListState extends State<CommandList> {
  CommandController? _controller;
  final _ownedScroll = ScrollController();
  final Set<String> _registered = {};
  ScrollController get _scroll => widget.scrollController ?? _ownedScroll;
  List<int> _prefix = const [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = CommandScope.of(context);
    if (_controller != controller) {
      _unregister();
      _controller = controller;
      controller.scrollRequestedId.addListener(_scrollToItem);
    }
    _prefix = CommandPosition.maybeOf(context)?.order ?? const [];
    _syncCatalog();
  }

  @override
  void didUpdateWidget(CommandList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCatalog();
  }

  void _syncCatalog() {
    final entries = widget.items ?? const <ItemEntry>[];
    assert(
      entries.map((i) => i.id).toSet().length == entries.length,
      'Item IDs must be unique.',
    );
    assert(
      entries.map((i) => i.value.trim()).toSet().length == entries.length,
      'Item values must be unique.',
    );
    final next = entries.map((i) => i.id).toSet();
    for (final id in _registered.difference(next)) {
      _controller?.unregisterItem(id);
    }
    for (var i = 0; i < entries.length; i++) {
      _controller?.registerItem(
        entries[i].copyWith(
          order: [..._prefix, i],
          keywords: List.unmodifiable(entries[i].keywords),
        ),
      );
    }
    _registered
      ..clear()
      ..addAll(next);
  }

  void _unregister() {
    _controller?.scrollRequestedId.removeListener(_scrollToItem);
    for (final id in _registered) {
      _controller?.unregisterItem(id);
    }
    _registered.clear();
  }

  void _scrollToItem() {
    if (widget.items == null) return;
    final id = _controller?.scrollRequestedId.value;
    if (id == null || !_registered.contains(id)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final visible = _controller!.visibleItems
          .where((i) => _registered.contains(i.id))
          .toList();
      final index = visible.indexWhere((i) => i.id == id);
      if (index < 0) return;
      final position = _scroll.position;
      final padding =
          widget.padding?.resolve(Directionality.of(context)).top ?? 0;
      final start = padding + index * widget.itemExtent!;
      final end = start + widget.itemExtent!;
      double? target;
      if (index == 0) {
        target = position.minScrollExtent;
      } else if (index == visible.length - 1) {
        target = position.maxScrollExtent;
      } else if (start < position.pixels) {
        target = start;
      } else if (end > position.pixels + position.viewportDimension) {
        target = end - position.viewportDimension;
      }
      if (target != null) {
        _scroll.jumpTo(
          target.clamp(position.minScrollExtent, position.maxScrollExtent),
        );
      }
    });
  }

  @override
  void dispose() {
    _unregister();
    _ownedScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller!,
      builder: (context, _) {
        Widget content;
        if (widget.items != null) {
          final entries = _controller!.visibleItems
              .where((i) => _registered.contains(i.id))
              .toList();
          final indices = {
            for (var i = 0; i < entries.length; i++) entries[i].id: i,
          };
          content = ListView.builder(
            controller: _scroll,
            physics: widget.physics,
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            itemExtent: widget.itemExtent,
            itemCount: entries.length,
            findChildIndexCallback: (key) =>
                key is ValueKey<String> ? indices[key.value] : null,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return CommandPosition(
                key: ValueKey(entry.id),
                order: entry.order,
                entry: entry,
                child: CommandItem(
                  value: entry.value,
                  disabled: entry.disabled,
                  forceMount: entry.forceMount,
                  onSelect: entry.onSelect,
                  builder: (context, state) =>
                      widget.itemBuilder!(context, entry, state),
                ),
              );
            },
          );
        } else {
          content = SingleChildScrollView(
            controller: _scroll,
            physics: widget.physics,
            padding: widget.padding,
            child: CommandListScope(
              spacing: widget.spacing,
              padding: widget.padding,
              child: CommandCollection(children: widget.children),
            ),
          );
        }
        if (widget.scrollbarBuilder != null) {
          content = widget.scrollbarBuilder!(context, content, _scroll);
        }
        if (widget.animateHeight) {
          content = CommandListSizer(
            duration: widget.animationDuration,
            curve: widget.animationCurve,
            child: content,
          );
        }
        return Semantics(container: true, label: widget.label, child: content);
      },
    );
  }
}
