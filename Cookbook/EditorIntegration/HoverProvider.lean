import VersoManual
import Cookbook.Lean

open Verso.Genre Manual Cookbook
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Term Tactic

set_option pp.rawOnError true

#doc (Manual) "Hover Providers" =>

%%%
tag := "hover-providers"
number := false
htmlSplit := .never
%%%

::: contributors
:::

{index}[Hover Providers]

When you hover your mouse over an identifier or keyword in your editor, a little
popup appears showing its type, its docstring, or what it does. Lean calls this
information a *hover*.

Unlike code actions, Lean does not have a special attribute like
`@[hover_provider]`. Instead, hover content comes directly from the *info
tree* — the record Lean keeps while elaborating every piece of syntax. The
hover handler walks this tree, finds the most specific node that covers the
cursor position, and shows its content.

There are three main ways to put your own information into that tree:

1. *Write a docstring on a `syntax` declaration* — the simplest way; Lean
   shows that docstring when the user hovers over your keyword.
2. *Call `addConstInfo`* — makes hovering over a custom token show the type
   and docstring of an existing Lean constant.
3. *Call `pushInfoLeaf` with a `TermInfo` node* — injects a specific
   expression and type directly at a syntax position.

# Docstrings on Custom Syntax

{index}[syntax docstring hover]

The easiest way to give your custom syntax a hover tooltip is to write a
`/-- ... -/` doc comment on the `syntax` declaration. Lean's hover handler
finds the docstring by looking up the *syntax kind* (the name you give in the
`(name := ...)` clause) in the environment.

```lean
/-- Computes the square of a `Nat`. -/
syntax (name := squareTerm) "square" term : term

@[term_elab squareTerm] def evalSquare : TermElab :=
    fun stx _expected => do
  let n ← elabTerm stx[1]
    (some (mkConst ``Nat))
  mkAppM ``Nat.mul #[n, n]

/-- info: 25 -/
#guard_msgs in
#eval square 5
```

Now hovering over the `square` keyword in any expression shows:

```
Computes the square of a `Nat`: `square n = n * n`.
```

No extra code is needed — just the docstring on the `syntax` declaration.

# `addConstInfo` — Point a Token to an Existing Constant

{index}[addConstInfo]

`addConstInfo` lets you say "when the user hovers over *this* piece of syntax,
show the type and docstring of *that* constant". It is useful when your custom
syntax is really just a renamed or abbreviated form of an existing definition.

The call stores a {lean}`Lean.Elab.TermInfo` node in the info tree with
`expr = mkConst name`. The hover handler finds it and shows the constant's full
signature, plus its docstring.

```lean
-- `natZero` is just Nat.zero spelled differently.
-- Hovering over `natZero` shows:
--   Nat.zero : Nat
-- ... along with Nat.zero's docstring.
elab "natZero" : term => do
  addConstInfo (← getRef) ``Nat.zero
  return mkConst ``Nat.zero

/-- info: 0 -/
#guard_msgs in
#eval natZero
```

The first argument to {name}`Lean.Elab.addConstInfo` is the syntax node to
*anchor* the hover on — `← getRef` returns the current reference point, which
is the syntax being elaborated. The second argument is the constant name.

# `pushInfoLeaf` — Inject a Type at a Syntax Position

{index}[pushInfoLeaf]

For more control, you can push a {lean}`Lean.Elab.TermInfo` leaf directly into
the info tree. This tells the hover handler "at *this* syntax position, the
expression is *X* and its type is *Y*".

The recipe below defines a `doubled` tactic that takes a number literal and
returns twice its value. By pushing a `TermInfo` leaf anchored at the *number
literal* token, hovering over the literal shows the computed doubled value and
its type.

```lean
elab "doubled" n:num : term => do
  let val := 2 * n.getNat
  -- Inject hover info at the `n` token:
  -- hovering over the number shows
  -- the doubled result and its type.
  pushInfoLeaf <| .ofTermInfo {
    elaborator := `doubled
    lctx        := ← getLCtx
    expr        := mkNatLit val
    stx         := n
    expectedType? :=
      some (mkConst ``Nat)
    isBinder := false
  }
  return mkNatLit val

/-- info: 6 -/
#guard_msgs in
#eval doubled 3
```

Hovering over the `3` in `doubled 3` now shows:

```
6 : Nat
```

The fields of {lean}`Lean.Elab.TermInfo` you need to fill in are:
- `elaborator` — a name for the elaborator that created this node (used in
  diagnostics; any `Name` works).
- `lctx` — the current local context, obtained with `← getLCtx`.
- `expr` — the expression to show on hover.
- `stx` — the syntax position to anchor the hover on.
- `expectedType?` — the type to show alongside `expr`.
- `isBinder` — `true` only for variable binders like function parameters.
