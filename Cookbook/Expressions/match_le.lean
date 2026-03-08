import VersoManual
import Cookbook.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Tactic Command
open Cookbook

set_option pp.rawOnError true

#doc (Manual) "Writing a function that matches an expression for inequality" =>

Suppose we want to inspect a goal to see if it is an inequality of the form `a ≤ b`, where a and b are natural numbers. If it is, we want to extract and print those values to the Infoview. Because this involves creating and assigning metavariables (temporary placeholders), we need to work inside the `MetaM` monad.

We will start by writing a function that takes an expression (`Expr`) as input. Its output will be an `Option (Expr × Expr)` wrapped inside the MetaM monad, allowing it to return the two sides of the inequality if a match is found, or none if it is not.

Therefore, the type signature of our function will be `Expr → MetaM (Option (Expr × Expr))`.

```lean
def match_le (e: Expr) : MetaM <| Option (Expr × Expr) := do
  let nat := mkConst ``Nat
  let a ← mkFreshExprMVar nat
  let b ← mkFreshExprMVar nat
  let ineq ← mkAppM ``Nat.le #[a, b]
  if (← isDefEq ineq e) then
    return some (a, b)
  else
    return none
```

`mkFreshExprMVar nat` constructs a metavariable of the type `nat`, where `nat` is an expression. This creates a blank hole that Lean can fill in later. `isDefEq ineq e` checks whether the constructed expression ineq and the target expression e are definitionally equal. Crucially, as it checks for equality, it attempts to unify them by assigning concrete values from e to our blank metavariables a and b.

Now, to see this function in action we write an elaborator that fetches the main goal during the proof and passes it to `match_le`.

```lean
elab "match_le" : tactic => do
  withMainContext do
  let goal ← getMainTarget
  match (← match_le (goal)) with
  | some (a, b) => logInfo m!"It is an inequality where
    a = {a}, b = {b}"
  | _ => logInfo m!"The goal is not an inequality"

example: 123 ≤ 234 := by
  match_le
  simp

```
