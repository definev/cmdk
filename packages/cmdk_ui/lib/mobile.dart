/// Mobile adapters and bottom sheet patterns for cmdk.
library;

import 'package:material_ui/material_ui.dart';

/// Shows a [Command] menu inside a mobile modal bottom sheet with automatic
/// keyboard insets handling, drag-to-dismiss support, and customizable presentation.
Future<T?> showCommandModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  double? elevation,
  ShapeBorder? shape,
  Clip clipBehavior = Clip.antiAlias,
  BoxConstraints? constraints,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  bool useSafeArea = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: (context) {
      final viewInsets = MediaQuery.of(context).viewInsets;
      return Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: builder(context),
      );
    },
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    elevation: elevation,
    shape:
        shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
    clipBehavior: clipBehavior,
    constraints: constraints,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
  );
}

/// A container widget designed for mobile bottom sheet presentations of [Command].
///
/// Automatically adjusts layout to avoid the software keyboard and provides
/// an optional drag handle.
class CommandBottomSheet extends StatelessWidget {
  const CommandBottomSheet({
    super.key,
    required this.child,
    this.maxHeightFraction = 0.85,
    this.showDragHandle = true,
    this.dragHandleColor,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(16.0)),
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxHeightFraction;
  final bool showDragHandle;
  final Color? dragHandleColor;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * maxHeightFraction;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDragHandle)
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color:
                        dragHandleColor ??
                        Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
            Flexible(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
