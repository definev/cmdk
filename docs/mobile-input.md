# Mobile command input

Command search is an editing session. Its text, caret, selection, composing range
and focus must survive result updates. The application chooses the surrounding
panel layout independently of the editor implementation.

## Framework editors

Use `materialCommandInputBuilder` from `package:cmdk/material.dart` under a
Material application, or `cupertinoCommandInputBuilder` from
`package:cmdk/cupertino.dart` under a Cupertino application. Both build a full
framework field without decoration; the command input retains its outer visual
composition. Flutter owns touch gestures, platform word boundaries, handles,
magnifier, clipboard actions, caret reveal and accessibility behavior.

The widgets-only default remains useful for custom design systems, but its
`EditableText` provides basic gestures and no default selection toolbar. It is
not a substitute for the framework adapters on a production phone UI.

The optional adapters retain SDK imports to support the declared Flutter >=3.24
range. Applications using the standalone `material_ui` or `cupertino_ui` design
libraries can supply their own editor builder without coupling the core to
either generation of design-system types.

## Editor seam

`CommandInput.editorBuilder(context, editor)` supplies a `CommandInputEditor`.
The builder must use its `controller` and `focusNode` and wire both
`onEditingComplete` and `onSubmitted`. It must not dispose these objects.
Keyboard configuration and visual settings are available on the same binding.
Prefix/suffix, placeholder and outer decoration are supplied by `CommandInput`.

The command input alone synchronizes text with `CommandController.search` and
publishes query edits. An editor builder should not add a second search listener,
submit handler or composition pipeline. Application-specific submission belongs
in a `CommandActivateIntent` action override so physical and soft activation
share it.

## Keyboard configuration

The defaults request:

| Setting | Default | Reason |
| --- | --- | --- |
| Autocorrect | Off | Avoid replacing command names or identifiers |
| Suggestions | On | Keep useful IME candidates available |
| Capitalization | None | Preserve the entered command casing |
| Smart quotes / dashes | Off | Preserve literal punctuation |
| Keyboard action | Search | Submit the current selected result |
| Keyboard appearance | Native adapter's theme | Follow the host application |

The first four settings, appearance and caret `scrollPadding` are configurable.
IME support varies; enabling suggestions is a request, not a guarantee about
what a particular keyboard displays. Flutter/native keyboard configuration may
take effect on the next focus session; the command input never tears down a
focused session merely to refresh a keyboard option.

Do not lowercase, trim or normalize the visible editing buffer on every
keystroke. Normalize for matching in the search/filter layer. For remote search,
accept the local controlled query immediately and debounce the remote request
separately. Debouncing text ownership itself can make the editor roll back what
the user is typing.

## Composition and synchronization

Composing text participates in live search, including incremental Vietnamese
IME edits. An active composing range blocks command activation and navigation
shortcuts. A soft Search notification during composition leaves both the buffer
and focus intact; the library does not clear composing to turn it into a command.

If an authoritative controlled/programmatic query differs from a focused IME
buffer, replacement is deferred. When composition commits (even if only the
composing range changes), the latest authoritative query is reconciled. Focus
loss also flushes a pending replacement. Accepted edits with equal text keep the
full editing value. Programmatic replacements preserve selection direction and
clamp offsets to the new text; they do not echo user-edit callbacks.

Moving the caret, selecting a word and copying do not publish query edits.
Paste/replace edits publish the resulting text once through the same search
pipeline as typing. The command input does not parse or implement Vietnamese
keyboard rules; the platform IME owns those rules.

## Submission and focus

Search invokes the nearest enabled `CommandActivateIntent`. It retains focus by
default when the panel remains mounted, including when there is no enabled
result. `unfocusOnSubmit: true` unfocuses before an enabled soft submission; it
does not alter the behavior of physical Enter. If a command navigates or closes
the panel, the input never tries to restore its previous focus afterwards.

The prefix/suffix participate in a `TextFieldTapRegion`. A suffix clear button
may call an external text controller's `clear()`; this remains an input edit and
does not trigger outside-click dismissal. The application supplies the clear
button's label and touch target. Panel outside-tap dismissal remains owned by
the presentation layer.

## Verification

`test/mobile_input_test.dart` exercises the widgets-only editor and the actual
Material/Android and Cupertino/iOS adapters. It covers keyboard configuration,
focus on submit, composition protection, accepted/rejected controlled edits,
deferred query reconciliation and native word selection/clipboard behavior.
The wider keyboard suite checks routing, overrides and held-key behavior.

These are widget tests with simulated platform IME messages. Device verification
is still needed for Gboard/iOS Vietnamese input, keyboard candidate UI and OS
text-selection affordances. Adaptive panel sizing is a separate concern.
