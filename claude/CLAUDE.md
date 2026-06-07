# General Preferences

These are my personal, cross-project preferences. They apply to every session.

## Communication

- Be concise and direct. Skip filler and restating the question.
- When something is ambiguous, ask before making large assumptions.
- Avoid technical jargon; use simpler, everyday terms instead.
- Keep written output as short as possible — I hate reading too much text. This applies especially to plans.
- I'm a visual learner: prefer visuals (diagrams, tables, ASCII sketches) over text whenever they can explain something.

## Code Style

- Prefer simple, readable solutions over clever ones.
- Match the existing style and conventions of the codebase.
- Prefer declarative code over imperative code: describe *what* the result should be rather than step-by-step *how* to compute it (e.g. map/filter over manual loops with mutation, configuration over procedural setup), as long as it stays readable.

## Comments

- Default to writing NO comments. Code should be self-documenting through clear naming and structure.
- Only add a comment when the WHY is non-obvious and cannot be expressed in code: a hidden constraint, a subtle invariant, a workaround for a specific bug, or behavior that would surprise a reader.
- Never write comments that restate what the code does, narrate changes ("added X", "now uses Y"), or explain syntax.
- Never write comments referencing the previous state of the code, especially after migrations or refactors ("was previously X", "replaced the old Y", "migrated from Z"). Git history is the record of what was there before — comments must only describe the code as it is now.
- Don't add docstrings, comments, or type annotations to code you didn't change.

## Workflow

- Never commit or push unless explicitly asked.
- When fixing a bug, explain the root cause, not just the fix.
