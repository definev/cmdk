/// Optional Cupertino editor for CommandInput.
library;

// Keep this optional adapter compatible with the package's Flutter >=3.24 range.
// Apps using standalone cupertino_ui can supply their field via editorBuilder.
// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'src/command_input.dart';

/// Uses Flutter's native-style gestures, selection and context menu without
/// field chrome. Requires the usual CupertinoLocalizations ancestors.
///
/// CommandInput(editorBuilder: cupertinoCommandInputBuilder, ...)
Widget cupertinoCommandInputBuilder(
  BuildContext context,
  CommandInputEditor editor,
) => CupertinoTextField(
  controller: editor.controller,
  focusNode: editor.focusNode,
  autofocus: editor.autofocus,
  decoration: null,
  padding: EdgeInsets.zero,
  style: editor.style,
  cursorColor: editor.cursorColor,
  keyboardType: TextInputType.text,
  textInputAction: TextInputAction.search,
  autocorrect: editor.autocorrect,
  enableSuggestions: editor.enableSuggestions,
  textCapitalization: editor.textCapitalization,
  smartDashesType: editor.smartDashesType,
  smartQuotesType: editor.smartQuotesType,
  keyboardAppearance: editor.keyboardAppearance,
  scrollPadding: editor.scrollPadding,
  onEditingComplete: editor.onEditingComplete,
  onSubmitted: editor.onSubmitted,
);
