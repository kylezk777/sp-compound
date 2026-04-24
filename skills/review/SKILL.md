---
name: review
description: Use when code changes need quality review before merge. Multi-reviewer code review with automated merge pipeline and auto-fix. Supports interactive, autofix, report-only, and headless modes.
---

# Multi-Reviewer Code Review

## Overview

Dispatch specialized reviewer agents in parallel, merge findings through a quality pipeline, and optionally auto-fix safe issues.

**Announce at start:** "I'm using the sp-compound review skill for multi-reviewer code review."

## Argument Parsing

`$ARGUMENTS` accepts optional tokens (strip recognized tokens before interpreting remainder as PR number, URL, or branch name):

**Primary mode tokens (mutually exclusive):**
- **`mode:autofix`** — skip user questions, apply safe_auto only
- **`mode:report-only`** — read-only, no edits, no artifacts, no todos
- **`mode:headless`** — for skill-to-skill invocation, structured output

**Modifier tokens (compatible with any primary mode):**
- **`mode:no-triage`** — skip the adversarial triage step (Step 5.5); all findings flow through unchanged

**Other tokens:**
- **`base:<sha-or-ref>`** — override diff base (do not combine with PR/branch target)
- **`plan:<path>`** — load specific plan for requirements verification

Default (no tokens): interactive mode.

**Conflicting mode flags:** If multiple **primary** mode tokens appear (autofix/report-only/headless), stop without dispatching agents. Emit error: `Review failed. Reason: conflicting mode flags — <mode_a> and <mode_b> cannot be combined.` (In headless, prefix with `(headless mode)`.) Modifier tokens like `mode:no-triage` do NOT trigger this rule.

## Mode Detection

| Mode | When | Behavior |
|------|------|----------|
| **Interactive** (default) | No mode token | Review, apply safe_auto, present findings, ask policy decisions on gated/manual. Triage runs if >= 5 findings. |
| **Autofix** | `mode:autofix` | No interaction. Apply safe_auto only, write residual work, never commit/push/PR. Triage runs if >= 5 findings. |
| **Report-only** | `mode:report-only` | Read-only. Report only, no edits, no artifacts, no todos, no commit/push/PR. Triage runs if >= 5 findings but no artifact is written. Safe for parallel use. Cannot switch shared checkout. |
| **Headless** | `mode:headless` | Programmatic. Apply safe_auto (single pass), return structured text output, no todos, never commit/push/PR. Triage runs if >= 5 findings. Cannot switch shared checkout. End with "Review complete" signal. |

### Headless mode guardrails
- Never use interactive question tools. Infer intent conservatively.
- **Require determinable diff scope.** If no branch, PR, or `base:` ref is determinable, emit `Review failed (headless mode). Reason: no diff scope detected. Re-invoke with a branch name, PR number, or base:<ref>.` and stop.
- **Cannot switch shared checkout.** If caller passes PR/branch target, emit `Review failed (headless mode). Reason: cannot switch shared checkout.` and stop (unless already in isolated worktree).
- **Not safe for concurrent use** on shared checkout (mutates files via safe_auto fixes).
- If all reviewers fail: emit `Code review degraded (headless mode). Reason: 0 of N reviewers returned results.` then "Review complete".

### Report-only mode guardrails
- Never use interactive question tools. Infer intent conservatively.
- **Cannot switch shared checkout.** If caller passes PR/branch target, tell caller to use an isolated worktree or review current branch as-is.
- **Safe for parallel read-only use** on the same checkout (no mutations).

## Severity Scale

| Level | Meaning | Action |
|-------|---------|--------|
| **P0** | Critical breakage, exploitable vulnerability, data loss | Must fix before merge |
| **P1** | High-impact defect in normal usage, breaking contract | Should fix |
| **P2** | Moderate: edge case, perf regression, maintainability trap | Fix if straightforward |
| **P3** | Low-impact, minor improvement | User's discretion |

## Action Routing

Severity answers **urgency**. Routing answers **who acts next**.

| `autofix_class` | Default owner | Meaning |
|-----------------|---------------|---------|
| `safe_auto` | `review-fixer` | Local, deterministic fix. Apply automatically when mode allows. |
| `gated_auto` | `downstream-resolver` or `human` | Concrete fix exists but changes behavior/contracts. Needs approval. |
| `manual` | `downstream-resolver` or `human` | Actionable but requires design judgment. |
| `advisory` | `human` or `release` | Report-only. Learnings, rollout notes, residual risk. |

Routing rules:
- Synthesis owns the final route. Persona routing is input, not final.
- On disagreement, choose the more conservative route (never widen without evidence).
- Only `safe_auto -> review-fixer` enters the fixer queue automatically.
- `requires_verification: true` means fix is incomplete without targeted tests or re-review.

## Stage 1: Determine Scope

### With `base:` argument (fast path)
Use directly: `git merge-base HEAD <base>`, then `git diff -U10`. Do not combine with PR/branch target.

### With PR number or URL argument
**Skip pre-check:** Before checkout, run `gh pr view <pr> --json state`. If `state` is `CLOSED` or `MERGED`, stop with `PR is closed/merged; not reviewing.` Draft PRs are reviewed normally (draft is not a skip condition).

If `mode:report-only` or `mode:headless`: do not switch shared checkout (see mode guardrails). Verify worktree is clean (`git status --porcelain`) before `gh pr checkout`. Fetch PR metadata with `gh pr view --json title,body,baseRefName,headRefName,url`. Compute local diff against PR base branch (not `gh pr diff`, which misses local fix commits). If base ref cannot be resolved, stop with error.

### With branch name argument
If `mode:report-only` or `mode:headless`: do not switch shared checkout. Verify worktree is clean before `git checkout <branch>`. Detect base via `references/resolve-base.sh` (PR metadata -> origin/HEAD -> gh repo view -> common names). If base cannot be resolved, stop with error.

### No argument (standalone)
Detect base via `references/resolve-base.sh`. If base cannot be resolved, stop with error (do not fall back to `git diff HEAD` which silently misses committed work).

### All paths produce
Diff (`git diff -U10`), file list, and untracked files list.

### Untracked file handling
Always inspect the untracked list. Untracked files are outside review scope until staged.
- **Interactive:** If non-empty, tell user which files are excluded. If any should be reviewed, tell user to `git add` them first.
- **Headless/autofix:** Proceed with tracked changes only. Note excluded files in Coverage section.

## Stage 2: Intent Discovery

Build 2-3 line intent summary from:
- Branch name and commit log (`git log --oneline` from merge-base)
- PR title/body if available

In interactive mode: ask one clarifying question if intent is ambiguous.
In non-interactive modes: infer conservatively.

### Plan Discovery
Search for plan document (stop at first hit):
1. `plan:` argument (if provided) -> `plan_source: explicit`
2. PR body scan for `.sp-compound/plans/*.md` paths. Single unambiguous match -> `explicit`. Multiple/ambiguous -> `inferred` for best match.
3. Auto-discovery: keyword match from branch name against `.sp-compound/plans/*.md`. Single unambiguous match -> `inferred`. Ambiguous or generic keywords (review, fix, update) -> skip.

If found: extract Requirements Trace for completeness check in Stage 6. Record `plan_source` for routing unaddressed requirements:
- **explicit**: unaddressed requirements become P1 findings (`manual -> downstream-resolver`)
- **inferred**: unaddressed requirements become P3 findings (`advisory -> human`) — no autonomous follow-up

## Stage 3: Select Reviewers

**Always-on (every review):**
- correctness-reviewer
- testing-reviewer

**Conditional (based on diff content):**
- security-reviewer — when diff touches auth, public endpoints, user input, permissions
- performance-reviewer — when diff touches DB queries, data transforms, caching, async
- adversarial-reviewer — when diff exceeds 50 changed executable (non-test/non-generated/non-lockfile) lines, or touches auth, payments, data mutations, external APIs

**Note:** `triage-reviewer` is NOT selected in this stage. It runs in Stage 5.5 against the merged finding list, not against the diff. It is dispatched automatically when the merged new-finding count >= 5 and `mode:no-triage` is absent.

**Plus:** Dispatch `learnings-researcher` agent to search `.sp-compound/solutions/` for related past issues.

**File-type awareness:** Instruction-prose files (Markdown, JSON schemas, config) do not benefit from runtime-focused reviewers. Count only executable code lines toward line-count thresholds. For diffs that only change prose files, skip adversarial unless the prose describes auth, payment, or data-mutation behavior.

Announce selected team with per-conditional justifications as progress (not a blocking question).

## Stage 4: Dispatch Reviewers

Launch all selected reviewers in parallel. Each receives:
- Their persona prompt (from `agents/review/<name>.md`)
- Diff scope rules (from `references/diff-scope.md`)
- The JSON output contract (from `references/findings-schema.md`)
- The diff (`git diff -U10 <base>..<head>`)
- File list
- Intent summary
- PR metadata (title, body, URL) when reviewing a PR

Each reviewer returns JSON findings to the orchestrator.

**Model tiering:** Reviewer sub-agents use mid-tier model (e.g., `sonnet` in Claude Code). Orchestrator stays on default (most capable) for intent discovery, selection, merge, and synthesis. If the platform has no model override mechanism or the available model names are unknown, omit the model parameter and let agents inherit the default.

**Permission mode:** Omit the `mode` parameter on sub-agent dispatch so the user's configured permission settings apply.

Reviewers are **read-only** -- they may use `git diff`, `git blame`, `git log`, `gh pr view` but must NOT edit files, change branches, commit, push, or create PRs.

**Protected artifacts:** Reviewers must NOT recommend deleting or cleaning up files under `.sp-compound/brainstorms/`, `.sp-compound/plans/`, `.sp-compound/solutions/`, or any knowledge store paths documented in project instruction files. These are durable knowledge assets, not dead code.

## Stage 5: Merge Pipeline

Read and follow `references/merge-pipeline.md`.

1. **Validate** -- check required fields (title, severity, file, line, confidence, autofix_class, owner, requires_verification, pre_existing) and value constraints. Drop malformed findings.
2. **Confidence gate** — suppress < 0.60 (P0 at 0.50+ survives)
3. **Deduplicate** — fingerprint by file + line bucket +/-3 + title
3.5. **Pre-existing detection** — git blame to separate pre-existing from new findings
4. **Cross-reviewer boost** — 2+ reviewers on same issue → +0.10 confidence (cap 1.0)
5. **Resolve disagreements** — annotate when reviewers disagree on severity/route. Keep most conservative.
5.5. **Adversarial triage** — dispatch `triage-reviewer` when >= 5 new findings and `mode:no-triage` is absent. Emits KEEP/DOWNGRADE/DROP verdicts with hard recall safety rails (see Stage 5.5 below).
6. **Route** — set final autofix_class, owner, requires_verification. Never widen without evidence.
7. **Partition** — fixer queue (safe_auto -> review-fixer), residual actionable (gated_auto/manual -> downstream-resolver), report-only (advisory + human/release)
8. **Sort** — severity → confidence → file → line
9. **Coverage** — union residual_risks and testing_gaps across reviewers

## Stage 5.5: Adversarial Triage (conditional)

When the merged new-finding count (after Step 5, excluding pre-existing) is >= 5 AND `mode:no-triage` is NOT set, dispatch the `triage-reviewer` agent per `references/merge-pipeline.md` Step 5.5.

The triage-reviewer reads `references/triage-rubric.md` and emits KEEP / DOWNGRADE / DROP verdicts per finding. The pipeline validates each verdict (confidence gates, evidence anchoring, hard red-lines for P0 / cross-reviewer consensus / sensitive paths) before applying. Failed validations revert the verdict to KEEP.

**Model tier:** triage-reviewer runs at the highest tier available (NOT mid-tier) — the agent must reason counterfactually about reachability and containment. Override the default reviewer model tier when dispatching this agent.

**PR-label bypass:** if PR title/body/labels contain `hotfix`, `security`, `cve`, `p0`, or `p1-prod` (case-insensitive), skip the step entirely; all findings flow through unchanged.

**Fail-open:** triager failure (error/timeout/malformed output) is treated as a no-op. All findings pass through at their original severity. The review does NOT abort.

**Artifact:** full triage detail (verdicts, rationale, reverted verdicts) writes to `.sp-compound/review-runs/<run-id>/triage.json` in interactive, autofix, and headless modes. Report-only mode honors its "no artifacts" contract and skips artifact write.

See `references/merge-pipeline.md` Step 5.5 and `references/triage-rubric.md` for the full rules.

## Stage 6: Report

Assemble the final report using **pipe-delimited markdown tables for findings** from the review output template (`references/review-output-template.md`). The table format is mandatory for finding rows in interactive mode -- do not render findings as freeform text blocks or horizontal-rule-separated prose.

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

### Pre-Existing Issues
Findings where `pre_existing: true` — code that existed before this PR. Listed for visibility but excluded from verdict and auto-fix.

### Learnings & Past Solutions
From learnings-researcher — related historical issues.

### Coverage
Suppressed count, residual risks, testing gaps, failed/timed-out reviewers. Note intent uncertainty in non-interactive modes.

### Verdict
- **"Ready to merge"** — no new P0/P1, all findings addressed (pre-existing P0/P1 don't block)
- **"Ready with fixes"** — safe_auto fixes applied, remaining are P2/P3 (pre-existing excluded)
- **"Not ready"** — new P0/P1 remain unfixed

When an `explicit` plan has unaddressed requirements, verdict must reflect it. When `inferred`, note in reasoning but don't block on it alone.

### Headless output format

In `mode:headless`, replace tables with structured text envelope:

```
Code review complete (headless mode).

Scope: <scope>
Intent: <intent>
Reviewers: <list>
Verdict: <Ready to merge | Ready with fixes | Not ready>
Triage: <dropped N (high-confidence false-positive), downgraded M. Details: <path> | no changes (examined K findings) | skipped (PR labeled <match>) | bypassed (user requested) | failed (reason: <reason>). All findings shown unfiltered | not run (< 5 findings)>
Artifact: .sp-compound/review-runs/<run-id>/

(If triage dropped > 50% of findings, prepend the line `⚠  Triage dropped >50% of findings in this run. Inspect triage.json before trusting the verdict.` as the very first line of the envelope.)

Applied N safe_auto fixes.

Gated-auto findings (concrete fix, changes behavior/contracts):

[P1][gated_auto -> downstream-resolver][needs-verification] File: <file:line> -- <title> (reviewer, confidence N)
  Why: <why_it_matters>
  Suggested fix: <suggested_fix or "none">
  Evidence: <evidence[0]>

Manual findings (actionable, needs handoff):

[P1][manual -> downstream-resolver] File: <file:line> -- <title> (reviewer, confidence N)
  Why: <why_it_matters>
  Evidence: <evidence[0]>

Advisory findings (report-only):

[P2][advisory -> human] File: <file:line> -- <title> (reviewer, confidence N)
  Why: <why_it_matters>

Pre-existing issues:
[P2][gated_auto -> downstream-resolver] File: <file:line> -- <title> (reviewer, confidence N)
  Why: <why_it_matters>

Learnings & Past Solutions:
- <learning>

Coverage:
- Suppressed: N findings below 0.60 confidence (P0 at 0.50+ retained)
- Untracked files excluded: <files>
- Failed reviewers: <reviewer>

Review complete
```

Omit sections with zero items. End with "Review complete" as terminal signal.

**Format verification:** Before delivering the report, verify the findings sections use pipe-delimited table rows (`| # | File | Issue | ... |`) not freeform text. If findings are rendered as prose blocks separated by horizontal rules or bullet points, reformat into tables.

### Fallback

If the platform doesn't support parallel sub-agents, run reviewers sequentially. All other stages stay the same.

## Quality Gates

Before delivering the report, verify:

1. **Every finding is actionable.** If it says "consider" or "might want to" without a concrete fix, rewrite with a specific action.
2. **No false positives from skimming.** Verify the surrounding code was read. Check the "bug" isn't handled elsewhere, the "unused import" isn't used in a type annotation.
3. **Severity is calibrated.** Style nit is never P0. SQL injection is never P3.
4. **Line numbers are accurate.** Verify each cited line against file content.
5. **Findings don't duplicate linter output.** Focus on semantic issues, not what formatters catch.
6. **Protected artifacts are respected.** Discard any findings that recommend deleting or gitignoring files in `.sp-compound/brainstorms/`, `.sp-compound/plans/`, or `.sp-compound/solutions/`.
7. **Report format is correct.** Findings use pipe-delimited table rows, not freeform text blocks or horizontal-rule-separated prose.

## Post-Review: Fix & Handoff

If zero findings after suppression and pre-existing separation, skip fix phase.

### Step 1: Build action sets
- **Fixer queue:** `safe_auto -> review-fixer` findings
- **Residual actionable:** unresolved `gated_auto` or `manual` (`downstream-resolver`)
- **Report-only queue:** `advisory` + anything owned by `human` or `release`
- Never convert advisory-only outputs into fix work or todos.

### Step 2: Apply by mode

**Interactive:**
1. Apply safe_auto fixes automatically (safe by definition).
2. If gated_auto/manual remain, ask a policy question using the platform's blocking question tool (`AskUserQuestion` in Claude Code, `request_user_input` in Codex, `ask_user` in Gemini):
   - When gated_auto present: "1. Review and approve specific gated fixes (Recommended) / 2. Leave as residual work / 3. Report only"
   - When only manual remain: "1. Leave as residual work (Recommended) / 2. Report only"
3. If no blocking question tool available, present numbered options as text and wait.
4. Only add gated_auto to fixer queue after explicit user approval.

**Autofix:** Apply safe_auto only. No questions. Leave gated_auto/manual/human/release unresolved.

**Report-only:** No fixes. No artifacts. Stop after report.

**Headless:** Apply safe_auto in single pass (no re-review loop). Return structured findings. No questions.

### Step 3: Fix rounds (interactive and autofix only)
- Spawn one fixer subagent for the fixer queue. Apply fixes and run targeted tests.
- Re-review only changed scope after fixes land.
- **Maximum 2 rounds.** Remaining issues become residual work.
- If any applied finding has `requires_verification: true`, round is incomplete until verification runs.

### Step 4: Next steps (interactive only)
After fix cycle completes, offer mode-appropriate options:
- **PR mode:** Push fixes / Exit
- **Branch mode (not default branch):** Create PR (Recommended) / Continue / Exit
- **Default branch:** Continue / Exit

Autofix, report-only, headless: stop after report and residual handoff. Never commit/push/PR.

## Integration

**Called by:**
- **sp-compound:work** (Phase 3) — after all tasks complete
- Directly by user for standalone review

**Dispatches:**
- Review agents: correctness, testing, security (conditional), performance (conditional), adversarial (conditional)
- triage-reviewer (conditional, Stage 5.5; uses highest model tier, not mid-tier)
- learnings-researcher agent (always)

**Consumes:**
- `references/findings-schema.md` -- output format contract
- `references/merge-pipeline.md` -- merge rules (includes Step 5.5 triage)
- `references/diff-scope.md` -- scope classification rules for reviewers
- `references/resolve-base.sh` -- base branch detection script (fork-safe)
- `references/triage-rubric.md` -- triage verdict rubric (Stage 5.5)
- `references/triage-test-scenarios.md` -- triage regression fixtures
- `.sp-compound/solutions/` -- via learnings-researcher for historical context
