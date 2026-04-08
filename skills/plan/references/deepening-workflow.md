# Plan Deepening Workflow

Load this file only when the deepening gate determines that deepening is warranted (Standard/Deep plans, or Lightweight plans touching high-risk areas).

## Confidence Scoring

For each plan section, score using:
- **Trigger count** — number of checklist problems that apply (see below)
- **Risk bonus** — +1 if the topic is high-risk and section is materially relevant
- **Critical-section bonus** — +1 for Key Technical Decisions, Implementation Units, System-Wide Impact, Risks & Dependencies, Open Questions

A section is a deepening candidate if it scores **2+ total** (or **1+** in a high-risk domain with material importance).

Select **top 2-5 sections** by score. For Lightweight plans (high-risk exception), cap at 1-2.

## Section Checklists

**Requirements Trace**
- Requirements vague or disconnected from implementation units
- Success criteria missing or not reflected downstream
- Origin requirements not clearly carried forward

**Context & Research**
- Relevant patterns named but never used in decisions
- Cited learnings don't materially shape the plan
- High-risk work lacks appropriate grounding
- Research is generic, not tied to this repo

**Key Technical Decisions**
- Decision stated without rationale
- No tradeoffs or rejected alternatives discussed
- Obvious design fork exists but never addressed

**Open Questions**
- Product blockers hidden as assumptions
- Planning-owned questions deferred to implementation
- Deferred items too vague to be useful later

**Implementation Units**
- Dependency order unclear
- File paths or test paths missing
- Units too large, too vague, or micro-stepped
- Test scenarios vague, skip applicable categories, or missing for feature-bearing units
- Verification outcomes not expressed as observable results

**System-Wide Impact**
- Affected interfaces, callbacks, entry points missing
- Failure propagation underexplored
- State lifecycle, caching, data integrity risks absent where relevant

**Risks & Dependencies**
- Risks listed without mitigation
- Rollout, monitoring, migration implications missing when warranted
- External dependency assumptions weak or unstated
- Security, performance, or data risks absent where obvious

## Dispatch Targeted Research

For each selected section:
1. Announce what's being strengthened and why
2. Choose the smallest useful agent set (1-3 per section, max ~8 total)
3. Map sections to research types:

| Section Gap | Research Focus |
|-------------|---------------|
| Requirements / Open Questions | Flow analysis, edge cases, user journey gaps |
| Context & Research | Historical learnings, framework docs, best practices |
| Key Technical Decisions | Architecture review, design tradeoffs, external validation |
| Implementation Units | Repo patterns, file targets, sequencing clues |
| System-Wide Impact | Cross-boundary effects, performance, security, data integrity |
| Risks & Dependencies | Security, migration, deployment, capacity concerns |

4. Each agent receives: plan summary, exact section text, why it was selected, specific question to answer
5. Each agent returns: findings that improve planning quality, stronger rationale/verification/references. No implementation code.

## Synthesize and Strengthen

After research returns:
1. Integrate findings into the plan's weak sections
2. Strengthen rationale, add references, improve test scenarios, fill gaps
3. Do NOT rewrite sections that scored well — only strengthen the weak ones
4. Add `deepened: YYYY-MM-DD` to plan YAML frontmatter
5. Briefly report what was strengthened and the key improvements
