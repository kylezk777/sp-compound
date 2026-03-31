---
name: review
description: Use when code changes need quality review before merge. Multi-reviewer code review with automated merge pipeline and auto-fix. Supports interactive, autofix, and headless modes.
---

# Multi-Reviewer Code Review

## Overview

Dispatch specialized reviewer agents in parallel, merge findings through a quality pipeline, and optionally auto-fix safe issues.

**Announce at start:** "I'm using the sp-compound review skill for multi-reviewer code review."

## Argument Parsing

`$ARGUMENTS` accepts optional tokens:
- **`mode:autofix`** — skip user questions, apply safe_auto only
- **`mode:headless`** — for skill-to-skill invocation, structured output
- **`base:<sha-or-ref>`** — override diff base
- **`plan:<path>`** — load specific plan for requirements verification

Default (no tokens): interactive mode.

## Stage 1: Determine Scope

### With `base:` argument
Use directly: `git merge-base HEAD <base>`, then `git diff -U10`.

### No argument (standalone)
Detect base: `git merge-base HEAD main` or `git merge-base HEAD master`.

Get diff, file list, untracked files. Untracked files are outside review scope until staged.

## Stage 2: Intent Discovery

Build 2-3 line intent summary from:
- Branch name and commit log (`git log --oneline` from merge-base)
- PR title/body if available

In interactive mode: ask one clarifying question if intent is ambiguous.
In non-interactive modes: infer conservatively.

### Plan Discovery
Search for plan document:
1. `plan:` argument (if provided)
2. Auto-discovery: keyword match from branch name against `docs/plans/*.md`

If found: extract Requirements Trace for completeness check in Stage 6.

## Stage 3: Select Reviewers

**Always-on (every review):**
- correctness-reviewer
- testing-reviewer

**Conditional (based on diff content):**
- security-reviewer — when diff touches auth, public endpoints, user input, permissions
- performance-reviewer — when diff touches DB queries, data transforms, caching, async
- adversarial-reviewer — when diff exceeds 50 non-test changed lines

**Plus:** Dispatch `learnings-researcher` agent to search `docs/solutions/` for related past issues.

Announce selected team as progress (not a blocking question).

## Stage 4: Dispatch Reviewers

Launch all selected reviewers in parallel. Each receives:
- Their persona prompt (from `agents/review/<name>.md`)
- The diff (`git diff -U10 <base>..<head>`)
- File list
- Intent summary

**Model:** Reviewers use cheapest capable model (e.g., haiku). Orchestrator stays on default.

Reviewers are **read-only** — they may use `git diff`, `git blame`, `git log` but must NOT edit files.

## Stage 5: Merge Pipeline

Read and follow `references/merge-pipeline.md`:

1. **Validate** — drop malformed findings
2. **Confidence gate** — suppress < 0.60 (P0 at 0.50+ survives)
3. **Deduplicate** — fingerprint by file + line bucket +/-3 + title
4. **Cross-reviewer boost** — 2+ reviewers on same issue → +0.10 confidence
5. **Route** — classify safe_auto / gated_auto / manual / advisory
6. **Sort** — severity → confidence → file → line

## Stage 6: Report

Output as markdown tables:

### Header
Scope, intent, mode, reviewer team.

### Findings Table
Grouped by severity (P0, P1, P2, P3). Each row: #, file:line, issue, reviewer(s), confidence, route.

Empty severity levels omitted.

### Requirements Completeness (if plan found)
Checklist of met / not addressed / partially addressed requirements.

### Applied Fixes (if any)
What was auto-fixed.

### Residual Work
Unresolved gated_auto/manual findings.

### Learnings & Past Solutions
From learnings-researcher — related historical issues.

### Verdict
- **"Ready to merge"** — no P0/P1, all findings addressed
- **"Ready with fixes"** — safe_auto fixes applied, remaining are P2/P3
- **"Not ready"** — P0/P1 remain unfixed

## Post-Review: Auto-Fix

### Interactive Mode
1. Apply safe_auto fixes automatically
2. If gated_auto/manual findings remain: ask user what to do
3. Maximum 2 fix rounds, then remaining become residual work

### Autofix Mode
Apply safe_auto only. No questions. Write residual work as report.

### Headless Mode
Apply safe_auto in single pass. Return structured findings. No questions.

## Integration

**Called by:**
- **sp-compound:work** (Phase 3) — after all tasks complete
- Directly by user for standalone review

**Dispatches:**
- Review agents: correctness, testing, security (conditional), performance (conditional), adversarial (conditional)
- learnings-researcher agent (always)

**Consumes:**
- `references/findings-schema.md` — output format contract
- `references/merge-pipeline.md` — merge rules
- `docs/solutions/` — via learnings-researcher for historical context
