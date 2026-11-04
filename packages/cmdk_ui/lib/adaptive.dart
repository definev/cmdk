/// Adaptive platform-aware widgets and builders for cmdk.
library;

import 'package:cmdk/cmdk.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as cupertino;
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
  EditableTextContextMenuBuilder? contextMenuBuilder,
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
      contextMenuBuilder: contextMenuBuilder,
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
      contextMenuBuilder: contextMenuBuilder,
    )(context, editor);
  }
};

/// An adaptive, platform-aware search input for mobile and desktop [Command] menus.
///
/// Automatically switches between iOS/macOS Cupertino conventions (Cupertino text field,
/// selection handles and magnifier) and Android/Material conventions
/// (Material text field and theme typography).
///
/// Features built-in:
/// - Native text editing engine with selection magnifier and clipboard actions
/// - Mobile touch target sizing (default 44px min height)
/// - Adaptive filled/unfilled styling with system fill colors
class AdaptiveCommandInput extends StatelessWidget {
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
    this.onKeyEvent,
    this.editorBuilder,
    this.contextMenuBuilder,
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

  /// Key event interceptor.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Custom editor builder override.
  final CommandInputEditorBuilder? editorBuilder;

  /// Builds the text selection menu. When omitted, uses the platform editor's
  /// default menu, including the system menu where supported.
  /// Custom [editorBuilder] implementations receive this through
  /// [CommandInputEditor.contextMenuBuilder].
  final EditableTextContextMenuBuilder? contextMenuBuilder;

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

  TargetPlatform _resolvePlatform(BuildContext context) {
    if (platform != null) return platform!;
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
    if (cursorColor != null) return cursorColor!;
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
    if (placeholderStyle != null) return placeholderStyle;
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

  Decoration? _resolveDecoration(
    bool isApple,
    bool isDark,
    BuildContext context,
  ) {
    if (decoration != null) return decoration;
    if (!filled) return null;

    return BoxDecoration(
      color:
          fillColor ??
          (isApple
              ? (isDark ? const Color(0x3D767680) : const Color(0x1F767680))
              : material.Theme.of(context).colorScheme.surfaceContainerHighest),
      borderRadius:
          borderRadius ?? BorderRadius.circular(isApple ? 10.0 : 12.0),
    );
  }

  EdgeInsetsGeometry _resolvePadding(bool isApple) {
    if (padding != null) return padding!;
    if (filled) {
      return EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: isApple ? 7.0 : 6.0,
      );
    }
    return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);
  }

  @override
  Widget build(BuildContext context) {
    final platform = _resolvePlatform(context);
    final isApple = _isApplePlatform(platform);
    final isDark = _isDarkMode(platform, context);

    final effectiveCursorColor = _resolveCursorColor(isApple, context);
    final effectiveDecoration = _resolveDecoration(
      isApple,
      isDark,
      context,
    );
    final effectivePadding = _resolvePadding(isApple);
    final effectivePlaceholderStyle = _resolvePlaceholderStyle(
      isApple,
      isDark,
      context,
    );

    final effectiveEditorBuilder =
        editorBuilder ??
        (isApple
            ? cupertinoCommandInputBuilder(
                cursorColor: effectiveCursorColor,
                cursorWidth: cursorWidth,
                cursorHeight: cursorHeight,
                cursorRadius: cursorRadius,
                cursorOpacityAnimates: cursorOpacityAnimates,
                showCursor: showCursor,
                style: style,
                keyboardAppearance: keyboardAppearance,
                scrollPadding: scrollPadding,
              )
            : materialCommandInputBuilder(
                cursorColor: effectiveCursorColor,
                cursorWidth: cursorWidth,
                cursorHeight: cursorHeight,
                cursorRadius: cursorRadius,
                cursorOpacityAnimates: cursorOpacityAnimates,
                showCursor: showCursor,
                style: style,
                keyboardAppearance: keyboardAppearance,
                scrollPadding: scrollPadding,
              ));

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: CommandInput(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        placeholder: placeholder,
        placeholderWidget: placeholderWidget,
        style: style,
        placeholderStyle: effectivePlaceholderStyle,
        cursorColor: effectiveCursorColor,
        cursorWidth: cursorWidth ?? 1.5,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorOpacityAnimates: cursorOpacityAnimates,
        showCursor: showCursor,
        onValueChange: onValueChange,
        padding: effectivePadding,
        decoration: effectiveDecoration,
        prefix: prefix,
        suffix: suffix,
        onKeyEvent: onKeyEvent,
        editorBuilder: effectiveEditorBuilder,
        contextMenuBuilder: contextMenuBuilder,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        textCapitalization: textCapitalization,
        smartDashesType: smartDashesType,
        smartQuotesType: smartQuotesType,
        keyboardAppearance: keyboardAppearance,
        scrollPadding: scrollPadding,
        unfocusOnSubmit: unfocusOnSubmit,
      ),
    );
  }
}
