# Discoverability Check

Verify that project instruction files would lead agents to discover `.sp-compound/solutions/`.

## When to Run

Every time after writing or refreshing a knowledge store document.

## Assessment

Identify which root-level instruction files exist (`AGENTS.md`, `CLAUDE.md`, or both). Read the file(s) and determine which holds the substantive content -- one file may just be a shim that `@`-includes the other. The substantive file is the assessment and edit target; ignore shims. If neither file exists, skip this check entirely.

An agent reading the instruction files should learn three things:

1. **That a searchable knowledge store exists** — `.sp-compound/solutions/` is mentioned
2. **Enough about its structure to search effectively** — category organization, YAML frontmatter fields
3. **When to search it** — relevant when implementing or debugging in documented areas

This is a **semantic assessment**, not a string match. The information could be a line in an architecture section, a bullet in a gotchas section, spread across multiple places, or expressed without ever using the exact path `.sp-compound/solutions/`. Use judgment — if an agent would reasonably discover and use the knowledge store after reading the file, the check passes.

## If Already Discoverable

No action needed — move on.

## If Not Discoverable

1. **Prefer existing sections over new ones.** Before creating a new section, check whether the information could be a single line in the closest related section — an architecture tree, a directory listing, a documentation section, or a conventions block. A line added to an existing section is almost always better than a new headed section. Only add a new section as a last resort.
2. Draft the smallest addition that communicates the three things. Match the file's existing style and density. The addition should describe the knowledge store itself, not the plugin.
3. **Keep tone informational, not imperative.** Express timing as description, not instruction — "relevant when implementing or debugging in documented areas" rather than "check before implementing or debugging." Imperative directives like "always search before implementing" cause redundant reads when a workflow already includes a dedicated search step.
4. **Require user consent** before editing any instruction file. In full/interactive mode, explain why discoverability matters and use the platform's blocking question tool (`AskUserQuestion` in Claude Code, `request_user_input` in Codex, `ask_user` in Gemini) to get consent. In compact-safe/lightweight mode, output a one-liner note and move on. In autofix mode, include as a recommendation in the report — do not edit instruction files.

## Example Additions

When there is an existing directory listing or architecture section — add a line:
```
.sp-compound/solutions/  # documented solutions to past problems, organized by category with YAML frontmatter (module, tags, category)
```

When nothing in the file is a natural fit — a small headed section:
```markdown
## Documented Solutions

`.sp-compound/solutions/` — documented solutions to past problems (bugs, best practices, workflow patterns), organized by category with YAML frontmatter (`module`, `tags`, `category`). Relevant when implementing or debugging in documented areas.
```

These are calibration examples, not templates. Adapt to the file.
