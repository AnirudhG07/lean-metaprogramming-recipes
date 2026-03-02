import VersoManual
import MetaprogrammingRecipes.Lean

-- Chapter Aggregator (for imports)
import MetaprogrammingRecipes.Chapters
import MetaprogrammingRecipes.Index

-- This gets access to most of the manual genre (which is also useful for textbooks)
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks, elaborated in the same process and
-- environment as Verso
open Verso.Genre.Manual.InlineLean


open MetaprogrammingRecipes

set_option pp.rawOnError true


#doc (Manual) "Lean 4 Metaprogramming Cookbook" =>

Welcome to the *Lean 4 Metaprogramming Cookbook*, a practical guide
to writing metaprogramming Lean4 code. This cookbook provides from
simple examples to more complex ones which you can easily understand
and integrate in your code.

If you are new to Lean 4, We recommend you to start with the basics
of Lean4 before you jump into the metaprogramming part. You can find
the official documentation and tutorials on the Lean 4 website.

If want to write metaprogramming code in Lean 4, this is the right
place to find the recipes you need. We have organized the recipes into
different chapters, each focusing on a specific aspect of
metaprogramming in Lean 4. You can find the chapters below:

Special thanks to the contributors who have shared their knowledge
and experience in programming with Lean 4, making this cookbook
possible. We hope that this resource will be helpful for both beginners
and experienced programmers looking to deepen their understanding of
Lean 4.

{include 1 MetaprogrammingRecipes.Expressions}

{include 1 MetaprogrammingRecipes.Syntax}

{include 1 MetaprogrammingRecipes.Index}
