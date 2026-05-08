# Watch List

Upstream features with potential but not yet ready for adoption. Reviewed during Phase 0 and Phase 5 of each self-improve run.

## Format

```
### feature-name

**Source:** SP / CE
**What it does:** [brief description]
**Why watch:** [potential value for sp-compound]
**Blocker:** [why not adopting now]
**Added:** YYYY-MM-DD
**Re-evaluate by:** YYYY-MM-DD
```

## Entries

### ce-ideate

**Source:** CE
**What it does:** Generates ranked, grounded improvement ideas using parallel sub-agent ideation with different frames and adversarial filtering
**Why watch:** Fills "what should I work on" entry point gap — extends chain to ideate→brainstorm→plan→work
**Blocker:** Low demand signal; expensive sub-agent approach (3-4 parallel agents per invocation)
**Added:** 2026-04-12
**Re-evaluate by:** 2026-07-12

### git-commit (standalone)

**Source:** CE
**What it does:** Single well-crafted git commit with convention detection, logical splitting, main-branch protection
**Why watch:** Gap between "no commit" and "full commit+push+PR" — useful for incremental work commits
**Blocker:** Minor gap; git-commit-push-pr covers most use cases; users can use git commit directly
**Added:** 2026-04-12
**Re-evaluate by:** 2026-07-12

### lfg (autonomous pipeline)

**Source:** CE
**What it does:** Full autonomous pipeline — plan, work, review (autofix), todo-resolve, browser-test — in one command
**Why watch:** Compelling "run the full chain automatically" concept
**Blocker:** Depends on todo-resolve and test-browser which sp-compound lacks
**Added:** 2026-04-12
**Re-evaluate by:** 2026-07-12

### test-browser

**Source:** CE
**What it does:** End-to-end browser tests on pages affected by PR/branch changes using agent-browser CLI
**Why watch:** Strengthens verification step with real browser testing
**Blocker:** Depends on agent-browser CLI (external dependency not universally available)
**Added:** 2026-04-12
**Re-evaluate by:** 2026-07-12

### ce-sessions (session history search)

**Source:** CE
**What it does:** Search past Claude Code / Codex / Cursor session files for what was tried, how a problem was investigated, or what happened recently. Backed by two primitives (ce-session-inventory, ce-session-extract) that own JSONL layout knowledge.
**Why watch:** Adjacent to the knowledge flywheel — raw session history is a different axis from curated .sp-compound/solutions/ entries and could feed compound with un-captured context. Strong pre-plan research value.
**Blocker:** Infrastructure cost (three coupled skills plus scripts that know each platform's session-store layout); unclear demand signal; risk of overlap/confusion with curated solutions store (principle #4).
**Added:** 2026-04-22
**Re-evaluate by:** 2026-07-22

### ce-doc-review

**Source:** CE
**What it does:** Reviews requirements or plan documents via parallel persona sub-agents, auto-applies safe fixes, routes remaining findings through an interactive walk-through.
**Why watch:** Fills a pre-code review gap between plan output and work input — currently sp-compound has no explicit doc-quality gate on plan.md before dispatch.
**Blocker:** plan and review already carry strong validation logic; persona-agent dispatch is expensive; overlap with plan's self-check could muddy the chain contract (principle #2). Need demand signal before adopting.
**Added:** 2026-04-22
**Re-evaluate by:** 2026-07-22

### ce-optimize

**Source:** CE
**What it does:** Metric-driven iterative optimization loops — define a measurable goal, build measurement scaffolding, run parallel experiments, filter by hard gates and/or LLM-as-judge scores, converge toward the best solution.
**Why watch:** Genuinely novel capability (no sp-compound equivalent) that could strengthen work/review for measurable-outcome tasks (prompt tuning, search relevance, build perf, clustering).
**Blocker:** Large scope (~500+ lines, YAML spec schema, experiment runner); niche audience (ML/metrics-heavy work); no demand signal yet in sp-compound's general-purpose scope; tension with principle #1 (conciseness).
**Added:** 2026-05-08
**Re-evaluate by:** 2026-08-08

### ce-strategy

**Source:** CE
**What it does:** Creates and maintains STRATEGY.md — a durable, canonical product grounding document (target problem, approach, users, metrics, tracks) that ce-ideate/ce-brainstorm/ce-plan read as upstream context.
**Why watch:** Adds persistent product grounding upstream of the brainstorm→plan chain; could improve plan quality when a project lacks a canonical direction doc.
**Blocker:** Adoption coupled with ce-ideate (also Watch); expands "canonical doc" surface beyond .sp-compound/solutions/ and risks muddying the knowledge flywheel (principle #4); requires cascading edits to brainstorm and plan to consume STRATEGY.md.
**Added:** 2026-05-08
**Re-evaluate by:** 2026-08-08
