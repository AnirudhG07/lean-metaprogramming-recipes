import VersoManual
import Cookbook.Lean

open Verso.Genre Manual Cookbook
open Verso.Genre.Manual.InlineLean

open Lean Elab Server RequestM Snapshots CodeAction Lsp

set_option pp.rawOnError true

#doc (Manual) "Code Actions" =>

%%%
tag := "code-actions"
number := false
htmlSplit := .never
%%%

::: contributors
:::

{index}[Code Actions]

A *code action* is the little lightbulb 💡 that appears in your editor when
your cursor is on certain code. When you click it, the editor offers a menu of
fixes and improvements. For example, `#guard_msgs` uses a code action to update
its expected output automatically.

In Lean, code actions are functions you register with special attributes. Each
function receives information about what is under the cursor, decides whether
it has something useful to offer, and returns a list of suggestions — or an
empty list if it has nothing to say.

The building block is {lean}`Lean.Server.LazyCodeAction`:

```lean
-- A code action has two parts:
-- (1) eager: shown immediately (keep this cheap!)
-- (2) lazy?: heavy work, run only when user accepts
#check @Lean.Server.LazyCodeAction
```

The `eager` part holds the `title` that appears in the lightbulb menu and an
optional `kind?` (`"quickfix"`, `"refactor"`, etc.). The `lazy?` part is an
`IO` computation that runs only when the user *accepts* the action — this is
where you do the heavy work, like building the replacement text.

Three flavors of code action attribute exist:

- *`@[command_code_action SyntaxKind?]`* — fires when the cursor is on a
  command (or a specific kind of command if you pass a syntax kind).
- *`@[hole_code_action]`* — fires when the cursor is on a hole (`_`, `?_`,
  or `sorry`).
- *`@[tactic_code_action]`* (Batteries) — fires on tactic nodes.

# Add a Docstring Template

{index}[command_code_action]

When you write a new `def` but forget to document it, wouldn't it be nice
if your editor could insert a starter docstring for you? This code action does
exactly that.

It fires only on `def` declarations that have no docstring yet. It reads the
function name and any explicit parameter names from the syntax tree, then
offers to insert a `/-- ... -/` block above the `def`.

```lean
@[command_code_action Lean.Parser.Command.declaration]
def addDocstringAction : CommandCodeAction :=
    fun _params _snap _ctx node => do
  -- Pull the command syntax out of the info tree node.
  let .node (.ofCommandInfo info) _ := node | return #[]
  let stx := info.stx
  -- Only act on `def`, not on `theorem`, `abbrev`, etc.
  if stx[1].getKind !=
      ``Lean.Parser.Command.definition then
    return #[]
  -- Do nothing if a docstring already exists.
  -- stx[0] = declModifiers; [0] = optional docComment.
  if stx[0][0].getKind ==
      ``Lean.Parser.Command.docComment then
    return #[]
  -- Read the function name from the declId node.
  let name := stx[1][1][0].getId.toString
  -- Walk the signature to collect explicit parameter names.
  -- stx[1][2] = optDeclSig (binders + return type).
  let sig := stx[1][2]
  let mut paramLines : Array String := #[]
  for binder in sig.getArgs do
    if binder.getKind ==
        ``Lean.Parser.Term.explicitBinder then
      for id in binder[1].getArgs do
        if id.isIdent then
          paramLines := paramLines.push
            s!"  {id.getId.toString} : ..."
  let argsSection :=
    if paramLines.isEmpty then ""
    else "\nArgs:\n" ++
      "\n".intercalate paramLines.toList
  let doc ← readDoc
  let eager : CodeAction := {
    title := s!"Add docstring to `{name}`"
    kind? := "quickfix"
  }
  return #[{
    eager
    lazy? := some do
      -- Insert just before the start of the declaration.
      let some startPos := stx.getPos? true | return eager
      let insertRange :=
        doc.meta.text.utf8RangeToLspRange
          ⟨startPos, startPos⟩
      return { eager with
        edit? := some <| .ofTextEdit
          doc.versionedIdentifier {
            range := insertRange
            newText :=
              s!"/--\n{name}{argsSection}\n-/\n"
          }
      }
  }]
```

Given `def add (x y : Nat) : Nat := x + y`, placing the cursor on it and
clicking the lightbulb inserts:

```
def add (x y : Nat) : Nat := x + y
```

# Wrap a Command in a Block Comment

{index}[comment out code action]

Sometimes you want to quickly disable a command without deleting it. This
code action offers to wrap any command in `/-` `-/`, which comments it out.

This is a good example of "enclosing" — wrapping existing code in something
new. The key steps are: read the original text of the command, then replace
that range with the wrapped version.

```lean
@[command_code_action]
def commentOutAction : CommandCodeAction :=
    fun _params _snap _ctx node => do
  let .node (.ofCommandInfo info) _ := node | return #[]
  let stx := info.stx
  let doc ← readDoc
  let eager : CodeAction := {
    title := "Wrap in block comment (/- -/)"
    kind? := "refactor"
  }
  return #[{
    eager
    lazy? := some do
      let some startPos := stx.getPos? true | return eager
      let some endPos := stx.getTailPos? true | return eager
      -- Read the original source text of the command.
      let original := String.Pos.Raw.extract
        doc.meta.text.source startPos endPos
      let range := doc.meta.text.utf8RangeToLspRange
        ⟨startPos, endPos⟩
      return { eager with
        edit? := some <| .ofTextEdit
          doc.versionedIdentifier {
            range
            newText := s!"/-\n{original}\n-/"
          }
      }
  }]
```

Placing the cursor on `def foo := 42` and accepting gives:

/-
def foo := 42
-/

# Replace a Hole with `sorry`

{index}[hole_code_action]

This code action fires on holes — the `_` and `?_` placeholders Lean uses when
it needs you to fill in a proof or value. It offers to replace the hole with
`sorry`, which is handy when you want to silence a "don't know how to fill
this" error temporarily so you can keep elaborating the rest of the file.

{lean}`Lean.CodeAction.HoleCodeAction` receives a {lean}`Lean.Elab.TermInfo`
(elaboration info about the hole) instead of a full `InfoTree`, so working
with it is simpler:

```lean
@[hole_code_action]
def holeToSorryAction : HoleCodeAction :=
    fun _params _snap _ctx info => do
  let doc ← readDoc
  let eager : CodeAction := {
    title := "Replace hole with sorry"
    kind? := "quickfix"
  }
  return #[{
    eager
    lazy? := some do
      -- The hole syntax tells us what to replace.
      let some startPos :=
        info.stx.getPos? true | return eager
      let some endPos :=
        info.stx.getTailPos? true | return eager
      let range := doc.meta.text.utf8RangeToLspRange
        ⟨startPos, endPos⟩
      return { eager with
        edit? := some <| .ofTextEdit
          doc.versionedIdentifier {
            range
            newText := "sorry"
          }
      }
  }]
```

Clicking the lightbulb on `_` in `example : 1 = 1 := _` replaces it with
`sorry`.
