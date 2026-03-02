import VersoManual
import MetaprogrammingRecipes.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open MetaprogrammingRecipes

set_option pp.rawOnError true

#doc (Manual) "Tactics" =>

# What are Tactics?

Tactics are used to build proofs.

# A Basic Tactic

```lean
open Lean Elab Tactic

elab "hello_tactic" : tactic => do
  evalTactic (← `(tactic| skip))

example : 1 = 1 := by
  hello_tactic
  rfl
```
