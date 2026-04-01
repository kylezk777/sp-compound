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
- Deferred unknowns
- Scope boundaries

**Ask questions NOW** — better to clarify than build wrong.

### Step 2: Setup Environment

Check current git branch vs default branch, offer options:

1. **Continue on current feature branch** (if already on one)
2. **Create a new branch** (if on default branch)
3. **Use git worktree** — invoke `sp-compound:git-worktree` (recommended for parallel dev)
4. **Continue on default branch** (requires explicit user confirmation — dangerous)

### Step 3: Create Task List (skip for trivial)
Break plan into actionable tasks from implementation units. Include dependency ordering and testing tasks.

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
3. Run tests after each change
4. Commit incrementally

## Test Discovery

Before changing any file:
1. Find its existing test files (search for `test_<name>`, `<name>.test`, `<name>_test`)
2. Check test scenarios against 4 categories:
   - Happy path
   - Edge cases
   - Error/failure paths
   - Integration scenarios
3. Supplement gaps before writing tests

## Incremental Commits

- Commit when a logical unit is complete AND tests pass
- Don't commit WIP or partial work
- Conventional commit messages (feat:, fix:, refactor:, test:)
- Stage only relevant files (not `git add .`)

## Phase 3: Quality Check

After all tasks complete:

1. **Run full test suite and linting**
2. **Invoke `sp-compound:review`** — multi-reviewer code review
3. **Address review findings** — fix critical/important issues
4. **Run `sp-compound:verification`** — evidence before claiming done

## Phase 4: Ship

After review passes:

1. **Invoke `sp-compound:finishing-branch`** — present merge/PR/cleanup options
2. **Suggest `sp-compound:compound`** — if a notable problem was solved during this work, suggest capturing the learning

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
