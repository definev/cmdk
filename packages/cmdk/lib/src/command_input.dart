import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'controller.dart';
import 'scope.dart';
import 'keyboard.dart';

/// Builds the editor inside [CommandInput]'s input area. The builder must wire
/// the supplied controller, focus node and both submission callbacks. It must
/// not dispose them. Query synchronization remains owned by [CommandInput].
typedef CommandInputEditorBuilder =
    Widget Function(BuildContext context, CommandInputEditor editor);

/// The editing session shared by a headless or framework-native editor.
///
/// Use the optional material.dart / cupertino.dart builders for Flutter's full
/// text selection gestures, handles, magnifier and context menu.
class CommandInputEditor {
  const CommandInputEditor._({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.style,
    required this.cursorColor,
    required this.backgroundCursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.showCursor,
    required this.onEditingComplete,
    required this.onSubmitted,
    required this.autocorrect,
    required this.enableSuggestions,
    required this.textCapitalization,
    required this.smartDashesType,
    required this.smartQuotesType,
    required this.keyboardAppearance,
    required this.scrollPadding,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextStyle style;
  final Color cursorColor;
  final Color backgroundCursorColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final bool? showCursor;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onSubmitted;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
}

/// Creates a default widgets-only editor builder using Flutter's core [EditableText].
///
/// Appearance properties such as [cursorColor], [cursorWidth], [cursorHeight],
/// [cursorRadius], [cursorOpacityAnimates], and [showCursor] can be configured
/// directly. Any omitted property defaults to the values passed by
/// [CommandInputEditor] from the enclosing [CommandInput].
CommandInputEditorBuilder defaultCommandInputEditorBuilder({
  Color? cursorColor,
  Color? backgroundCursorColor,
  double? cursorWidth,
  double? cursorHeight,
  Radius? cursorRadius,
  bool? cursorOpacityAnimates,
  bool? showCursor,
  TextStyle? style,
  Brightness? keyboardAppearance,
  EdgeInsets? scrollPadding,
}) =>
    (BuildContext context, CommandInputEditor editor) => EditableText(
      controller: editor.controller,
      focusNode: editor.focusNode,
      autofocus: editor.autofocus,
      style: style ?? editor.style,
      cursorColor: cursorColor ?? editor.cursorColor,
      backgroundCursorColor:
          backgroundCursorColor ?? editor.backgroundCursorColor,
      cursorWidth: cursorWidth ?? editor.cursorWidth,
      cursorHeight: cursorHeight ?? editor.cursorHeight,
      cursorRadius: cursorRadius ?? editor.cursorRadius,
      cursorOpacityAnimates:
          cursorOpacityAnimates ?? editor.cursorOpacityAnimates ?? false,
      showCursor: showCursor ?? editor.showCursor,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      autocorrect: editor.autocorrect,
      enableSuggestions: editor.enableSuggestions,
      textCapitalization: editor.textCapitalization,
      smartDashesType: editor.smartDashesType,
      smartQuotesType: editor.smartQuotesType,
      keyboardAppearance:
          keyboardAppearance ?? editor.keyboardAppearance ?? Brightness.light,
      scrollPadding: scrollPadding ?? editor.scrollPadding,
      onEditingComplete: editor.onEditingComplete,
      onSubmitted: editor.onSubmitted,
    );

/// A completely headless, unstyled search input for the command menu.
///
/// Built on Flutter's core [EditableText] and keyboard event handling.
class CommandInput extends StatefulWidget {
  const CommandInput({
    super.key,
    this.controller,
    this.focusNode,
    this.autofocus = true,
    this.placeholder = 'Search...',
    this.placeholderWidget,
    this.style,
    this.placeholderStyle,
    this.cursorColor = const Color(0xFF000000),
    this.backgroundCursorColor = const Color(0xFFE0E0E0),
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.showCursor,
    this.onValueChange,
    this.padding,
    this.decoration,
    this.prefix,
    this.suffix,
    this.onKeyEvent,
    this.editorBuilder,
    this.autocorrect = false,
    this.enableSuggestions = true,
    this.textCapitalization = TextCapitalization.none,
    this.smartDashesType = SmartDashesType.disabled,
    this.smartQuotesType = SmartQuotesType.disabled,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20),
    this.unfocusOnSubmit = false,
  });

  /// Optional external [TextEditingController].
  final TextEditingController? controller;

  /// Optional external [FocusNode].
  final FocusNode? focusNode;

  /// Whether the input should autofocus on build.
  final bool autofocus;

  /// Placeholder text string.
  final String placeholder;

  /// Custom widget to display when the input is empty.
  final Widget? placeholderWidget;

  /// Text style for input text.
  final TextStyle? style;

  /// Text style for placeholder text.
  final TextStyle? placeholderStyle;

  /// Cursor color.
  final Color cursorColor;

  /// Background cursor color for iOS style cursor.
  final Color backgroundCursorColor;

  /// Cursor width. Defaults to 2.0.
  final double cursorWidth;

  /// Optional cursor height.
  final double? cursorHeight;

  /// Optional cursor radius.
  final Radius? cursorRadius;

  /// Whether the cursor blinks with opacity animation.
  final bool? cursorOpacityAnimates;

  /// Whether to show the cursor.
  final bool? showCursor;

  /// Callback when the input text changes.
  final ValueChanged<String>? onValueChange;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Optional decoration (border, background, etc.).
  final Decoration? decoration;

  /// Optional prefix widget placed to the left of the text input (e.g. search icon).
  final Widget? prefix;

  /// Optional suffix widget placed to the right of the text input.
  final Widget? suffix;

  /// Optional callback to intercept key events before [CommandInput] processes them.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Replaces only the editor. Prefix, suffix, decoration, query ownership,
  /// keyboard scoping and IME guards stay with [CommandInput]. The default is
  /// [defaultCommandInputEditorBuilder]. For mobile, use
  /// [materialCommandInputBuilder] or [cupertinoCommandInputBuilder] from the
  /// corresponding optional library, or supply a native editor builder of your own.
  final CommandInputEditorBuilder? editorBuilder;

  /// Whether the keyboard may automatically correct command names.
  final bool autocorrect;

  /// Requests keyboard suggestions; the active IME ultimately decides what to show.
  final bool enableSuggestions;
  final TextCapitalization textCapitalization;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;

  /// If omitted, native adapters use the surrounding theme's brightness.
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;

  /// Whether a valid soft-keyboard submission unfocuses before invoking the
  /// command action. By default the user can keep typing while the panel stays
  /// open. This never requests focus again if an action navigates elsewhere.
  /// Physical Enter follows the command action's focus behavior.
  final bool unfocusOnSubmit;

  @override
  State<CommandInput> createState() => _CommandInputState();
}

class _CommandInputState extends State<CommandInput> {
  late TextEditingController _textController;
  bool _ownsTextController = false;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  CommandController? _commandController;
  bool _syncing = false;
  late String _lastText;
  bool _pendingReconciliation = false;

  bool get _isComposing =>
      _textController.value.composing.isValid &&
      !_textController.value.composing.isCollapsed;

  static const TextStyle _defaultStyle = TextStyle(
    fontSize: 14.0,
    color: Color(0xFF000000),
  );

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _textController = widget.controller!;
    } else {
      _textController = TextEditingController();
      _ownsTextController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode(
        debugLabel: 'CommandInputFocusNode',
      );
      _ownsFocusNode = true;
    }

    _lastText = _textController.text;
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cmd = CommandScope.of(context);
    if (_commandController != cmd) {
      _commandController?.removeListener(_syncFromCommand);
      _commandController = cmd;
      cmd.addListener(_syncFromCommand);
      _syncFromCommand(rebuild: false);
    }
  }

  void _syncFromCommand({bool rebuild = true, bool force = false}) {
    final search = _commandController!.search;
    if (_textController.text == search) {
      _pendingReconciliation = false;
      return;
    }
    // Do not replace a live IME buffer (including rejected controlled edits).
    // Reconcile the latest authoritative query after commit or focus loss.
    if (!force && _focusNode.hasFocus && _isComposing) {
      _pendingReconciliation = true;
      return;
    }
    _pendingReconciliation = false;
    _syncing = true;
    final selection = _textController.selection;
    _textController.value = TextEditingValue(
      text: search,
      selection: selection.copyWith(
        baseOffset: selection.baseOffset.clamp(0, search.length),
        extentOffset: selection.extentOffset.clamp(0, search.length),
      ),
    );
    _lastText = search;
    _syncing = false;
    if (rebuild && mounted) setState(() {});
  }

  @override
  void didUpdateWidget(CommandInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final old = _textController;
      old.removeListener(_onTextChanged);
      final owned = _ownsTextController;
      _ownsTextController = widget.controller == null;
      _textController =
          widget.controller ?? TextEditingController.fromValue(old.value);
      _lastText = _textController.text;
      _textController.addListener(_onTextChanged);
      if (owned) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
      _syncFromCommand(rebuild: false);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      final old = _focusNode;
      old.removeListener(_onFocusChanged);
      final owned = _ownsFocusNode;
      _ownsFocusNode = widget.focusNode == null;
      _focusNode =
          widget.focusNode ?? FocusNode(debugLabel: 'CommandInputFocusNode');
      _focusNode.addListener(_onFocusChanged);
      _syncFromCommand(rebuild: false);
      if (owned) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
  }

  @override
  void dispose() {
    _commandController?.removeListener(_syncFromCommand);
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsTextController) _textController.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_syncing) return;
    final text = _textController.text;
    if (text != _lastText) {
      _lastText = text;
      _commandController?.setSearch(text);
      widget.onValueChange?.call(text);
      // Controlled search can reject the edit. Reconcile after the parent has rebuilt.
      if (_commandController?.search != text) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncFromCommand();
        });
      }
      setState(() {});
    }
    if (_pendingReconciliation && !_isComposing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncFromCommand();
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _pendingReconciliation) {
      _syncFromCommand(force: true);
    }
  }

  void _completeEditing() {
    // EditableText's default completion clears composing and unfocuses before
    // onSubmitted. The command input owns that decision instead.
  }

  void _submit(String _) {
    if (_isComposing) return;
    final target = _focusNode.context;
    if (target == null) return;
    final invoke = Actions.handler(target, const CommandActivateIntent());
    if (invoke == null) return;
    if (widget.unfocusOnSubmit) _focusNode.unfocus();
    invoke();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.onKeyEvent != null) {
      final customResult = widget.onKeyEvent!(node, event);
      if (customResult != KeyEventResult.ignored) {
        return customResult;
      }
    }

    if (!_focusNode.hasFocus) return KeyEventResult.ignored;
    final composing = _textController.value.composing;
    if (composing.isValid && !composing.isCollapsed) {
      return KeyEventResult.skipRemainingHandlers;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? _defaultStyle;
    final effectivePlaceholderStyle = effectiveStyle.merge(
      widget.placeholderStyle ?? const TextStyle(color: Color(0xFF888888)),
    );
    final isEmpty = _textController.text.isEmpty;

    final editor = CommandInputEditor._(
      controller: _textController,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      style: effectiveStyle,
      cursorColor: widget.cursorColor,
      backgroundCursorColor: widget.backgroundCursorColor,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      showCursor: widget.showCursor,
      onEditingComplete: _completeEditing,
      onSubmitted: _submit,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      textCapitalization: widget.textCapitalization,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
    );

    Widget inputArea = Stack(
      alignment: Alignment.centerLeft,
      children: [
        if (isEmpty)
          widget.placeholderWidget ??
              Text(
                widget.placeholder,
                style: effectivePlaceholderStyle,
              ),
        CommandInputKeyboardScope(
          controller: _commandController!,
          textController: _textController,
          child: (widget.editorBuilder ?? defaultCommandInputEditorBuilder())(
            context,
            editor,
          ),
        ),
      ],
    );

    Widget content;
    if (widget.prefix != null || widget.suffix != null) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.prefix != null) widget.prefix!,
          Expanded(child: inputArea),
          if (widget.suffix != null) widget.suffix!,
        ],
      );
    } else {
      content = inputArea;
    }

    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: content);
    }

    if (widget.decoration != null) {
      content = DecoratedBox(decoration: widget.decoration!, child: content);
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKeyEvent,
      child: Semantics(
        hint: widget.placeholder,
        child: TextFieldTapRegion(child: content),
      ),
    );
  }
}
