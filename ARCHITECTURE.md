# Flutter implementation

## Catalog and results

`CommandController` owns item metadata, search, selection, scores and one cached
result order. Input, layout and keyboard navigation all consume that order.
Snapshots are immutable and cached until state changes, rather than copying the
entire score map in every row build. Ties preserve source order.

The eager `CommandList(children: ...)` adapts mounted `CommandItem`s into the
catalog. `CommandCollection` gives each source slot a stable key and source path.
It ranks whole sibling blocks by their best visible match; a custom wrapper does
not need to be inspected or unwrapped. Internal layout within a custom block is
preserved. `CommandGroup` uses the same collection for its children. Hiding a
group changes `Offstage` and `ExcludeFocus` properties without replacing the
subtree. Clearing search restores source order.

`CommandList.builder` registers all `ItemEntry` data independently of rendered
rows. Virtual row disposal never removes catalog entries. It requires a fixed
`itemExtent`, which permits scrolling to an unbuilt result using its filtered
index. The list owns the catalog registrations and removes them on replacement,
controller migration, or disposal. A builder returns row content, not another
`CommandItem`; pointer handling and selection semantics come from the list.

IDs and trimmed values must be unique in a menu. Use widget keys for stateful
source children that can be reordered or inserted by the application. Catalog
metadata is copied when registered so mutable caller lists cannot silently
change cached results. Only visible, enabled entries can be activated.

## Lifecycle and subscriptions

`CommandScope` is an identity-only `InheritedWidget`: changing selection cannot
re-enter registration through `didChangeDependencies`. Widgets explicitly listen
to state via `ListenableBuilder` or `CommandStateSelector`. Selectors recompute
when their function changes and use `==` to compare selected values; callers
should select immutable values with meaningful equality.

Item registration is idempotent. Metadata changes invalidate results and batch
one publication after layout, avoiding notifications during build. Repeated
builds with identical metadata schedule no additional frames. Controller and
text-controller migration always unregister/unsubscribe from the old owner.
Internal controllers are disposed only after descendants have detached.

## Controlled state and ownership

A root binding carries controlled values, callbacks and optional configuration
overrides. It never replaces callbacks or configuration owned by an external
controller. Removing the binding or an override reveals the controller's own
configuration again. A controller can be attached to one `Command` at a time.

Non-null `value` and `search` are controlled. Interaction requests a change via
callbacks; the parent decides whether to apply it. Use `value: ''` for an empty
controlled selection; omit `value` for controller-managed selection. Parent
updates do not echo callbacks. `onValueChange` accepts `null` when an uncontrolled
selection clears. Selection remains valid across catalog updates, and search
selects the first enabled match in uncontrolled mode.

The command search is authoritative for `CommandInput` text, including initial
text. Programmatic synchronization uses `TextEditingValue` without firing edit
callbacks. Selection-only text-controller notifications are not search edits.
During active, focused IME composition, authoritative query replacements are
deferred until commit or focus loss. A temporary editing buffer can therefore
differ from a controlled search without repeatedly destroying the composing
range. On reconciliation, selection direction and in-range offsets are retained.

`CommandInputEditor` is the editor seam: it carries the owned editing session,
keyboard settings and completion callbacks. Optional Material/Cupertino adapters
use complete framework text fields, so gesture, clipboard, selection overlay
and magnifier behavior remain with Flutter. The core imports neither design
system. The fallback widgets-only editor deliberately provides basic editing;
applications opt into a native adapter for full mobile text interaction. Input
adornments share its text-field tap region. Soft submission bypasses Flutter's
default completion/unfocus sequence, checks composition and action enablement,
and keeps focus unless explicitly configured otherwise. No path requests focus
back after a command action.

Keyboard bindings map exact `SingleActivator`s to public navigation/activation
intents. Flutter `Shortcuts` performs lookup and dispatches through `Actions`.
The menu installs enabled default actions; caller-supplied or closer descendant
actions can replace them. Physical activation and `EditableText.onSubmitted`
both resolve the same action from the editable context. The root owns only its
fallback focus node and shortcut manager, never supplied actions or focus nodes.

The shortcut manager adds routing guards: it ignores another menu's focus and
embedded controls, yields during IME composition, and consumes repeated
activation shortcuts without invoking them. It delegates matching, enablement,
dispatch and key-consumption semantics to Flutter. Input `Focus.onKeyEvent` is
only a composition/interception guard. Root `Focus.onKeyEvent` is only a caller
hook; neither contains a second keyboard dispatch implementation. Root and input
markers carry controller identity so nested empty menus never navigate parents.
Unbound keys continue to ancestor/native shortcuts. Home/End remain menu
bindings by default; applications can remove them to restore caret movement.
Apple profiles add Meta+arrows, while Ctrl+Home/End work on every profile.
Changing an external controller's Vim setting notifies the binding layer.

## Dialogs

Both dialog interfaces use `RawDialogRoute` and require a `Navigator`. The
imperative helper pushes a normal dismissible route. The declarative widget is
a zero-size adapter whose `open` value controls a route: backdrop, Escape and
system back request `onOpenChange(false)`, and the parent accepts or rejects the
request. Route configuration follows widget updates; unmounting removes the
owned route. Flutter manages modal semantics, focus isolation/restoration and
navigation. Dialog content respects safe areas and keyboard insets.
