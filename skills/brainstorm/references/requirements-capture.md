# Requirements Capture

This content is loaded when Phase 4 begins -- after the collaborative dialogue has produced durable decisions worth preserving.

---

This document should behave like a lightweight PRD without PRD ceremony. Include what planning needs to execute well, and skip sections that add no value for the scope.

The requirements document is for product definition and scope control. Do **not** include implementation details such as libraries, schemas, endpoints, file layouts, or code structure unless the brainstorm is inherently technical and those details are themselves the subject of the decision.

**Required content for non-trivial work:**
- Problem frame
- Concrete requirements or intended behavior with stable IDs
- Scope boundaries
- Success criteria

**Include when materially useful:**
- Key decisions and rationale
- Dependencies or assumptions
- Outstanding questions
- Alternatives considered
- High-level technical direction only when the work is inherently technical and the direction is part of the product/architecture decision

**Document template** (omit clearly inapplicable optional sections):

```markdown
---
date: YYYY-MM-DD
topic: <kebab-case-topic>
---

# <Topic Title>

## Problem Frame
[Who is affected, what is changing, and why it matters]

## Requirements

**[Group Header]**
- R1. [Concrete requirement in this group]
- R2. [Concrete requirement in this group]

**[Group Header]**
- R3. [Concrete requirement in this group]

## Success Criteria
- [How we will know this solved the right problem]

## Scope Boundaries
- [Deliberate non-goal or exclusion]

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

**Grouping rules:** When requirements span multiple distinct concerns, group them under bold topic headers within the Requirements section. Group by logical theme, not discussion order. Requirements keep their original stable IDs -- numbering does not restart per group. Skip grouping only when all requirements are about the same thing.

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
