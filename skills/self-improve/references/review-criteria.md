# Review Criteria

Two-dimensional evaluation framework for differences between sp-compound and upstream skills.

## Dimension 1: Decision

Every difference must receive exactly one decision.

### Adopt

Port the upstream implementation into sp-compound, preserving sp-compound's concise style.

Criteria — ALL must be true:
- The functionality is genuinely missing from sp-compound (not solved differently)
- It aligns with design principles (especially #1 Conciseness, #3 Framework Agnostic)
- Impact assessment shows no unacceptable cascade effects
- It does not regress any sp-compound unique improvement

### Adapt

The upstream idea solves a real problem, but its implementation doesn't fit sp-compound. Reimplement using sp-compound's style and architecture.

Criteria — ALL must be true:
- The underlying problem is real and affects sp-compound users
- The upstream implementation conflicts with design principles or existing architecture
- A sp-compound-native solution can be designed with smaller scope or better fit

### Reject

Explicitly decline to adopt. The difference is understood and intentionally preserved.

Criteria — ANY is sufficient:
- sp-compound already solves the same problem with a different (equal or better) approach
- The functionality conflicts with design principles
- Impact assessment shows cascade effects that outweigh benefits
- The cost of adoption significantly exceeds the benefit

All Reject decisions MUST be recorded in `references/rejection-log.md` with reasoning so future runs do not re-evaluate the same item.

### Skip

Not applicable to sp-compound. No evaluation needed.

Criteria — ANY is sufficient:
- Framework-specific content (Rails, React, Go-specific enums or examples)
- Plugin-specific agents or infrastructure that sp-compound doesn't have
- Pure prose/verbosity differences (conciseness is deliberate)
- Cosmetic differences (section ordering, naming conventions)

## Dimension 2: Priority

Applies only to Adopt and Adapt decisions.

| Priority | Criteria |
|----------|----------|
| **P0** | Missing this causes agent to produce incorrect behavior, skip critical steps, or generate invalid output |
| **P1** | Adopting this measurably improves agent decision quality, user experience, or workflow reliability |
| **P2** | Nice-to-have improvement; no visible degradation without it |

## Cost-Benefit Evaluation Template

Every Adopt/Adapt/Reject decision requires this analysis. Skip decisions do not.

```
### Difference: [name]

**Benefit**
- Problem solved: [what]
- Who benefits: [which user scenarios]
- Without it: [consequence — agent error / degraded quality / nothing noticeable]

**Cost**
- Implementation complexity: Low / Medium / High
- Conciseness impact: Low / Medium / High
- Maintenance burden: [one-time port / ongoing sync needed]

**Equivalence Check**
- sp-compound has alternative approach: Yes / No
- If Yes, which is better and why: [assessment]

**Decision:** Adopt / Adapt / Reject / Skip
**Priority:** P0 / P1 / P2 (if Adopt/Adapt)
**Reasoning:** [one sentence]
```

## Impact Assessment

Required for all Adopt and Adapt decisions before implementation. Reject/Skip do not need this.

```
### Impact Check: [change description]

**Workflow chain:**
- [ ] Does this change any skill's output format or protocol?
- [ ] If yes, which downstream skills consume it? [list]

**Shared references:**
- [ ] Does this modify files used by multiple skills? [list files and skills]

**Knowledge store:**
- [ ] Does this affect .sp-compound/solutions/ schema or frontmatter? [details]

**Cross-skill consistency:**
- [ ] Do subagent prompts need updating? [list]

**Cascade verdict:**
- [ ] No cascade — safe to implement
- [ ] Cascade contained — [N] additional files need sync, listed above
- [ ] Cascade too broad — reconsider decision (Adopt -> Adapt, or Adapt -> Reject)
```

When cascade is too broad: first attempt to Adapt with a smaller-scope implementation. If Adapt is also not feasible, Reject with documented reasoning.

## Comparison Dimensions

For each skill, compare across:

1. **Phase/workflow completeness** — all phases present? any missing?
2. **Subagent protocol** — instructions detailed enough? what to pass, what to return?
3. **Reference files** — schemas, templates, mappings complete and consistent?
4. **Guardrails** — anti-pattern tables, critical constraints, common mistakes?
5. **Fallback paths** — compact modes, error handling, graceful degradation?
6. **Integration points** — cross-skill invocation, scope hints, knowledge store consumption?
7. **User interaction** — question style, blocking tools, consent requirements?
8. **Commit/output** — branching protocols, report format, output templates?

## What NOT to Port

- Framework-specific enum values or examples (principle #3)
- References to agents that don't exist in sp-compound
- Verbose prose that restates what preceding instructions already convey (principle #1)
- Features sp-compound has intentionally improved upon (principle #7)
- `disable-model-invocation: true` on skills that should be auto-invocable
