---
name: plan
description: Use when you have requirements or a detailed idea for a multi-step task, before touching code. Researches codebase and knowledge store, then creates SP-format implementation plans with informed code.
---

# Writing Research-Backed Plans

## Overview

Transform requirements into detailed implementation plans. Research the codebase and historical learnings FIRST, then write SP-format plans with complete code blocks, exact commands, and expected output.

**Announce at start:** "I'm using the sp-compound plan skill to create the implementation plan."

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>-plan.md`

## Interaction Method

Use the platform's question tool when available (`AskUserQuestion` in Claude Code, `request_user_input` in Codex, `ask_user` in Gemini). Otherwise, present numbered options in chat and wait for the user's reply before proceeding. Ask one question at a time.

## Core Principle

The plan has two audiences: humans who review it and agents who execute it. Research ensures the code blocks are grounded in reality, not invented from scratch.

## Phase 0: Load Upstream Requirements

### 0.1 Find Requirements Document
Search `docs/brainstorms/` for matching `*-requirements.md` files:
- Semantic match on topic
- Prefer recent (within 30 days) but use judgment

### 0.2 Resume Existing Plan
Search `docs/plans/` for existing plans on this topic:
- If found: ask whether to update or create new
- If updating: preserve completed checkboxes, modify remaining tasks

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
- **Deep** (7+ tasks, cross-cutting): Complex work. Full research + confidence deepening.

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

**Explicit attribution required:** "Based on `docs/solutions/runtime-errors/redis-pool-exhaustion.md`, we use connection pool prewarming..."

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

## Phase 3: Write the Plan

### Plan Format (SP-style — preserved exactly)

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use sp-compound:work to implement this plan task-by-task.

**Goal:** [One sentence]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies]

**Research Summary:** [2-3 sentences — what research found that shaped this plan]

**Requirements:** [Path to requirements document, if exists]

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

**Learnings applied:** [If any: "Based on docs/solutions/X, we..."]

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
- **Complete code:** If a step changes code, show the code.
- **Repo-relative file paths:** Always use repo-relative paths (e.g., `src/models/user.rb`), never absolute paths (e.g., `/Users/name/project/src/models/user.rb`). Absolute paths break portability across machines, worktrees, and teammates.
- **Exact commands with expected output:** Always.
- **DRY, YAGNI:** Don't over-engineer.
- **Execution notes:** Every task gets an execution note (test-first is default).
- **Requirements trace:** Every task links back to requirement IDs.
- **Learnings attribution:** Cite docs/solutions/ when the approach is informed by history.

## Phase 4: Confidence Deepening (Standard/Deep plans only)

After writing the plan, assess whether sections need strengthening. Skip for Lightweight plans unless they touch high-risk areas.

### 4.1 Deepening Gate

Quick-scan the plan for weak sections. A section is weak if it has thin rationale, missing tradeoffs, vague test scenarios, or gaps in risk treatment.

- If **0 sections** score as candidates: skip deepening, proceed to Phase 5
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

Fix issues inline. No need to re-review.

### 5.2 Write Plan to Disk

Save to `docs/plans/YYYY-MM-DD-<feature-name>-plan.md` BEFORE presenting options.

### 5.3 Execution Handoff

```
Plan complete and saved to `<path>`. Ready to execute?

1. Start sp-compound:work (recommended)
2. Open plan in editor for manual review
3. Keep plan, I'll execute later

Which approach?
```

**If option 1 chosen:** Invoke `sp-compound:work` with the plan path.

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
