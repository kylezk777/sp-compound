# sp-compound

A complete Software Development Discipline (SDD) plugin for Claude Code, built by merging the strengths of two proven plugins — **[Superpowers](https://github.com/anthropics/superpowers)** (SP) and **[Compound Engineering](https://github.com/anthropics/compound-engineering-plugin)** (CE) — into a unified system where **1 + 1 > 2**.

## Why sp-compound?

SP and CE each solve half the problem well:

| | Superpowers (SP) | Compound Engineering (CE) |
|--|---|---|
| **Strength** | Rigorous execution — TDD iron law, three-role subagent architecture, verification-before-completion | Knowledge compounding — .sp-compound/solutions/ flywheel, research-backed planning, multi-mode review |
| **Weakness** | No memory across projects; each task starts from zero | Execution discipline less structured; no spec/code-quality review split |

**sp-compound combines both:** SP's execution rigor ensures every task is built correctly, while CE's knowledge flywheel ensures every task makes the next one easier.

```
                    ┌─────────────────────────────────────────┐
                    │          Knowledge Flywheel              │
                    │                                         │
  ┌──────────┐  consume  ┌──────┐  consume  ┌──────┐         │
  │brainstorm│◄──────────│ plan │◄──────────│review│         │
  └────┬─────┘           └──┬───┘           └──┬───┘         │
       │                    │                  │              │
       │ requirements       │ plan             │ findings     │
       ▼                    ▼                  │              │
  ┌──────────┐        ┌──────────┐             │    produce   │
  │   plan   │───────►│   work   │─────────────┘  ┌────────┐ │
  └──────────┘        └──────────┘                 │compound│─┘
                      SP's 3-role                  └────────┘
                      subagent engine         CE's knowledge store
                                              .sp-compound/solutions/
```

## What You Get From Each Source

### From Superpowers

- **Three-role subagent architecture** — implementer + spec reviewer + code quality reviewer per task, with 4 status types (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED)
- **Flexible TDD** — test-first (default), characterization-first (legacy code), pragmatic (non-behavioral changes)
- **Verification before completion** — evidence before claims, always
- **Systematic debugging** — root cause investigation before fixing, with supporting techniques (root-cause tracing, defense-in-depth, condition-based waiting)
- **Receiving review** — technical evaluation of review feedback before implementing
- **Git worktree isolation** — parallel development without branch conflicts
- **Finishing branch** — structured merge/PR/cleanup options after implementation

### From Compound Engineering

- **Knowledge flywheel** — `compound` writes learnings to `.sp-compound/solutions/`, `plan` and `review` consume them via `learnings-researcher` agent
- **Research-backed planning** — 3 research agents (repo-research-analyst, learnings-researcher, best-practices-researcher) + conditional spec-flow-analyzer investigate before any code is written
- **Multi-reviewer code review** — 5 specialized reviewers (correctness, testing, security, performance, adversarial) with a 7-step merge pipeline including pre-existing issue detection
- **Compound-refresh** — 5 maintenance operations (Keep/Update/Consolidate/Replace/Delete) with 3 modes (interactive, autofix, autonomous)
- **Resume detection** — brainstorm and plan check for existing work before starting fresh
- **Discoverability checks** — ensure knowledge store is findable and searchable

### 1+1 > 2 (Synergies unique to sp-compound)

- **Research-informed TDD** — plan's research agents produce better code blocks, so flexible-tdd's test-first cycle starts from proven patterns instead of guessing
- **Review consumes learnings** — reviewers check against historically known pitfalls from `.sp-compound/solutions/`, catching issues that pure static analysis would miss
- **Debug feeds compound** — when systematic debugging solves a hard problem, compound captures the learning so the same class of bug is caught earlier next time
- **Spec-flow analysis** — conditional agent for complex state machines, dispatched after research consolidation to inform test scenarios and risk assessment

## Installation

### Claude Code

Register the marketplace, then install:

```bash
/plugin marketplace add kylezk777/sp-compound
/plugin install sp-compound
```

To update:

```bash
/plugin update sp-compound
```

### Cursor

In Cursor Agent chat:

```text
/add-plugin sp-compound
```

### Local Development

For development or customization, use `--plugin-dir` to load from a local checkout:

```bash
claude --plugin-dir /path/to/sp-compound
```

Or create a shell alias for convenience:

```bash
alias csp='claude --plugin-dir /path/to/sp-compound'
```

The plugin registers automatically via `.claude-plugin/plugin.json` and injects `using-sp-compound` at session start via the SessionStart hook.

## Core Workflow

The core cycle: **Brainstorm -> Plan -> Work -> Review -> Compound**

Each stage chains automatically to the next:

```
brainstorm ──► plan ──► work ──► review ──► finishing-branch
                                              │
                                              ▼
                                           compound (auto via finishing-branch
                                                     Step 4.5, or manual anytime)
```

| Stage | Skill | Purpose |
|-------|-------|---------|
| Brainstorm | `sp-compound:brainstorm` | Turn ideas into requirements through collaborative Q&A |
| Plan | `sp-compound:plan` | Research codebase + knowledge store, create implementation plan with complete code |
| Work | `sp-compound:work` | Execute plan using subagent architecture (4 strategies: inline / inline+TDD / serial / parallel) |
| Review | `sp-compound:review` | Multi-reviewer code review with 7-step merge pipeline |
| Compound | `sp-compound:compound` | Capture learnings in `.sp-compound/solutions/` |

## Supporting Skills

| Skill | When to Use |
|-------|-------------|
| `sp-compound:debug` | Bug, test failure, or unexpected behavior — investigate root cause before fixing |
| `sp-compound:receiving-review` | Received review feedback — evaluate technically before implementing |
| `sp-compound:flexible-tdd` | Implementing any feature or bugfix — choose the right TDD strategy |
| `sp-compound:verification` | About to claim work is complete — run verification, then report |
| `sp-compound:git-worktree` | Need isolated workspace for parallel development |
| `sp-compound:finishing-branch` | Implementation done — present merge/PR/cleanup options |
| `sp-compound:compound-refresh` | Knowledge store maintenance — review and update stale entries |

## Plugin Structure

```
sp-compound/
├── .claude-plugin/plugin.json       # Plugin registration
├── CLAUDE.md                        # Skill routing reference
├── hooks/
│   ├── hooks.json                   # SessionStart hook config
│   └── session-start                # Injects using-sp-compound at session start
├── skills/                          # 13 skills
│   ├── using-sp-compound/           # Session bootstrap + skill routing
│   ├── brainstorm/                  # Requirements discovery
│   ├── plan/                        # Research-backed implementation planning
│   ├── work/                        # Subagent-driven execution
│   ├── review/                      # Multi-reviewer code review
│   ├── compound/                    # Knowledge capture
│   ├── compound-refresh/            # Knowledge maintenance
│   ├── debug/                       # Systematic root-cause debugging
│   ├── receiving-review/            # Review feedback evaluation
│   ├── flexible-tdd/                # TDD strategy selection
│   ├── verification/                # Evidence-based completion checks
│   ├── git-worktree/                # Isolated workspace management
│   └── finishing-branch/            # Branch completion options
└── agents/                          # 9 agents
    ├── research/                    # 4 research agents
    │   ├── repo-research-analyst    # Codebase patterns + architecture
    │   ├── learnings-researcher     # .sp-compound/solutions/ knowledge lookup
    │   ├── best-practices-researcher # External guidance (conditional)
    │   └── spec-flow-analyzer       # State machine analysis (conditional)
    └── review/                      # 5 review agents
        ├── correctness-reviewer     # Logic + spec compliance (always-on)
        ├── testing-reviewer         # Test quality + coverage (always-on)
        ├── security-reviewer        # OWASP + auth + data (conditional)
        ├── performance-reviewer     # Complexity + resources (conditional)
        └── adversarial-reviewer     # Edge cases + failure modes (conditional)
```

## Knowledge Store

When a project uses sp-compound, learnings accumulate in `.sp-compound/solutions/` with YAML frontmatter:

```yaml
---
title: Redis Pool Exhaustion Under Burst Load
category: runtime-errors
severity: high
tags: [redis, connection-pool, burst-traffic]
date_created: 2026-03-15
---
```

These learnings are consumed by:
- **plan** — `learnings-researcher` finds relevant history, plan cites and follows proven patterns
- **review** — `learnings-researcher` checks against known pitfalls
- **brainstorm** — lightweight frontmatter grep for scope/risk assessment
- **compound-refresh** — maintains accuracy with 5 operations across 3 modes

## Design Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Standalone plugin (no SP runtime dependency) | Clean separation, independent upgrades, shareable |
| D2 | SP-style plans with complete code blocks | Subagent architecture expects this format; research layer improves quality without changing format |
| D3 | CE-style brainstorm (requirements, not design) | Clearer separation: brainstorm = WHAT, plan = HOW |
| D4 | Project-level `.sp-compound/solutions/` in git | Team knowledge compounds faster than individual memory |
| D5 | Full CE inheritance for compound/compound-refresh | CE's core differentiator; simplification loses material value |
| D6 | 5 core reviewers (from CE's 16+) | Covers ~80% of value; stack-specific reviewers excluded for tech-agnosticism |
| D7 | SP's three-role subagent architecture preserved | Work is SP's strongest phase; any modification risks regression |
| D8 | Knowledge flywheel: 4 stages consume, 2 produce | Structural guarantee that knowledge compounds with every cycle |

## License

MIT
