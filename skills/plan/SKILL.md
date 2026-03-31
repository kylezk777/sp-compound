---
name: plan
description: Use when you have requirements or a detailed idea for a multi-step task, before touching code. Researches codebase and knowledge store, then creates SP-format implementation plans with informed code.
---

# Writing Research-Backed Plans

## Overview

Transform requirements into detailed implementation plans. Research the codebase and historical learnings FIRST, then write SP-format plans with complete code blocks, exact commands, and expected output.

**Announce at start:** "I'm using the sp-compound plan skill to create the implementation plan."

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>-plan.md`

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
- If ambiguous: recommend `sp-compound:brainstorm` first
- If clear: establish problem frame, scope, and success criteria inline

### 0.5 Classify Plan Depth
- **Lightweight** (1-2 tasks): Small, bounded changes. Skip external research.
- **Standard** (3-6 tasks): Normal features. Full research.
- **Deep** (7+ tasks, cross-cutting): Complex work. Full research + confidence deepening.

## Phase 1: Research Layer

**This is the highest-value addition over plain SP. Research BEFORE writing.**

### 1.1 Dispatch Research Agents

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

Skip Agent 3 for Lightweight plans or when strong local patterns exist.

### 1.2 Consolidate Research

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

### 1.3 How Learnings Influence the Plan

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

- **No Placeholders:** Every step has actual content. No "TBD", "implement later", "add tests for above."
- **Complete code:** If a step changes code, show the code.
- **Exact file paths:** Always.
- **Exact commands with expected output:** Always.
- **DRY, YAGNI:** Don't over-engineer.
- **Execution notes:** Every task gets an execution note (test-first is default).
- **Requirements trace:** Every task links back to requirement IDs.
- **Learnings attribution:** Cite docs/solutions/ when the approach is informed by history.

## Phase 4: Confidence Deepening (Standard/Deep plans only)

After writing the plan, score weak sections:

### 4.1 Identify Weak Sections
Check each section against:
- Are requirements fully traced? (every R# maps to a task)
- Are research findings reflected in code blocks?
- Are risks identified with mitigation?
- Are test scenarios comprehensive across 4 categories? (happy path, edge cases, error paths, integration)

### 4.2 Strengthen Weak Sections
For sections scoring low:
- Dispatch targeted research agents with specific questions
- Strengthen the section based on findings
- "Stronger not longer" — don't pad, improve

Skip for Lightweight plans unless they touch high-risk areas.

## Phase 5: Self-Review and Handoff

### 5.1 Self-Review Checklist

1. **Spec coverage:** Every requirement (R1, R2...) maps to at least one task?
2. **Placeholder scan:** Any "TBD", "TODO", "implement later", "similar to Task N"?
3. **Type consistency:** Same names used for same things across all tasks?
4. **Learnings integration:** If learnings-researcher found relevant docs, are they reflected?
5. **Research grounding:** Are code blocks based on actual codebase patterns (from repo-research)?

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
