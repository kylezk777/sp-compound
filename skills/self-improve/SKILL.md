---
name: self-improve
description: "Compare sp-compound skills against their upstream sources (Superpowers and Compound Engineering), identify functional gaps, and fix them iteratively. Use manually when maintaining or upgrading sp-compound skill quality. Not auto-invoked."
disable-model-invocation: true
---

# Self-Improve: Upstream Gap Analysis and Fix

Systematically compare sp-compound skills against their upstream sources in Superpowers (SP) and Compound Engineering (CE), identify meaningful gaps, fix them, and verify until no actionable gaps remain.

## Source Locations

Upstream plugins must be accessible locally. Verify before starting:
- **SP**: find `superpowers/skills/` relative to the sp-compound repo's parent directory
- **CE**: find `compound-engineering-plugin/plugins/compound-engineering/skills/` relative to the same parent

If either is missing, report and ask the user for the correct path. Do not guess.

## Scope Selection

If `$ARGUMENTS` is provided, treat it as a comma-separated list of skill names to improve. Otherwise, improve ALL skills listed in `references/provenance-map.md`.

## Workflow

```
Phase 0: git pull upstream repos + load config
For each skill in scope (parallel where possible):
  Phase 1: Read & Compare
  Phase 2: Evaluate Gaps
  Phase 3: Fix
  Phase 4: Re-Compare
  Repeat Phase 2-4 until no actionable gaps remain
Phase 5: Scan upstream for unported features worth adopting
```

Skills are independent — dispatch them to parallel subagents when improving multiple skills simultaneously. Phase 5 runs once after all skills are done.

---

## Phase 0: Setup

1. **Pull latest upstream code.** Both SP and CE are actively maintained open-source projects. Before any comparison, ensure local copies are current:
   ```
   git -C <SP repo root> pull
   ```
   ```
   git -C <CE repo root> pull
   ```
   If a pull fails (dirty tree, network issue), report the error and ask the user whether to continue with the current local version or abort. Do not force-reset or stash without consent.

2. Read `references/provenance-map.md` to resolve which upstream skill(s) map to each sp-compound skill in scope
3. Read `references/review-criteria.md` to load severity classification and comparison dimensions
4. Verify upstream source paths exist. If a source skill directory is missing, skip that comparison pair and report it

## Phase 1: Read & Compare

For each sp-compound skill, read:
- The sp-compound SKILL.md + all files under its `references/` directory
- Each mapped upstream SKILL.md + all files under their `references/` and `assets/` directories

Then produce a **gap report** structured as:

```
## Gap Report: <skill-name>

### Functionality Comparison
| Feature | Upstream Detail | sp-compound Status | Severity |
|---------|----------------|-------------------|----------|
| ...     | ...            | Present / Missing / Reduced | Must Fix / Should Fix / Skip |

### Reference File Comparison
| File | Upstream | sp-compound | Differences |
|------|----------|-------------|-------------|
| ...  | ...      | ...         | ...         |

### sp-compound Improvements (not in upstream)
- List features sp-compound has that upstream doesn't (these must NOT be regressed)
```

### Comparison Rules

- Compare **semantics, not prose**. A feature covered in different words or structure is not a gap.
- sp-compound's conciseness is intentional. Only flag missing *functionality*, not missing *verbosity*.
- Framework-specific content (Rails enums, plugin-specific agents) removed by design — classify as Skip.
- When sp-compound has a feature upstream doesn't (e.g., autonomous mode, pattern templates), list it under "sp-compound Improvements" to protect from regression.

## Phase 2: Evaluate Gaps

Apply `references/review-criteria.md` severity rules to each gap:

- **Must Fix**: functional gaps, missing schema entries, missing guardrails, missing fallback modes, underspecified critical protocols
- **Should Fix**: efficiency guidance, interaction principles, edge-case protocols, missing scope hints
- **Skip**: intentional differences, framework-specific content, verbosity differences

Produce a fix plan:

```
## Fix Plan: <skill-name>

### Must Fix
1. [file] — [what to change and why]

### Should Fix
1. [file] — [what to change and why]

### Skip (with reason)
1. [gap description] — [why it's intentional or not applicable]
```

If no Must Fix or Should Fix items: report the skill as clean and move to next skill.

## Phase 3: Fix

Apply all Must Fix and Should Fix items. Rules:

- Edit existing files. Do not create new files unless the gap requires a new reference file.
- Preserve sp-compound's concise style. Port the *functionality*, not the upstream's prose length.
- Do not regress sp-compound improvements listed in Phase 1.
- When porting schema/enum changes, ensure consistency across all reference files that share the same definitions (e.g., solution-schema.yaml and yaml-schema.md must stay in sync).
- When adding sections to a SKILL.md, place them in logical order relative to existing phases/sections.

## Phase 4: Re-Compare

Re-read the modified sp-compound files and re-run Phase 1 comparison against the same upstream sources.

- If new Must Fix or Should Fix gaps are found (including regressions introduced by Phase 3): return to Phase 2.
- If only Skip items remain: the skill is clean. Output a final summary and move to next skill.
- Maximum 3 iterations per skill. If gaps persist after 3 rounds, report them as unresolved with context.

---

## Parallel Execution

When scope includes multiple skills, dispatch one subagent per skill (or per small group of related skills). Each subagent runs the full Phase 1-4 loop independently.

### Subagent Dispatch

For each skill (or skill group), spawn a subagent with this prompt structure:

```
You are improving sp-compound's `<skill-name>` skill by comparing it against upstream sources.

## Your Task
Run the self-improve workflow (Phase 1-4) for `<skill-name>`.

## Files to Read

sp-compound:
- <sp-compound skill SKILL.md path>
- <sp-compound reference file paths>

Upstream source(s):
- <upstream SKILL.md path(s)>
- <upstream reference/asset file paths>

## Review Criteria
<inline the content of references/review-criteria.md>

## Rules
- Use native file tools (Read, Glob, Grep, Edit) — no shell commands for file operations
- Port functionality, not prose. Keep sp-compound's concise style.
- Do NOT regress sp-compound improvements: <list improvements from provenance map>
- Ensure cross-file consistency after edits (schema + mapping + template must agree)
- Maximum 3 compare-fix iterations

## Output
Return a structured report:
1. Gap report (Phase 1)
2. Fix plan (Phase 2)
3. Changes made (Phase 3)
4. Final verification (Phase 4)
5. Any unresolved items
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

After all existing skills have been improved, evaluate the latest SP and CE for features sp-compound has NOT yet adopted.

### Process

1. Inventory all SP skills and CE skills (read their SKILL.md frontmatter)
2. Diff against `references/provenance-map.md` to find upstream skills with no sp-compound counterpart
3. For each unported skill or notable feature, evaluate:
   - **Relevance**: does it serve the sp-compound workflow (brainstorm -> plan -> work -> review -> compound)?
   - **Independence**: can it function without plugin-specific agents or infrastructure?
   - **Value**: does it address a gap users would notice, or is it niche?
4. Also scan ported skills for **new sections or features added upstream since last sync** — upstream skills evolve, and a skill that was fully ported 3 months ago may now have new phases, modes, or guardrails

### Output

Append a "New Feature Opportunities" section to the consolidated report:

```
## New Feature Opportunities

Features in latest SP/CE not yet adopted by sp-compound. Listed for evaluation only — this skill does not implement them.

### From Superpowers
| Skill / Feature | What It Does | Relevance to sp-compound | Recommendation |
|----------------|-------------|-------------------------|----------------|
| ...            | ...         | High / Medium / Low     | Worth porting / Nice-to-have / Skip |

### From Compound Engineering
| Skill / Feature | What It Does | Relevance to sp-compound | Recommendation |
|----------------|-------------|-------------------------|----------------|
| ...            | ...         | High / Medium / Low     | Worth porting / Nice-to-have / Skip |

### New Additions to Already-Ported Skills
| Upstream Skill | New Feature | Added Since | Recommendation |
|---------------|------------|-------------|----------------|
| ...           | ...        | (approx)    | Port / Evaluate / Skip |
```

Only list items with Medium or High relevance. Skip items that are clearly framework-specific, niche, or redundant with existing sp-compound capabilities.

---

## Output

After all skills are processed, produce a consolidated report:

```
# Self-Improve Report

## Summary
| Skill | Iterations | Must Fix | Should Fix | Skipped | Status |
|-------|-----------|----------|------------|---------|--------|

## Changes Made
### <skill-name>
- [file:line] — [what changed]

## Unresolved
### <skill-name>
- [gap] — [why unresolved, suggested next step]

## Protected Improvements
Features unique to sp-compound that were verified not regressed:
- [skill]: [feature]

## New Feature Opportunities
(from Phase 5 — see Phase 5 Output section for table format)
```
