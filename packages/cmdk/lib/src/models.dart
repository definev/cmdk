import 'package:flutter/foundation.dart';

/// Metadata for a registered command item.
class ItemEntry {
  static const _unset = Object();
  const ItemEntry({
    required this.id,
    required this.value,
    this.keywords = const [],
    this.groupId,
    this.disabled = false,
    this.forceMount = false,
    this.onSelect,
    this.order = const [],
  });

  final String id;
  final String value;
  final List<String> keywords;
  final String? groupId;
  final bool disabled;
  final bool forceMount;
  final VoidCallback? onSelect;

  /// Source position assigned by the list adapter, independent of score order.
  final List<int> order;

  bool sameMetadata(ItemEntry other) =>
      value == other.value &&
      groupId == other.groupId &&
      disabled == other.disabled &&
      forceMount == other.forceMount &&
      listEquals(keywords, other.keywords) &&
      listEquals(order, other.order);

  ItemEntry copyWith({
    String? id,
    String? value,
    List<String>? keywords,
    Object? groupId = _unset,
    bool? disabled,
    bool? forceMount,
    Object? onSelect = _unset,
    List<int>? order,
  }) {
    return ItemEntry(
      id: id ?? this.id,
      value: value ?? this.value,
      keywords: keywords ?? this.keywords,
      groupId: identical(groupId, _unset) ? this.groupId : groupId as String?,
      disabled: disabled ?? this.disabled,
      forceMount: forceMount ?? this.forceMount,
      onSelect: identical(onSelect, _unset)
          ? this.onSelect
          : onSelect as VoidCallback?,
      order: order ?? this.order,
    );
  }
}

/// Immutable snapshot of the Command state.
@immutable
class CommandState {
  const CommandState({
    required this.search,
    required this.selectedValue,
    required this.selectedItemId,
    required this.filteredCount,
    required this.scores,
    required this.visibleGroupIds,
  });

  final String search;
  final String? selectedValue;
  final String? selectedItemId;
  final int filteredCount;
  final Map<String, double> scores;
  final Set<String> visibleGroupIds;

  bool isItemSelected(String value) => selectedValue == value;
  bool isGroupVisible(String groupId) => visibleGroupIds.contains(groupId);
  double getItemScore(String itemId) => scores[itemId] ?? 0.0;
}
