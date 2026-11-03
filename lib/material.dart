/// Optional Material editor for CommandInput. The core cmdk.dart library stays
/// independent of Material and Cupertino.
library;

// Keep this optional adapter compatible with the package's Flutter >=3.24 range.
// Apps using standalone material_ui can supply their TextField via editorBuilder.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'src/command_input.dart';

/// Uses Flutter's full text-field behavior without field decoration or padding.
/// Requires the usual Material and MaterialLocalizations ancestors.
///
/// CommandInput(editorBuilder: materialCommandInputBuilder, ...)
Widget materialCommandInputBuilder(
        BuildContext context, CommandInputEditor editor) =>
    TextField(
      controller: editor.controller,
      focusNode: editor.focusNode,
      autofocus: editor.autofocus,
      decoration: null,
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
