import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A declarative adapter over Flutter's dialog route. Requires a Navigator.
/// The widget occupies no layout space; [open] controls the modal route.
class CommandDialog extends StatefulWidget {
  const CommandDialog(
      {super.key,
      required this.open,
      this.onOpenChange,
      this.barrierColor = const Color(0x80000000),
      this.barrierDismissible = true,
      this.alignment = Alignment.center,
      this.padding = const EdgeInsets.all(24),
      this.maxWidth = 640,
      this.decoration,
      required this.child});
  final bool open;
  final ValueChanged<bool>? onOpenChange;
  final Color barrierColor;
  final bool barrierDismissible;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final Decoration? decoration;
  final Widget child;

  static Future<T?> show<T>(
      {required BuildContext context,
      required WidgetBuilder builder,
      bool barrierDismissible = true,
      Color barrierColor = const Color(0x80000000),
      Duration transitionDuration = const Duration(milliseconds: 150),
      Alignment alignment = Alignment.center,
      double maxWidth = 640,
      Decoration? decoration}) {
    return Navigator.of(context, rootNavigator: true).push<T>(RawDialogRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: 'Dismiss Command Dialog',
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      transitionDuration: MediaQuery.maybeOf(context)?.disableAnimations == true
          ? Duration.zero
          : transitionDuration,
      transitionBuilder: _transition,
      pageBuilder: (context, _, __) => _DialogSurface(
          alignment: alignment,
          maxWidth: maxWidth,
          decoration: decoration,
          onDismiss: () => Navigator.of(context).pop(),
          child: builder(context)),
    ));
  }

  static Widget _transition(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1).animate(curved),
            child: child));
  }

  @override
  State<CommandDialog> createState() => _CommandDialogState();
}

class _CommandDialogState extends State<CommandDialog> {
  late final ValueNotifier<CommandDialog> _configuration;
  RawDialogRoute<void>? _route;
  NavigatorState? _navigator;
  bool _scheduled = false;
  @override
  void initState() {
    super.initState();
    _configuration = ValueNotifier(widget);
    _scheduleSync();
  }

  @override
  void didUpdateWidget(CommandDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleSync();
  }

  void _scheduleSync() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      _configuration.value = widget;
      if (!widget.open) {
        _removeRoute();
        return;
      }
      if (_route != null) return;
      _navigator = Navigator.of(context, rootNavigator: true);
      final route = RawDialogRoute<void>(
          barrierDismissible:
              false, // The controlled parent decides whether to close.
          barrierColor: const Color(0x00000000),
          transitionDuration: Duration.zero,
          traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
          pageBuilder: (context, _, __) =>
              ValueListenableBuilder<CommandDialog>(
                valueListenable: _configuration,
                builder: (context, configuration, _) => PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, result) {
                      if (!didPop) configuration.onOpenChange?.call(false);
                    },
                    child: Stack(fit: StackFit.expand, children: [
                      ModalBarrier(
                          color: configuration.barrierColor,
                          dismissible: configuration.barrierDismissible,
                          semanticsLabel: 'Dismiss Command Dialog',
                          onDismiss: () =>
                              configuration.onOpenChange?.call(false)),
                      _DialogSurface(
                          alignment: configuration.alignment,
                          maxWidth: configuration.maxWidth,
                          padding: configuration.padding,
                          decoration: configuration.decoration,
                          onDismiss: () =>
                              configuration.onOpenChange?.call(false),
                          child: configuration.child),
                    ])),
              ));
      _route = route;
      _navigator!.push(route).then((_) {
        if (identical(_route, route)) {
          _route = null;
          if (mounted && widget.open) widget.onOpenChange?.call(false);
        }
      });
    });
  }

  void _removeRoute() {
    final route = _route;
    _route = null;
    if (route?.isActive == true) _navigator!.removeRoute(route!);
  }

  @override
  void dispose() {
    // Route removal mutates the Navigator; defer it until unmounting finishes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeRoute();
      _configuration.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _DialogSurface extends StatelessWidget {
  const _DialogSurface(
      {required this.child,
      required this.alignment,
      required this.maxWidth,
      required this.onDismiss,
      this.padding = const EdgeInsets.all(24),
      this.decoration});
  final Widget child;
  final Alignment alignment;
  final double maxWidth;
  final VoidCallback onDismiss;
  final EdgeInsetsGeometry padding;
  final Decoration? decoration;
  @override
  Widget build(BuildContext context) => FocusScope(
      autofocus: true,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onDismiss();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.maybeOf(context)?.viewInsets.bottom ?? 0),
          child: SafeArea(
              child: Align(
                  alignment: alignment,
                  child: Padding(
                      padding: padding,
                      child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: decoration == null
                              ? child
                              : DecoratedBox(
                                  decoration: decoration!, child: child)))))));
}
