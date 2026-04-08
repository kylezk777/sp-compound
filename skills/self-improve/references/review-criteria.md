# Review Criteria

Criteria for evaluating gaps between sp-compound skills and their upstream sources.

## Severity Classification

### Must Fix (functional gaps)

- Missing functionality that the upstream skill has and that applies generically (not framework-specific)
- Missing categories, enum values, or schema entries that cause incorrect classification
- Missing guardrails that prevent common agent mistakes (anti-pattern tables, critical constraints)
- Missing fallback modes (e.g., compact-safe for context-constrained sessions)
- Missing protocol details that leave agent behavior underspecified for critical operations (e.g., subagent handoff, file write/delete decisions)

### Should Fix (quality gaps)

- Missing search strategies or efficiency guidance (thresholds, frontmatter-first patterns)
- Missing scope/invocation hints that downstream skills depend on
- Underspecified auto memory integration (missing tagging rules, fallback behavior)
- Missing interaction principles (how to ask questions, when to ask vs. decide)
- Missing commit/branching protocols for edge cases (dirty working tree)
- Missing core rules that prevent low-value churn or doc-code mismatch

### Skip (intentional differences)

- Framework-specific enums removed for generality (e.g., Rails component values)
- Plugin-specific agents that don't exist in sp-compound (e.g., performance-oracle)
- Auto-invoke trigger phrases (convention, not core)
- Output verbosity differences (conciseness is a deliberate sp-compound choice)
- Features unique to sp-compound with no upstream equivalent (e.g., autonomous mode)

## Comparison Dimensions

For each skill, compare across these dimensions:

1. **Phase/workflow completeness** — are all phases present? any phases missing?
2. **Subagent protocol** — are subagent instructions detailed enough? what to pass, what to return?
3. **Reference files** — are schemas, templates, mappings complete and consistent?
4. **Guardrails** — anti-pattern tables, critical constraints, common mistakes?
5. **Fallback paths** — compact modes, error handling, missing-tool graceful degradation?
6. **Integration points** — cross-skill invocation, scope hints, knowledge store consumption?
7. **User interaction** — question style, blocking tools, consent requirements?
8. **Commit/output** — branching protocols, report format, output templates?

## What NOT to Port

- Rails-specific or domain-specific enum values -> sp-compound is framework-agnostic
- References to ce-specific agents (kieran-rails-reviewer, etc.)
- `disable-model-invocation: true` — don't add to skills that should be auto-invocable. Appropriate only for maintenance-only skills (e.g., self-improve, compound-refresh)
- Verbose prose sections that are motivational rather than instructional
- Features sp-compound has intentionally improved upon (don't regress)
