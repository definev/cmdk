import 'package:flutter/widgets.dart';
import 'controller.dart';
import 'models.dart';

/// Provides controller identity. State subscriptions are explicit via
/// [CommandStateSelector], so unrelated state does not invalidate dependencies.
class CommandScope extends InheritedWidget {
  const CommandScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final CommandController controller;

  @override
  bool updateShouldNotify(CommandScope oldWidget) =>
      controller != oldWidget.controller;

  static CommandController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CommandScope>();
    assert(
      scope != null,
      'CommandScope.of() called with a context that does not contain a CommandScope. '
      'Make sure your widget is a descendant of a Command widget.',
    );
    return scope!.controller;
  }

  static CommandController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CommandScope>()
        ?.controller;
  }
}

/// InheritedWidget passing the current [CommandList] configuration.
class CommandListScope extends InheritedWidget {
  const CommandListScope({
    super.key,
    this.spacing = 0.0,
    required super.child,
  });

  final double spacing;

  static CommandListScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CommandListScope>();
  }

  @override
  bool updateShouldNotify(CommandListScope oldWidget) =>
      spacing != oldWidget.spacing;
}

/// InheritedWidget passing the current [groupId] and [forceMount] context.
class CommandGroupScope extends InheritedWidget {
  const CommandGroupScope({
    super.key,
    required this.groupId,
    this.forceMount = false,
    this.spacing = 0.0,
    required super.child,
  });

  final String groupId;
  final bool forceMount;
  final double spacing;

  static CommandGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CommandGroupScope>();
  }

  @override
  bool updateShouldNotify(CommandGroupScope oldWidget) {
    return groupId != oldWidget.groupId ||
        forceMount != oldWidget.forceMount ||
        spacing != oldWidget.spacing;
  }
}

/// A reactive selector widget mirroring `useCommandState` in cmdk.
/// Only rebuilds when the slice returned by [selector] changes.
class CommandStateSelector<T> extends StatefulWidget {
  const CommandStateSelector({
    super.key,
    required this.selector,
    required this.builder,
  });

  final T Function(CommandState state) selector;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<CommandStateSelector<T>> createState() =>
      _CommandStateSelectorState<T>();
}

class _CommandStateSelectorState<T> extends State<CommandStateSelector<T>> {
  CommandController? _controller;
  late T _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = CommandScope.of(context);
    if (_controller != controller) {
      _controller?.removeListener(_onStateChanged);
      _controller = controller;
      _controller?.addListener(_onStateChanged);
      _value = widget.selector(_controller!.snapshot);
    }
  }

  @override
  void didUpdateWidget(CommandStateSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.selector(_controller!.snapshot);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    final newValue = widget.selector(_controller!.snapshot);
    if (newValue != _value) {
      setState(() {
        _value = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value);
  }
}
