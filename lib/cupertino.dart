/// Optional Cupertino editor for CommandInput.
library;

// Keep this optional adapter compatible with the package's Flutter >=3.24 range.
// Apps using standalone cupertino_ui can supply their field via editorBuilder.
import 'package:cupertino_ui/cupertino_ui.dart';
import 'src/command_input.dart';

/// Uses Flutter's native-style gestures, selection and context menu without
/// field chrome. Requires the usual CupertinoLocalizations ancestors.
///
/// ```dart
/// CommandInput(
///   editorBuilder: cupertinoCommandInputBuilder(
///     cursorColor: CupertinoColors.activeBlue,
///     cursorWidth: 2.0,
///   ),
///   ...
/// )
/// ```
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
}) => (BuildContext context, CommandInputEditor editor) => CupertinoTextField(
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
);
