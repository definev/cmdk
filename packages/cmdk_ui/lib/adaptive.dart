/// Adaptive platform-aware widgets and builders for cmdk.
library;

import 'package:cmdk/cmdk.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' as material;
import 'cupertino.dart';
import 'material.dart';

/// Automatically selects [cupertinoCommandInputBuilder] on iOS/macOS and
/// [materialCommandInputBuilder] on other platforms.
CommandInputEditorBuilder adaptiveCommandInputBuilder({
  Color? cursorColor,
  double? cursorWidth,
  double? cursorHeight,
  Radius? cursorRadius,
  bool? cursorOpacityAnimates,
  bool? showCursor,
  TextStyle? style,
  Brightness? keyboardAppearance,
  EdgeInsets? scrollPadding,
}) => (BuildContext context, CommandInputEditor editor) {
  final platform = material.Theme.of(context).platform;
  final isApple =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  if (isApple) {
    return cupertinoCommandInputBuilder(
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorOpacityAnimates: cursorOpacityAnimates,
      showCursor: showCursor,
      style: style,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
    )(context, editor);
  } else {
    return materialCommandInputBuilder(
      cursorColor: cursorColor,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorOpacityAnimates: cursorOpacityAnimates,
      showCursor: showCursor,
      style: style,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
    )(context, editor);
  }
};

/// An adaptive, platform-aware search input for mobile and desktop [Command] menus.
///
/// Automatically switches between iOS/macOS Cupertino conventions (Cupertino text field,
/// selection handles, clear button, magnifier) and Android/Material conventions
/// (Material text field, ripple clear button, theme typography).
///
/// Features built-in:
/// - Native text editing engine with selection magnifier and clipboard actions
/// - Adaptive reactive clear button (shows when query is not empty)
/// - Optional cancel button for modal search presentations
/// - Mobile touch target sizing (default 44px min height)
/// - Adaptive filled/unfilled styling with system fill colors
class AdaptiveCommandInput extends StatefulWidget {
  const AdaptiveCommandInput({
    super.key,
    this.controller,
    this.focusNode,
    this.autofocus = true,
    this.placeholder = 'Search...',
    this.placeholderWidget,
    this.style,
    this.placeholderStyle,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.showCursor,
    this.onValueChange,
    this.padding,
    this.decoration,
    this.filled = false,
    this.fillColor,
    this.borderRadius,
    this.prefix,
    this.suffix,
    this.showClearButton = true,
    this.clearIcon,
    this.clearButtonColor,
    this.showCancelButton = false,
    this.cancelButtonLabel = 'Cancel',
    this.cancelButtonStyle,
    this.onCancel,
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
    this.platform,
    this.minHeight = 44.0,
  });

  /// Optional external [TextEditingController]. If omitted, one is managed internally.
  final TextEditingController? controller;

  /// Optional external [FocusNode].
  final FocusNode? focusNode;

  /// Whether the input should autofocus when mounted.
  final bool autofocus;

  /// Placeholder text string. Defaults to 'Search...'.
  final String placeholder;

  /// Custom widget to display when the input is empty.
  final Widget? placeholderWidget;

  /// Text style for input text.
  final TextStyle? style;

  /// Text style for placeholder text.
  final TextStyle? placeholderStyle;

  /// Cursor color. Defaults to the platform's primary color.
  final Color? cursorColor;

  /// Cursor width. Defaults to 1.5.
  final double? cursorWidth;

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

  /// Inner padding around the search field.
  final EdgeInsetsGeometry? padding;

  /// Explicit custom decoration. Overrides [filled] and [fillColor].
  final Decoration? decoration;

  /// Whether to render a platform-styled background container (pill/rect).
  final bool filled;

  /// Custom background fill color when [filled] is true.
  final Color? fillColor;

  /// Border radius when [filled] is true.
  final BorderRadius? borderRadius;

  /// Optional prefix widget placed to the left of the text input.
  final Widget? prefix;

  /// Custom suffix widget placed to the right of the text input.
  final Widget? suffix;

  /// Whether to automatically show an adaptive clear button when text is non-empty.
  final bool showClearButton;

  /// Custom icon data for the clear button.
  final IconData? clearIcon;

  /// Color for the clear button icon.
  final Color? clearButtonColor;

  /// Whether to display a trailing cancel button (common in iOS modal search).
  final bool showCancelButton;

  /// Label for the cancel button. Defaults to 'Cancel'.
  final String cancelButtonLabel;

  /// Style for the cancel button text.
  final TextStyle? cancelButtonStyle;

  /// Callback when the cancel button is tapped.
  final VoidCallback? onCancel;

  /// Key event interceptor.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Custom editor builder override.
  final CommandInputEditorBuilder? editorBuilder;

  /// Whether the keyboard may automatically correct text.
  final bool autocorrect;

  /// Whether keyboard suggestions are requested.
  final bool enableSuggestions;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Smart dashes configuration.
  final SmartDashesType smartDashesType;

  /// Smart quotes configuration.
  final SmartQuotesType smartQuotesType;

  /// Keyboard appearance brightness.
  final Brightness? keyboardAppearance;

  /// Scroll padding for keyboard insets.
  final EdgeInsets scrollPadding;

  /// Whether soft-keyboard submission unfocuses before invoking action.
  final bool unfocusOnSubmit;

  /// Target platform override. If null, adapts to surrounding theme or OS.
  final TargetPlatform? platform;

  /// Minimum height to ensure touch target accessibility. Defaults to 44.0.
  final double minHeight;

  @override
  State<AdaptiveCommandInput> createState() => _AdaptiveCommandInputState();
}

class _AdaptiveCommandInputState extends State<AdaptiveCommandInput> {
  TextEditingController? _internalController;
  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hasText = _effectiveController.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(AdaptiveCommandInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _effectiveController.removeListener(_onTextChanged);
        _internalController?.dispose();
        _internalController = null;
      } else {
        oldWidget.controller!.removeListener(_onTextChanged);
      }

      if (widget.controller == null) {
        _internalController = TextEditingController();
      }
      _effectiveController.addListener(_onTextChanged);
      _hasText = _effectiveController.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.removeListener(_onTextChanged);
      _internalController?.dispose();
    } else {
      widget.controller!.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (_hasText != hasText) {
      _hasText = hasText;
      if (!mounted) return;
      final phase = SchedulerBinding.instance.schedulerPhase;
      final isBuilding =
          phase == SchedulerPhase.persistentCallbacks ||
          phase == SchedulerPhase.midFrameMicrotasks;
      if (isBuilding) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      } else {
        setState(() {});
      }
    }
  }

  void _clearText() {
    _effectiveController.clear();
  }

  TargetPlatform _resolvePlatform(BuildContext context) {
    if (widget.platform != null) return widget.platform!;
    return material.Theme.of(context).platform;
  }

  bool _isApplePlatform(TargetPlatform platform) {
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  bool _isDarkMode(TargetPlatform platform, BuildContext context) {
    if (_isApplePlatform(platform)) {
      return cupertino.CupertinoTheme.maybeBrightnessOf(context) ==
          Brightness.dark;
    }
    return material.Theme.of(context).brightness == Brightness.dark;
  }

  Color _resolveCursorColor(bool isApple, BuildContext context) {
    if (widget.cursorColor != null) return widget.cursorColor!;
    if (isApple) {
      final cupertinoTheme = cupertino.CupertinoTheme.of(context);
      return cupertinoTheme.primaryColor;
    } else {
      final theme = material.Theme.of(context);
      return theme.colorScheme.primary;
    }
  }

  TextStyle? _resolvePlaceholderStyle(
    bool isApple,
    bool isDark,
    BuildContext context,
  ) {
    if (widget.placeholderStyle != null) return widget.placeholderStyle;
    if (isApple) {
      return TextStyle(
        color: isDark ? const Color(0x99EBEBF5) : const Color(0x993C3C43),
      );
    } else {
      final theme = material.Theme.of(context);
      final color = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
      return TextStyle(color: color);
    }
  }

  Color _resolveMutedColor(bool isApple, bool isDark, BuildContext context) {
    if (isApple) {
      return isDark ? const Color(0x99EBEBF5) : const Color(0x993C3C43);
    } else {
      final theme = material.Theme.of(context);
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  Decoration? _resolveDecoration(
    bool isApple,
    bool isDark,
    BuildContext context,
  ) {
    if (widget.decoration != null) return widget.decoration;
    if (!widget.filled) return null;

    if (widget.fillColor != null) {
      return BoxDecoration(
        color: widget.fillColor,
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(isApple ? 10.0 : 12.0),
      );
    }

    if (isApple) {
      return BoxDecoration(
        color: isDark ? const Color(0x3D767680) : const Color(0x1F767680),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(10.0),
      );
    } else {
      final theme = material.Theme.of(context);
      final color = theme.colorScheme.surfaceContainerHighest;
      return BoxDecoration(
        color: color,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12.0),
      );
    }
  }

  EdgeInsetsGeometry _resolvePadding(bool isApple) {
    if (widget.padding != null) return widget.padding!;
    if (widget.filled) {
      return EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: isApple ? 7.0 : 6.0,
      );
    }
    return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);
  }

  Widget? _buildSuffix(bool isApple, Color mutedColor) {
    if (widget.suffix != null) return widget.suffix;
    if (!widget.showClearButton || !_hasText) return null;

    final color = widget.clearButtonColor ?? mutedColor;
    if (isApple) {
      return cupertino.CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        minimumSize: const Size.square(32.0),
        onPressed: _clearText,
        child: Icon(
          widget.clearIcon ?? cupertino.CupertinoIcons.clear_thick_circled,
          size: 16.0,
          color: color,
        ),
      );
    } else {
      return material.InkResponse(
        canRequestFocus: false,
        radius: 18.0,
        onTap: _clearText,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          child: Icon(
            widget.clearIcon ?? material.Icons.cancel,
            size: 18.0,
            color: color,
          ),
        ),
      );
    }
  }

  Widget? _buildCancelButton(bool isApple) {
    if (!widget.showCancelButton) return null;

    if (isApple) {
      return cupertino.CupertinoButton(
        padding: const EdgeInsets.only(left: 8.0, right: 4.0),
        minimumSize: const Size.square(36.0),
        onPressed: widget.onCancel,
        child: Text(
          widget.cancelButtonLabel,
          style: widget.cancelButtonStyle,
        ),
      );
    } else {
      return material.TextButton(
        onPressed: widget.onCancel,
        style: widget.cancelButtonStyle != null
            ? material.TextButton.styleFrom(textStyle: widget.cancelButtonStyle)
            : null,
        child: Text(widget.cancelButtonLabel),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = _resolvePlatform(context);
    final isApple = _isApplePlatform(platform);
    final isDark = _isDarkMode(platform, context);
    final mutedColor = _resolveMutedColor(isApple, isDark, context);

    final suffixWidget = _buildSuffix(isApple, mutedColor);
    final effectiveDecoration = _resolveDecoration(isApple, isDark, context);
    final effectivePadding = _resolvePadding(isApple);
    final effectiveCursorColor = _resolveCursorColor(isApple, context);
    final effectivePlaceholderStyle = _resolvePlaceholderStyle(
      isApple,
      isDark,
      context,
    );

    final editorBuilder =
        widget.editorBuilder ??
        (isApple
            ? cupertinoCommandInputBuilder(
                cursorColor: effectiveCursorColor,
                cursorWidth: widget.cursorWidth,
                cursorHeight: widget.cursorHeight,
                cursorRadius: widget.cursorRadius,
                cursorOpacityAnimates: widget.cursorOpacityAnimates,
                showCursor: widget.showCursor,
                style: widget.style,
                keyboardAppearance: widget.keyboardAppearance,
                scrollPadding: widget.scrollPadding,
              )
            : materialCommandInputBuilder(
                cursorColor: effectiveCursorColor,
                cursorWidth: widget.cursorWidth,
                cursorHeight: widget.cursorHeight,
                cursorRadius: widget.cursorRadius,
                cursorOpacityAnimates: widget.cursorOpacityAnimates,
                showCursor: widget.showCursor,
                style: widget.style,
                keyboardAppearance: widget.keyboardAppearance,
                scrollPadding: widget.scrollPadding,
              ));

    Widget input = ConstrainedBox(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      child: CommandInput(
        controller: _effectiveController,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        placeholder: widget.placeholder,
        placeholderWidget: widget.placeholderWidget,
        style: widget.style,
        placeholderStyle: effectivePlaceholderStyle,
        cursorColor: effectiveCursorColor,
        cursorWidth: widget.cursorWidth ?? 1.5,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorOpacityAnimates: widget.cursorOpacityAnimates,
        showCursor: widget.showCursor,
        onValueChange: widget.onValueChange,
        padding: effectivePadding,
        decoration: effectiveDecoration,
        prefix: widget.prefix,
        suffix: suffixWidget,
        onKeyEvent: widget.onKeyEvent,
        editorBuilder: editorBuilder,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        textCapitalization: widget.textCapitalization,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        unfocusOnSubmit: widget.unfocusOnSubmit,
      ),
    );

    if (widget.showCancelButton) {
      final cancelButton = _buildCancelButton(isApple);
      if (cancelButton != null) {
        input = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: input),
            cancelButton,
          ],
        );
      }
    }

    return input;
  }
}
