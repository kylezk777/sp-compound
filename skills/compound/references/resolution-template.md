# Solution Document Template

Use this template when creating new docs/solutions/ documents.

## Bug Track Template

```markdown
---
title: "<Concise problem description>"
category: <category>
track: bug
date_created: YYYY-MM-DD
status: current
module: <module-name>
component: <component-name>
tags: [tag1, tag2, tag3]
resolution_type: <type>
related_files:
  - path/to/file1.ext
  - path/to/file2.ext
---

## Problem

What was the problem? Symptoms observed.

## Root Cause

Why did it happen? Technical explanation.

## Failed Attempts

What was tried that didn't work? (Optional but valuable — saves others from repeating)

## Solution

What fixed it? Include code snippets if helpful.

## Prevention

How to prevent this from happening again. Tests, linting rules, architectural changes.

## Related Issues

Links to related docs, issues, or PRs, if any.
```

## Knowledge Track Template

```markdown
---
title: "<Concise guidance description>"
category: <category>
track: knowledge
date_created: YYYY-MM-DD
status: current
module: <module-name>
component: <component-name>
tags: [tag1, tag2, tag3]
related_files:
  - path/to/file1.ext
---

## Context

When does this guidance apply? What situation triggers this?

## Guidance

The recommended approach. What to do and how.

## Rationale

Why this approach? What alternatives were considered and rejected?

## Applicability

When this guidance does and does NOT apply. Boundary conditions.

## Examples

Code examples showing the recommended approach in practice. (Optional)

## Related

Links to related docs, issues, or PRs, if any.
```

## Pattern Document Template

```markdown
---
title: "<Pattern name>"
category: patterns
track: knowledge
date_created: YYYY-MM-DD
status: current
tags: [tag1, tag2]
derived_from:
  - docs/solutions/<category>/<learning1>.md
  - docs/solutions/<category>/<learning2>.md
---

## Pattern

Describe the recurring solution in abstract terms.

## When to Apply

Conditions that trigger this pattern.

## When NOT to Apply

Conditions where this pattern is wrong.

## Examples

Concrete examples from different modules.

## Source Learnings

List the specific learnings this pattern was derived from, with links.
```
