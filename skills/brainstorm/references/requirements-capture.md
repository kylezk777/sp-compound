# Requirements Capture

This content is loaded when Phase 4 begins -- after the collaborative dialogue has produced durable decisions worth preserving.

---

This document should behave like a lightweight PRD without PRD ceremony. Include what planning needs to execute well, and skip sections that add no value for the scope.

The requirements document is for product definition and scope control. Do **not** include implementation details such as libraries, schemas, endpoints, file layouts, or code structure unless the brainstorm is inherently technical and those details are themselves the subject of the decision.

## Section matrix

| Section | Lightweight | Standard / Deep-feature | Deep-product |
|---|---|---|---|
| Problem Frame | Required | Required | Required |
| Actors (A-IDs) | Omit unless triggered | Triggered | Triggered |
| Key Flows (F-IDs) | Omit unless triggered | Triggered | Expected by default |
| Requirements (R-IDs) | Required | Required | Required |
| Acceptance Examples (AE-IDs) | Omit unless triggered | Triggered | Triggered |
| Success Criteria | Required | Required | Required |
| Scope Boundaries | Single list | Single list | Split: "Deferred for later" + "Outside this product's identity" |
| Key Decisions | When material | When material | When material |
| Dependencies / Assumptions | When material | When material | When material |
| Outstanding Questions | When material | When material | When material |
| Next Steps | Required | Required | Required |

**Triggered sections — when to include**
- **Actors** — multiple humans, agents, or systems are meaningfully involved, or decisions change by whose perspective is optimized for.
- **Key Flows** — work involves multi-step interaction or coordinates across existing flows.
- **Acceptance Examples** — a requirement's behavior is hard to pin down without a concrete scenario; each example back-references `Covers: R-IDs`.

**Document template** (omit clearly inapplicable optional sections):

```markdown
---
date: YYYY-MM-DD
topic: <kebab-case-topic>
---

# <Topic Title>

## Problem Frame
[Who is affected, what is changing, and why it matters]

## Actors
[Include when triggered. Stable A-IDs.]
- A1. [Name or role]: [What they do in this context]

## Key Flows
[Include when triggered. Each flow: trigger, actors, steps, outcome, Covered by.]
- F1. [Flow name]
  - **Trigger:** [What initiates the flow]
  - **Actors:** A1, A2
  - **Steps:** [3-7 steps]
  - **Outcome:** [What is true after the flow completes]
  - **Covered by:** R1, R2

## Requirements

**[Group Header]**
- R1. [Concrete requirement in this group]
- R2. [Concrete requirement in this group]

**[Group Header]**
- R3. [Concrete requirement in this group]

## Acceptance Examples
[Include when triggered. Each example is definitive for what it describes.]
- AE1. **Covers R1, R2.** Given [state], when [action], [outcome].

## Success Criteria
- [How we will know this solved the right problem — human outcome]
- [How a downstream agent can tell the handoff was clean]

## Scope Boundaries
[Lightweight / Standard / Deep-feature: single list.]
- [Deliberate non-goal or exclusion]

[Deep-product only: split into two subsections instead.]
### Deferred for later
- [Work that will be done eventually but not in v1]

### Outside this product's identity
- [Adjacent product we could build but are rejecting — positioning decision, not a deferral]

## Key Decisions
- [Decision]: [Rationale]

## Dependencies / Assumptions
- [Only include if material]

## Outstanding Questions

### Resolve Before Planning
- [Affects R1][User decision] [Question that must be answered before planning can proceed]

### Deferred to Planning
- [Affects R2][Technical] [Question that should be answered during planning or codebase exploration]
- [Affects R2][Needs research] [Question that likely requires research during planning]

## Historical Context
[If learnings were found in .sp-compound/solutions/, summarize relevance here]

## Next Steps
[If Resolve Before Planning is empty: -> sp-compound:plan for structured implementation planning]
[If Resolve Before Planning is not empty: -> Resume sp-compound:brainstorm to resolve blocking questions before planning]
```

**Visual communication** -- Include a visual aid when the requirements would be significantly easier to understand with one. Read `references/visual-communication.md` for the decision criteria, format selection, and placement rules.

**Scope-matched ceremony:**
- **Standard** and **Deep** brainstorms: a requirements document is usually warranted
- **Lightweight** brainstorms: keep the document compact. Skip document creation when the user only needs brief alignment and no durable decisions need to be preserved
- For very small requirements docs with only 1-3 simple requirements, plain bullet requirements are acceptable. For Standard and Deep, use stable IDs (R1, R2, R3) so planning and review can refer to them unambiguously

**ID format:** Use `R1.`, `A1.`, `F1.`, `AE1.` as a plain prefix at the start of the bullet -- do not bold the ID. R-IDs stay sequential across groups; numbering does not restart per group.

**Grouping rules:** When requirements span multiple distinct concerns, group them under bold topic headers within the Requirements section. Group by logical theme, not discussion order. Skip grouping only when all requirements are about the same thing.

**Size heuristics:**
- If a capability-named group has only one requirement, ungroup it
- If total requirements exceed ~15-20, stop and ask whether this is one brainstorm or several

**Outstanding question rules:**
- Use `Resolve Before Planning` only for questions that truly block planning
- If `Resolve Before Planning` is non-empty, keep working those questions during the brainstorm by default
- If the user explicitly wants to proceed anyway, convert each remaining item into an explicit decision, assumption, or `Deferred to Planning` question before proceeding
- Put technical questions, or questions that require validation or research, under `Deferred to Planning` when they are better answered there
- Use tags: `[Needs research]`, `[Technical]`, `[User decision]`, `[Affects RN]` (where N is the requirement ID)
- Carry deferred questions forward explicitly rather than treating them as a failure to finish the requirements doc

**Before finalizing, check:**
- What would `sp-compound:plan` still have to invent if this brainstorm ended now?
- Do any requirements depend on something claimed to be out of scope?
- Are any unresolved items actually product decisions rather than planning questions?
- Did implementation details leak in when they shouldn't have?
- Do any requirements claim that infrastructure is absent without that claim having been verified against the codebase? If so, verify now or label as an unverified assumption.
- Is there a low-cost change that would make this materially more useful?
- Would a visual aid (flow diagram, comparison table, relationship diagram) help a reader grasp the requirements faster than prose alone?

If planning would need to invent product behavior, scope boundaries, or success criteria, the brainstorm is not complete yet.

Ensure `.sp-compound/brainstorms/` directory exists before writing.
