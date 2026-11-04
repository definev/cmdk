# cmdk showcase

A runnable showcase of command menus built with `cmdk` and styled with `mix`.

From the repository root:

```bash
flutter pub get
cd example
flutter run -d chrome
```

Use `-d macos` for the macOS app, or choose another configured Flutter device.
Switch themes in the app. On web, append a query such as `?theme=vercel` to
open a theme directly.

## Find an example

| Use case | Open in the showcase | Source |
| --- | --- | --- |
| Async search with loading, retry, and stale-response handling | [Raycast](#raycast-app-owned-async-search) · `?theme=raycast` | [raycast.dart](lib/clones/raycast.dart) |
| Nested pages and keyboard back navigation | [Vercel](#vercel-nested-pages) · `?theme=vercel` | [vercel.dart](lib/clones/vercel.dart) |
| A preview that follows the selected item | [Framer](#framer-selection-driven-preview) · `?theme=framer` | [framer.dart](lib/clones/framer.dart) |
| Custom rows with icons, shortcut hints, and selection styling | Linear · `?theme=linear` | [linear.dart](lib/clones/linear.dart) |
| A custom glass surface around a command menu | Liquid Glass · `?theme=glass` | [liquid_glass.dart](lib/clones/liquid_glass.dart) |
| Dialogs and a bottom sheet that return a selected value | [Material / Cupertino / Sheet dock](#modal-command-menus-cmdk_ui) | [command_dialog_examples.dart](lib/command_dialog_examples.dart) |

The showcase's application setup and theme routing live in [main.dart](lib/main.dart).
For a minimal menu, see the [main README](../README.md#usage).

## Modal command menus (`cmdk_ui`)

Below the theme switcher, a compact dock opens each modal presentation:

- **Material**: `showMaterialCommandDialog<String>` with a `Dialog` shell.
- **Cupertino**: `showCupertinoCommandDialog<String>` with a custom shell.
- **Sheet**: `showCommandModalBottomSheet<String>` with a drag handle and
  keyboard insets handled by the helper.

Each opens the same Raycast-styled `CommandMenu`: a dark surface, subtle rim,
compact rows, and a keyboard-hint footer. The menu lives in
[`lib/command_menu.dart`](lib/command_menu.dart). Try `preferences`, press Enter or tap
**Open Settings**, and the selected command appears below the buttons. Escape,
the close button, or tapping the backdrop cancels and returns `null`. Opening
again starts with a fresh query. The menu scrolls when space is limited.
On narrow screens the dock shows icons without tooltips. Cancelling leaves no
status text; selecting a command shows only its name.

The complete example is in [`lib/command_dialog_examples.dart`](lib/command_dialog_examples.dart).
The showcase uses `MaterialApp` to supply a Navigator, themes, and the Material
and Cupertino localizations required by these helpers. Use a context below
that app when opening a modal:

```dart
import 'package:cmdk_ui/cmdk_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'command_menu.dart';

final selected = await showMaterialCommandDialog<String>(
  context: context,
  builder: (dialogContext) => const Dialog(
    backgroundColor: Color(0x00000000),
    elevation: 0,
    child: CommandMenu(),
  ),
);
// selected is the chosen command, or null when dismissed.
```

The helpers present a route; the builder supplies `Command`, `CommandInput`,
and `CommandList`. Inside the menu, `CommandItem.onSelect` calls
`Navigator.of(context).pop(command.value)` using the menu's route context to
complete the returned `Future<String?>`. Check `mounted` before updating state
after awaiting a result, as the example does.

## Raycast: app-owned async search

Type an app or command name, such as `Slack`, into the main search field.
Search waits for a 200 ms debounce, then uses a simulated remote source with
450–900 ms latency. The source filters the bundled catalog; no network access is
required. Short queries intentionally take longer so quick edits can produce
responses out of order.

While searching, the previous results stay visible and the red gradient line
under the input runs instead of showing loading text. It stops when search
finishes or the query is cleared; reduced motion uses a static gradient.
Stale rows, keyboard activation, and footer actions are disabled. Publishing
new results selects the first row in presentation order, even if the previous
selection is still present. Clearing the field restores the full catalog and
selects Linear immediately. An empty state appears only after a successful
search with no matches; a failed search retains disabled rows and offers Retry.
Raycast retains its fixed 393 px results viewport through pending, empty, and
error states. Its empty state follows the app's result snapshot.

The example in [raycast.dart](lib/clones/raycast.dart) owns the debounce, pending/error
state, request generation, and disposal. `Command(shouldFilter: false)` presents
the supplied results without filtering them again. Each request captures a
generation number; only the current generation may publish results or errors.
This rejects stale responses even while the next query is still debouncing.

`RaycastCMDK.search` can be supplied with a function returning matching names
from the demo catalog to replace the simulated source. The widget tests use this
to control response order and failures. This demonstrates async I/O orchestration;
the simulated source does not move CPU-intensive scoring off the UI isolate.

## Vercel: nested pages

Select **Search Projects...** to enter the Projects page. The breadcrumbs follow
the page stack, and each page supplies its own command groups. Press Backspace
with an empty search field to return; with text in the field, it edits normally.

[vercel.dart](lib/clones/vercel.dart) keeps the page stack and selection in app
state, clears the query when changing pages, and extends the default shortcuts
with a custom back action.

## Framer: selection-driven preview

Move through the component list with the arrow keys or pointer. The preview
beside the list updates to match the selected component.

[framer.dart](lib/clones/framer.dart) uses `Command.value` and `onValueChange` to
keep selection in app state and share it with the preview pane. Its item builder
styles each row from `CommandItemState`.
