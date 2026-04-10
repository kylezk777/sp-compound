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

| Category | Directory | Typical Content |
|----------|-----------|-----------------|
| best-practices | `.sp-compound/solutions/best-practices/` | Recommended approaches, coding standards, proven patterns |
| workflow-issues | `.sp-compound/solutions/workflow-issues/` | Development workflow improvements, process optimizations |
| developer-experience | `.sp-compound/solutions/developer-experience/` | Local dev setup, tooling, CI/CD friction, contributor ergonomics |
| documentation-gaps | `.sp-compound/solutions/documentation-gaps/` | Missing docs, unclear APIs, undocumented behavior |

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
