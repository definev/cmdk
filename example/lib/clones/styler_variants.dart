import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:cmdk/cmdk.dart';

/// Context variant for selection state using Flutter's [WidgetState.selected].
final selectedVariant = ContextVariant.widgetState(WidgetState.selected);

/// Manual variant for copied notification badge state.
const copiedVariant = NamedVariant('copied');

/// Extension providing fluent `.onSelected(style)` variant support on all Mix stylers.
extension StylerVariantX<T extends Style<S>, S extends Spec<S>>
    on VariantStyleMixin<T, S> {
  /// Defines styling to be merged when [WidgetState.selected] is active in the context.
  T onSelected(T style) =>
      variant(ContextVariant.widgetState(WidgetState.selected), style);
}

/// Binds [CommandItemState] to Mix's [WidgetStateProvider] for descendant stylers.
///
/// Publishes [WidgetState.selected], [WidgetState.hovered], and [WidgetState.disabled]
/// into the widget tree so that `.onSelected()`, `.onHovered()`, and `.onDisabled()`
/// stylers can resolve their variants automatically.
class CommandItemStateProvider extends StatelessWidget {
  const CommandItemStateProvider({
    super.key,
    required this.state,
    required this.child,
  });

  final CommandItemState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WidgetStateProvider(
      states: {
        if (state.isSelected) WidgetState.selected,
        if (state.isHovered) WidgetState.hovered,
        if (state.isDisabled) WidgetState.disabled,
      },
      child: child,
    );
  }
}
