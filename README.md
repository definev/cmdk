# ⌘K for Flutter

⌘K is a fast, unstyled, composable command menu / combobox for Flutter. You render items, and it filters and sorts them automatically using fuzzy scoring, low-latency keyboard navigation, and granular reactivity.

⌘K supports a fully composable compound-widget API, so you can nest custom widgets, sections, or static layouts anywhere within the menu tree.

---

## Features

- **Fast**: High-performance fuzzy scoring engine ported directly from `command-score`, ranking thousands of items in single-digit milliseconds.
- **Unstyled**: The core `cmdk.dart` uses only Flutter widgets/services. Optional Material and Cupertino editor adapters provide full text-editing gestures and menus without adding field decoration.
- **Composable**: Compound widget architecture mirroring cmdk (`Command`, `CommandInput`, `CommandList`, `CommandGroup`, `CommandItem`, `CommandSeparator`, `CommandEmpty`, `CommandLoading`, `CommandDialog`).
- **Keyboard & Vim Navigation**:
  - `ArrowDown` / `ArrowUp`: Item navigation (with optional `loop` wrap-around).
  - `Alt + ArrowDown` / `Alt + ArrowUp`: Jump between groups.
  - `Meta + ArrowDown` / `Meta + ArrowUp` on Apple platforms (or `Home` / `End`, `Ctrl + Home` / `Ctrl + End`): Jump to start / end.
  - Vim shortcuts: `Ctrl + j` / `Ctrl + n` (down), `Ctrl + k` / `Ctrl + p` (up) with `Alt`/`Meta` modifiers.
  - `Enter`: Select active item.
- **Mouse & Pointer Support**: Hover-to-select and tap-to-activate.
- **Accessibility**: First-class Flutter `Semantics` mapping to native accessibility trees (VoiceOver, TalkBack, Narrator).

---

## Installation

Add `cmdk` to your `pubspec.yaml`:

```yaml
dependencies:
  cmdk:
    git:
      url: https://github.com/definev/cmdk.git
```

---

## Quickstart

```dart
import 'package:flutter/widgets.dart';
import 'package:cmdk/cmdk.dart';

class MyCommandMenu extends StatelessWidget {
  const MyCommandMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Command(
      label: 'Command Menu',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CommandInput(
            placeholder: 'Type a command or search...',
          ),
          const CommandSeparator(),
          CommandList(
            children: [
              const CommandEmpty(
                child: Text('No results found.'),
              ),
              CommandGroup(
                heading: const Text('Letters'),
                children: [
                  CommandItem(
                    value: 'a',
                    onSelect: () => print('Selected A'),
                    child: const Text('A'),
                  ),
                  CommandItem(
                    value: 'b',
                    onSelect: () => print('Selected B'),
                    child: const Text('B'),
                  ),
                  const CommandSeparator(),
                  CommandItem(
                    value: 'c',
                    onSelect: () => print('Selected C'),
                    child: const Text('C'),
                  ),
                ],
              ),
              CommandItem(
                value: 'apple',
                keywords: const ['fruit', 'red'],
                onSelect: () => print('Selected Apple'),
                child: const Text('Apple'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Modal Dialog

You can render the command menu inside a modal dialog in two ways:

### 1. Declarative Widget (`CommandDialog`)

```dart
CommandDialog(
  open: isDialogOpen,
  onOpenChange: (open) => setState(() => isDialogOpen = open),
  child: Command(
    child: ...
  ),
)
```

### 2. Imperative Helper (`CommandDialog.show`)

```dart
CommandDialog.show<void>(
  context: context,
  builder: (context) {
    return Command(
      child: ...
    );
  },
);
```

Pressing `Escape` or tapping the backdrop automatically dismisses the dialog.

---

## Parts & Custom Styling

Because `cmdk` is headless and unstyled, you customize the appearance using standard Flutter styling:

### `CommandItem` Custom Builder
Use `builder` to access interactive state (`isSelected`, `isDisabled`, `isHovered`, `score`):

```dart
CommandItem(
  value: 'settings',
  builder: (context, state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: state.isSelected ? const Color(0xFF1E293B) : const Color(0x00000000),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          const Text('⚙️ Settings'),
          const Spacer(),
          if (state.isSelected)
            const Text('↵', style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  },
)
```

### `CommandStateSelector` (Mirroring `useCommandState`)
Listen to slices of state with surgical rebuild precision:

```dart
CommandStateSelector<String>(
  selector: (state) => state.search,
  builder: (context, search) {
    return Text('Searching for "$search"...');
  },
)
```

---

## Example Showcase

The `example/` folder contains a full clone of the original cmdk showcase with an interactive theme switcher featuring 4 themes styled using the **`mix`** package (`package:mix`):

- **Raycast**: Action footer, badge tags, application launchers, search filtering.
- **Linear**: Issue trackers, status/priority indicators, and action triggers.
- **Vercel**: Crisp monochrome hierarchy, breadcrumbs, and page navigation.
- **Framer**: Split insert-panel with real-time preview panel following active selection.

To run the interactive showcase:

```bash
cd example
flutter run -d macos # or chrome, windows, linux
```

---

## Architecture

The original TypeScript/React codebase is preserved inside `reference/`.

## Flutter state and lifecycle

`CommandScope.of(context)` obtains the controller and depends only on its
identity. To render reactive state, use `CommandStateSelector` (slice comparison
uses `==`) or `ListenableBuilder(listenable: controller, ...)`.

With an external `CommandController`, omitted widget options preserve the
controller's configuration and callbacks. Explicit widget options override them
only while attached. A controller belongs to one `Command` at a time.

Non-null `Command.value` and `Command.search` are controlled: update them in the
corresponding callback to accept a requested change. Use `value: ''` for an empty
controlled selection. `onValueChange` can receive `null` when the uncontrolled
selection clears. Programmatic search updates synchronize the input without
firing its edit callback. The command search also initializes an externally
provided `TextEditingController`.

## Large datasets

The virtual constructor takes complete metadata so search and keyboard
navigation include rows that have never been built:

```dart
CommandList.builder(
  items: [
    ItemEntry(id: 'settings', value: 'Settings', onSelect: openSettings),
    ItemEntry(id: 'help', value: 'Help', keywords: ['support'], onSelect: openHelp),
  ],
  itemExtent: 44,
  itemBuilder: (context, item, state) => Text(item.value),
)
```

Provide a bounded height, for example with `Expanded` or `SizedBox`. IDs and
trimmed values must be unique. The builder returns presentation content; the
list supplies `CommandItem` interaction and semantics. The old
`itemCount`/index-builder constructor is replaced by `items`, `itemExtent`, and
the data/state builder. Fixed row height enables exact scrolling to unbuilt
results.

Composable lists rank whole sibling blocks, including custom wrappers, by their
best matching item. Groups rank their children using the same result order.
Clearing search restores source order. Use keys when the application reorders
stateful source children.

Both `CommandDialog` and `CommandDialog.show` require a `Navigator` ancestor,
such as `WidgetsApp`, `MaterialApp`, or `CupertinoApp`. The declarative widget
occupies no layout space and can be placed anywhere under that Navigator;
`open` and `onOpenChange` control a native modal route.

See [ARCHITECTURE.md](ARCHITECTURE.md) for state ownership and lifecycle details.


## Keyboard actions and remapping

`Command` provides Flutter `Shortcuts` and `Actions`. The public intents are
`CommandNavigateIntent(CommandNavigation.next)` (also `previous`, `first`,
`last`, `nextGroup`, `previousGroup`) and `CommandActivateIntent()`.

`shortcuts` replaces the default map; omit it to follow `vimBindings` and the
current platform. Use the defaults as a base for an additive remap:

```dart
Command(
  shortcuts: {
    ...CommandKeyboardShortcuts.defaults(vimBindings: false),
    const SingleActivator(LogicalKeyboardKey.f2):
        const CommandNavigateIntent(CommandNavigation.last),
  },
  actions: {
    CommandActivateIntent: CallbackAction<CommandActivateIntent>(
      onInvoke: (_) {
        // Custom activation; return null when no result is needed.
        openSelectedCommand();
        return null;
      },
    ),
  },
  child: menu,
)
```

Bindings use exact modifiers: Shift+arrows, Shift+Home/End, copy/paste,
word movement and other unbound editing shortcuts retain Flutter's behavior.
Home/End intentionally navigate the menu by default. To use them for caret
movement in the search field, remove their bindings:

```dart
final shortcuts = CommandKeyboardShortcuts.defaults()
  ..remove(const SingleActivator(LogicalKeyboardKey.home))
  ..remove(const SingleActivator(LogicalKeyboardKey.end));
```

An empty map disables the menu's physical bindings. Native editor submission
still invokes `CommandActivateIntent`: keyboard bindings and form submission
are separate entry points to the same action. Override/disable the action to
control both. `Command.actions` overrides defaults; a closer descendant `Actions`
can override them further. An ancestor `Actions` does not replace the menu's
nearer defaults. Custom actions belong to the application and are not disposed
by `Command`. Use `Actions.maybeInvoke(context, intent)` for programmatic dispatch
from a descendant context; Flutter respects the action's `isEnabled` result.

Only a focused menu root or its `CommandInput` uses the default menu bindings.
Embedded buttons, other text fields and input prefix/suffix controls retain their
own keyboard behavior. Descendant `Shortcuts` can opt custom controls into the
public intents. Nested menus use the nearest menu's actions, even if empty.

The input guards IME composition before shortcut dispatch. Navigation repeats;
activation repeats matching the menu's shortcut manager are consumed without
re-invocation. If adding a separate descendant `Shortcuts` layer, use
`SingleActivator(..., includeRepeats: false)` for activation bindings. Input and
root `onKeyEvent` hooks remain available for low-level interception before the
menu manager. Escape is owned by the modal dialog. A global Cmd+K/Ctrl+K opener
belongs to the host application: bind it with `Shortcuts`/`Actions` or
`CallbackShortcuts` around the application shell, and update `CommandDialog.open`.
The library does not install a process-wide keyboard listener.

## Mobile text editing

The default `CommandInput` is a low-level, widgets-only `EditableText`. For a
production mobile input, use a framework text field through `editorBuilder`:

```dart
import 'package:cmdk/cmdk.dart';
import 'package:cmdk/material.dart';

CommandInput(
  editorBuilder: materialCommandInputBuilder,
  style: const TextStyle(fontSize: 16, color: Color(0xFF111111)),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
)
```

For a Cupertino application, import `package:cmdk/cupertino.dart` and use
`cupertinoCommandInputBuilder`. These adapters delegate word selection, cursor
dragging, selection handles, magnifier and copy/paste menus to Flutter's
`TextField` / `CupertinoTextField`. Supply their usual application/localization
ancestors (and a Material ancestor for the Material editor). The field itself
has no decoration or extra padding; the command input still owns the surrounding
prefix/suffix, placeholder, padding and decoration. Native selection/cursor
affordances follow the field's theme. The low-level editor alone uses
`backgroundCursorColor`.

Defaults suit command names and identifiers: `autocorrect: false`,
`enableSuggestions: true`, `textCapitalization: TextCapitalization.none`, with
smart quotes and smart dashes disabled. These settings are configurable; actual
suggestion UI is controlled by the IME. Native adapters inherit keyboard
brightness from their theme unless `keyboardAppearance` is provided.

Search dispatches the same enabled `CommandActivateIntent` as Enter and keeps
focus by default. If an action closes the panel or opens another route, the input
does not request focus back. Use `unfocusOnSubmit: true` to unfocus on a valid
soft-keyboard submission. Disabled actions and active IME composition do not
unfocus or activate.

Live composing text participates in search. Controlled or programmatic query
reconciliation waits until composition commits or focus leaves, preserving the
IME's editing buffer. Selection-only and composition-only updates do not emit
query edits. Prefix/suffix controls share the editor's `TextFieldTapRegion`, so a
clear button can call an external text controller's `clear()` without being
treated as an outside click.

Custom editors, including standalone `material_ui` / `cupertino_ui` fields, can
use the public `CommandInputEditor` binding. Wire its controller, focus node,
`onEditingComplete` and `onSubmitted` callbacks; retain its keyboard settings.
Do not dispose the supplied controller/focus node. See
[mobile input behavior](docs/mobile-input.md) for the contract and verification.
