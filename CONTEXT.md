# Command menu context

## Existing concepts

- **Catalog**: registered item metadata, including entries whose virtual rows
  have never been built.
- **Query**: the command's search string. A controlled parent decides whether
  to accept an edit; input reconciliation preserves active IME composition.
- **Result order**: the shared order consumed by layout and keyboard navigation.
- **Selection**: the selected item value, controlled by the parent or managed
  by the command controller.
- **Activation**: executing an item's selection callback through keyboard,
  submission, or pointer interaction.

See [ARCHITECTURE.md](ARCHITECTURE.md) for existing implementation behavior.

## Async result design in progress

The following terms and policy describe the agreed direction, not functionality
already implemented in the library.

- **Displayed results**: the last published result set retained in the menu.
  During an asynchronous search, these may belong to an earlier query.
- **Pending search**: a newer query is awaiting results. The input continues to
  update immediately; any search debounce must not delay text editing.
- **Pending activation policy**: retain previous results for display and show
  loading, but prevent activation of those results through Enter or pointer
  interaction. Reconcile selection when the new results are published.

Ownership of asynchronous execution, pending navigation, error handling, and
the precise selection reconciliation policy remain to be decided.

## Raycast example

The Raycast showcase demonstrates this policy using app-owned async search;
it does not add async execution to the library. The example owns debounce and
request generations, rejects outdated completions, and passes results to a
command with automatic filtering disabled. Pending or failed search retains
disabled rows and prevents footer actions. Successful publication selects the
first row in presentation order, even if the previous selection is still present.
Clearing the query immediately restores the catalog and selects Linear.
A red gradient line indicates pending search
without visible loading text; reduced motion keeps the gradient static. The
results viewport stays at a fixed height. Liquid Glass uses synchronous search.
These example choices do not settle the future library interface.
