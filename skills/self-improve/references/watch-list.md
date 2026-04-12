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
