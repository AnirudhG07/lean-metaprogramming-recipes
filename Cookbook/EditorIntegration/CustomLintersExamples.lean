import VersoManual
import Cookbook.Lean
import Cookbook.EditorIntegration.CustomLinters

open Verso.Genre Manual Cookbook
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Tactic Command

set_option pp.rawOnError true

#doc (Manual) "Custom Linters: Examples" =>

%%%
tag := "custom-linters-examples"
number := false
htmlSplit := .never
%%%

::: contributors
:::

{index}[Custom Linters: Examples]

This recipe demonstrates the linters defined in
{ref "custom-linters"}[Custom Linters]. Because `register_option` registers its
option at module-import time, the options are only available after that module is
imported — which is why these examples live in a separate file.

Linter options are enabled using `set_option` *before* the definition they should
check, not with the `set_option ... in` form: the `in` form wraps the whole
command, and the linter then sees the outer `set_option` syntax node rather than
the inner `declaration`, causing the linter's kind-guard to return early.

# Warning Linter Demo

`set_option linter.allCapsName true` enables the naming-convention linter.
Camel-cased names pass silently.

```lean
section
set_option linter.allCapsName true

def MAXRETRIES : Nat := 5

def maxRetries : Nat := 5   -- no warning

end
```

# Error Linter Demo

When {name}`linter.todoInName` is enabled, any definition whose name contains `TODO`
or `FIXME` becomes a red error.

```lean
section
set_option linter.todoInName true

/-- error: Name `sortListTODO` is a placeholder -/
#guard_msgs in
def sortListTODO (xs : List Nat) : List Nat := xs

end
```

# Info Linter Demo

{name}`linter.noDocstring` emits a blue information message for undocumented definitions.
Adding a doc comment silences it.

```lean
section
set_option linter.noDocstring true

def noDocHelper (x : Nat) : Nat := x + 1

/-- Increments a natural number. -/
def documentedHelper (x : Nat) : Nat := x + 1

end
```
