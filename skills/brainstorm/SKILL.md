---
name: brainstorm
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent and requirements through collaborative dialogue. Outputs a requirements document (WHAT to build), not a design document."
---

# Brainstorming Ideas Into Requirements

Help turn ideas into fully formed requirements documents through natural collaborative dialogue.

Start by checking for existing work and project context, then ask questions one at a time to refine the idea. Once you understand what to build, present the requirements and get user approval.

All file references in generated documents must use repo-relative paths (e.g., `src/models/user.rb`), never absolute paths.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented requirements and the user has approved them. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need Requirements"

Every project goes through this process. The requirements can be short (a few sentences for truly simple projects), but you MUST present them and get approval.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Resume check** — search for existing brainstorm work
2. **Classify and route** — software vs non-software, assess scope (Lightweight/Standard/Deep), bypass if requirements already clear
3. **Context scan** — check project files, docs, recent commits, knowledge store; verify claims against codebase
4. **Product pressure test** — challenge the request to catch misframing (scaled to scope)
5. **Offer Visual Companion** — if topic involves visual questions (its own message, not combined)
6. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
7. **Propose 2-3 approaches** — with trade-offs; present all then recommend
8. **Present requirements** — grouped by theme, get user approval
9. **Write requirements doc** — save to `.sp-compound/brainstorms/YYYY-MM-DD-<topic>-requirements.md`
10. **Requirements self-review** — check for placeholders, contradictions, ambiguity, scope
11. **User reviews written requirements** — ask user to review before proceeding
12. **Transition to planning** — resolve blocking questions, then invoke sp-compound:plan skill

## Phase 0: Resume Detection

Before starting fresh, check for existing work:

```
Search: .sp-compound/brainstorms/*-requirements.md
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

## Phase 0.5: Classify and Route

### Task Domain

Classify whether this is a software task before proceeding:

- **Software** (continue to Scope Assessment below) -- references code, repos, APIs, databases, or asks to build/modify/debug/deploy software.
- **Non-software brainstorming** -- BOTH: no software signals present AND the user wants to explore/decide/think through something in a non-software domain. Facilitate conversationally using diverse angles (inversion, constraint removal, analogy), separate generation from evaluation, converge by reflecting priorities back, and synthesize a summary. Do not follow the software phases below.
- **Neither** -- quick-help request, error message, factual question, single-step task. Respond directly, skip all brainstorming phases.

### Scope Assessment

Classify work scope using the feature description and a light repo scan:

- **Lightweight** -- small, well-bounded, low ambiguity
- **Standard** -- normal feature or bounded refactor with some decisions to make
- **Deep** -- cross-cutting, strategic, or highly ambiguous

If the scope is unclear, ask one targeted question to disambiguate. Match ceremony to scope throughout: lightweight brainstorms stay compact, deep brainstorms explore fully.

### Clear Requirements Bypass

If the user already provides specific acceptance criteria, references existing patterns, describes exact expected behavior, or has a constrained well-defined scope -- skip Phases 1-2 entirely. Confirm understanding, then go straight to Phase 4 (present requirements) or Phase 6 (transition) if a requirements doc adds no value.

## Phase 1: Context Scan

Before asking questions, gather project context:

### 1.1 Project Constraints
- Read CLAUDE.md / AGENTS.md for project rules and constraints
- Note any workflow or scope constraints that affect the brainstorm

### 1.2 Existing Artifacts
- Search for prior brainstorms, plans, specs related to this topic
- Check recent git history for related work

### 1.3 Verify Before Claiming

When the brainstorm touches checkable infrastructure (database tables, routes, config files, dependencies, model definitions), read the relevant source files to confirm what actually exists. Any claim that something is absent -- a missing table, an endpoint that doesn't exist, a dependency not listed -- must be verified against the codebase first. If not verified, label it as an unverified assumption.

### 1.4 Lightweight Learnings Check

Search `.sp-compound/solutions/` frontmatter for related historical experience:

```
Grep .sp-compound/solutions/**/*.md for module/component/tags matching the topic
```

- Do NOT deep-read the documents (that's the plan skill's job)
- Do NOT launch a subagent for this — just frontmatter grep
- Purpose: inform the user about existing knowledge
  - "This area has N historical learnings including X-type and Y-type issues"
  - This affects scope assessment and risk evaluation
- If `.sp-compound/solutions/` doesn't exist, note it and move on

## Phase 1.5: Product Pressure Test

Before generating approaches, challenge the request to catch misframing. Match depth to scope:

**Lightweight:** Is this solving the real user problem? Are we duplicating something that already covers this?

**Standard:** Is this the right problem, or a proxy for a more important one? What user or business outcome actually matters? What happens if we do nothing? Is there a nearby framing that creates more value without more carrying cost?

**Deep:** Standard questions plus: What durable capability should this create in 6-12 months? Does this move the product toward that, or is it only a local patch?

Use the result to sharpen the conversation, not to override the user's intent.

## Phase 1.75: Visual Companion

If upcoming questions will involve visual content (mockups, layouts, diagrams, architecture), offer the companion once for consent:

> "Some of what we're working on might be easier to explain if I can show it to you in a web browser. I can put together mockups, diagrams, comparisons, and other visuals as we go. Want to try it? (Requires opening a local URL)"

**This offer MUST be its own message.** Do not combine it with clarifying questions or any other content. Wait for the user's response.

If they decline, proceed with text-only brainstorming. If the topic has no visual component, skip this phase entirely.

**Per-question decision (after acceptance):** Even after the user accepts, decide FOR EACH QUESTION whether to use the browser or terminal:
- **Use browser** for: mockups, wireframes, layout comparisons, architecture diagrams, side-by-side visual designs
- **Use terminal** for: requirements questions, conceptual choices, tradeoff lists, scope decisions

A question about a UI topic is not automatically a visual question. "What does personality mean in this context?" → terminal. "Which wizard layout works better?" → browser.

## Phase 2: Interactive Q&A

### Decomposition Check
- If the request describes multiple independent subsystems → flag immediately, help decompose
- If too large for a single spec → break into sub-projects, brainstorm first one

### Question Guidelines
- Ask what the user is already thinking before offering your own ideas -- surfaces hidden context and prevents fixation on AI-generated framings
- One question at a time — don't overwhelm
- Prefer multiple choice when possible
- Focus on: purpose, constraints, success criteria, user expectations
- Open-ended is fine when exploring unknowns

## Phase 3: Propose Approaches

- Propose 2-3 different approaches with trade-offs
- Use at least one non-obvious angle -- inversion (what if we did the opposite?), constraint removal (what if X weren't a limitation?), or analogy from another domain
- Present all approaches first, then state your recommendation -- leading with a recommendation before the user sees alternatives anchors the conversation prematurely
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
[If learnings were found in .sp-compound/solutions/, summarize relevance here]
```

**Key rules:**
- Stable requirement IDs (R1, R2, R3...) — planning will reference these
- Group by logical theme, not discussion order
- WHAT not HOW — no architecture, no technology choices, no implementation details
- Outstanding questions split explicitly into blocking vs deferred

Ask after each theme whether it looks right. Be ready to revise.

## Phase 5: Write & Review

### Write Document
Save to: `.sp-compound/brainstorms/YYYY-MM-DD-<topic>-requirements.md`

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

### Blocking Questions Gate

If `Resolve Before Planning` in the requirements document contains any items, do NOT proceed to planning. Instead:
- Ask the blocking questions now, one at a time
- If the user wants to proceed anyway, convert each remaining item into an explicit decision, assumption, or `Deferred to Planning` question first
- If the user wants to pause, present the brainstorm as paused/blocked

### Handoff Options

Present next steps:
- **Proceed to planning (Recommended)** -- invoke sp-compound:plan with the requirements doc path
- **Proceed directly to work** -- only when scope is lightweight, success criteria are clear, scope boundaries are clear, and no technical questions remain. Invoke sp-compound:work.
- **Ask more questions** -- return to Phase 2 Q&A
- **Done for now** -- return later

Do NOT invoke any skill other than sp-compound:plan or sp-compound:work.

### Closing Summary

When the workflow ends or hands off, display:

```
Brainstorm complete!
Requirements doc: <path>  (if created)
Key decisions:
- [Decision 1]
- [Decision 2]
Recommended next step: sp-compound:plan
```

If paused with blocking questions remaining:

```
Brainstorm paused.
Requirements doc: <path>  (if created)
Planning is blocked by:
- [Blocking question 1]
- [Blocking question 2]
Resume brainstorm to resolve these before planning.
```

## Key Principles

- **One question at a time** — don't overwhelm
- **Multiple choice preferred** — easier to answer when possible
- **YAGNI ruthlessly** — remove unnecessary requirements
- **Explore alternatives** — always propose 2-3 approaches
- **WHAT not HOW** — requirements, not design. Leave HOW for planning.
- **Incremental validation** — present requirements, get approval before writing
- **Resume over restart** — check for existing work before starting fresh
