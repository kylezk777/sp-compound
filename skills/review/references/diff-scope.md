# Diff Scope Rules

These rules apply to every reviewer. They define what is "your code to review" versus pre-existing context.

## Scope Discovery

Determine the diff to review using this priority order:

1. **User-specified scope.** If the caller passed `BASE:`, `FILES:`, or `DIFF:` markers, use that scope exactly.
2. **Unpushed commits vs base branch.** If the working copy is clean, review `git diff $(git merge-base HEAD <base>)` where `<base>` is the resolved review base.

The scope step in the SKILL.md handles discovery and passes the resolved diff. Reviewers do not need to run git commands for scope detection.

## Finding Classification Tiers

### Primary (directly changed code)

Lines added or modified in the diff. This is the main focus. Report findings against these lines at full confidence.

### Secondary (immediately surrounding code)

Unchanged code within the same function, method, or block as a changed line. If a change introduces a bug that's only visible by reading the surrounding context, report it -- but note the issue exists in the interaction between new and existing code.

### Pre-existing (unrelated to this diff)

Issues in unchanged code that the diff didn't touch and doesn't interact with. Mark these as `"pre_existing": true`. They're reported separately and don't count toward the review verdict.

**The rule:** If the same issue would be flagged on an identical diff that didn't include the surrounding file, it's pre-existing. If the diff makes the issue *newly relevant* (e.g., a new caller hits an existing buggy function), it's secondary.
