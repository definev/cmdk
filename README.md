# ⌘K for Flutter

A composable command menu for Flutter, ported from [cmdk](https://github.com/dip/cmdk) by Paco Coursey.
You build the interface; `cmdk` handles search, ranking, and keyboard navigation.

Start with a search field and a few commands, then style them to fit your app.
The core package is unstyled and uses only Flutter widgets and services.

## Installation

Add `cmdk` to your `pubspec.yaml`:

```yaml
dependencies:
  cmdk: ^0.1.0
```

Requires Flutter 3.32 or newer and Dart 3.8 or newer. Then run `flutter pub get`.

## Usage

Place this menu inside your app and pass in the actions it should run:

```dart
import 'package:cmdk/cmdk.dart';
import 'package:flutter/widgets.dart';

Widget commandMenu({
  required VoidCallback openSettings,
  required VoidCallback openHelp,
}) {
  return SizedBox(
    width: 320,
    height: 240,
    child: Command(
      label: 'Quick actions',
      // Optional: observe the query while cmdk filters the items automatically.
      onSearchChange: (query) => debugPrint('Search: $query'),
      child: Column(
        children: [
          const CommandInput(placeholder: 'Search commands...'),
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

`CommandInput` updates the search query as you type. `Command` automatically
filters and ranks items by `value` and `keywords`: try “settings” or “preferences”
for Settings, and “support” for Help. `CommandEmpty` appears when nothing matches;
clearing the query restores all items. Use `onSearchChange` to observe query changes.

Use ↑ / ↓ to navigate, and press Enter or tap to run a command.

The example leaves appearance to your app. Use `CommandItem.builder` to style
selected rows; see [custom styling](docs/usage.md#custom-styling-and-reactive-state).
For native text editing and modal helpers, use the companion
[`cmdk_ui` package](packages/cmdk_ui/README.md).

## Showcase

Run the [example app](example/README.md) to explore complete menus:

```bash
flutter pub get
cd example
flutter run -d chrome
```

For more involved use cases, start with [async search in Raycast](example/README.md#raycast-app-owned-async-search),
[nested pages in Vercel](example/README.md#vercel-nested-pages), or
[a selection-driven preview in Framer](example/README.md#framer-selection-driven-preview).
The [modal examples](example/README.md#modal-command-menus-cmdk_ui) show how to open
the same menu in a Material dialog, Cupertino dialog, or bottom sheet and return a result.

See the [usage guide](docs/usage.md) for controlled state, keyboard remapping,
and large lists, or [mobile input](docs/mobile-input.md) for native editors and IME behavior.
Implementation details live in [ARCHITECTURE.md](ARCHITECTURE.md).
