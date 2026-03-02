import VersoManual
import MetaprogrammingRecipes.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open MetaprogrammingRecipes

set_option pp.rawOnError true

#doc (Manual) "Commands" =>

# What are Commands?
{index}[Commands]

Commands are instructions that change the environment.

# A Basic Command

```lean
open Lean Elab Command

elab "#ping" : command => do
  logInfo "pong"

#ping
```

# Constants

```lean
def pi := 3.14
```
