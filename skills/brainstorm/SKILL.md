---
name: brainstorm
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent and requirements through collaborative dialogue. Outputs a requirements document (WHAT to build), not a design document."
---

# Brainstorming Ideas Into Requirements

Help turn ideas into fully formed requirements documents through natural collaborative dialogue.

Start by checking for existing work and project context, then ask questions one at a time to refine the idea. Once you understand what to build, present the requirements and get user approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented requirements and the user has approved them. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need Requirements"

Every project goes through this process. The requirements can be short (a few sentences for truly simple projects), but you MUST present them and get approval.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Resume check** — search for existing brainstorm work
2. **Context scan** — check project files, docs, recent commits, knowledge store
3. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
4. **Propose 2-3 approaches** — with trade-offs and your recommendation
5. **Present requirements** — grouped by theme, get user approval
6. **Write requirements doc** — save to `docs/brainstorms/YYYY-MM-DD-<topic>-requirements.md`
7. **Requirements self-review** — check for placeholders, contradictions, ambiguity, scope
8. **User reviews written requirements** — ask user to review before proceeding
9. **Transition to planning** — invoke sp-compound:plan skill

## Phase 0: Resume Detection

Before starting fresh, check for existing work:

```
Search: docs/brainstorms/*-requirements.md
```

If matching documents found, ask:

```
Found existing requirements document: <filename>
Last modified: <date>

1. Continue from where we left off (recommended if recent)
2. Start fresh (new requirements document)

Which approach?
```

If resuming: read document, summarize current state, identify outstanding questions, and build on existing decisions rather than duplicating effort.

## Phase 1: Context Scan

Before asking questions, gather project context:

### 1.1 Project Constraints
- Read CLAUDE.md / AGENTS.md for project rules and constraints
- Note any workflow or scope constraints that affect the brainstorm

### 1.2 Existing Artifacts
- Search for prior brainstorms, plans, specs related to this topic
- Check recent git history for related work

### 1.3 Lightweight Learnings Check

Search `docs/solutions/` frontmatter for related historical experience:

```
Grep docs/solutions/**/*.md for module/component/tags matching the topic
```

- Do NOT deep-read the documents (that's the plan skill's job)
- Do NOT launch a subagent for this — just frontmatter grep
- Purpose: inform the user about existing knowledge
  - "This area has N historical learnings including X-type and Y-type issues"
  - This affects scope assessment and risk evaluation
- If `docs/solutions/` doesn't exist, note it and move on

## Phase 2: Interactive Q&A

### Scope Assessment
Before detailed questions, assess scope:
- If the request describes multiple independent subsystems → flag immediately, help decompose
- If too large for a single spec → break into sub-projects, brainstorm first one

### Question Guidelines
- One question at a time — don't overwhelm
- Prefer multiple choice when possible
- Focus on: purpose, constraints, success criteria, user expectations
- Open-ended is fine when exploring unknowns

## Phase 3: Propose Approaches

- Propose 2-3 different approaches with trade-offs
- Lead with your recommended option and explain why
- Present conversationally, not as a formal comparison matrix

## Phase 4: Present Requirements

Present requirements grouped by logical theme. This document answers WHAT to build, NOT HOW.

**Requirements document structure:**

```markdown
# <Topic> Requirements

## Problem Statement
[What problem are we solving? Why does it matter?]

## Success Criteria
[How do we know when this is done? Measurable where possible.]

## Requirements

### <Theme 1>
- **R1:** [Requirement with stable ID]
- **R2:** [Requirement with stable ID]

### <Theme 2>
- **R3:** [Requirement with stable ID]
- **R4:** [Requirement with stable ID]

## Scope Boundaries
[What is explicitly OUT of scope]

## Outstanding Questions

### Resolve Before Planning
[Product decisions that block planning]

### Deferred to Planning
[Technical/research questions better answered during planning]
- [Needs research] <question>
- [Technical] <question>

## Historical Context
[If learnings were found in docs/solutions/, summarize relevance here]
```

**Key rules:**
- Stable requirement IDs (R1, R2, R3...) — planning will reference these
- Group by logical theme, not discussion order
- WHAT not HOW — no architecture, no technology choices, no implementation details
- Outstanding questions split explicitly into blocking vs deferred

Ask after each theme whether it looks right. Be ready to revise.

## Phase 5: Write & Review

### Write Document
Save to: `docs/brainstorms/YYYY-MM-DD-<topic>-requirements.md`

### Self-Review
After writing, check with fresh eyes:
1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections?
2. **Internal consistency:** Do requirements contradict each other?
3. **Scope check:** Focused enough for a single implementation plan?
4. **Ambiguity check:** Could any requirement be interpreted two ways? Pick one.
5. **WHAT not HOW check:** Does any requirement specify implementation details? Remove them.

Fix issues inline. No need to re-review.

### User Review Gate

> "Requirements written to `<path>`. Please review and let me know if you want changes before we start planning."

Wait for user response. If changes requested, make them and re-run self-review. Only proceed once approved.

## Phase 6: Transition to Planning

**Terminal state: invoke sp-compound:plan**

Do NOT invoke any other skill. sp-compound:plan is the next step.

If the work is trivially simple and user agrees, may skip planning and invoke sp-compound:work directly.

## Key Principles

- **One question at a time** — don't overwhelm
- **Multiple choice preferred** — easier to answer when possible
- **YAGNI ruthlessly** — remove unnecessary requirements
- **Explore alternatives** — always propose 2-3 approaches
- **WHAT not HOW** — requirements, not design. Leave HOW for planning.
- **Incremental validation** — present requirements, get approval before writing
- **Resume over restart** — check for existing work before starting fresh
