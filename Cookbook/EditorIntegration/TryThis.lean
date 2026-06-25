import VersoManual
import Cookbook.Lean

open Verso.Genre Manual Cookbook
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Tactic Command

set_option pp.rawOnError true

#doc (Manual) "Try This Suggestions" =>

%%%
tag := "try-this-suggestions"
number := false
htmlSplit := .never
%%%

::: contributors
:::

{index}[Try This Suggestions]

A *"Try this"* suggestion is the clickable hint that appears in the
infoview when tactics like `exact?`, `apply?`, and `simp?` find a solution.
Clicking the link (or accepting the lightbulb code action) replaces the
current term or tactic with the suggestion. The mechanism is built on
Lean's widget and info-tree infrastructure, exposed through the `TryThis`
namespace (`Lean.Meta.Tactic.TryThis`).

An example recipe using {lean}`TryThis.addSuggestion` inside a tactic is
in {ref "replacing-with-what-works"}[Replacing with What Works].
This recipe covers the underlying API in more detail.

# The `TryThis.Suggestion` Type

{index}[TryThis.Suggestion]

The core data type is {lean}`TryThis.Suggestion`. Its key fields are:

- `suggestion : TryThis.SuggestionText` — the replacement text. Coercions
  from {lean}`String` and `TSyntax kind` mean you rarely construct `SuggestionText`
  directly.
- `preInfo?`, `postInfo?` — optional strings shown immediately before/after
  the suggestion in the infoview widget.
- `messageData? : Option MessageData` — if set, displayed *instead of*
  `suggestion` in the widget message. Useful when the pretty-printed form
  should carry hover information.
- `toCodeActionTitle? : Option (String → String)` — controls the lightbulb
  menu text. Default: `"Try this: " ++ suggestion`.

Coercions from `String` and `TSyntax` make construction concise:

```lean
-- from String
def tts1 : TryThis.Suggestion := "exact rfl"

-- from TSyntax, with extra postInfo
elab "hintTactic" t:tactic : tactic => do
  TryThis.addSuggestion (← getRef) {
    suggestion := t
    postInfo? := " -- from hint"
  }
```

# `addSuggestion`

{index}[addSuggestion]

{lean}`TryThis.addSuggestion` is the primary primitive. It logs an info
message with a clickable suggestion and registers the associated code action:

```lean
#check @TryThis.addSuggestion
-- TryThis.addSuggestion :
--   Syntax → TryThis.Suggestion
--   → ... → CoreM Unit
```

Key parameters:
- `ref : Syntax` — where the widget and code action appear.
- `s : Suggestion` — the suggestion to display.
- `origSpan? : Option Syntax` — the span to *replace*; defaults to `ref`.
- `header : String` — message prefix; default `"Try this:"`.
- `codeActionPrefix? : Option String` — lightbulb label prefix;
  default `"Try this: "`.
- `diffGranularity` — how to render the inline diff preview.

A minimal tactic that always suggests `rfl`:

```lean
elab "tryRfl" : tactic => do
  TryThis.addSuggestion (← getRef) "rfl"
-- in the infoview: Try this: rfl
```

For multiple suggestions at once, use {lean}`TryThis.addSuggestions`:

```lean
elab "tryRflOrDecide" : tactic => do
  TryThis.addSuggestions (← getRef)
    #["rfl", "decide"]
```

# CoreM Constraint

{index}[liftCoreM]

`addSuggestion` lives in {lean}`CoreM`. In `TacticM` and `MetaM` this is
automatic — the monad stack already includes `CoreM`. In `CommandElabM`
it is not, and you must lift with {lean}`Command.liftCoreM`:

```lean
elab "#tryHint" : command =>
  Command.liftCoreM do
    TryThis.addSuggestion
      (← getRef) "exact rfl"
```

# `MessageData.hint` — the Newer API

{index}[MessageData.hint]

`addSuggestion` is implemented on top of {lean}`Lean.MessageData.hint`,
a more composable interface that returns `MessageData` (instead of logging
immediately) and renders an *inline diff* in the infoview:

```lean
#check @MessageData.hint
-- MessageData.hint :
--   MessageData → Array Hint.Suggestion
--   → ... → CoreM MessageData
```

{lean}`Hint.Suggestion` extends `TryThis.Suggestion` with:
- `span? : Option Syntax` — where to apply this suggestion (overrides the
  `ref` argument).
- `diffGranularity : Hint.DiffGranularity` — per-suggestion diff granularity:
  `.auto`, `.char`, `.word`, `.all`, or `.none`.

Using `MessageData.hint` directly gives control over the surrounding message:

```lean
elab "#hintCmd" : command =>
  Command.liftCoreM do
    let msg ← MessageData.hint
      m!"Consider using Nat.succ:"
      #[{ suggestion := "Nat.succ n" }]
    logInfoAt (← getRef) msg
```

# How It Works: Info Trees

{index}[Info Trees]

`addSuggestion` (via `MessageData.hint`) inserts a leaf into the *info
tree* — the elaboration metadata Lean records for every elaborated node.
This leaf carries a {lean}`TryThis.TryThisInfo` value containing the text
edit and code action title.

The built-in provider `tryThisProvider`
(`@[builtin_code_action_provider]`) scans the info tree whenever the cursor
moves, finds `TryThisInfo` leaves overlapping the cursor, and returns a
{lean}`Lean.Server.LazyCodeAction` for each:

```lean
#check @Lean.Server.LazyCodeAction
-- structure LazyCodeAction where
--   eager : CodeAction
--   lazy? : Option (IO CodeAction)
```

`eager` is sent to the editor immediately (cheap); `lazy?` runs only when
the user accepts the action. `tryThisProvider` uses only `eager`, since
the edit is already pre-computed.

# Specialized Code Action Attributes

{index}[command_code_action]
{index}[hole_code_action]

Rather than writing a full {lean}`Lean.Server.CodeActionProvider` from
scratch, three focused attributes are available:

- *`@[command_code_action]`* — registered on a {lean}`Lean.CodeAction.CommandCodeAction`
  function; called on every command. Used by `#guard_msgs` to offer its
  replacement suggestion.
- *`@[tactic_code_action]`* (Batteries) — same idea for tactic nodes.
- *`@[hole_code_action]`* — called on holes (`_`, `?_`, `sorry`);
  registered on a {lean}`Lean.CodeAction.HoleCodeAction` function.

All three are implemented in terms of the lower-level
`@[code_action_provider]` / `@[builtin_code_action_provider]` attribute.
