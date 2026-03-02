import VersoManual
import MetaprogrammingRecipes.Lean

-- This gets access to most of the manual genre
open Verso.Genre Manual

-- This gets access to Lean code that's in code blocks
open Verso.Genre.Manual.InlineLean

-- Open common Lean namespaces for metaprogramming
open Lean Elab Meta Tactic Command

-- Access to custom cookbook features
open MetaprogrammingRecipes
