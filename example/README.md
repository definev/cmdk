# cmdk showcase

Run `flutter run` from this directory and select **Raycast** in the theme
switcher. On web, open the app with `?theme=raycast` to select it directly.

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

The example in `lib/clones/raycast.dart` owns the debounce, pending/error
state, request generation, and disposal. `Command(shouldFilter: false)` presents
the supplied results without filtering them again. Each request captures a
generation number; only the current generation may publish results or errors.
This rejects stale responses even while the next query is still debouncing.

`RaycastCMDK.search` can be supplied with a function returning matching names
from the demo catalog to replace the simulated source. The widget tests use this
to control response order and failures. This demonstrates async I/O orchestration;
the simulated source does not move CPU-intensive scoring off the UI isolate.
