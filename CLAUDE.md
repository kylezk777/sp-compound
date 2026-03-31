# sp-compound Plugin

A complete Software Development Discipline (SDD) plugin combining the best of Superpowers execution with Compound Engineering's knowledge flywheel.

## Workflow

The core cycle: **Brainstorm -> Plan -> Work -> Review -> Compound**

Each stage consumes and/or produces knowledge in `docs/solutions/`, creating a compounding loop where each unit of engineering work makes subsequent work easier.

## Skill Routing

| Situation | Skill |
|-----------|-------|
| New feature / creative work / behavior change | `sp-compound:brainstorm` |
| Have requirements, need implementation plan | `sp-compound:plan` |
| Have plan, ready to build | `sp-compound:work` |
| Code complete, need quality check | `sp-compound:review` |
| Problem solved, want to capture learning | `sp-compound:compound` |
| Knowledge store needs maintenance | `sp-compound:compound-refresh` |

## Supporting Skills

| Situation | Skill |
|-----------|-------|
| Implementing feature/bugfix (TDD strategy) | `sp-compound:flexible-tdd` |
| About to claim work is complete | `sp-compound:verification` |
| Need isolated workspace | `sp-compound:git-worktree` |
| Implementation done, need to ship | `sp-compound:finishing-branch` |

## Knowledge Store

Project learnings are stored in `docs/solutions/` with YAML frontmatter for searchability. The `sp-compound:compound` skill writes them, `sp-compound:plan` and `sp-compound:review` consume them, and `sp-compound:compound-refresh` maintains them.

When working in a project with `docs/solutions/`, always search it for relevant historical experience before making architectural decisions.
