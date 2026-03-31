# Category-to-Directory Mapping

Problem type determines which directory under `docs/solutions/` the document belongs to.

| Category | Directory | Typical Problems |
|----------|-----------|-----------------|
| build-errors | `docs/solutions/build-errors/` | Compilation failures, dependency conflicts, build tool issues |
| test-failures | `docs/solutions/test-failures/` | Flaky tests, test infrastructure, assertion issues |
| runtime-errors | `docs/solutions/runtime-errors/` | Crashes, exceptions, unexpected behavior at runtime |
| performance-issues | `docs/solutions/performance-issues/` | Slow queries, memory leaks, high latency |
| database-issues | `docs/solutions/database-issues/` | Migration failures, connection issues, schema problems |
| security-issues | `docs/solutions/security-issues/` | Vulnerabilities, auth issues, data exposure |
| ui-bugs | `docs/solutions/ui-bugs/` | Rendering issues, interaction bugs, layout problems |
| integration-issues | `docs/solutions/integration-issues/` | API failures, third-party service issues, webhook problems |
| logic-errors | `docs/solutions/logic-errors/` | Business logic bugs, incorrect calculations, state machine issues |
| (patterns) | `docs/solutions/patterns/` | Recurring solutions abstracted from multiple learnings |

## Filename Convention

```
docs/solutions/<category>/YYYY-MM-DD-<descriptive-slug>.md
```

Example: `docs/solutions/runtime-errors/2026-03-31-redis-pool-exhaustion.md`

## Pattern Documents

Pattern docs live in `docs/solutions/patterns/` and are DERIVED from multiple learning docs. They:
- Generalize a recurring solution across modules
- Reference the specific learnings they're derived from
- Have `track: knowledge` in frontmatter
- Are higher-leverage but also higher-risk when stale
