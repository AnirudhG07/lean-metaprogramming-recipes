import VersoManual
import MetaprogrammingRecipes.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open MetaprogrammingRecipes

set_option pp.rawOnError true

#doc (Manual) "Expressions" =>

# What are Expressions?
{index}[Expressions]

In Lean, everything is an `Expr`.

```lean
def hello := "Metaprogramming"
```

# Simple Definitions

```lean
def one := 1
def two := 2
```

# A Simple Theorem

```lean
theorem one_add_one : 1 + 1 = 2 := rfl
```
