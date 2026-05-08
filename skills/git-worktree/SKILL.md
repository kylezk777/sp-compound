---
name: git-worktree
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - creates isolated git worktrees with smart directory selection and safety verification
---

# Using Git Worktrees

## Overview

Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching.

**Core principle:** Systematic directory selection + safety verification = reliable isolation.

**Announce at start:** "I'm using the git-worktree skill to set up an isolated workspace."

## Step 0: Detect Existing Isolation

Before creating anything, check if you are already in a worktree:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
git rev-parse --show-superproject-working-tree 2>/dev/null   # non-empty = submodule
```

**If `GIT_DIR != GIT_COMMON` AND submodule check is empty:** Already in a linked worktree. Skip creation. Jump to Creation Step 6 (setup) + Step 7 (baseline). Report existing path + branch state (note detached HEAD if applicable — branch creation needed at finish time).

**Otherwise:** Continue. Standard submodules have `GIT_DIR == GIT_COMMON` and look like normal repos; the `--show-superproject-working-tree` probe exists only to catch the rare case of a linked worktree created *inside* a submodule, so it is not misclassified as a top-level worktree.

## Prefer Native Worktree Tools

Before running `git worktree add`, check whether the harness exposes a native worktree tool (e.g., `EnterWorktree`, `WorktreeCreate`, a `/worktree` command, or a `--worktree` flag). If present, use it and skip directly to Creation Step 6 — native tools manage placement, branching, and cleanup that the harness tracks; manual `git worktree add` creates phantom state the harness cannot see. Only fall back to manual git when no native tool exists.

## Directory Selection Process

Follow this priority order:

### 1. Check Existing Directories

```bash
ls -d .worktrees 2>/dev/null     # Preferred (hidden)
ls -d worktrees 2>/dev/null      # Alternative
```

**If found:** Use that directory. If both exist, `.worktrees` wins.

### 2. Check CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

**If preference specified:** Use it without asking.

### 3. Ask User

If no directory exists and no CLAUDE.md preference:

```
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/worktrees/<project-name>/ (global location)

Which would you prefer?
```

## Safety Verification

### For Project-Local Directories

**MUST verify directory is ignored before creating worktree:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:** Add to .gitignore, commit, then proceed.

### For Global Directory

No .gitignore verification needed — outside project entirely.

## When to Create a Worktree

Create a worktree for: parallel feature work, PR review while keeping main checkout free, multi-branch experiments. **Do not** create a worktree for single-task work that can happen on a branch in the main checkout.

## Creation Steps

1. **Detect project name:** `project=$(basename "$(git rev-parse --show-toplevel)")`
2. **Resolve base branch:** Determine `from-branch` (default: origin's default branch, fallback to `main`). Fetch the latest: `git fetch origin <from-branch>`. Create the new branch from `origin/<from-branch>` so the worktree starts from a known base, not wherever HEAD happens to be.
3. **Create worktree:** `git worktree add "$path" -b "$BRANCH_NAME" "origin/<from-branch>"`. If this fails with a permission error (sandbox denial), report that sandbox blocked creation, work in place, and run Steps 6–7 in the main checkout.
4. **Copy environment files:** Copy `.env`, `.env.local`, `.env.test`, and similar dotenv files from the main repo to the worktree (skip `.env.example` — it's tracked). These are gitignored and won't exist in the new worktree without explicit copying.
5. **Trust dev tool configs:** If mise or direnv are installed and config files exist in the worktree, trust them so hooks and scripts work immediately. Only auto-trust configs unchanged from the base branch. Flag modified configs for manual review. For PR-review worktrees from untrusted sources, skip `direnv allow` regardless (`.envrc` can source unvalidated files).
6. **Run project setup:** Auto-detect from package.json/Cargo.toml/go.mod/requirements.txt/pyproject.toml
7. **Verify clean baseline:** Run tests. If fail: report + ask. If pass: report ready.
8. **Report location:** Full path, test count, ready status.

## Troubleshooting

| Error | Action |
|-------|--------|
| "Worktree already exists" | Switch to it (`cd <path>`) or remove (`git worktree remove <path>`) before recreating |
| "Cannot remove worktree: it is the current worktree" | `cd` out first, then `git worktree remove` |
| Permission error on `git worktree add` | Sandbox blocked creation — work in main checkout and report |

## Quick Reference

| Situation | Action |
|-----------|--------|
| Already in linked worktree | Skip creation (Step 0); run setup + baseline only |
| In a submodule | Treat as normal repo (submodule guard) |
| Native worktree tool available | Use it instead of `git worktree add` |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check CLAUDE.md -> Ask user |
| Directory not ignored | Add to .gitignore + commit |
| Tests fail during baseline | Report failures + ask |
| No package.json/Cargo.toml | Skip dependency install |
| mise/direnv config modified | Flag for manual review |

## Red Flags

**Never:**
- Create a worktree when Step 0 detects you're already in one
- Use `git worktree add` when a native worktree tool (e.g., `EnterWorktree`) is available
- Create worktree without verifying it's ignored (project-local)
- Skip baseline test verification
- Proceed with failing tests without asking
- Assume directory location when ambiguous
- Skip CLAUDE.md check for directory preference

**Always:**
- Run Step 0 detection before creating anything
- Prefer native worktree tools over manual git fallback
- Follow directory priority: existing > CLAUDE.md > ask
- Verify directory is ignored for project-local
- Auto-detect and run project setup
- Verify clean test baseline

## Integration

**Called by:**
- **sp-compound:work** — when user selects worktree execution strategy
- Any skill needing isolated workspace

**Pairs with:**
- **sp-compound:finishing-branch** — cleans up worktree after work complete
