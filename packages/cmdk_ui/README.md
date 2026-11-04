# cmdk_ui

Platform-aware inputs and modal helpers for [cmdk](https://github.com/definev/cmdk#readme).
Keep your command menu's layout and styling, and use native text editing for
search, selection, and clipboard actions.

`cmdk_ui` re-exports `cmdk`, so one import gives you the command widgets and adapters.

## Installation

Requires Flutter 3.47 or newer and Dart 3.13 or newer.
Add `cmdk_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  cmdk_ui: ^0.1.0
```

Then run `flutter pub get`.

## Search menu

Use `AdaptiveCommandInput` inside a `Command`. It follows the platform's text
editing conventions: Cupertino on iOS/macOS and Material on other platforms.

```dart
import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:flutter/widgets.dart';

Widget searchMenu({
  required VoidCallback openSettings,
  required VoidCallback openHelp,
}) {
  return SizedBox(
    width: 320,
    height: 240,
    child: Command(
      label: 'Quick actions',
      onSearchChange: (query) => debugPrint('Search: $query'),
      child: Column(
        children: [
          const AdaptiveCommandInput(
            placeholder: 'Search commands...',
            filled: true,
          ),
          Expanded(
            child: CommandList(
              children: [
                const CommandEmpty(child: Text('No results found.')),
                CommandItem(
                  value: 'Settings',
                  keywords: const ['preferences'],
                  onSelect: openSettings,
                  child: const Text('Settings'),
                ),
                CommandItem(
                  value: 'Help',
                  keywords: const ['support'],
                  onSelect: openHelp,
                  child: const Text('Help'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

Type “preferences” to find Settings or “support” to find Help. `Command` handles
filtering and ranking automatically; `onSearchChange` lets your app observe the
query. Use ↑ / ↓ and Enter, or tap a result, to run its action.

The adapters use `material_ui` and `cupertino_ui`. Provide their corresponding
themes and localizations in your app; the [showcase app setup](https://github.com/definev/cmdk/blob/main/example/lib/main.dart)
uses `MaterialApp` from `package:material_ui/material_ui.dart`. Menu rows remain
yours to style with [`CommandItem.builder`](https://github.com/definev/cmdk/blob/main/docs/usage.md#custom-styling-and-reactive-state).

If you already use `CommandInput`, set its `editorBuilder` to
`adaptiveCommandInputBuilder()`, `materialCommandInputBuilder()`, or
`cupertinoCommandInputBuilder()` to keep your existing input layout. See the
[editor guide](https://github.com/definev/cmdk/blob/main/docs/mobile-input.md#framework-editors) for selection menus,
keyboard settings, and custom editors.

## Dialogs and bottom sheets

Open the [modal showcase](https://github.com/definev/cmdk/blob/main/example/README.md#modal-command-menus-cmdk_ui)
to try `showMaterialCommandDialog`, `showCupertinoCommandDialog`, and
`showCommandModalBottomSheet` with the same menu. Each helper presents the widget
you build and returns the result passed to `Navigator.pop`, or `null` on dismissal.
Use a context below your app's Navigator when opening a modal.

The complete [presentation examples](https://github.com/definev/cmdk/blob/main/example/lib/command_dialog_examples.dart)
and [shared menu](https://github.com/definev/cmdk/blob/main/example/lib/command_menu.dart) show how to return a selected
command and handle keyboard insets in a bottom sheet.

For async search, nested pages, and selection-driven previews, explore the
[example app](https://github.com/definev/cmdk/blob/main/example/README.md#find-an-example).
Run the full showcase from a repository checkout:

```bash
flutter pub get
cd example
flutter run -d chrome
```
