/// Cupertino adapters and widgets for cmdk.
library;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cmdk/cmdk.dart';

/// Uses Flutter's native-style gestures, selection and context menu without
/// field chrome. Requires the usual CupertinoLocalizations ancestors.
CommandInputEditorBuilder cupertinoCommandInputBuilder({
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
}) =>
    (BuildContext context, CommandInputEditor editor) => DefaultSelectionStyle(
      selectionColor: (cursorColor ?? editor.cursorColor).withValues(
        alpha: 0.4,
      ),
      child: CupertinoTextField(
        controller: editor.controller,
        focusNode: editor.focusNode,
        autofocus: editor.autofocus,
        decoration: null,
        padding: EdgeInsets.zero,
        style: style ?? editor.style,
        cursorColor: cursorColor ?? editor.cursorColor,
        cursorWidth: cursorWidth ?? editor.cursorWidth,
        cursorHeight: cursorHeight ?? editor.cursorHeight,
        cursorRadius:
            cursorRadius ?? editor.cursorRadius ?? const Radius.circular(2.0),
        cursorOpacityAnimates:
            cursorOpacityAnimates ?? editor.cursorOpacityAnimates ?? true,
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
        contextMenuBuilder:
            contextMenuBuilder ??
            editor.contextMenuBuilder ??
            const CupertinoTextField().contextMenuBuilder,
      ),
    );

/// A [CommandScrollbarBuilder] that wraps the list with [CupertinoScrollbar].
CommandScrollbarBuilder cupertinoCommandScrollbarBuilder({
  bool? thumbVisibility,
  double? thickness,
  Radius? radius,
  ScrollNotificationPredicate? notificationPredicate,
}) =>
    (BuildContext context, Widget child, ScrollController scrollController) =>
        CupertinoScrollbar(
          controller: scrollController,
          thumbVisibility: thumbVisibility,
          thickness: thickness ?? CupertinoScrollbar.defaultThickness,
          radius: radius ?? CupertinoScrollbar.defaultRadius,
          notificationPredicate: notificationPredicate,
          child: child,
        );

/// Helper to show a [Command] inside a Cupertino modal popup dialog.
Future<T?> showCupertinoCommandDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color barrierColor = kCupertinoModalBarrierColor,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showCupertinoDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: builder,
  );
}
