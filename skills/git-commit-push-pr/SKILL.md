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

**Edge cases — Detached HEAD:**
Ask whether to create a feature branch. If yes, derive a name from the change content and `git checkout -b <branch-name>`. If no, stop.

**Edge cases — On default branch with changes:**
Ask whether to create a feature branch (don't push the default branch directly).

**Edge cases — Clean working tree:**
When git status shows no staged, modified, or untracked files, determine the next action:
1. Run `git rev-parse --abbrev-ref --symbolic-full-name @{u}` to check upstream.
2. If upstream exists, run `git log <upstream>..HEAD --oneline` for unpushed commits.

Decision tree:
- **On default branch, no unpushed commits, no open PR**: nothing to do. Stop.
- **On default branch with unpushed commits**: ask whether to create a feature branch first.
- **Feature branch, no upstream configured** (never pushed): skip commit, go to push.
- **Feature branch, unpushed commits exist**: skip commit, go to push.
- **Feature branch, all pushed, no open PR**: skip commit and push, go to PR description.
- **Feature branch, all pushed, open PR exists**: report up to date. Stop.

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

### Detect base branch and remote

Resolve the base branch and the remote that hosts it. In fork-based PRs, the base may correspond to a remote other than `origin` (commonly `upstream`).

Fallback chain (stop at first success):
1. **PR metadata** (if open PR exists): `gh pr view --json baseRefName,url`. Extract `baseRefName`. Match the PR URL's `owner/repo` against `git remote -v` to find the correct remote. Fall back to `origin` if no match.
2. **Remote default**: `git rev-parse --abbrev-ref origin/HEAD` — strip `origin/` prefix. Use `origin`.
3. **GitHub API**: `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'`. Use `origin`.
4. **Common names**: try main, master, develop, trunk via `git rev-parse --verify origin/<candidate>`.

If none resolve, ask the user to specify the target branch.

### Gather branch scope

Verify the remote-tracking ref exists and fetch if needed:
```bash
git rev-parse --verify <base-remote>/<base-branch> 2>/dev/null || git fetch --no-tags <base-remote> <base-branch>
```

Then gather the merge base, commit list, and full diff:
```bash
MERGE_BASE=$(git merge-base <base-remote>/<base-branch> HEAD) && echo "MERGE_BASE=$MERGE_BASE" && echo '=== COMMITS ===' && git log --oneline $MERGE_BASE..HEAD && echo '=== DIFF ===' && git diff $MERGE_BASE...HEAD
```

### Classify commits

- **Feature commits** — implement the PR's purpose. Drive the description.
- **Fix-up commits** — code review fixes, lint, style, typos. Invisible to reader.

Only feature commits inform the description.

### Frame the narrative before sizing

After classifying commits, articulate the PR's narrative frame:

1. **Before**: What was broken, limited, or impossible? (One sentence.)
2. **After**: What's now possible or improved? (One sentence.)
3. **Scope rationale** (only if the PR touches 2+ separable-looking concerns): Why do these ship together? (One sentence.)

This frame becomes the opening of the description. For small+simple PRs, the "after" sentence alone may be the entire description.

### Size the description

| Change Profile | Approach |
|----------------|----------|
| Small + simple (typo, config, dep bump) | 1-2 sentences, no headers. Under ~300 chars. |
| Small + non-trivial (bugfix, behavioral change) | Short "Problem / Fix" narrative, 3-5 sentences. |
| Medium feature or refactor | Summary paragraph + what changed and why. Call out design decisions. |
| Large or architecturally significant | Full narrative: problem context, approach, key decisions, migration/rollback notes. |
| Performance improvement | Include before/after measurements in a markdown table. |

### Writing Voice

If the user has documented style preferences (in CLAUDE.md, project instructions, or prior feedback), follow those. Otherwise:
- Active voice throughout. Vary sentence length deliberately.
- No filler phrases: "it's worth noting", "importantly", "essentially", "in order to", "leverage", "utilize".
- Use digits for numbers ("3 files"), not words ("three files").
- Plain English. Technical jargon is fine when it's the clearest term; avoid business jargon.
- Trust the reader. Do not make a claim and immediately explain it.

### Writing Principles

- **Lead with value**: first sentence = *why this PR exists*, not what files changed
- **Describe the net result, not the journey**: no intermediate failures, debugging steps, iteration history
- **When commits conflict, trust the final diff**
- **Explain the non-obvious**: spend space on things the diff doesn't show
- **No empty sections**: omit sections that don't apply
- **Test plan only when non-obvious**: edge cases the reviewer might miss, specific setup needed
- **No `#` prefix on list items**: GitHub auto-links `#1` as an issue reference
- **No orphaned opening paragraphs**: If the description uses `##` headings anywhere, the opening summary must also be under a heading (e.g., `## Summary`). A bare paragraph followed by titled sections looks like a missing heading.
- **No Commits section**: GitHub shows commits in its own tab. Omit unless commits need ordering/shipping annotations.
- **No Review / process section**: Do not describe how to review (checklists, process bullets). Call out non-obvious things to scrutinize inline with the change.
- **Visual aids**: include Mermaid diagrams or ASCII art only when structurally complex (3+ interacting components, multi-step workflows). Skip for trivial changes. Use `TB` direction for Mermaid so diagrams stay narrow. Prose is authoritative when diagram and text disagree.

### Compression Pass (before applying)

Re-read the composed body once and apply these cuts:

- If any section restates content already in `## Summary`, remove it.
- If "Testing" or "Test plan" has more than 2 paragraphs, compress to bullets.
- If the body has 5+ H3 subsections each describing one mechanism, consolidate into a single table. Reserve prose H3 callouts for 2-3 genuine design decisions.
- If the body exceeds the sizing row's target by more than 30%, compress the longest non-Summary section by half.
- Large PRs: target ~100 lines, cap ~150. Selectivity, not comprehensiveness.

**Value-lead check**: re-read the first sentence of `## Summary`. If it describes what was moved, renamed, or added ("This PR introduces..."), rewrite to lead with what's now possible or what was broken and is now fixed.

## Step 6: Create or Update PR

### New PR
```bash
gh pr create --title "the pr title" --body "$(cat <<'EOF'
PR description here
EOF
)"
```

### Existing PR
Report the PR URL, then ask whether to update the description. If yes, rewrite from scratch based on the full branch diff (not just new commits). Before applying, preview: "New title: `<title>` (`<N>` chars). Summary leads with: `<first two sentences>`. Total body: `<L>` lines. Apply?" — the first two sentences of the Summary carry most of the reviewer's attention. On decline, accept steering text and regenerate; do not apply.

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
