import VersoManual
import Cookbook.Lean
import Cookbook.EditorIntegration.CustomLinters
import Cookbook.EditorIntegration.CustomLintersExamples
import Cookbook.EditorIntegration.CodeActions
import Cookbook.EditorIntegration.TryThis
import Cookbook.EditorIntegration.HoverProvider
import Cookbook.EditorIntegration.InlayHints

open Verso.Genre Manual Cookbook

#doc (Manual) "Editor Integration" =>

%%%
tag := "editor-integration"
number := false
%%%

::: contributors
:::

This chapter collects recipes for enriching the Lean developer experience through the editor. It covers tools that communicate back to the user: custom linters that flag problems automatically, code actions that offer interactive fixes, *Try this* suggestions that propose concrete terms or tactics, hover providers that surface computed information on demand, and inlay hints that annotate source code inline.

*Recipes:*

{include 1 Cookbook.EditorIntegration.CustomLinters}
{include 1 Cookbook.EditorIntegration.CustomLintersExamples}
{include 1 Cookbook.EditorIntegration.CodeActions}
{include 1 Cookbook.EditorIntegration.TryThis}
{include 1 Cookbook.EditorIntegration.HoverProvider}
{include 1 Cookbook.EditorIntegration.InlayHints}
