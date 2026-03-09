import VersoManual
import Cookbook.Lean

-- Chapter Aggregator (for imports)
import Cookbook.Chapters
import Cookbook.Index
import Cookbook.Example

open Verso.Genre Manual
open Verso.Genre.Manual.InlineLean


open Cookbook

set_option pp.rawOnError true


#doc (Manual) "Lean 4 (Meta)programming Cookbook" =>

Welcome to the *Lean 4 (Meta)programming Cookbook*, a collection of recipes and examples for
programming and metaprogramming in Lean4. This cookbook provides a wide range of recipes, from basic to advanced which you can easily understand and integrate in your code.

If you are new to Lean 4, we recommend you to start with the basics
of Lean4 and use this resource to help you get started. You can find
the official documentation and tutorials on the Lean 4 website.

If want to write metaprogramming code in Lean 4, this is the right
place to find the recipes you need. We have organized the recipes into
different chapters, each focusing on a specific aspect of
metaprogramming in Lean 4. You can find the chapters below:

We hope that this resource will be helpful for both beginners
and experienced programmers looking to deepen their understanding of
Lean 4.

{include 1 Cookbook.Expressions}

{include 1 Cookbook.Syntax}

{include 1 Cookbook.Example}

{include 1 Cookbook.Index}

{include 1 Cookbook.workingWithFilesAndExternalProgramsNotMetaprogramming}

{include 1 Cookbook.workingWithSyntax}

{include 1 Cookbook.workingWithExpressions}

{include 1 Cookbook.extendingSyntax}

{include 1 Cookbook.maintainingState}

{include 1 Cookbook.workingWithTactics}
