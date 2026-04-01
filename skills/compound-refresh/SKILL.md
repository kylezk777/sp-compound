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

## 5 Maintenance Operations

| Operation | When | Action |
|-----------|------|--------|
| **Keep** | Still accurate and useful | No file edit. Report reviewed. |
| **Update** | Core solution correct but references drifted | In-place edits: renamed paths, moved modules, fixed links, updated metadata |
| **Consolidate** | 2+ docs overlap heavily, both correct | Merge unique content into canonical doc, delete subsumed doc |
| **Replace** | Core guidance now misleading | Sufficient evidence: write replacement + delete old. Insufficient: mark stale with `superseded_by` hint |
| **Delete** | Code/workflow gone, no successor | Delete file. Git history preserves it. No `_archived/` directory. |

### Key Boundaries

- **Update vs Replace:** If you find yourself rewriting the solution section, that's Replace, not Update.
- **Consolidate vs Delete:** If subsumed doc has unique content → Consolidate. If it adds nothing → Delete.
- **Delete safety:** Before deleting, check if problem domain is still active. Code gone + domain gone = Delete. Code gone + domain active = Replace.
- **Age alone is not a stale signal.** A 2-year-old learning matching current code is fine.

## Scope Selection

Discover learnings and pattern docs under `docs/solutions/`, excluding README.md.

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
| **Broad** | 9+ docs or repo-wide sweep | Triage first, investigate in batches |

## Phase 1: Investigate Learnings

For each candidate learning, read it and cross-reference against the codebase:

### Check Dimensions
- **References:** File paths, class names, modules — still exist or moved?
- **Recommended solution:** Does the fix match current code?
- **Code examples:** Do snippets reflect current implementation?
- **Related docs:** Are cross-referenced learnings/patterns present and consistent?
- **Overlap:** Does another doc cover the same problem domain, reference same files, or recommend similar solution?

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

### Cross-Doc Conflict Check
Contradictions between docs (conflicting recommendations, inconsistent references) are more urgent than individual staleness.

## Phase 2: Classify Action

For each document, classify as Keep/Update/Consolidate/Replace/Delete based on investigation evidence.

## Phase 3: Ask for Decisions (Interactive Only)

Most Updates and Consolidations applied directly. Only ask when:
- Action is genuinely ambiguous
- About to Delete without clear evidence
- Canonical doc choice for Consolidate is unclear
- About to create a Replace successor

Autofix mode: skip entirely. Proceed to Phase 4.

## Phase 4: Execute Actions

### Keep Flow
No file edit. Summarize why learning remains trustworthy.

### Update Flow
In-place edits only. Valid: renamed references, updated module names, fixed links, refreshed notes.
Invalid "updates" (rewriting solution section) → should be Replace instead.

### Consolidate Flow
**Autonomous mode:** Skip. Mark both docs as stale with `stale_reason: consolidation-candidate`. Report recommendation.
1. Confirm canonical doc
2. Extract unique content from subsumed doc(s)
3. Merge naturally into canonical
4. Update cross-references
5. Delete subsumed doc

### Replace Flow
**Autonomous mode:** Always take insufficient-evidence path (mark stale). Never write replacement.
**Sufficient evidence:** Write new learning at same category path, delete old file, set `superseded_by` if applicable.
**Insufficient evidence:** Mark old doc as stale: add `status: stale`, `stale_reason`, `stale_date` to frontmatter. Report recommendation for manual resolution or future `sp-compound:compound` capture.

### Delete Flow
**Autonomous mode:** Skip. Mark as stale with `stale_reason: deletion-candidate`. Report recommendation.
Delete only when clearly obsolete, redundant with no unique content, or problem domain is gone.
**Do not delete just because it's old.** Git history preserves the content.

## Phase 5: Commit Changes

Skip if no files modified.

### Autofix Mode
- On main/master: create branch, commit, attempt PR. If PR fails, report branch name.
- On feature branch: separate commit on current branch.

### Interactive Mode
- On main: offer branch+PR (recommended) or direct commit
- On feature branch: commit as separate commit (recommended)

Stage only compound-refresh files. Conventional commit message summarizing what was refreshed.

## Discoverability Check

Runs every time after the refresh report. Read and follow `skills/compound/references/discoverability-check.md`.

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
