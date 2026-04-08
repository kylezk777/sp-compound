---
name: reproduce-bug
description: "Systematically reproduce and investigate a bug from a GitHub issue. Use when the user provides a GitHub issue number or URL for a bug they want reproduced or investigated."
---

# Reproduce Bug

Hypothesis-driven workflow for reproducing and investigating bugs from issue reports. Framework-agnostic.

## Phase 1: Understand the Issue

If no issue number/URL provided, ask the user for one (using the platform's question tool — `AskUserQuestion` in Claude Code, `request_user_input` in Codex, or present a prompt and wait).

```bash
gh issue view <number-or-url> --json title,body,comments,labels,assignees
```

Extract from the issue:
- **Reported symptoms** — error messages, wrong output, crashes
- **Expected behavior** — what should happen
- **Reproduction steps** — steps the reporter provided (if any)
- **Environment clues** — browser, OS, version, user role, data conditions
- **Frequency** — always, intermittent, or one-time

Note what's missing — this shapes the investigation strategy.

## Phase 2: Hypothesize

Before running anything, form 2-3 theories about the root cause.

### Search for relevant code

Use native content-search (e.g., Grep) for:
- Error messages or strings mentioned in the issue
- Feature names, route paths, UI labels
- Related model/service/controller names

### Form hypotheses

For each hypothesis, identify:
- **What** might be wrong
- **Where** in the codebase (specific files)
- **Why** it would produce the reported symptoms

Rank by likelihood. Investigate most likely first.

## Phase 3: Reproduce

### Route A: Test-based (backend, logic, data bugs)

1. Search for existing tests covering the affected code
2. Run them — do any already fail?
3. If not, write a minimal failing test demonstrating the reported behavior
4. A failing test matching symptoms = confirmed reproduction

### Route B: Browser-based (UI, visual, interaction bugs)

If browser automation tools are available (`agent-browser`, Playwright, etc.):
1. Navigate to affected area
2. Follow reproduction steps from the issue
3. Capture screenshots of the error state
4. Check for console errors

If no browser tools are available, guide the user through manual reproduction.

### Route C: Manual / environment-specific

For bugs needing specific data, user roles, or external service state:
1. Document required conditions
2. Ask user whether they can set up the conditions
3. Guide through manual reproduction if needed

### If reproduction fails

1. Try remaining hypotheses
2. Check for environment-specific factors
3. Search for recent changes: `git log --oneline -20 -- <affected_files>`
4. Document what was tried and what conditions might be missing

## Phase 4: Investigate Root Cause

### Check available observability

Depending on what the project has:
- Application logs — search for error patterns, stack traces
- Error tracking — Sentry, AppSignal, Datadog, etc.
- Browser console — for UI bugs
- Database state — unexpected values, missing associations
- Request/response cycle — status codes, params, timing

### Trace the code path

1. Read relevant source files from the entry point identified in Phase 2
2. Identify where behavior diverges from expectations
3. Check edge cases: nil/null, empty collections, boundary conditions, race conditions
4. Look for recent changes: `git log --oneline -10 -- <file>`

## Phase 5: Document and Present

Compile findings:
1. **Root cause** — what's wrong and where (file paths + line numbers)
2. **Reproduction steps** — verified steps to trigger (confirmed or unconfirmed)
3. **Evidence** — test output, log excerpts, screenshots
4. **Suggested fix** — if apparent, describe specific code changes
5. **Open questions** — anything unclear

Present to user. Do NOT post to GitHub without explicit consent.

Ask the user:
```
Investigation complete. How to proceed?
1. Post findings to the issue as a comment
2. Start working on a fix (invokes sp-compound:debug or sp-compound:work)
3. Just review the findings (no external action)
```

If posting:
```bash
gh issue comment <number> --body "$(cat <<'EOF'
## Bug Investigation

**Root Cause:** [summary]

**Reproduction Steps (verified):**
1. [step]

**Relevant Code:** [file:line references]

**Suggested Fix:** [description if applicable]
EOF
)"
```

## Integration

**Complements:** `sp-compound:debug` — debug handles bugs encountered during development; reproduce-bug handles bugs reported by others via issues.

**May invoke:**
- `sp-compound:debug` — if the user chooses to fix and the root cause needs deeper investigation
- `sp-compound:work` — if the user chooses to fix and a plan exists
- `sp-compound:flexible-tdd` — reproduction test becomes the failing test for TDD
