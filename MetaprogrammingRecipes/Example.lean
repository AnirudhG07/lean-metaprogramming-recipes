import MetaprogrammingRecipes.Common

open Verso.Genre.Manual
open Verso.Genre.Manual.InlineLean
open MetaprogrammingRecipes

set_option pp.rawOnError true

#doc (Manual) "Template Example" =>

%%%
authors := ["Your Github Name"]
tag := "template-example"
%%%

-- This chapter demonstrates the standard layout and features available for cookbook entries.

# Introduction

Use the `#` symbol for top-level sections. Each chapter should start with a clear problem statement and a summary of the solution.

# Inline Lean Code

You can include Lean code that is elaborated directly within the document. This is useful for small snippets.

```lean
def helloCookbook := "Welcome!"
```

The output of a code block can be shown using `{leanOutput}`:

```lean (name := evalHello)
#eval helloCookbook
```
```leanOutput evalHello
"Welcome!"
```

# Extractable Code

The `{savedLean}` block is special: it's elaborated like `{lean}`, but also saved to a file in the `example-code` directory when the book is built. Use this for complete, standalone examples that readers might want to download.

```savedLean
def extractableFunction (n : Nat) : Nat := n + 1
```

You can also include comments specifically for the extracted file:

```savedComment
This comment will appear at the top of the extracted file!
```

# Errors and Warnings

Expected errors must be explicitly marked with `+error`:

```lean +error (name := typeError)
def bad : Nat := "not a nat"
```
```leanOutput typeError
Type mismatch
  "not a nat"
has type
  String
but is expected to have type
  Nat
```

# Cross-References

You can link to other sections using their tags: {ref "template-example"}[Back to top].

# Notes and Citations

You can add marginal notes like this.{margin}[Marginal notes are great for extra context.]
Citations can also be included if relevant references are defined in `Papers.lean`.
