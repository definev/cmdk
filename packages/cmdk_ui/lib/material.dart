/// Material adapters and widgets for cmdk.
library;

import 'package:material_ui/material_ui.dart';
import 'package:cmdk/cmdk.dart';

/// Uses Flutter's full Material text-field behavior without field decoration or padding.
/// Requires the usual Material and MaterialLocalizations ancestors.
CommandInputEditorBuilder materialCommandInputBuilder({
  Color? cursorColor,
  double? cursorWidth,
  double? cursorHeight,
  Radius? cursorRadius,
  bool? cursorOpacityAnimates,
  bool? showCursor,
  TextStyle? style,
  Brightness? keyboardAppearance,
  EdgeInsets? scrollPadding,
}) =>
    (BuildContext context, CommandInputEditor editor) => Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: editor.controller,
        focusNode: editor.focusNode,
        autofocus: editor.autofocus,
        decoration: null,
        style: style ?? editor.style,
        cursorColor: cursorColor ?? editor.cursorColor,
        cursorWidth: cursorWidth ?? editor.cursorWidth,
        cursorHeight: cursorHeight ?? editor.cursorHeight,
        cursorRadius: cursorRadius ?? editor.cursorRadius,
        cursorOpacityAnimates:
            cursorOpacityAnimates ?? editor.cursorOpacityAnimates,
        showCursor: showCursor ?? editor.showCursor,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        autocorrect: editor.autocorrect,
        enableSuggestions: editor.enableSuggestions,
        textCapitalization: editor.textCapitalization,
        smartDashesType: editor.smartDashesType,
        smartQuotesType: editor.smartQuotesType,
        keyboardAppearance: keyboardAppearance ?? editor.keyboardAppearance,
        scrollPadding: scrollPadding ?? editor.scrollPadding,
        onEditingComplete: editor.onEditingComplete,
        onSubmitted: editor.onSubmitted,
      ),
    );

/// A [CommandScrollbarBuilder] that wraps the list with Material's [Scrollbar].
CommandScrollbarBuilder materialCommandScrollbarBuilder({
  bool? thumbVisibility,
  bool? trackVisibility,
  double? thickness,
  Radius? radius,
  bool? interactive,
  ScrollNotificationPredicate? notificationPredicate,
}) =>
    (BuildContext context, Widget child, ScrollController scrollController) =>
        Scrollbar(
          controller: scrollController,
          thumbVisibility: thumbVisibility,
          trackVisibility: trackVisibility,
          thickness: thickness,
          radius: radius,
          interactive: interactive,
          notificationPredicate: notificationPredicate,
          child: child,
        );

/// Helper to show a [Command] inside a Material modal dialog.
Future<T?> showMaterialCommandDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? const Color(0x80000000),
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: builder,
  );
}
