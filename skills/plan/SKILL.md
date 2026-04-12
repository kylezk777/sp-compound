---
name: plan
description: Use when you have requirements or a detailed idea for a multi-step task, before touching code. Researches codebase and knowledge store, then creates SP-format implementation plans with informed code.
argument-hint: "[optional: feature description or requirements doc path]"
---

# Writing Research-Backed Plans

## Overview

Transform requirements into detailed implementation plans. Research the codebase and historical learnings FIRST, then write SP-format plans with complete code blocks, exact commands, and expected output.

<feature_description> #$ARGUMENTS </feature_description>

**If the feature description above is empty, ask the user:** "What would you like to plan? Describe the feature or task you have in mind."

Do not proceed until there is a clear planning input.

**Announce at start:** "I'm using the sp-compound plan skill to create the implementation plan."

**Save plans to:** `.sp-compound/plans/YYYY-MM-DD-<feature-name>-plan.md`

## Interaction Method

Use `AskUserQuestion` when available. Otherwise, present numbered options in chat and wait for the user's reply before proceeding. Ask one question at a time.

## Core Principle

The plan has two audiences: humans who review it and agents who execute it. Research ensures the code blocks are grounded in reality, not invented from scratch.

## Phase 0: Load Upstream Requirements

### 0.1 Find Requirements Document
Search `.sp-compound/brainstorms/` for matching `*-requirements.md` files:
- Semantic match on topic
- Prefer recent (within 30 days) but use judgment

### 0.2 Resume Existing Plan
Search `.sp-compound/plans/` for existing plans on this topic:
- If found: ask whether to update or create new
- If updating: preserve completed checkboxes, modify remaining tasks

**Deepen intent:** If the user says "deepen the plan", "deepen my plan", or similar, identify the target plan in `.sp-compound/plans/`. If the plan appears complete (all major sections present, implementation tasks defined), short-circuit to Phase 4 (Confidence Deepening) in interactive mode -- present findings for user approval before integrating. Normal editing requests ("update the test scenarios", "add a task") follow the standard resume flow, not the deepen fast-path.

### 0.3 Classify Outstanding Questions
From the requirements document's outstanding questions:
- **Planning-owned:** Technical/architectural questions → resolve during research
- **Blocking:** Product questions → surface to user, refuse to continue until resolved

### 0.4 No-Requirements Fallback
If no requirements document exists:
- Assess whether the request is clear enough for direct planning
- If ambiguity is mainly product framing, user behavior, or scope: recommend `sp-compound:brainstorm` first
- If the user wants to continue anyway, run a short planning bootstrap:
  - Problem frame
  - Intended behavior
  - Scope boundaries and obvious non-goals
  - Success criteria
  - Blocking questions or assumptions
- Keep the bootstrap brief — it preserves direct-entry convenience, not a full brainstorm replacement
- If the bootstrap uncovers major unresolved product questions, recommend `sp-compound:brainstorm` again; if the user still wants to continue, require explicit assumptions before proceeding

### 0.5 Scope Check
If the requirements cover multiple independent subsystems, suggest breaking into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

### 0.6 Classify Plan Depth
- **Lightweight** (1-2 tasks): Small, bounded changes. Skip external research.
- **Standard** (3-6 tasks): Normal features. Full research.
- **Deep** (7+ tasks, cross-cutting): Complex work. Full research + confidence deepening + **phased planning (see 0.7)**.

Depth classification is preliminary here — it is confirmed after Phase 2.5 (File Structure), when the actual task count is known. If File Structure reveals 7+ logical task groups, reclassify to Deep and use phased planning even if the initial estimate was Standard.

### 0.7 Phased Planning (Deep plans only)

Generating 7+ tasks with complete code blocks in a single pass exhausts context, degrades quality toward the end, and introduces cross-task inconsistencies. Deep plans use phased planning: write an architecture skeleton first, then detail tasks batch-by-batch.

**Phase A — Architecture Skeleton:**

Write the plan header (Goal, Architecture, Tech Stack, Research Summary, Rejected Alternatives) plus:

1. **Module Map** — every module/component, its responsibility, and which requirements (R1, R2...) it addresses
2. **Interface Contracts** — complete type definitions for the types, function signatures, API shapes, or data schemas that modules **share with each other**. These are the cross-module seams that lock consistency. Write actual code for these — this is the one place where cross-module types are defined once. Module-internal types are NOT included here; each batch defines its own.
3. **Execution Order** — which modules must be built first (foundation), which can be parallelized, which depend on others. Group into **batches** of 3-6 tasks each.
4. **Per-batch summary** — 2-3 sentences describing scope and deliverables. No code blocks yet.

Batch structure:
- **Batch 1 is always Foundation**: shared types, data models, core utilities — implements the interface contracts defined above
- **Batch 2-N are functional slices**: each delivers a complete, testable feature area
- **Each batch: 3-6 tasks** (the Standard sweet spot for plan quality)
- **Minimize cross-batch file edits**: later batches should avoid modifying files created by earlier batches. Cross-module interaction goes through the interface contracts.

Write skeleton to disk immediately after completion.

**Phase B — Batch Detail (serial, one batch at a time):**

For each batch in execution order:
1. Read the architecture skeleton (interface contracts are the consistency anchor)
2. Read all previous batches' **summaries** (not full code blocks — see format below)
3. Generate the current batch's tasks with full SP-format: complete code blocks, exact commands, expected output, execution notes, requirements trace — identical to the existing plan rules
4. Write a **batch summary** after the tasks

**Batch section heading format** (work uses this to detect batch boundaries):

```markdown
## Batch N: [Batch Name]
```

Example: `## Batch 1: Foundation`, `## Batch 2: User Management`. Always use h2 (`##`), always start with `Batch`, always include the batch number and a descriptive name after the colon.

**Batch summary format:**

```markdown
### Batch N Summary
**Files:** src/models/user.ts, src/models/types.ts, src/utils/crypto.ts
**Key exports:** User class, CreateUserInput type, UserRole enum, hashPassword()
```

5. Append the batch (tasks + summary) to the plan file on disk

The batch summary is lightweight (~10-15 lines) and carries forward to subsequent batches as context, replacing the need to hold previous batches' full code blocks in context.

**When NOT to use phased planning:**
- Lightweight and Standard plans — the overhead isn't justified
- User explicitly says "write the full plan in one pass" — respect the choice, but warn about quality risks for 10+ tasks

## Phase 1: Research Layer

**This is the highest-value addition over plain SP. Research BEFORE writing.**

### 1.1 Detect Execution Posture

Before dispatching research, silently detect the intended execution approach from available signals:

| Signal Source | What to Check |
|---------------|---------------|
| Requirements / origin doc | "TDD", "test-first", "characterization tests first", "spike" |
| Project instruction files | Testing conventions, TDD requirements |
| Repo patterns | Existing test structure, test-to-code ratio |

If a posture is detected (test-first, characterization-first, pragmatic, or external-delegate), carry it forward as an `Execution note:` on each implementation unit in the plan. This enables `sp-compound:work` to invoke `sp-compound:flexible-tdd` with the right strategy.

If no signal is found, omit the execution note — work will use its own default.

### 1.2 Dispatch Research Agents

Launch in parallel:

**Agent 1: repo-research-analyst** (always)
```
Dispatch sp-compound:repo-research-analyst agent with:
- Feature description from requirements
- Target files/modules if known
- Questions from Phase 0.3 that are planning-owned
```

**Agent 2: learnings-researcher** (always)
```
Dispatch sp-compound:learnings-researcher agent with:
- Feature description
- Target modules/components
- Problem domain keywords
```

**Agent 3: best-practices-researcher** (conditional — high-risk only)
```
Dispatch ONLY when the feature involves:
- Security (auth, encryption, input validation)
- Payments (billing, transactions)
- Data migrations (schema changes, backfills)
- External APIs (third-party integrations)
- Compliance (privacy, GDPR, audit)

Provide: feature description + technology stack from Agent 1
```

**External research decision:** After Agents 1-2 return, decide whether Agent 3 adds value:
- **Always research when:** High-risk topics (above list), codebase lacks relevant local patterns (fewer than 3 direct examples), or the technology scan found the relevant layer absent/thin.
- **Skip when:** The codebase already shows strong local patterns (multiple direct, recently-touched examples), the user already knows the intended shape, or additional context would add little practical value.
- Announce the decision briefly: "Your codebase has solid patterns for this. Proceeding without external research." or "This involves payment processing, so I'll research current best practices first."

Skip Agent 3 for Lightweight plans unless they touch high-risk areas.

### 1.3 Consolidate Research

Merge agent outputs into a research summary:

```
## Research Summary

### Codebase Patterns
[From repo-research-analyst: architecture, naming, testing patterns, relevant files]

### Historical Learnings
[From learnings-researcher: directly/indirectly relevant docs, pattern docs]
[If none: "No historical experience found — first time in this area"]

### External Guidance (if researched)
[From best-practices-researcher: official docs, security guidance, known pitfalls]

### Resolved Questions
[Planning-owned questions resolved by research]

### Material Constraints
[Hard constraints discovered: API limits, framework restrictions, etc.]
```

### 1.4 Flow Analysis (conditional — Deep plans with stateful behavior)

After consolidating research, dispatch if the feature involves state machines, multi-step workflows, or event-driven flows:

```
Dispatch sp-compound:spec-flow-analyzer agent with:
- Feature description
- Consolidated research from Phase 1.2 (codebase patterns, existing state handling)
- Target states/transitions if identifiable from requirements
```

Skip for Lightweight/Standard plans unless the feature is clearly stateful.

Flow analysis output feeds into: test scenarios (edge cases), risk section (error paths), and implementation approach (state handling patterns).

### 1.4b Reclassify Depth When Research Reveals External Contracts

If the current classification is **Lightweight** and Phase 1 research found the work touches any of these external contract surfaces, reclassify to **Standard**:
- Environment variables consumed by external systems, CI, or other repositories
- Exported public APIs, CLI flags, or command-line interface contracts
- CI/CD configuration files (`.github/workflows/`, `Dockerfile`, deployment scripts)
- Shared types or interfaces imported by downstream consumers
- Documentation referenced by external URLs or linked from other systems

Announce briefly: "Reclassifying to Standard -- this change touches [surface] with external consumers."

### 1.5 How Learnings Influence the Plan

When learnings-researcher returns relevant findings:

| Finding Type | Plan Impact |
|---|---|
| Directly relevant learning | Implementation unit's Approach should cite and follow the proven solution |
| Known edge case from learning | Test Scenarios MUST include it |
| Proven code pattern | Code blocks should base on the pattern, not invent from scratch |
| Historical risk | Risks & Dependencies section must include it |
| Prevention rule | Plan should incorporate the prevention measure |

**Explicit attribution required:** "Based on `.sp-compound/solutions/runtime-errors/redis-pool-exhaustion.md`, we use connection pool prewarming..."

## Phase 2: Resolve Planning Questions

Build question list from:
- Deferred questions from requirements
- Gaps found during research
- Technical decisions needed

Each question: classify as planning-resolvable or implementation-deferred.
Only ask user when answer materially affects architecture, scope, or sequencing.

## Phase 2.5: File Structure

Before defining tasks, map out which files will be created or modified and what each is responsible for. This locks in decomposition decisions early.

- Design units with clear boundaries and well-defined interfaces. One clear responsibility per file.
- Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure — but if a file has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

After mapping the file structure, confirm the depth classification from Phase 0.6: if the structure reveals 7+ logical task groups, reclassify to Deep and use phased planning (Phase 0.7).

## Phase 3: Write the Plan

**Deep plans using phased planning (Phase 0.7):** In this phase, write only the Architecture Skeleton (Phase A). Then proceed to Phase B (batch-by-batch detail) serially — each batch generates full SP-format tasks and appends to the plan file. After all batches are detailed, proceed to Phase 4 (confidence deepening on skeleton + Batch 1) and Phase 5 (self-review).

### Plan Format (SP-style — preserved exactly)

**Every plan MUST start with this header:**

```markdown
---
title: [Feature Name] Implementation Plan
type: [feat|fix|refactor]
status: active
date: YYYY-MM-DD
origin: .sp-compound/brainstorms/YYYY-MM-DD-<topic>-requirements.md  # include when planning from a requirements doc
deepened: YYYY-MM-DD  # optional, set when confidence deepening substantively strengthens the plan
---

# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use sp-compound:work to implement this plan task-by-task.

**Goal:** [One sentence]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies]

**Research Summary:** [2-3 sentences — what research found that shaped this plan]

**Requirements:** [Path to requirements document, if exists]

**Scope Boundaries:**
- [Explicit non-goal or exclusion]

<!-- Optional: when some items are planned work for a separate PR or task, distinguish from true non-goals -->
### Deferred to Separate Tasks
- [Work that will be done separately]: [Where or when]

**Rejected Alternatives:**

| Alternative | Why rejected |
|-------------|-------------|
| [Approach that was considered] | [Specific reason: perf, complexity, constraint, etc.] |

<!-- Optional: include when the plan creates 3+ new files in a new directory hierarchy.
     Shows the expected output shape at a glance. Omit for plans that only modify existing files. -->
## Output Structure

    [directory tree showing new directories and files]

---
```

**Task structure — each step is one action (2-5 minutes):**

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext`
- Test: `tests/exact/path/to/test.ext`

**Execution note:** [test-first | characterization-first | pragmatic]

**Requirements trace:** [R1, R3 — which requirements this task addresses]

**Learnings applied:** [If any: "Based on .sp-compound/solutions/X, we..."]

- [ ] **Step 1: Write the failing test**

```language
// complete test code here
```

- [ ] **Step 2: Run test to verify it fails**

Run: `test-command path/to/test`
Expected: FAIL with "specific error message"

- [ ] **Step 3: Write minimal implementation**

```language
// complete implementation code here
```

- [ ] **Step 4: Run test to verify it passes**

Run: `test-command path/to/test`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add <specific files>
git commit -m "feat: descriptive message"
```
````

### Plan Rules

- **No Placeholders:** Every step has actual content. No "TBD", "TODO", "implement later", "add tests for above", "add appropriate error handling", "handle edge cases", "similar to Task N" (repeat the code -- the reader may see tasks out of order), steps that describe what to do without showing how, or references to types/functions not defined in any task.
- **Rejected Alternatives:** The plan header MUST include the Rejected Alternatives table. If only one approach was viable, state why the obvious alternative was ruled out. Implementers and reviewers need this context to avoid re-discovering the same dead ends.
- **Complete code:** If a step changes code, show the code.
- **Repo-relative file paths:** Always use repo-relative paths (e.g., `src/models/user.rb`), never absolute paths (e.g., `/Users/name/project/src/models/user.rb`). Absolute paths break portability across machines, worktrees, and teammates.
- **Exact commands with expected output:** Always.
- **DRY, YAGNI:** Don't over-engineer.
- **Execution notes:** Every task gets an execution note (test-first is default).
- **Requirements trace:** Every task links back to requirement IDs.
- **Learnings attribution:** Cite .sp-compound/solutions/ when the approach is informed by history.

## Phase 4: Confidence Deepening (Standard/Deep plans only)

After writing the plan, assess whether sections need strengthening. Skip for Lightweight plans unless they touch high-risk areas.

**For phased Deep plans:** Apply confidence deepening to the **architecture skeleton** (module boundaries, interface contracts, rejected alternatives) and **Batch 1 (Foundation)** only. Later functional batches are Standard-sized and have work's three-role review as a quality backstop — deepening every batch would multiply token cost with diminishing returns.

### 4.1 Deepening Gate

**Two deepening modes:**
- **Auto mode** (default during plan generation): Runs without asking for approval. Sub-agent findings are synthesized directly into the plan.
- **Interactive mode** (activated by the deepen fast-path in Phase 0.2): Findings are presented individually for user review before integration. The user can accept, reject, or discuss each finding.

Quick-scan the plan for weak sections. A section is weak if it has thin rationale, missing tradeoffs, vague test scenarios, or gaps in risk treatment.

- **Thin local grounding override:** If Phase 1 triggered external research because local patterns were thin (fewer than 3 direct examples), always proceed to scoring regardless of how grounded the plan appears. When the plan was built on unfamiliar territory, claims about system behavior are more likely to be assumptions than verified facts.
- If **0 sections** score as candidates (and the thin-grounding override does not apply): skip deepening, proceed to Phase 5
- If **1+ sections** score: load `references/deepening-workflow.md` and follow the confidence scoring, targeted research dispatch, and synthesis steps

### 4.2 Execute Deepening

Read and follow `references/deepening-workflow.md`:
1. Score each section using the checklists (trigger count + risk bonus + critical-section bonus)
2. Select top 2-5 weak sections (1-2 for Lightweight)
3. Announce what's being strengthened and why
4. Dispatch targeted research agents (1-3 per section, max ~8 total)
5. Integrate findings: strengthen rationale, add references, improve test scenarios
6. Add `deepened: YYYY-MM-DD` to plan YAML frontmatter

**Principle: "Stronger not longer"** — improve weak sections, don't pad strong ones.

## Phase 5: Self-Review and Handoff

### 5.1 Self-Review Checklist

1. **Spec coverage:** Every requirement (R1, R2...) maps to at least one task?
2. **Placeholder scan:** Any violations of the No Placeholders rule? ("TBD", "TODO", "implement later", "add appropriate error handling", "handle edge cases", "similar to Task N", steps without code blocks, references to undefined types/functions)
3. **Type consistency:** Same names used for same things across all tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.
4. **Learnings integration:** If learnings-researcher found relevant docs, are they reflected?
5. **Research grounding:** Are code blocks based on actual codebase patterns (from repo-research)?
6. **Path check:** All file paths repo-relative? No absolute paths leaked in?
7. **Rejected Alternatives:** Does the header include the Rejected Alternatives table with specific reasons?

**Additional checks for phased Deep plans:**

8. **Interface contract coverage:** Do the contracts cover all cross-module interactions? Any batch task imports a type not defined in the contracts?
9. **Batch sizing:** Is every batch 3-6 tasks? Oversized batches defeat the purpose of phasing.
10. **Cross-batch file edits:** Do later batches avoid modifying files created by earlier batches? If unavoidable, do the interface contracts pre-define the extension point?
11. **Batch summaries:** Does every batch end with a summary (files + key exports)?

Fix issues inline. No need to re-review.

### 5.2 Write Plan to Disk

Save to `.sp-compound/plans/YYYY-MM-DD-<feature-name>-plan.md` BEFORE presenting options.

### 5.3 Execution Handoff

```
Plan complete and saved to `<path>`. Ready to execute?

1. Start sp-compound:work (recommended)
2. Open plan in editor for manual review
3. Keep plan, I'll execute later
4. Create issue in project tracker

Which approach?
```

**If option 1 chosen:** Invoke `sp-compound:work` with the plan path.

**If option 4 chosen:** Detect the project tracker from `AGENTS.md` or `CLAUDE.md` (`project_tracker: github` or `project_tracker: linear`). For GitHub: `gh issue create --title "<type>: <title>" --body-file <plan_path>`. For Linear: `linear issue create --title "<title>" --description "$(cat <plan_path>)"`. If no tracker is configured, ask which they use and suggest adding it to `AGENTS.md`.

## Integration

**Called by:**
- **sp-compound:brainstorm** — terminal state invokes this skill
- Directly by user when requirements are already clear

**Invokes:**
- **sp-compound:work** — when plan is approved and user chooses to execute

**Dispatches agents:**
- **repo-research-analyst** — always during Phase 1
- **learnings-researcher** — always during Phase 1
- **best-practices-researcher** — conditionally during Phase 1 (high-risk only)
- **spec-flow-analyzer** — conditionally after Phase 1.2 (Deep plans with stateful behavior)
