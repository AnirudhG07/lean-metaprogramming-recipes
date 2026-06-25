import VersoManual
import Cookbook.Lean

open Verso.Genre Manual Cookbook
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Term

set_option pp.rawOnError true

#doc (Manual) "Inlay Hints" =>

%%%
tag := "inlay-hints"
number := false
htmlSplit := .never
%%%

::: contributors
:::

{index}[Inlay Hints]

An *inlay hint* is the small greyed-out annotation that appears right in your
source code — not in the infoview, but inline, directly in the editor. You see
them when Lean shows `: Nat` after a variable whose type it inferred, or
`{u}` for auto-bound universe levels. They sit in the text without changing it,
and in most editors you can click them to actually insert the annotation.

Lean emits inlay hints by pushing {lean}`Lean.Elab.InlayHint` values into the
info tree as `CustomInfo` nodes. The server then walks the tree and sends them
to the editor via the LSP `textDocument/inlayHint` request.

The structure you fill in is {lean}`Lean.Elab.InlayHintInfo`:

```lean
#check @Lean.Elab.InlayHintInfo
-- structure InlayHintInfo where
--   position    : String.Pos.Raw
--   label       : InlayHintLabel
--   kind?       : Option InlayHintKind
--   textEdits   : Array InlayHintTextEdit
--   tooltip?    : Option String
--   paddingLeft : Bool
--   paddingRight: Bool
```

- `position` — the byte offset in the file where the hint is placed.
- `label` — the text to show, either `.name "some string"` or `.parts [...]`
  for multi-part labels with per-part tooltips and links.
- `kind?` — `.type` for type annotations, `.parameter` for argument labels.
  Editors use this to colour the hint differently.
- `textEdits` — if non-empty, the user can click the hint to apply these
  text edits (inserting the annotation into the source).
- `tooltip?` — markdown text shown when hovering over the hint.
- `paddingLeft`/`paddingRight` — whether to add a space on either side.

{lean}`Lean.Elab.InlayHint` extends `InlayHintInfo` with two more fields:
`lctx` (the local context, needed to run the deferred computation) and
`deferredResolution` (a `MetaM` action run lazily — explained in the
second recipe).

To emit a hint, call `pushInfoLeaf <| .ofCustomInfo hint.toCustomInfo`
inside any `TermElabM`, `TacticM`, or `CommandElabM` context.


# A Simple Type Annotation Hint

{index}[type annotation inlay hint]

This recipe defines an `annotate` elaborator. It wraps any term, computes
the inferred type with `ppExpr`, and places a `: Type` hint immediately after
the term in the editor.

`getTailPos?` gives the byte position of the last character of a syntax
node — that is where the hint goes.

```lean
elab (name := annotateTerm) "annotate" e:term : term => do
  let val  ← elabTerm e none
  let type ← inferType val
  -- Pretty-print the type in the current MetaM context.
  let typeStr := s!": {← ppExpr type}"
  let stx : Syntax := e
  if let some endPos := stx.getTailPos? true then
    pushInfoLeaf <| .ofCustomInfo {
      position     := endPos
      label        := .name typeStr
      kind?        := some .type
      textEdits    := #[]
      paddingLeft  := false
      paddingRight := false
      lctx         := ← getLCtx
      : InlayHint
    }.toCustomInfo
  return val

/-- info: 5 -/
#guard_msgs in
#eval annotate (2 + 3)
-- editor inline: (2 + 3): Nat
```

In the editor, `(2 + 3)` will appear followed by the greyed-out `: Nat` right
in the source file, without touching the actual text.

# Deferred Resolution, Tooltip and Click-to-Insert

{index}[deferredResolution]
{index}[inlay hint textEdit]

The `deferredResolution` field lets you separate two concerns:

- *Immediate*: a cheap, fast label shown right away (before the
  MetaM work has run). Lean renders this before resolution completes.
- *Deferred*: a `MetaM` computation that refines the hint —
  updating the label, adding a tooltip, or computing text edits.

This matters because `ppExpr` and `inferType` can be expensive. By putting
them in `deferredResolution`, you avoid blocking the editor while Lean is
still processing the rest of the file.

The recipe below extends `annotate` to:
- Show `: ?` immediately, then update to the real type once resolved.
- Add a markdown *tooltip* (hover over the hint to see it).
- Add a *text edit* so clicking the hint inserts `: Type` into the source.

```lean
elab (name := annotFull) "annotate!" e:term : term => do
  let val  ← elabTerm e none
  let stx  : Syntax := e
  let some endPos := stx.getTailPos? true | return val
  pushInfoLeaf <| .ofCustomInfo {
    position  := endPos
    -- Shown immediately while deferred work runs.
    label     := .name " : ?"
    kind?     := some .type
    textEdits := #[]
    lctx      := ← getLCtx
    deferredResolution := fun ih => do
      -- This MetaM block runs lazily.
      let type    ← inferType val
      let typeStr := s!" : {← ppExpr type}"
      return { ih with
        label    := .name typeStr
        tooltip? := some s!"Inferred type:{typeStr}"
        -- Clicking inserts the annotation at endPos.
        textEdits := #[{
          range   := ⟨endPos, endPos⟩
          newText := typeStr
        }]
      }
    : InlayHint
  }.toCustomInfo
  return val

/-- info: 5 -/
#guard_msgs in
#eval annotate! (2 + 3)
```

The hint starts as `: ?` and updates to `: Nat` once Lean has run the
deferred computation. Hovering over the hint shows the markdown tooltip,
and clicking it inserts ` : Nat` after `(2 + 3)` in your source.
