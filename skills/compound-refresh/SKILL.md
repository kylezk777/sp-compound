---
name: compound-refresh
description: Use to maintain docs/solutions/ knowledge store quality. Reviews existing learnings against the current codebase, then updates, consolidates, replaces, or deletes stale documents. Supports interactive and autofix modes.
---

# Compound Refresh: Maintain the Knowledge Store

## Overview

Maintain `docs/solutions/` quality by reviewing existing learnings against the current codebase. Keeps the knowledge store accurate so it helps rather than misleads.

**Announce at start:** "I'm using the sp-compound compound-refresh skill to maintain the knowledge store."

## Mode Detection

Check `$ARGUMENTS` for `mode:autofix` or `mode:autonomous`:
- **Interactive** (default): user present, ask decisions on ambiguous cases
- **Autofix**: no user interaction, apply unambiguous actions, mark ambiguous as stale
- **Autonomous**: unattended execution (e.g., scheduled via cron). More conservative than autofix:
  - Only execute Keep and Update operations
  - Mark everything else (Consolidate, Replace, Delete) as stale with recommendation
  - Higher confidence threshold: only act when evidence is unambiguous
  - Machine-parseable report format (structured markdown with consistent headings)
  - Never create new files (no Replace successors)
  - If any doc cannot be assessed → mark stale, do not guess

### Autofix Mode Rules
1. Skip all user questions — never pause for input
2. Process all docs in scope
3. Apply all safe actions; record failures as "recommended"
4. Mark as stale when uncertain (add `status: stale`, `stale_reason`, `stale_date` in frontmatter)
5. Conservative confidence — borderline cases get marked stale
6. Generate report with **Applied** and **Recommended** sections

### Autonomous Mode Rules
1. All Autofix rules apply, PLUS:
2. **No destructive operations** — never Delete, never Replace (write successor)
3. **No creative operations** — never Consolidate (requires judgment on canonical doc)
4. **Update only when confident** — if any ambiguity in reference drift, mark stale instead
5. **Report format** — each document gets a structured block:
   ```
   ### <filepath>
   - **Status:** kept | updated | marked-stale
   - **Evidence:** <one-line summary>
   - **Action:** <what was done or recommended>
   ```
6. Exit code convention: 0 = all processed, 1 = some marked stale (needs human follow-up)

## Interaction Principles (Interactive Mode Only)

In autofix/autonomous mode, skip all user questions. In interactive mode:

- Ask questions **one at a time** using the platform's blocking question tool (`AskUserQuestion` in Claude Code, `request_user_input` in Codex, `ask_user` in Gemini)
- Prefer **multiple choice** when natural options exist
- Start with **scope and intent**, then narrow only when needed
- Do **not** ask the user to make decisions before you have evidence
- Lead with a **recommendation** and explain briefly

## 5 Maintenance Operations

| Operation | When | Action |
|-----------|------|--------|
| **Keep** | Still accurate and useful | No file edit. Report reviewed. |
| **Update** | Core solution correct but references drifted | In-place edits: renamed paths, moved modules, fixed links, updated metadata |
| **Consolidate** | 2+ docs overlap heavily, both correct | Merge unique content into canonical doc, delete subsumed doc |
| **Replace** | Core guidance now misleading | Sufficient evidence: write replacement + delete old. Insufficient: mark stale with `superseded_by` hint |
| **Delete** | Code/workflow gone, no successor | Delete file. Git history preserves it. No `_archived/` directory. |

### Core Rules

1. **Evidence informs judgment.** The signals below are inputs, not a mechanical scorecard. Use engineering judgment to decide whether the artifact is still trustworthy.
2. **Prefer no-write Keep.** Do not update a doc just to leave a review breadcrumb.
3. **Match docs to reality, not the reverse.** When current code differs from a learning, update the learning. Do not ask whether code changes were "intentional" or "a regression" — that is outside doc maintenance scope.
4. **Be decisive, minimize questions.** When evidence is clear (file renamed, class moved, reference broken), apply the update. Only ask when the right action is genuinely ambiguous. In autofix mode, mark ambiguous cases as stale instead.
5. **No cosmetic edits.** Do not edit a doc just to fix a typo, polish wording, or make cosmetic changes that do not materially improve accuracy or usability.
6. **Use Update only for meaningful, evidence-backed drift.** Paths, module names, related links, category metadata, code snippets, and clearly stale wording are fair game when fixing them materially improves accuracy.
7. **Use Replace only when there is a real replacement.** That means either: the current conversation contains a recently verified replacement fix, the user provided enough replacement context, codebase investigation found the current approach, or newer docs/PRs/issues provide strong successor evidence.
8. **Delete when the code is gone.** If the referenced code or workflow no longer exists and no successor can be found, delete the file. Missing referenced files with no matching code is strong Delete evidence. But check if the problem domain is still active first (see Delete Flow).
9. **Evaluate document-set design, not just accuracy.** Redundant docs are dangerous because they drift silently — two docs saying the same thing will eventually say different things.
10. **Delete, don't archive.** No `_archived/` directory. Git history preserves every deleted file. A dedicated archive directory pollutes search results and nobody reads it.

### Key Boundaries

- **Update vs Replace:** If you find yourself rewriting the solution section, that's Replace, not Update.
- **Consolidate vs Delete:** If subsumed doc has unique content → Consolidate. If it adds nothing → Delete.
- **Age alone is not a stale signal.** A 2-year-old learning matching current code is fine.

## Refresh Order

Refresh in this order:
1. Review individual learning docs first
2. Note which learnings stayed valid, were updated, consolidated, replaced, or deleted
3. Then review any pattern docs that depend on those learnings

Why: learning docs are the primary evidence. Pattern docs are derived from one or more learnings. Stale learnings can make a pattern look more valid than it really is. If the user starts by naming a pattern doc, inspect the supporting learning docs before changing the pattern.

## Scope Selection

Discover learnings and pattern docs under `docs/solutions/`, excluding README.md and anything under `_archived/`. If an `_archived/` directory exists, flag it in the report as a legacy artifact that should be cleaned up (files either restored or deleted).

If `$ARGUMENTS` provided, match candidates by (tried in order):
1. Directory match (subdirectory name)
2. Frontmatter match (module, component, tags)
3. Filename match (partial OK)
4. Content search (keyword in body)

If no matches: ask user to clarify (interactive) or report and stop (autofix).
If no candidate docs exist: report "run sp-compound:compound first."

## Phase 0: Assess and Route

Estimate scope and choose interaction path:

| Scope | When | Style |
|-------|------|-------|
| **Focused** | 1-2 files or user named specific doc | Investigate directly, present recommendation |
| **Batch** | Up to ~8 independent docs | Investigate first, present grouped recommendations |
| **Broad** | 9+ docs or repo-wide sweep | Triage first (see below), investigate in batches |

### Broad Scope Triage

When 9+ candidate docs, do a lightweight triage before deep investigation:

1. **Inventory** — read frontmatter of all candidates, group by module/component/category
2. **Impact clustering** — identify areas with the densest clusters. A cluster of 5 learnings and 2 patterns in the same module is higher-impact than 5 isolated single-doc areas (staleness in one likely affects others)
3. **Spot-check drift** — for each cluster, check whether primary referenced files still exist. Missing references in a high-impact cluster = strongest signal for where to start
4. **Recommend a starting area** — present the highest-impact cluster with a brief rationale and ask the user to confirm or redirect. In autofix/autonomous mode, skip the question and process all clusters in impact order

## Phase 1: Investigate Learnings

For each candidate learning, read it and cross-reference against the codebase:

### Check Dimensions
- **References:** File paths, class names, modules — still exist or moved?
- **Recommended solution:** Does the fix match current code?
- **Code examples:** Do snippets reflect current implementation?
- **Related docs:** Are cross-referenced learnings/patterns present and consistent?
- **Auto memory:** Check the auto memory directory (if it exists) for notes in the same problem domain. A memory note describing a different approach than what the learning recommends is a supplementary drift signal. Memory-sourced evidence is secondary to codebase evidence — tag findings with "(auto memory)" in the evidence report.
- **Overlap:** Does another doc cover the same problem domain, reference same files, or recommend similar solution?

### Memory-Sourced Drift Signal Rules
- Memory-only drift (no codebase corroboration) -> mark stale, not action
- Memory + codebase drift -> strengthens the case for Replace
- Memory contradicts learning but code matches learning -> learning is correct, ignore memory

### Drift Classification
- **Update territory:** References moved but core approach still matches current code
- **Replace territory:** Recommended solution conflicts with current code, architecture changed, pattern no longer preferred

### Judgment Guidelines
1. **Contradiction = strong Replace signal** — recommendation conflicts with current code = actively misleading
2. **Age alone is not stale** — old learning matching current code is fine
3. **Check for successors** before deleting — newer learnings, PRs, issues

## Phase 1.5: Investigate Pattern Docs

Pattern docs are derived guidance — higher leverage, stale pattern is more dangerous.
A pattern doc with no clear supporting learnings is a stale signal.

## Phase 1.75: Document-Set Analysis

Evaluate the document set as a whole:

### Overlap Detection
Compare docs sharing module/component/tags across 5 dimensions:
- Problem statement, solution shape, referenced files, prevention rules, root cause
- **High overlap across 3+ dimensions = strong Consolidate signal**

### Supersession Signals
- Newer doc covering same files but broader scope
- Older doc describing specific incident, newer doc generalizes it
- Two docs recommending same fix, newer has better context

### Canonical Doc Identification

For each topic cluster (docs sharing a problem domain), identify which doc is the canonical source of truth — the most recent, broadest, most accurate doc. All others are either distinct (independent retrieval value), subsumed (unique content fits in canonical), or redundant (adds nothing — Delete).

### Retrieval-Value Test

Before recommending that two docs stay separate: "If a maintainer searched for this topic six months from now, would having these as separate docs improve discoverability, or just create drift risk?" Separate docs earn their keep only when they cover genuinely different sub-problems, target different audiences, or would be unwieldy merged. If none apply, prefer consolidation.

### Cross-Doc Conflict Check
Contradictions between docs (conflicting recommendations, inconsistent references) are more urgent than individual staleness. Flag for immediate resolution via Consolidate or targeted Update/Replace.

## Pattern Guidance

Apply the same five outcomes to pattern docs, but evaluate them as derived guidance:
- **Keep**: underlying learnings still support the generalized rule
- **Update**: rule holds but examples, links, scope, or supporting references drifted
- **Consolidate**: two pattern docs generalize the same learnings or cover the same concern
- **Replace**: generalized rule is now misleading, or underlying learnings support a different synthesis. Base replacement on the refreshed learning set
- **Delete**: pattern no longer valid, no longer recurring, or fully subsumed by a stronger pattern doc

## Subagent Strategy

Choose the lightest approach that fits the scope:

| Approach | When |
|----------|------|
| **Main thread only** | Small scope, short docs |
| **Sequential subagents** | 1-2 artifacts with many supporting files to read |
| **Parallel subagents** | 3+ truly independent artifacts with low cross-references |
| **Batched subagents** | Broad sweeps — narrow scope first, investigate in batches |

Two subagent roles:
1. **Investigation subagents** — read-only. Return: file path, evidence, recommended action, confidence. Can run in parallel when artifacts are independent.
2. **Replacement subagents** — write a single new learning. Run one at a time, sequentially (each may read significant code).

When spawning subagents, include: "Use native file search and read tools (Glob, Grep, Read) for all investigation. Do NOT use shell commands for file operations."

## Phase 2: Classify Action

For each document, classify as Keep/Update/Consolidate/Replace/Delete based on investigation evidence.

## Phase 3: Ask for Decisions (Interactive Only)

Autofix/autonomous mode: skip this entire phase. Proceed to Phase 4.

Most Updates and Consolidations applied directly. Only ask when:
- Action is genuinely ambiguous
- About to Delete without clear evidence (when auto-delete criteria are met, proceed without asking)
- Canonical doc choice for Consolidate is unclear
- About to create a Replace successor

### Question Style
- Ask **one question at a time** using the platform's blocking question tool
- Prefer **multiple choice** when natural options exist
- Lead with the **recommended option** and a one-sentence rationale
- Do not list all five actions unless all five are genuinely plausible
- Do not ask about whether code changes were intentional — stay in doc-accuracy lane

## Phase 4: Execute Actions

### Keep Flow
No file edit. Summarize why learning remains trustworthy.

### Update Flow
In-place edits only. Valid: renamed references, updated module names, fixed links, refreshed notes.
Invalid "updates" (rewriting solution section) → should be Replace instead.

### Consolidate Flow
**Autonomous mode:** Skip. Mark both docs as stale with `stale_reason: consolidation-candidate`. Report recommendation.

Process Consolidate candidates by topic cluster:
1. Confirm canonical doc (broadest, most current, most accurate)
2. Extract unique content from subsumed doc(s) — edge cases, alternative approaches, extra prevention rules
3. Merge naturally into canonical at the logical location (do not just append)
4. Update cross-references in other docs that point to subsumed doc
5. Delete subsumed doc (no archive)

If a cluster has 3+ overlapping docs, process pairwise: consolidate the two most overlapping first, then evaluate whether the merged result should be consolidated with the next.

**Splitting:** If one doc has grown unwieldy and covers multiple distinct problems, it is valid to recommend splitting. Only do this when sub-topics are genuinely independent and a maintainer might search for one without needing the other.

### Replace Flow
**Autonomous mode:** Always take insufficient-evidence path (mark stale). Never write replacement.

**When evidence is sufficient** (understand both old recommendation AND current approach):
1. Read the compound skill's reference files: `skills/compound/references/solution-schema.yaml`, `skills/compound/references/yaml-schema.md`, `skills/compound/references/resolution-template.md`
2. Spawn a single replacement subagent. Pass it:
   - The old learning's full content
   - Summary of investigation evidence (what changed, what current code does, why old guidance misleads)
   - Target path and category
   - Contents of the three reference files above (source of truth for frontmatter, categories, sections)
3. The subagent writes the replacement using reference files as the contract. It should use native file search/read tools for additional context.
4. After the subagent completes, the orchestrator deletes the old learning file. The new learning may include `superseded_by` for traceability.

**When evidence is insufficient** (drift too fundamental to document the current approach confidently):
Mark old doc as stale in place: add `status: stale`, `stale_reason`, `stale_date` to frontmatter. Report what evidence was found, what is missing, and recommend running `sp-compound:compound` when the user next encounters that problem area.

### Delete Flow
**Autonomous mode:** Skip. Mark as stale with `stale_reason: deletion-candidate`. Report recommendation.

**Before deleting, check if the problem domain is still active.** When referenced files are gone, that is strong evidence the implementation is gone, but the problem domain may persist:
- Implementation gone + domain gone = Delete (e.g., feature fully removed)
- Implementation gone + domain active = Replace (e.g., auth code moved, app still handles auth)

**Auto-delete when:** referenced code is gone AND problem domain is gone, OR doc is fully superseded by a clearly better successor, OR doc is plainly redundant.

Do not delete just because it is old. Do not keep a doc just because its general advice is "still sound" — if the specific code it references is gone, the learning misleads readers. Git history preserves the content.

## Phase 5: Commit Changes

Skip if no files modified.

### Autofix Mode
- On main/master: create branch, commit, attempt PR. If PR fails, report branch name.
- On feature branch: separate commit on current branch.

### Interactive Mode

**On main/master/default branch:**
1. Create a branch, commit, and open a PR (recommended) — branch name specific to what was refreshed (e.g., `docs/refresh-auth-learnings`)
2. Commit directly to current branch
3. Don't commit — I'll handle it

**On feature branch, clean working tree:**
1. Commit as a separate commit (recommended)
2. Create a separate branch and commit
3. Don't commit

**On feature branch, dirty working tree (other uncommitted changes):**
1. Commit only compound-refresh changes (selective staging — other dirty files stay untouched)
2. Don't commit

Stage only compound-refresh files — never stage unrelated dirty files. Conventional commit message summarizing what was refreshed.

## Discoverability Check

Runs every time after the refresh report. Read and follow `skills/compound/references/discoverability-check.md`.

If the check produces an edit to an instruction file and Phase 5 already committed, either amend the existing commit (if still on the same branch and no push has occurred) or create a small follow-up commit. If Phase 5 already pushed, push the follow-up as well so the remote stays in sync. If the user chose "Don't commit" in Phase 5, leave the edit unstaged alongside other uncommitted changes.

## Output Report

Summary header: Scanned, Kept, Updated, Consolidated, Replaced, Deleted, Marked stale.

For every file processed:
- File path
- Classification
- Evidence found
- Action taken/recommended

### Autofix Report
Split into:
- **Applied:** successful actions with details
- **Recommended:** actions that couldn't be applied, with context for manual follow-up
- **Legacy cleanup** (if `docs/solutions/_archived/` exists): list archived files and recommend disposition (restore, delete, or consolidate)

## Integration

**Invoked by:**
- User manually for knowledge store maintenance
- `sp-compound:compound` (Phase 2.5) when new learning contradicts existing docs

**Consumes:**
- `docs/solutions/` — the knowledge store being maintained
- `skills/compound/references/solution-schema.yaml` — for valid frontmatter fields during Replace

**Relationship to compound:**
- `compound` captures newly solved, verified problems
- `compound-refresh` maintains older learnings as the codebase evolves
- Consolidate proactively as the doc set grows: every compound invocation adds a new doc — over time, multiple docs may cover the same problem
