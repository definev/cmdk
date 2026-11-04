import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'command_score.dart';
import 'models.dart';

/// One catalog and one result order shared by layout, filtering and navigation.
class CommandController extends ChangeNotifier {
  CommandController({
    String? value,
    String? search,
    bool shouldFilter = true,
    bool loop = false,
    bool vimBindings = true,
    bool disablePointerSelection = false,
    CommandFilter? filter,
    this.onValueChange,
    this.onSearchChange,
  }) : _loop = loop,
       _vimBindings = vimBindings,
       _disablePointerSelection = disablePointerSelection,
       _selectedValue = value?.trim(),
       _search = search ?? '',
       _shouldFilter = shouldFilter,
       _filter = filter ?? defaultFilter;

  static double defaultFilter(
    String value,
    String search, [
    List<String>? keywords,
  ]) => commandScore(value, search, keywords);
  bool _loop;
  bool get loop => _binding?.loop ?? _loop;
  set loop(bool value) => _loop = value;
  bool _vimBindings;
  bool get vimBindings => _binding?.vimBindings ?? _vimBindings;
  set vimBindings(bool value) {
    if (_vimBindings == value) return;
    _vimBindings = value;
    _emit();
  }

  bool _disablePointerSelection;
  bool get disablePointerSelection =>
      _binding?.disablePointerSelection ?? _disablePointerSelection;
  set disablePointerSelection(bool value) => _disablePointerSelection = value;
  ValueChanged<String?>? onValueChange;
  ValueChanged<String>? onSearchChange;
  bool _shouldFilter;
  bool get shouldFilter => _binding?.shouldFilter ?? _shouldFilter;
  set shouldFilter(bool value) {
    if (value == _shouldFilter) return;
    _shouldFilter = value;
    _invalidate();
    _refreshConfiguration();
  }

  CommandFilter _filter;
  CommandFilter get filter => _binding?.filter ?? _filter;
  set filter(CommandFilter value) {
    if (value == _filter) return;
    _filter = value;
    _invalidate();
    _refreshConfiguration();
  }

  void _refreshConfiguration() {
    _batch(() {
      if (_items.isNotEmpty) _reconcileSelection();
      _emit();
    });
  }

  String _search;
  String get search => _search;
  String? _selectedValue;
  String? get selectedValue => _selectedValue;
  String? get selectedItemId {
    _compute();
    for (final item in _ordered) {
      if (item.value == _selectedValue && !item.disabled) return item.id;
    }
    return null;
  }

  final Map<String, ItemEntry> _items = {};
  final Map<String, bool> _groups = {};
  final Map<String, double> _scores = {};
  final Set<String> _visibleGroups = {};
  List<ItemEntry> _ordered = [];
  bool _dirty = true;
  bool _scheduled = false;
  bool _scrollAfterPublish = false;
  bool _pendingScrollIntoView = true;
  String? _pendingScrollValue;
  bool _resetSelectionAfterPublish = false;
  int _batchDepth = 0;
  bool _pendingNotification = false;
  bool _disposed = false;
  CommandState? _snapshot;

  /// Scroll requests are events: repeated requests for the same item still fire.
  final ValueNotifier<String?> scrollRequestedId = ValueNotifier(null);
  int get filteredCount {
    _compute();
    return _ordered.length;
  }

  double itemScore(String id) {
    _compute();
    return _scores[id] ?? 0;
  }

  CommandState get snapshot => _snapshot ??= CommandState(
    search: search,
    selectedValue: selectedValue,
    selectedItemId: selectedItemId,
    filteredCount: filteredCount,
    scores: Map.unmodifiable(_scores),
    visibleGroupIds: Set.unmodifiable(_visibleGroups),
  );

  // A Command owns this binding, never the callbacks/configuration of an external controller.
  CommandBinding? _binding;
  void attach(CommandBinding binding) {
    assert(
      _binding == null || identical(_binding!.owner, binding.owner),
      'A controller can only be attached to one Command.',
    );
    final previousFilter = filter;
    final previousShouldFilter = shouldFilter;
    _binding = binding;
    var changed =
        previousFilter != filter || previousShouldFilter != shouldFilter;
    if (changed) _invalidate();
    var valueChanged = false;
    var searchChanged = false;
    if (binding.value != null && binding.value!.trim() != _selectedValue) {
      _selectedValue = binding.value!.trim();
      valueChanged = true;
      changed = true;
    }
    if (binding.search != null && binding.search != _search) {
      _search = binding.search!;
      _resetSelectionAfterPublish = true;
      _invalidate();
      searchChanged = true;
      changed = true;
    }
    if (changed) {
      if (searchChanged) {
        _scrollAfterPublish = true;
      } else if (valueChanged) {
        if (_pendingScrollValue == _selectedValue) {
          _scrollAfterPublish = _pendingScrollIntoView;
        } else {
          _scrollAfterPublish = false;
        }
      }
      _pendingScrollValue = null;
      _pendingScrollIntoView = true;
      _snapshot = null;
      _scheduleLifecycleNotify();
    }
  }

  void detach(Object owner) {
    if (identical(_binding?.owner, owner)) {
      _binding = null;
      _invalidate();
      _scheduleLifecycleNotify();
    }
  }

  void setSearch(String query) {
    if (query == _search) return;
    if (_binding?.search == null) {
      _batch(() {
        _search = query;
        _invalidate();
        _selectFirstValidItem();
        _requestScroll();
        _emit();
      });
    }
    onSearchChange?.call(query);
    _binding?.onSearchChange?.call(query);
  }

  void selectValue(String? value, {bool scrollIntoView = true}) {
    final next = value?.trim();
    if (next == _selectedValue) return;
    _pendingScrollValue = next;
    _pendingScrollIntoView = scrollIntoView;
    if (_binding?.value == null) {
      _selectedValue = next;
      _snapshot = null;
      if (scrollIntoView) _requestScroll();
      _emit();
    }
    onValueChange?.call(next);
    _binding?.onValueChange?.call(next);
  }

  void selectItemId(String id, {bool scrollIntoView = true}) {
    final item = _items[id];
    if (item != null && !item.disabled && isItemVisible(id)) {
      selectValue(item.value, scrollIntoView: scrollIntoView);
    }
  }

  void _requestScroll() {
    // A controlled selection is committed by attach(). Until then, the old
    // item may occupy a different position in the newly filtered results.
    if (_binding?.value != null &&
        _pendingScrollValue != null &&
        _pendingScrollValue != _selectedValue) {
      return;
    }
    scrollRequestedId.value = null;
    scrollRequestedId.value = selectedItemId;
  }

  void _invalidate() {
    _dirty = true;
    _snapshot = null;
  }

  void _batch(VoidCallback action) {
    _batchDepth++;
    try {
      action();
    } finally {
      _batchDepth--;
      if (_batchDepth == 0 && _pendingNotification) {
        _pendingNotification = false;
        _emit();
      }
    }
  }

  void _emit() {
    if (_disposed) return;
    _snapshot = null;
    if (_batchDepth > 0) {
      _pendingNotification = true;
    } else {
      notifyListeners();
    }
  }

  /// Idempotent registration. Widget adapters batch lifecycle mutations per frame.
  void registerItem(ItemEntry item) {
    if (_disposed) return;
    if (item.id.isEmpty || item.value.trim().isEmpty) {
      throw ArgumentError('Command item IDs and values must be non-empty.');
    }
    final old = _items[item.id];
    item = item.copyWith(
      value: item.value.trim(),
      keywords: List.unmodifiable(item.keywords),
      order: List.unmodifiable(item.order),
    );
    _items[item.id] = item;
    if (old != null && old.sameMetadata(item)) {
      if (old.onSelect != item.onSelect) {
        _ordered = List.unmodifiable(
          _ordered.map((entry) => entry.id == item.id ? item : entry),
        );
      }
      return;
    }
    _invalidate();
    _scheduleLifecycleNotify();
  }

  void updateItem(ItemEntry item) => registerItem(item);
  void unregisterItem(String id) {
    if (_disposed || _items.remove(id) == null) return;
    _invalidate();
    _scheduleLifecycleNotify();
  }

  void registerGroup(String id, {bool forceMount = false}) {
    if (_disposed || (_groups.containsKey(id) && _groups[id] == forceMount)) {
      return;
    }
    _groups[id] = forceMount;
    _invalidate();
    _scheduleLifecycleNotify();
  }

  void unregisterGroup(String id) {
    if (_disposed || _groups.remove(id) == null) return;
    _invalidate();
    _scheduleLifecycleNotify();
  }

  void _scheduleLifecycleNotify() {
    if (_disposed || _scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (_disposed) return;
      assert(
        _items.values.map((item) => item.value).toSet().length == _items.length,
        'Item values must be unique within a Command.',
      );
      _batch(() {
        if (_resetSelectionAfterPublish && _binding?.value == null) {
          _selectFirstValidItem();
        } else {
          _reconcileSelection();
        }
        _resetSelectionAfterPublish = false;
        if (_scrollAfterPublish) {
          _scrollAfterPublish = false;
          _requestScroll();
        }
        _emit();
      });
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _reconcileSelection() {
    _compute();
    if (_binding?.value != null) return;
    if (_selectedValue == null ||
        !_items.values.any((i) => i.value == _selectedValue)) {
      _selectFirstValidItem();
    } else if (_items.values.any(
      (i) => i.value == _selectedValue && (i.disabled || !isItemVisible(i.id)),
    )) {
      _selectFirstValidItem();
    }
  }

  void _selectFirstValidItem() {
    final valid = getSortedValidItems();
    selectValue(valid.isEmpty ? null : valid.first.value);
  }

  void _compute() {
    if (!_dirty) return;
    _dirty = false;
    _scores.clear();
    _visibleGroups.clear();
    final root = _ResultBranch();
    var index = 0;
    for (final item in _items.values) {
      final score = !shouldFilter || search.isEmpty
          ? 1.0
          : filter(item.value, search, item.keywords);
      _scores[item.id] = score;
      if (score > 0 || item.forceMount) {
        if (item.groupId != null) _visibleGroups.add(item.groupId!);
        var branch = root;
        for (final part in item.order.isEmpty ? [index] : item.order) {
          branch = branch.children.putIfAbsent(part, _ResultBranch.new);
        }
        branch.items.add(item);
        branch.score = score > branch.score ? score : branch.score;
      }
      index++;
    }
    _groups.forEach((id, force) {
      if (force || !shouldFilter || search.isEmpty) _visibleGroups.add(id);
    });
    _ordered = List.unmodifiable(
      root.flatten(shouldFilter && search.isNotEmpty),
    );
  }

  bool isItemVisible(String id) {
    _compute();
    return _items.containsKey(id) &&
        ((_scores[id] ?? 0) > 0 || _items[id]!.forceMount);
  }

  bool isGroupVisible(String id) {
    _compute();
    return !shouldFilter || search.isEmpty || _visibleGroups.contains(id);
  }

  List<ItemEntry> get visibleItems {
    _compute();
    return _ordered;
  }

  List<ItemEntry> getSortedValidItems() =>
      visibleItems.where((i) => !i.disabled).toList(growable: false);

  void nextItem({bool isAlt = false, bool isMeta = false}) =>
      _move(1, isAlt: isAlt, isMeta: isMeta);
  void prevItem({bool isAlt = false, bool isMeta = false}) =>
      _move(-1, isAlt: isAlt, isMeta: isMeta);
  void _move(int direction, {bool isAlt = false, bool isMeta = false}) {
    if (isMeta) {
      direction > 0 ? lastItem() : firstItem();
      return;
    }
    final valid = getSortedValidItems();
    if (valid.isEmpty) return;
    final current = valid.indexWhere((i) => i.value == _selectedValue);
    if (isAlt && current >= 0) {
      final group = valid[current].groupId;
      for (
        var i = current + direction;
        i >= 0 && i < valid.length;
        i += direction
      ) {
        if (valid[i].groupId != group) {
          final target = valid[i].groupId;
          selectValue(valid.firstWhere((item) => item.groupId == target).value);
          return;
        }
      }
    }
    var next = current < 0 ? 0 : current + direction;
    if (loop) next = (next + valid.length) % valid.length;
    if (next >= 0 && next < valid.length) selectValue(valid[next].value);
  }

  void firstItem() {
    final valid = getSortedValidItems();
    if (valid.isNotEmpty) selectValue(valid.first.value);
  }

  void lastItem() {
    final valid = getSortedValidItems();
    if (valid.isNotEmpty) selectValue(valid.last.value);
  }

  void selectCurrent() {
    final id = selectedItemId;
    if (id != null) _items[id]?.onSelect?.call();
  }

  @override
  void dispose() {
    _disposed = true;
    _binding = null;
    scrollRequestedId.dispose();
    _items.clear();
    _groups.clear();
    _scores.clear();
    _visibleGroups.clear();
    _ordered = const [];
    _snapshot = null;
    super.dispose();
  }
}

/// Layout branches preserve wrapped blocks while ranking siblings by best match.
class _ResultBranch {
  final Map<int, _ResultBranch> children = {};
  final List<ItemEntry> items = [];
  double score = 0;
  List<ItemEntry> flatten(bool rank) {
    final branches = children.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final results = <int, List<ItemEntry>>{};
    for (final entry in branches) {
      results[entry.key] = entry.value.flatten(rank);
      if (entry.value.score > score) score = entry.value.score;
    }
    if (rank) {
      branches.sort((a, b) {
        final comparison = b.value.score.compareTo(a.value.score);
        return comparison == 0 ? a.key.compareTo(b.key) : comparison;
      });
    }
    return [...items, for (final entry in branches) ...results[entry.key]!];
  }
}

/// Internal root binding; values supplied by the parent stay authoritative.
class CommandBinding {
  const CommandBinding({
    required this.owner,
    this.value,
    this.search,
    this.onValueChange,
    this.onSearchChange,
    this.shouldFilter,
    this.filter,
    this.loop,
    this.vimBindings,
    this.disablePointerSelection,
  });
  final Object owner;
  final String? value;
  final String? search;
  final ValueChanged<String?>? onValueChange;
  final ValueChanged<String>? onSearchChange;
  final bool? shouldFilter;
  final CommandFilter? filter;
  final bool? loop;
  final bool? vimBindings;
  final bool? disablePointerSelection;
}
