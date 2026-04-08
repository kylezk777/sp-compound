# sp-compound Skill Provenance Map

Each sp-compound skill traces to one or more upstream skills in Superpowers (SP) and/or Compound Engineering (CE).

## Source Locations

Resolve relative to sp-compound's parent directory:
- **SP**: `../superpowers/skills/`
- **CE**: `../compound-engineering-plugin/plugins/compound-engineering/skills/`

## Mapping

| sp-compound Skill | Source Type | SP Skill(s) | CE Skill(s) |
|---|---|---|---|
| brainstorm | merged | brainstorming | ce-brainstorm |
| plan | merged | writing-plans | ce-plan |
| work | merged | subagent-driven-development, executing-plans, dispatching-parallel-agents | ce-work, ce-work-beta |
| review | merged | requesting-code-review | ce-review |
| git-worktree | merged | using-git-worktrees | git-worktree |
| compound | CE only | — | ce-compound |
| compound-refresh | CE only | — | ce-compound-refresh |
| debug | SP only | systematic-debugging | — |
| flexible-tdd | SP only | test-driven-development | — |
| verification | SP only | verification-before-completion | — |
| receiving-review | merged | receiving-code-review | resolve-pr-feedback |
| finishing-branch | SP only | finishing-a-development-branch | — |
| using-sp-compound | SP only | using-superpowers | — |
| git-commit-push-pr | CE only | — | git-commit-push-pr |
| reproduce-bug | CE only | — | reproduce-bug |
| writing-skills | SP only | writing-skills | — |

## Source Type Definitions

- **merged**: SP provides structure/format, CE adds knowledge layer or vice versa. Compare against BOTH sources.
- **CE only**: Full CE inheritance. Compare against CE source only.
- **SP only**: Full SP inheritance (possibly extended). Compare against SP source only.

## Reference Files

Reference/asset files are discovered dynamically during Phase 1. The agent should glob `references/` and `assets/` directories under both sp-compound and upstream skill directories to find all files to compare. No static mapping is maintained here — it drifts too easily.
