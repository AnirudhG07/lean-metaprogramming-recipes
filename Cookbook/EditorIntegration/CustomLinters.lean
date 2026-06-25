import VersoManual
import Cookbook.Lean

open Verso.Genre Manual Cookbook
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Tactic Command

set_option pp.rawOnError true

#doc (Manual) "Custom Linters" =>

%%%
tag := "custom-linters"
number := false
htmlSplit := .never
%%%

::: contributors
:::

{index}[Custom Linters]

Lean's linter infrastructure lets you register checks that run automatically after every command.
A linter is a value of type {lean}`Lean.Elab.Command.Linter` — a structure with a single
field `run : Syntax → CommandElabM Unit` — registered globally with
{lean}`Lean.Elab.Command.addLinter`.
Each linter is paired with a {lean}`Bool` option created by `register_option`
so that users can silence it with `set_option linter.xxx false`.

Three severity levels are available, matching the editor colours:

- {name}`Lean.Linter.logLint` — yellow warning; also appends a note about how to disable the linter
- {name}`Lean.logErrorAt` — red error
- {name}`Lean.logInfoAt` — blue information message

Because `register_option` registers its option at *module-import time*, the option is only
known to `set_option` after the defining module is imported. The demos that trigger each
linter therefore live in a separate recipe,
{ref "custom-linters-examples"}[Custom Linters: Examples].

# Warning Linter

{index}[Warning linter]

The linter below warns when any definition or theorem has a name written entirely in
uppercase — a style that conflicts with Lean's camelCase convention.

The `run` field receives the full syntax of each command. The linter checks whether it is
a {lean}`Lean.Parser.Command.declaration`, then traverses the syntax tree with
{lean}`Lean.Syntax.topDown` to find the first {lean}`Lean.Parser.Command.declId` node,
from which the declared name can be read.

```lean
register_option linter.allCapsName : Bool := {
  defValue := false
  descr := "warn when a definition name is all-uppercase"
}

def allCapsLinter : Lean.Elab.Command.Linter where
  run stx := do
    unless Lean.Linter.getLinterValue linter.allCapsName
               (← Lean.Linter.getLinterOptions) do return
    if stx.getKind !=
        ``Lean.Parser.Command.declaration then return
    for node in stx.topDown do
      if node.getKind ==
          ``Lean.Parser.Command.declId then
        let nameId := node[0]
        if nameId.isIdent then
          let name := nameId.getId.toString
          let hasLower := name.any Char.isLower
          let hasAlpha := name.any Char.isAlpha
          if !hasLower && hasAlpha && name.length > 1 then
            Lean.Linter.logLint linter.allCapsName nameId
              m!"Name `{name}` is all-caps; \
                prefer camelCase"
        break

initialize Lean.Elab.Command.addLinter allCapsLinter
```

# The `@[deprecated]` Attribute

{index}[deprecated attribute]

Lean ships with a built-in deprecation linter (`linter.deprecated`).
Marking a declaration with `@[deprecated]` causes any later use of that name to trigger
a yellow warning pointing readers to the replacement.

The replacement must be defined *before* the attribute is applied, since Lean resolves it
during elaboration. The `since` field records the version or date at which the deprecation
was introduced.

```lean
def add (a b : Nat) : Nat := a + b

@[deprecated add (since := "2.0")]
def plus (a b : Nat) : Nat := a + b

/-- warning: `plus` has been deprecated: Use `add` instead
---
info: 3 -/
#guard_msgs in
#eval plus 1 2
```

You can also provide a free-form message instead of a replacement name:

```lean
@[deprecated "use Nat.add directly" (since := "3.0")]
def legacyAdd (a b : Nat) : Nat := a + b
```

# Error Linter

{index}[Error linter]

`Lean.logErrorAt` produces a red error instead of a yellow warning. Use it for issues that
should block further work, not merely advisory notices.

The linter below treats any declaration whose name contains `TODO` or `FIXME` as an error.

```lean
register_option linter.todoInName : Bool := {
  defValue := false
  descr := "error when a name contains TODO or FIXME"
}

def todoInNameLinter : Lean.Elab.Command.Linter where
  run stx := do
    unless Lean.Linter.getLinterValue linter.todoInName
               (← Lean.Linter.getLinterOptions) do return
    if stx.getKind !=
        ``Lean.Parser.Command.declaration then return
    for node in stx.topDown do
      if node.getKind ==
          ``Lean.Parser.Command.declId then
        let nameId := node[0]
        if nameId.isIdent then
          let name := nameId.getId.toString
          if (name.splitOn "TODO").length > 1
              || (name.splitOn "FIXME").length > 1 then
            logErrorAt nameId
              m!"Name `{name}` is a placeholder"
        break

initialize Lean.Elab.Command.addLinter todoInNameLinter
```

# Info Linter

{index}[Info linter]

`Lean.logInfoAt` produces a blue informational message with no squiggly underline —
appropriate for helpful hints that do not indicate a mistake.

The linter below suggests adding a doc comment to undocumented definitions.
`stx[0]` holds the `declModifiers` node; `stx[0][0]` is the slot for the optional
doc-comment. Its kind equals {lean}`Lean.Parser.Command.docComment` exactly when a doc comment
is present.

```lean
register_option linter.noDocstring : Bool := {
  defValue := false
  descr := "suggest doc comments on public defs"
}

def noDocstringLinter : Lean.Elab.Command.Linter where
  run stx := do
    unless Lean.Linter.getLinterValue linter.noDocstring
        (← Lean.Linter.getLinterOptions) do return
    if stx.getKind !=
        ``Lean.Parser.Command.declaration then return
    let hasDoc :=
      stx[0][0].getKind ==
        ``Lean.Parser.Command.docComment
    unless hasDoc do
      for node in stx.topDown do
        if node.getKind == ``Lean.Parser.Command.declId then
          let nameId := node[0]
          if nameId.isIdent then
            logInfoAt nameId
              m!"Consider adding a doc comment \
                to `{nameId.getId.toString}`"
          break

initialize Lean.Elab.Command.addLinter noDocstringLinter
```

# Squiggly Underline Range

{index}[squiggly underline]
{index}[diagnostic range]

The yellow squiggly underline that appears in the editor is not separate from
the warning message — it is the *range* of the syntax node you pass to
{name}`Lean.Linter.logLint` (or {name}`Lean.logWarningAt`). Lean translates
that range directly into an LSP diagnostic, and the editor draws the squiggly
under exactly that span.

*Narrow squiggly* — pass only the identifier node (`nameId`). Only the
function name gets underlined. This is what all the examples in this chapter
do: `logLint opt nameId msg`.

*Wide squiggly* — pass the whole command syntax (`stx`). The squiggly
stretches across the entire declaration, from `def` to the final token.

```lean
register_option linter.squigglyDemo : Bool := {
  defValue := false
  descr := "demonstrate squiggly range control"
}

-- Narrow: only the declared name is underlined.
def narrowLinter : Lean.Elab.Command.Linter where
  run stx := do
    unless Lean.Linter.getLinterValue linter.squigglyDemo
        (← Lean.Linter.getLinterOptions) do return
    if stx.getKind !=
        ``Lean.Parser.Command.declaration then return
    for node in stx.topDown do
      if node.getKind ==
          ``Lean.Parser.Command.declId then
        let nameId := node[0]
        -- Passing `nameId` underlines only the name.
        Lean.Linter.logLint linter.squigglyDemo nameId
          m!"narrow squiggly: just the name"
        break

-- Wide: the whole declaration is underlined.
def wideLinter : Lean.Elab.Command.Linter where
  run stx := do
    unless Lean.Linter.getLinterValue linter.squigglyDemo
        (← Lean.Linter.getLinterOptions) do return
    if stx.getKind !=
        ``Lean.Parser.Command.declaration then return
    -- Passing `stx` underlines the full command.
    Lean.Linter.logLint linter.squigglyDemo stx
      m!"wide squiggly: entire declaration"

initialize Lean.Elab.Command.addLinter narrowLinter
initialize Lean.Elab.Command.addLinter wideLinter
```

The same principle applies to `logErrorAt` and `logInfoAt`: whichever syntax
node you pass, that is the span that gets highlighted in the editor.
