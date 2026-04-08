---
name: git-commit-push-pr
description: "Commit, push, and open a PR with an adaptive, value-first description. Use when the user says 'commit and PR', 'push and open a PR', 'ship this', 'create a PR', or wants to go from working changes to an open pull request in one step. Also handles PR description updates."
---

# Git Commit, Push, and PR

Go from working tree changes to an open pull request in a single workflow. PR descriptions communicate *value and intent* proportional to the complexity of the change.

## Mode Detection

- **Full workflow** (default): commit -> push -> create/update PR
- **Description-only update**: user says "update the PR description" / "refresh the PR" -> skip to Description Update section

## Step 1: Gather Context

Collect in as few commands as possible:
```bash
git status
git diff HEAD
git branch --show-current
git log --oneline -10
git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || echo 'UNRESOLVED'
gh pr view --json url,title,state 2>/dev/null || echo 'NO_OPEN_PR'
```

**Edge cases:**
- Detached HEAD: ask whether to create a feature branch
- On default branch with changes: ask whether to create a feature branch (don't push directly)
- Clean working tree: check for unpushed commits or missing PR before stopping
- Unpushed commits exist: skip commit, go to push

## Step 2: Determine Conventions

Priority order for commit messages and PR titles:
1. Project instruction files (AGENTS.md, CLAUDE.md) if loaded
2. Recent commit history patterns
3. Fallback: conventional commits (`type(scope): description`)

## Step 3: Stage and Commit

1. If on default branch, create a descriptive feature branch first
2. Scan changed files for naturally distinct concerns — split into separate commits when obvious (file-level only, no `git add -p`). Two or three logical commits at most.
3. Stage specific files (never `git add -A`). Use heredoc for commit message:
   ```bash
   git add file1 file2 && git commit -m "$(cat <<'EOF'
   commit message here
   EOF
   )"
   ```

## Step 4: Push

```bash
git push -u origin HEAD
```

## Step 5: Write PR Description

### Detect base branch

Fallback chain (stop at first success):
1. PR metadata: `gh pr view --json baseRefName,url`
2. Remote default: `git rev-parse --abbrev-ref origin/HEAD`
3. GitHub API: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`
4. Common names: try main, master, develop, trunk

### Gather branch scope

```bash
MERGE_BASE=$(git merge-base <remote>/<base> HEAD) && git log --oneline $MERGE_BASE..HEAD && git diff $MERGE_BASE...HEAD
```

### Classify commits

- **Feature commits** — implement the PR's purpose. Drive the description.
- **Fix-up commits** — code review fixes, lint, style, typos. Invisible to reader.

Only feature commits inform the description.

### Size the description

| Change Profile | Approach |
|----------------|----------|
| Small + simple (typo, config, dep bump) | 1-2 sentences, no headers. Under ~300 chars. |
| Small + non-trivial (bugfix, behavioral change) | Short "Problem / Fix" narrative, 3-5 sentences. |
| Medium feature or refactor | Summary paragraph + what changed and why. Call out design decisions. |
| Large or architecturally significant | Full narrative: problem context, approach, key decisions, migration/rollback notes. |
| Performance improvement | Include before/after measurements in a markdown table. |

### Writing Principles

- **Lead with value**: first sentence = *why this PR exists*, not what files changed
- **Describe the net result, not the journey**: no intermediate failures, debugging steps, iteration history
- **When commits conflict, trust the final diff**
- **Explain the non-obvious**: spend space on things the diff doesn't show
- **No empty sections**: omit sections that don't apply
- **Test plan only when non-obvious**: edge cases the reviewer might miss, specific setup needed
- **No `#` prefix on list items**: GitHub auto-links `#1` as an issue reference
- **Visual aids**: include Mermaid diagrams or ASCII art only when structurally complex (3+ interacting components, multi-step workflows). Skip for trivial changes.

## Step 6: Create or Update PR

### New PR
```bash
gh pr create --title "the pr title" --body "$(cat <<'EOF'
PR description here
EOF
)"
```

### Existing PR
Report the PR URL, then ask whether to update the description. If yes, rewrite from scratch based on the full branch diff (not just new commits).

```bash
gh pr edit --body "$(cat <<'EOF'
Updated description here
EOF
)"
```

## Description Update Workflow

For "update/refresh the PR description" requests:

1. Confirm intent with user
2. Find open PR via `gh pr view`
3. Read current description, gather full branch scope, classify commits
4. Write new description following sizing + writing principles above
5. Summarize changes from old -> new description, get user confirmation
6. Apply with `gh pr edit --body`

## Integration

**Called by:**
- `sp-compound:finishing-branch` Option 2 (Push and Create PR)
- User directly ("ship this", "create a PR", "commit and PR")
