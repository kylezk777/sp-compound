---
name: reproduce-bug
description: "Systematically reproduce and investigate a bug from a GitHub issue. Use when the user provides a GitHub issue number or URL for a bug they want reproduced or investigated."
---

# Reproduce Bug

Hypothesis-driven workflow for reproducing and investigating bugs from issue reports. Framework-agnostic.

## Core Principles

1. **Investigate before fixing.** Do not propose a fix until you can explain the full causal chain from trigger to symptom with no gaps. "Somehow X leads to Y" is a gap.
2. **Predictions for uncertain links.** When the causal chain has uncertain or non-obvious links, form a prediction — something in a different code path or scenario that must also be true. If the prediction is wrong but a fix "works," you found a symptom, not the cause.
3. **One change at a time.** Test one hypothesis, change one thing. If changing multiple things to "see if it helps," stop — that is shotgun debugging.

## Phase 1: Understand the Issue

If no issue number/URL provided, ask the user for one (using the platform's question tool — `AskUserQuestion` in Claude Code, `request_user_input` in Codex, `ask_user` in Gemini — or present a prompt and wait).

**If the input references an issue tracker**, fetch it:
- GitHub (`#123`, `org/repo#123`, github.com URL): `gh issue view <number-or-url> --json title,body,comments,labels,assignees`
- Other trackers (Linear, Jira, etc.): attempt to fetch using available MCP tools or by fetching the URL content. If fetch fails, ask the user to paste the relevant issue content.

**Prior-attempt awareness:** If the user indicates prior failed attempts ("I've been trying", "keeps failing", "stuck"), ask what they have already tried before investigating.

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

Before forming hypotheses, check for these anti-patterns: proposing a fix before explaining the cause, reaching for another attempt without new information, certainty without evidence ("I know what this is" before reading code), and minimizing scope ("it's probably just...").

For each hypothesis, state:
- **What** is wrong and **where** (file:line)
- **Causal chain**: how the trigger leads to the observed symptom, step by step
- **Prediction** (for uncertain links): something in a different code path that must also be true if this hypothesis is correct. When the chain is obvious (missing import, clear null ref), the chain itself is sufficient — no prediction needed.

Rank by likelihood. Before forming a new hypothesis, review what has already been ruled out and why.

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
2. **Intermittent bugs**: run the scenario in a loop to establish reproduction rate. Add targeted logging at suspected failure points. Systematically eliminate variables (different data, serial vs parallel, with/without network).
3. Check for environment-specific factors — differences between environments IS the investigation
4. Search for recent changes: `git log --oneline -20 -- <affected_files>`
5. Document what was tried and what conditions might be missing

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
2. Follow the execution path backward from the error: "where did this value come from?" and "who called this?" — do not stop at the first function that looks wrong; the root cause is where bad state originates, not where it is first observed
3. Check edge cases: nil/null, empty collections, boundary conditions, race conditions
4. Look for recent changes: `git log --oneline -10 -- <file>`

### Causal chain gate

Do not proceed to Phase 5 until you can explain the full causal chain from trigger to symptom with no gaps. The user can explicitly authorize proceeding with the best-available hypothesis if investigation is stuck.

### Smart escalation

If 2-3 hypotheses are exhausted without confirmation, diagnose why:

| Pattern | Diagnosis | Next move |
|---------|-----------|-----------|
| Hypotheses point to different subsystems | Architecture/design problem | Present findings, suggest brainstorm |
| Evidence contradicts itself | Wrong mental model | Re-read code path without assumptions |
| Works locally, fails in CI/prod | Environment problem | Systematically compare environments |
| Fix works but prediction was wrong | Symptom fix, not root cause | Keep investigating |

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
