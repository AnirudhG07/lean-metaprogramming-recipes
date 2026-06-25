import VersoManual
import Cookbook.Lean
import Cookbook.Tactics.CheckingTactics

open Verso.Genre Manual Cookbook
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Tactic Command

set_option pp.rawOnError true

#doc (Manual) "Replacing with What Works" =>

%%%
tag := "replacing-with-what-works"
number := false
htmlSplit := .never
%%%

::: contributors
:::


{index}[Replacing with What Works]

A common tactic pattern is to *search* over possible completions and,
once one succeeds, emit a {ref "try-this-suggestions"}[Try this] suggestion
so the user can lock in the answer and avoid re-running the search on every
compilation. The API details for {lean}`TryThis.addSuggestion` are covered in
{ref "try-this-suggestions"}[Try This Suggestions].

Here we combine {lean}`TryThis.addSuggestion` with the `checkTactic` helper
from {ref "checking-tactics"}[Checking Tactics]: the tactic `check_tactic?`
tries each candidate in a list and suggests the first one that closes the goal.

```lean
syntax (name:= check_tactic) "check_tactic?"
  "[" tacticSeq,* "]" : tactic

@[tactic check_tactic] def checkTacticImpl : Tactic :=
  fun stx => withMainContext do
  match stx with
  | `(tactic| check_tactic? [$tacs,*]) =>
    for tac in tacs.getElems do
      let n? ← checkTactic
        (← getMainTarget) tac
      match n? with
      | some n =>
        if n = 0 then
          TryThis.addSuggestion stx tac
          evalTactic tac
          return
      | none =>
        logWarning m!"Tactic failed"
  | _ => throwUnsupportedSyntax

example : 2 ≤ 20 := by
  check_tactic? [rfl, decide, grind]
```
