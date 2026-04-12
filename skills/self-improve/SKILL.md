---
name: self-improve
description: "Compare sp-compound skills against their upstream peers (Superpowers and Compound Engineering), evaluate differences with cost-benefit analysis, and selectively adopt improvements. Use manually when maintaining or upgrading sp-compound skill quality. Not auto-invoked."
disable-model-invocation: true
---

# Self-Improve: Upstream Sync Evaluation

Systematically compare sp-compound skills against their peer projects — Superpowers (SP) and Compound Engineering (CE) — evaluate each difference on its own merit, and selectively adopt what genuinely improves sp-compound.

SP, CE, and sp-compound are peer projects evolving independently. This skill does NOT assume upstream is authoritative. It evaluates, decides, and acts.

## Source Locations

Upstream repos must be accessible locally. Verify before starting:
- **SP**: find `superpowers/skills/` relative to the sp-compound repo's parent directory
- **CE**: find `compound-engineering-plugin/plugins/compound-engineering/skills/` relative to the same parent

If either is missing, report and ask the user for the correct path. Do not guess.

## Scope Selection

If `$ARGUMENTS` is provided, treat it as a comma-separated list of skill names to improve. Otherwise, improve ALL skills listed in `references/provenance-map.md`.

## Workflow

```
Phase 0: Setup (git pull + load config + load design principles)
For each skill in scope (parallel where possible):
  Phase 1: Read & Compare
  Phase 2: Evaluate & Decide
  Phase 3: Impact Check + Fix
  Phase 4: Re-Compare
  Repeat Phase 2-4 until no actionable items remain
Phase 5: New Feature Discovery
```

Skills are independent — dispatch them to parallel subagents when improving multiple skills simultaneously. Phase 5 runs once after all skills are done.

---

## Phase 0: Setup

1. **Pull latest upstream code.** Both SP and CE are actively maintained. Before any comparison, ensure local copies are current:
   ```
   git -C <SP repo root> pull
   git -C <CE repo root> pull
   ```
   If a pull fails (dirty tree, network issue), report the error and ask the user whether to continue with the current local version or abort. Do not force-reset or stash without consent.

2. Read `references/provenance-map.md` to resolve which upstream skill(s) map to each sp-compound skill in scope
3. Read `references/design-principles.md` — these principles are the decision filter for all subsequent phases
4. Read `references/review-criteria.md` to load the evaluation framework (decision types, priority levels, cost-benefit template, impact assessment template)
5. Read `references/rejection-log.md` — skip re-evaluating items that were previously Rejected with still-valid reasoning
6. Read `references/watch-list.md` — check if any watched items now warrant re-evaluation
7. Verify upstream source paths exist. If a source skill directory is missing, skip that comparison pair and report it

## Phase 1: Read & Compare

For each sp-compound skill, read:
- The sp-compound SKILL.md + all files under its `references/` directory
- Each mapped upstream SKILL.md + all files under their `references/` and `assets/` directories

Then produce a **difference report** (not "gap report" — differences are neutral, not deficits):

```
## Difference Report: <skill-name>

### Functionality Comparison
| Feature | Upstream Detail | sp-compound Status | Notes |
|---------|----------------|-------------------|-------|
| ...     | ...            | Present / Missing / Different | [how sp-compound handles it, if differently] |

### Reference File Comparison
| File | Upstream | sp-compound | Differences |
|------|----------|-------------|-------------|
| ...  | ...      | ...         | ...         |

### sp-compound Unique Features
- [features sp-compound has that upstream doesn't — these MUST NOT be regressed]

### Previously Rejected (from rejection-log.md)
- [items already evaluated and rejected — skip unless context has materially changed]
```

### Comparison Rules

- Compare **semantics, not prose**. A feature covered in different words or structure is not a difference.
- sp-compound's conciseness is intentional. Only flag missing *functionality*, not missing *verbosity*.
- Framework-specific content removed by design — classify as Skip.
- When sp-compound has a feature upstream doesn't, list it under "sp-compound Unique Features" to protect from regression.
- When an item appears in rejection-log.md with still-valid reasoning, list it under "Previously Rejected" and do not re-evaluate unless the upstream implementation has materially changed.

## Phase 2: Evaluate & Decide

For each difference found in Phase 1 (excluding Previously Rejected and sp-compound Unique Features), apply the evaluation framework from `references/review-criteria.md`:

### Step 1: Cost-Benefit Analysis

Use the Cost-Benefit Evaluation Template for each difference. Key questions:

1. **Benefit**: What concrete improvement does adopting this bring? Would users or the agent notice its absence?
2. **Cost**: How much complexity does it add? Does it hurt conciseness (principle #1)?
3. **Equivalence**: Does sp-compound already solve this problem differently? If so, which approach is better *for sp-compound's context*?

### Step 2: Decision

Based on the analysis, assign one of:

| Decision | When |
|----------|------|
| **Adopt** | Genuinely missing, aligns with design principles, no equivalent exists |
| **Adapt** | Real problem, but upstream implementation doesn't fit — redesign for sp-compound |
| **Reject** | sp-compound's approach is equal/better, or cost outweighs benefit |
| **Skip** | Framework-specific, cosmetic, or not applicable |

For Adopt/Adapt, also assign priority: **P0** / **P1** / **P2**

### Step 3: Record Decisions

- Adopt/Adapt: proceed to Phase 3
- Reject: append to `references/rejection-log.md` with reasoning and date
- Skip: no action needed

Produce a decision summary:

```
## Decision Summary: <skill-name>

### Adopt
1. [P0/P1/P2] [feature] — [one-line reasoning]

### Adapt
1. [P0/P1/P2] [feature] — [one-line reasoning + how to adapt]

### Reject
1. [feature] — [reason]

### Skip
1. [feature] — [reason]
```

If no Adopt or Adapt items: report the skill as clean and move to next skill.

## Phase 3: Impact Check + Fix

### Step 1: Impact Check

Before implementing ANY change, run the Impact Assessment from `references/review-criteria.md` for each Adopt/Adapt item:

- Which skills in the workflow chain (brainstorm -> plan -> work -> review -> compound) are affected?
- Which shared reference files need synchronized updates?
- Does this touch the knowledge store schema (.sp-compound/solutions/ frontmatter)?
- Do subagent prompt templates need updating?

**Cascade handling:**
- No cascade → proceed to fix
- Contained cascade → fix all affected files together in this phase
- Broad cascade → attempt to Adapt with smaller scope. If Adapt is also not feasible, flip to Reject and record in rejection-log.md

### Step 2: Fix

Apply all Adopt and Adapt items that passed impact check. Rules:

- Edit existing files. Do not create new files unless the difference requires a new reference file.
- Preserve sp-compound's concise style. Port the *functionality*, not the upstream's prose length.
- Do not regress sp-compound unique features listed in Phase 1.
- When porting schema/enum changes, ensure consistency across all reference files that share the same definitions.
- When adding sections to a SKILL.md, place them in logical order relative to existing phases/sections.
- For Adapt items: implement the sp-compound-native solution designed in Phase 2, not the upstream version.

## Phase 4: Re-Compare

Re-read the modified sp-compound files and re-run Phase 1 comparison against the same upstream sources.

- If new Adopt/Adapt items are found (including regressions introduced by Phase 3): return to Phase 2.
- If only Reject/Skip items remain: the skill is clean. Output a final summary and move to next skill.
- Maximum 3 iterations per skill. If items persist after 3 rounds, report them as unresolved with context.

---

## Parallel Execution

When scope includes multiple skills, dispatch one subagent per skill (or per small group of related skills). Each subagent runs the full Phase 1-4 loop independently.

### Subagent Dispatch

For each skill (or skill group), spawn a subagent with this prompt structure:

```
You are evaluating sp-compound's `<skill-name>` skill against its upstream peers.

## Your Task
Run the self-improve workflow (Phase 1-4) for `<skill-name>`.

## Files to Read

sp-compound:
- <sp-compound skill SKILL.md path>
- <sp-compound reference file paths>

Upstream source(s):
- <upstream SKILL.md path(s)>
- <upstream reference/asset file paths>

## Design Principles
<inline the content of references/design-principles.md>

## Review Criteria
<inline the content of references/review-criteria.md>

## Previously Rejected
<inline relevant entries from references/rejection-log.md>

## Rules
- Use native file tools (Read, Glob, Grep, Edit) — no shell commands for file operations
- Evaluate each difference on its own merit, not its origin
- Port functionality, not prose. Keep sp-compound's concise style.
- Do NOT regress sp-compound unique features: <list from Phase 1>
- Run impact assessment BEFORE making any edit
- Ensure cross-file consistency after edits (schema + mapping + template must agree)
- Record all Reject decisions with reasoning
- Maximum 3 compare-fix iterations

## Output
Return a structured report:
1. Difference report (Phase 1)
2. Cost-benefit analysis + decisions (Phase 2)
3. Impact assessment results (Phase 3)
4. Changes made (Phase 3)
5. Final verification (Phase 4)
6. Reject decisions to record
7. Any unresolved items
```

### Grouping Heuristic

Skills sharing reference files must be handled by the **same** subagent to avoid conflicting edits. Independent skills can run fully in parallel.

Suggested groups:
1. `compound` + `compound-refresh` (shared references)
2. `brainstorm` (merged, CE + SP)
3. `plan` (merged, CE + SP)
4. `work` (merged, 3 SP skills + CE)
5. `review` (merged, SP + CE)
6. `debug` + `verification` + `flexible-tdd` (SP-only, independent)
7. `receiving-review` + `finishing-branch` + `git-worktree` (SP-only, independent)
8. `using-sp-compound` (SP-only, bootstrap skill)

## Phase 5: New Feature Discovery

After all existing skills have been processed, evaluate the latest SP and CE for features sp-compound has NOT yet adopted.

### Process

1. Inventory all SP skills and CE skills (read their SKILL.md frontmatter)
2. Diff against `references/provenance-map.md` to find upstream skills with no sp-compound counterpart
3. Check `references/watch-list.md` for items due for re-evaluation
4. For each unported skill or notable feature, run the **New Feature Evaluation**:

```
### New Feature: [name]
Source: SP / CE

**Value**
- Problem solved: [what]
- sp-compound users face this problem: Yes / No / Partially
- Current alternative: [none / manual workaround / partial coverage by existing skill]

**Fit**
- Design principle alignment: [check each principle, flag conflicts]
- Workflow chain integration: [standalone / needs insertion at specific point]
- Infrastructure dependencies: [none / requires specific agents or services]

**Cost**
- Implementation scope: [new skill / extend existing / reference file only]
- Ongoing maintenance: [one-time port / requires periodic upstream sync]

**Decision:** Worth Porting / Adapt Concept / Watch / Skip
**Reasoning:** [one sentence]
```

| Decision | Meaning |
|----------|---------|
| **Worth Porting** | High value, good fit, acceptable cost — recommend for next implementation cycle |
| **Adapt Concept** | Idea is valuable but needs sp-compound-native redesign |
| **Watch** | Potential but not urgent — add to watch-list.md with next review date |
| **Skip** | Not relevant to sp-compound |

5. Also scan ported skills for **new sections or features added upstream since last sync** — upstream skills evolve, and a skill that was fully evaluated previously may now have new phases, modes, or guardrails. Apply the same evaluation framework.

### Output

Append a "New Feature Opportunities" section to the consolidated report:

```
## New Feature Opportunities

### Worth Porting
| Feature | Source | Problem Solved | Recommended Approach |
|---------|--------|---------------|---------------------|
| ...     | SP/CE  | ...           | ...                 |

### Adapt Concept
| Feature | Source | Core Idea | How to Adapt for sp-compound |
|---------|--------|-----------|----------------------------|
| ...     | SP/CE  | ...       | ...                        |

### Watch (added to watch-list.md)
| Feature | Source | Why Watch | Re-evaluate By |
|---------|--------|-----------|---------------|
| ...     | SP/CE  | ...       | YYYY-MM-DD    |

### New Additions to Already-Ported Skills
| Upstream Skill | New Feature | Evaluation | Decision |
|---------------|------------|------------|----------|
| ...           | ...        | ...        | Adopt/Adapt/Reject/Skip |
```

Only list items with genuine potential. Skip items that are clearly framework-specific, niche, or redundant with existing sp-compound capabilities.

---

## Output

After all skills are processed, produce a consolidated report:

```
# Self-Improve Report

## Summary
| Skill | Iterations | Adopt | Adapt | Reject | Skip | Status |
|-------|-----------|-------|-------|--------|------|--------|

## Changes Made
### <skill-name>
- [file:line] — [what changed] — [decision: Adopt/Adapt]

## Rejected (recorded in rejection-log.md)
### <skill-name>
- [difference] — [reasoning]

## Unresolved
### <skill-name>
- [item] — [why unresolved, suggested next step]

## Protected Unique Features
Features unique to sp-compound that were verified not regressed:
- [skill]: [feature]

## New Feature Opportunities
(from Phase 5 — see Phase 5 Output section for table format)

## Watch List Updates
- [items added/updated in watch-list.md]
```
