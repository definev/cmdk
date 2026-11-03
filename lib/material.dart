/// Optional Material editor for CommandInput. The core cmdk.dart library stays
/// independent of Material and Cupertino.
library;

// Keep this optional adapter compatible with the package's Flutter >=3.24 range.
// Apps using standalone material_ui can supply their TextField via editorBuilder.
import 'package:material_ui/material_ui.dart';
import 'src/command_input.dart';

/// Uses Flutter's full text-field behavior without field decoration or padding.
/// Requires the usual Material and MaterialLocalizations ancestors.
///
/// ```dart
/// CommandInput(
///   editorBuilder: materialCommandInputBuilder(
///     cursorColor: Colors.deepPurple,
///     cursorWidth: 3.0,
///   ),
///   ...
/// )
/// ```
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
}) => (BuildContext context, CommandInputEditor editor) => TextField(
  controller: editor.controller,
  focusNode: editor.focusNode,
  autofocus: editor.autofocus,
  decoration: null,
  style: style ?? editor.style,
  cursorColor: cursorColor ?? editor.cursorColor,
  cursorWidth: cursorWidth ?? editor.cursorWidth,
  cursorHeight: cursorHeight ?? editor.cursorHeight,
  cursorRadius: cursorRadius ?? editor.cursorRadius,
  cursorOpacityAnimates: cursorOpacityAnimates ?? editor.cursorOpacityAnimates,
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
