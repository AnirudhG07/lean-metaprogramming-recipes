import VersoManual
import Cookbook.Lean

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean

open Lean Elab Meta Tactic Command
open Cookbook

set_option pp.rawOnError true


#doc (Manual) "How to build a Recipe" =>

%%%
tag := "building-recipe"
number := false
%%%

{index}[How to build a Recipe]

This chapter demonstrates the standard layout and features available for cookbook entries. Make sure to visit the website to see how the documentation is rendered and to get a better sense of how to structure your recipe.
You can use the template recipe  as a starting point.

This cookbook is built using Verso, hence understanding how to write in Verso is essential. Please go through this page to get familiar with writing styled documentation in Verso. You can also refer other recipes for the same or checkout the [Verso Manual](https://verso-user-manual.netlify.app/) for more detailed information.

# Adding Sections

Use the `#` symbol for top-level section like below. Each chapter should start with a clear problem statement and a summary of the solution. Just like `Introduction` here.

You can use `##` for subheaders to organize your content into sections. You can use `*` for a bolding - *Like this*.

# Formatting Text

## Adding inline Lean Code

You can include Lean code that is elaborated directly within the document. This is useful for small snippets.

```lean
def helloCookbook := "Welcome!"
```

## Errors and Warnings

Expected errors must be explicitly marked with `+error`. If the error message does not match exactly, the documentation build may fail.


## Cross-References

You can link to other sections using their tags: {ref "building-recipe"}[Back to top].

## Other Notes

You can add marginal notes like this.{margin}[Marginal notes are great for extra context.]
