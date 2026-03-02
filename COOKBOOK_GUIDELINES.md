# Lean 4 Metaprogramming Cookbook Guidelines

Welcome to the Lean 4 Metaprogramming Cookbook. We appreciate you taking out time and reading through this document, to help everyone code better with Lean4. This document outlines how you should contribute to the cookbook.

## Structure

The cookbook is organized into chapters, each focusing on a specific aspect of Lean 4 metaprogramming. Each chapter is a Lean file located in `MetaprogrammingRecipes/`. If you are reading this cookbook for the first time, please look at the website and start slowly.

> [!NOTE]
> As mentioned in README, this is not a book which will explain you concepts, you will have to get them from other books and resources of Lean4.

## Writing a New Recipe

Writing a new recipe is straightforward. Follow these steps to ensure your contribution is consistent with the existing content:

0. Make sure what you are writing is not already covered in the cookbook. Please consult in discussions before starting to write a new recipe. We want to avoid duplicates and ensure that we cover a wide range of topics.
1. **Create a New File**: Add a `.lean` file in `MetaprogrammingRecipes/{SUITABLE_CHAPTER}`.
2. **Import Common Modules**: Start your file with `import MetaprogrammingRecipes.Common`.
3. **Define the Document**: Use `#doc (Manual) "Your Title" =>`, to define the start of your document.
4. **Add Metadata**:
   ```lean
   %%%
   authors := ["Name1", "Name2"] -- Add your Github name if you contributed to this recipe
   %%%
   ```
5. **Use Sections**: Use `#` for top-level headers and `##` for sub-sections.
6. **Add to Main Doc**: Import your new file in `MetaprogrammingRecipes.lean` and include it using `{include 1 MetaprogrammingRecipes.YourFileName}`.

Please go through the [Example.lean](./MetaprogrammingRecipes/Example.lean) recipe for a template to follow, and check out the existing recipes for style and formatting.

## Best Practices

- **Atomic Examples**: Keep each recipe focused on one specific problem. It can be as simple as defining a simple Hello-world function, but it should be clearand concise.
- **Indexing**: Add index entries for key concepts: `{index}[My Concept]`.
- **Explain the "Why"**: Don't just show code; explain why a specific metaprogramming approach is used. Please mention any Pro-tips that you think are useful.
- **Cross-Reference**: Link to related recipes using `{ref "tag"}[text]` if needed.
- **Run Locally**: Always build your changes locally with `lake build metaprogramming-recipes && lake exe metaprogramming-recipes` before pushing.

## Building and Previewing

To build the HTML documentation:

```bash
lake build metaprogramming-recipes
lake exe metaprogramming-recipes
```

The output will be in `_out/html-multi`. You can serve it locally using any static file server (e.g., `python3 -m http.server -d _out/html-multi`).
