# Category-to-Directory Mapping

Category determines which directory under `.sp-compound/solutions/` the document belongs to, and which track (bug or knowledge) applies.

## Bug Track Categories

| Category | Directory | Typical Problems |
|----------|-----------|-----------------|
| build-errors | `.sp-compound/solutions/build-errors/` | Compilation failures, dependency conflicts, build tool issues |
| test-failures | `.sp-compound/solutions/test-failures/` | Flaky tests, test infrastructure, assertion issues |
| runtime-errors | `.sp-compound/solutions/runtime-errors/` | Crashes, exceptions, unexpected behavior at runtime |
| performance-issues | `.sp-compound/solutions/performance-issues/` | Slow queries, memory leaks, high latency |
| database-issues | `.sp-compound/solutions/database-issues/` | Migration failures, connection issues, schema problems |
| security-issues | `.sp-compound/solutions/security-issues/` | Vulnerabilities, auth issues, data exposure |
| ui-bugs | `.sp-compound/solutions/ui-bugs/` | Rendering issues, interaction bugs, layout problems |
| integration-issues | `.sp-compound/solutions/integration-issues/` | API failures, third-party service issues, webhook problems |
| logic-errors | `.sp-compound/solutions/logic-errors/` | Business logic bugs, incorrect calculations, state machine issues |

## Knowledge Track Categories

Prefer the narrowest applicable value. `best-practices` is the fallback when no narrower knowledge-track category fits.

| Category | Directory | Typical Content |
|----------|-----------|-----------------|
| architecture-patterns | `.sp-compound/solutions/architecture-patterns/` | Architectural or structural patterns (agent/skill/pipeline/workflow shape decisions) |
| design-patterns | `.sp-compound/solutions/design-patterns/` | Reusable non-architectural design approaches (interaction patterns, prompt shapes, content generation) |
| tooling-decisions | `.sp-compound/solutions/tooling-decisions/` | Language, library, or tool choices with durable rationale |
| conventions | `.sp-compound/solutions/conventions/` | Team-agreed way of doing something, captured so it survives turnover |
| workflow-issues | `.sp-compound/solutions/workflow-issues/` | Development workflow improvements, process optimizations |
| developer-experience | `.sp-compound/solutions/developer-experience/` | Local dev setup, tooling, CI/CD friction, contributor ergonomics |
| documentation-gaps | `.sp-compound/solutions/documentation-gaps/` | Missing docs, unclear APIs, undocumented behavior |
| best-practices | `.sp-compound/solutions/best-practices/` | Fallback — use only when no narrower knowledge-track category applies |

## Derived Documents

| Category | Directory | Typical Content |
|----------|-----------|-----------------|
| patterns | `.sp-compound/solutions/patterns/` | Recurring solutions abstracted from multiple learnings |

## Filename Convention

```
.sp-compound/solutions/<category>/YYYY-MM-DD-<descriptive-slug>.md
```

Example: `.sp-compound/solutions/runtime-errors/2026-03-31-redis-pool-exhaustion.md`

## Pattern Documents

Pattern docs live in `.sp-compound/solutions/patterns/` and are DERIVED from multiple learning docs. They:
- Generalize a recurring solution across modules
- Reference the specific learnings they're derived from (use `derived_from` in frontmatter)
- Have `track: knowledge` in frontmatter
- Are higher-leverage but also higher-risk when stale

## YAML Safety Rules

Strict YAML 1.2 parsers (`yq`, `js-yaml` strict, PyYAML) reject array items that start with a reserved indicator character as unquoted scalars. When writing items for any array-of-strings frontmatter field (`tags`, `related_files`, `applies_when`, `symptoms`, `derived_from`, or any future array field), wrap the value in double quotes if it:

- starts with any of: `` ` ``, `[`, `*`, `&`, `!`, `|`, `>`, `%`, `@`, `?`
- contains the substring `: ` (confuses flow-style parsers)

Example — before (breaks strict YAML):

    tags:
      - `rails-console`-specific
      - fix: edge-case

Example — after (parses cleanly):

    tags:
      - "`rails-console`-specific"
      - "fix: edge-case"
