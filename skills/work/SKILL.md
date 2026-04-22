---
name: work
description: Use when you have an implementation plan to execute or a clear task to implement. Dispatches subagents per task with three-role architecture (implementer, spec reviewer, code quality reviewer) and flexible execution strategies.
---

# Executing Work

## Overview

Execute plans efficiently using the best strategy for the task. For plans with 3+ tasks, use SP's three-role subagent architecture. For simpler work, use lighter strategies.

**Announce at start:** "I'm using the sp-compound work skill to execute this plan."

**Core principle:** Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration.

## Phase 0: Input Triage

Determine routing based on input:

### File Path Input
Read the plan file. Proceed to Phase 1.

### Bare Prompt Input
Scan for affected files and existing tests, then assess complexity:

- **Trivial** (1-2 files, no behavioral change): implement directly, no task list
- **Small/Medium** (clear scope, under ~10 files): build task list, proceed
- **Large** (cross-cutting, 10+ files): recommend `sp-compound:brainstorm` or `sp-compound:plan` first, but honor user's choice to proceed

## Phase 1: Setup & Strategy

### Step 1: Read Plan and Clarify (skip for bare prompts)
Read the plan fully. It's a decision artifact, not an execution script. Check:
- Implementation Units and their execution notes
- `Patterns to follow` fields on each unit (specific files or conventions to mirror)
- `Verification` fields on each unit (the primary "done" signal)
- Deferred unknowns
- Scope boundaries

**Ask questions NOW** — better to clarify than build wrong.

### Step 2: Setup Environment

Check current git branch vs default branch, offer options:

1. **Continue on current feature branch** (if already on one)
   - If the branch name is auto-generated or meaningless (e.g., `worktree-jolly-beaming-raven`), suggest renaming to something derived from the plan title (e.g., `feat/crowd-sniff`)
2. **Create a new branch** (if on default branch)
3. **Use git worktree** — invoke `sp-compound:git-worktree` (recommended for parallel dev)
4. **Continue on default branch** (requires explicit user confirmation — dangerous)

### Step 3: Create Task List (skip for trivial)
Break plan into actionable tasks from implementation units. Include dependency ordering and testing tasks.
- Carry each unit's `Execution note` into the task (test-first, characterization-first, pragmatic)
- Use each unit's `Verification` field as the primary "done" signal for that task
- Read each unit's `Patterns to follow` before implementing

**Batched plan handling:** If the plan contains `## Batch` sections (h2 headings starting with "Batch", from phased planning), enforce batch boundaries as hard dependencies when building the task list:
- Tasks **within** the same batch: set dependencies based on their logical relationships (same as non-batched plans)
- Tasks in **Batch N+1**: blockedBy ALL tasks in Batch N

This ensures serial execution respects batch order, and parallel execution only parallelizes within a single batch — never across batch boundaries. Non-batched plans are unaffected; this logic only activates when `## Batch` sections are detected.

### Step 4: Choose Execution Strategy

| Strategy | When | How |
|----------|------|-----|
| **Direct inline** | Trivial (1-2 files) | Implement directly, no subagents |
| **Inline with TDD** | 1-2 tasks | Execute tasks in this session following flexible-tdd |
| **Serial subagent** | 3+ tasks with dependencies | One implementer subagent per task + two-stage review (SP architecture) |
| **Parallel subagent** | 3+ independent tasks | Multiple implementer subagents + review after each |

**Default for 3+ tasks with dependencies: Serial subagent** — this is SP's proven path.

## Phase 2: Execute — Serial Subagent (Primary Path)

For each task in priority order:

### 2.1 Dispatch Implementer

Use `./implementer-prompt.md` template. Provide:
- Full task text from plan (never make subagent read plan file)
- Scene-setting context (where this fits, what was built before)
- Working directory
- Execution note (test-first / characterization-first / pragmatic)
- Instruction to check whether test scenarios cover all applicable categories (happy paths, edge cases, error paths, integration) and supplement gaps before writing tests

**Permission mode:** Omit the `mode` parameter when dispatching subagents so the user's configured permission settings apply. Do not pass `mode: "auto"` — it overrides user-level settings.

**Model selection:**
- 1-2 files with complete spec → cheapest capable model (e.g., haiku)
- Multi-file with integration → standard model
- Architecture/design judgment → most capable model

### 2.2 Handle Implementer Status

| Status | Action |
|--------|--------|
| **DONE** | Proceed to spec review |
| **DONE_WITH_CONCERNS** | Read concerns. If correctness/scope: address before review. If observations: note and proceed. |
| **NEEDS_CONTEXT** | Provide missing context, re-dispatch same model |
| **BLOCKED** | Assess: context problem → provide + re-dispatch. Test failure → invoke `sp-compound:debug` before re-dispatch. Too hard → re-dispatch with more capable model. Too large → break into smaller pieces. Plan wrong → escalate to human. |

**Never** ignore an escalation or force retry without changes.

### 2.3 Spec Compliance Review

Use `./spec-reviewer-prompt.md` template. Provide task requirements and implementer's report.

- **Spec compliant** → proceed to code quality review
- **Issues found** → implementer fixes → re-review (loop until compliant)

### 2.4 Code Quality Review

Use `./code-quality-reviewer-prompt.md` template. **Only after spec compliance passes.**

Provide: what was implemented, plan reference, BASE_SHA, HEAD_SHA.

- **Approved** → mark task complete
- **Issues found** → implementer fixes → re-review (loop until approved)

### 2.5 Mark Complete and Continue

Mark task complete in task list. Move to next task.

## Phase 2 (Alternate): Direct Inline

For trivial/small work without subagents:

1. Follow the plan steps directly
2. Use `sp-compound:flexible-tdd` for the execution note's strategy
3. Follow existing patterns — read plan-referenced files first, match naming conventions, reuse existing components
4. Run tests after each change
5. Commit incrementally

**Execution posture guardrails:**
- When working test-first: do not write the test and implementation in the same step
- Do not skip verifying that a new test fails before implementing the fix
- Do not over-implement beyond the current behavior slice
- Skip test-first for trivial renames, pure configuration, and pure styling work

**Stop and escalate when:**
- Hit a blocker (missing dependency, test fails repeatedly, instruction unclear)
- Plan has critical gaps preventing progress
- Verification fails and the cause is not obvious

Ask for clarification rather than guessing. Don't force through blockers.

**Revisit the plan when:**
- User updates the plan based on feedback
- Fundamental approach needs rethinking mid-execution
- Implementation reveals the plan's assumptions were wrong

## Test Discovery

Before changing any file:
1. Find its existing test files (search for `test_<name>`, `<name>.test`, `<name>_test`)
2. Check test scenarios against 4 categories and derive missing ones:

   | Category | When it applies | How to derive if missing |
   |----------|----------------|------------------------|
   | **Happy path** | Always for feature-bearing units | Read the unit's Goal and Approach for core input/output pairs |
   | **Edge cases** | Meaningful boundaries (inputs, state, concurrency) | Identify boundary values, empty/nil inputs, concurrent access patterns |
   | **Error/failure paths** | Failure modes (validation, external calls, permissions) | Enumerate invalid inputs, permission denials, downstream failures |
   | **Integration** | Crosses layers (callbacks, middleware, multi-service) | Identify the cross-layer chain, exercise without mocks |

3. Supplement gaps before writing tests

## System-Wide Test Check

Before marking a task done, trace the impact of the change:

| Question | Action |
|----------|--------|
| **What fires when this runs?** Callbacks, middleware, observers, event handlers — trace two levels out. | Read actual code for callbacks on models touched, middleware in request chain, `after_*` hooks. |
| **Do tests exercise the real chain?** If every dependency is mocked, the test proves logic in isolation only. | Write at least one integration test through the full callback/middleware chain. No mocks for interacting layers. |
| **Can failure leave orphaned state?** If code persists state before calling an external service, what happens on failure? | Trace the failure path with real objects. Test that failure cleans up or retry is idempotent. |
| **What other interfaces expose this?** Mixins, DSLs, alternative entry points. | Search for the method/behavior in related classes. Add parity now, not as a follow-up. |
| **Do error strategies align across layers?** Retry middleware + application fallback + framework error handling — conflicts? | List error classes at each layer. Verify rescue list matches what lower layer raises. |

**Skip when:** Leaf-node changes with no callbacks, no state persistence, no parallel interfaces. Purely additive changes (new helper, new view partial) need only a 10-second check.

## Incremental Commits

- Commit when a logical unit is complete AND tests pass
- **Heuristic:** "Can I write a commit message that describes a complete, valuable change? If yes, commit. If the message would be 'WIP' or 'partial X', wait."
- Don't commit WIP or partial work
- Conventional commit messages (feat:, fix:, refactor:, test:)
- Stage only relevant files (not `git add .`)
- If merge conflicts arise during rebasing or merging, resolve immediately — incremental commits make this easier

## Simplify as You Go

After every 2-3 completed tasks (or at natural phase boundaries like batch completions), review recently changed files against these AI code smell categories:

| Smell | What to look for | Action |
|-------|-----------------|--------|
| **Dead code** | Functions/variables added but never called; unreachable branches; debug leftovers | Delete — verify tests still pass |
| **Duplication** | Two blocks doing the same thing; copy-pasted logic with minor differences | Consolidate into shared helper |
| **Needless abstraction** | Pass-through wrappers; single-use helper layers; speculative indirection | Inline — the caller is clearer without it |
| **Boundary violation** | Wrong-layer imports; responsibilities placed in the wrong module | Move to correct layer |

**Order:** delete first, then consolidate, then restructure. Re-run tests after each pass.

Don't simplify after every single task — early patterns may look duplicated but diverge intentionally in later units.

## Post-Deploy Monitoring (include in PR)

For every change that ships, include a brief monitoring section in the PR description or commit notes:
- **Log queries:** concrete search terms or commands to verify the change works in production
- **Metrics/dashboards:** what to watch (latency, error rate, throughput)
- **Healthy signals:** what normal looks like after deploy
- **Rollback trigger:** what warrants an immediate rollback
- **Validation window and owner:** how long to monitor and who is responsible

Skip for changes that have no runtime impact (docs, comments, dev tooling).

## Phase 3: Quality Check

After all tasks complete:

1. **Run full test suite and linting**
2. **Invoke `sp-compound:review`** — multi-reviewer code review
3. **Address review findings** — fix critical/important issues
4. **Run `sp-compound:verification`** — evidence before claiming done

## Phase 4: Ship

After review passes:

1. **Update plan status** — if the input document has YAML frontmatter with a `status` field, update it to `completed`
2. **Invoke `sp-compound:finishing-branch`** — present merge/PR/cleanup options
3. **Suggest `sp-compound:compound`** — if a notable problem was solved during this work, suggest capturing the learning
   - If the user then runs `sp-compound:finishing-branch` and selects Options 1 or 2, Step 4.5 there will auto-capture — in that case this manual suggestion is redundant and should be skipped. Only surface this suggestion when the user signals they will **not** route through finishing-branch (e.g., Option 3 "keep as-is" / Option 4 "discard" / ad-hoc no-ship flow).

## Key Principles

1. **Start fast, execute faster** — clarify once, then move
2. **The plan is your guide** — follow referenced code and patterns
3. **Test as you go** — continuous testing prevents surprises
4. **Quality is built in** — patterns, tests, linting, review on every change
5. **Ship complete features** — a finished feature that ships beats a perfect feature that doesn't

## Red Flags

**Never:**
- Start implementation on main/master without explicit consent
- Skip reviews (spec compliance OR code quality)
- Proceed with unfixed issues
- Dispatch multiple implementers in parallel on same files
- Make subagent read plan file (provide full text instead)
- Skip subagent questions (answer before letting them proceed)
- Accept "close enough" on spec compliance
- Start code quality review before spec compliance confirmed

**If subagent asks questions:** Answer clearly and completely.
**If reviewer finds issues:** Implementer fixes → reviewer reviews again → repeat until approved.
**If subagent fails:** Dispatch fix subagent with specific instructions. Don't fix manually (context pollution).

## Integration

**Called by:**
- **sp-compound:plan** — when user approves plan and chooses to execute
- Directly by user with a plan path or bare prompt

**Invokes:**
- **sp-compound:flexible-tdd** — per implementation unit's execution note
- **sp-compound:review** — after all tasks complete (Phase 3)
- **sp-compound:verification** — before claiming completion (Phase 3)
- **sp-compound:finishing-branch** — after review passes (Phase 4)
- **sp-compound:git-worktree** — when user selects worktree strategy
