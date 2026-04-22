---
name: finishing-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests -> Present options -> Execute choice -> Clean up.

**Announce at start:** "I'm using the finishing-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass using sp-compound:verification principles:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Show failures. Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Determine Base Branch

```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

If detection fails or is ambiguous, ask: "This branch split from main -- is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

### Step 4: Execute Choice

#### Option 1: Merge Locally
```bash
git checkout <base-branch>
git pull
git merge <feature-branch>
<test command>  # Verify tests on merged result
git branch -d <feature-branch>
```
Then: Cleanup worktree (Step 5)

#### Option 2: Push and Create PR
```bash
git push -u origin <feature-branch>
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```
Keep worktree for PR revisions.

#### Option 3: Keep As-Is
Report: "Keeping branch <name>. Worktree preserved at <path>."
**Don't cleanup worktree.**

#### Option 4: Discard
Confirm first — show what will be lost (branch name, commits, worktree path) and require typed "discard" confirmation. Then:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```
Then: Cleanup worktree (Step 5)

### Step 4.5: Auto-Capture Learning (Options 1 & 2 only)

Applies only when user chose Option 1 (Merge locally) or Option 2 (Push and create PR). Does not apply to Option 3 (Keep as-is) or Option 4 (Discard).

Run these sub-steps **before** the state-changing git operation of Step 4 (`git merge` for Option 1; `git push` / `gh pr create` for Option 2). For Option 1: run this block after the local test verification on the feature branch but before `git checkout <base-branch>`. For Option 2: run this block before `git push -u origin <feature-branch>`.

**Skip path (no auto-capture).** Several branches below may decide to skip auto-capture (kill switch matched, gate dropped, compound reported skipped, or commit failed). "Skip path" always means the same thing:

1. Execute **none** of the remaining 4.5.x sub-steps.
2. **Resume Step 4's chosen ship operation** (`git merge` / `git push` / `gh pr create`) as if 4.5 had never run.
3. Then proceed to Step 5.

Skipping auto-capture must NEVER abort the user's chosen ship action. Auto-capture is additive; its absence does not block shipping.

#### 4.5.1 Kill-switch check

Scan the current conversation history for any of these opt-out phrases the user may have said at any point in this session:

- "skip compound"
- "no compound for this session"
- "disable auto-capture"
- "don't compound this"
- Any semantically equivalent statement whose clear intent is to disable auto-capture for this session

If matched: emit no output and take the **Skip path** above — do not invoke auto-capture, but still complete the ship operation.

Explicit manual invocations of `sp-compound:compound` remain available to the user at any time regardless of this flag; the flag only suppresses Step 4.5.

#### 4.5.2 Notable-learning gate

Gather the following signals once:

```bash
BASE=$(git merge-base HEAD <base-branch>)
git diff --stat $BASE...HEAD
git log --oneline $BASE..HEAD
```

Also detect whether this branch came from a planned workflow:

- Check whether any file under `.sp-compound/plans/*.md` is referenced in commit messages or the branch name (match by kebab-case slug).
- Presence of a matching plan is a **strong positive signal**.

**Hard DROP filters (trivial — skip auto-capture):**

- Diff touches only `*.md` or `*.txt` documentation files AND no matching plan exists AND total diff < 10 lines.
- Diff is whitespace/formatting-only (e.g., output of `git diff --ignore-all-space $BASE...HEAD` is empty).
- All commits on the branch have type `chore:` / `style:` / `docs:` AND diff touches < 3 files AND no matching plan exists.
- Diff touches only lock files (`*.lock`, `package-lock.json`, `Cargo.lock`, `go.sum`, `poetry.lock`, etc.).
- Diff is a pure mechanical rename (all hunks are `rename from`/`rename to` with identity body).

**Strong KEEP signals (auto-capture proceeds):**

- A matching plan exists in `.sp-compound/plans/`.
- Commit messages include a root-cause description (phrases like "fix root cause", "resolves", "regression", "deadlock", "race", "leak") that correspond to real non-trivial diff hunks.
- Diff touches 3+ files across 2+ modules with behavioral code changes (non-test, non-doc files).

**Borderline (neither hard-drop nor strong-keep):** apply a single prose-judgment question to the orchestrator: *"From this session's conversation, can I articulate a non-obvious learning (root cause, design decision, reusable pattern, or verified constraint) that a future reader of `.sp-compound/solutions/` would benefit from?"* If yes → proceed; if no → take the **Skip path**.

The notable-learning gate logic lives entirely in this skill's prose; no sub-agent dispatch, no external classifier.

#### 4.5.3 Invoke compound Auto Mode

If kill switch did not fire and the notable-learning gate returned proceed:

Invoke `sp-compound:compound mode:auto` with the current session's problem-and-solution context. Capture its single-line output.

- On `✓ Captured: <path>` — retain `<path>` and `pre_state` (if returned) for the rollback window (the remainder of this skill's turn plus the next few user turns). Proceed to 4.5.4.
- On `✓ Auto-capture skipped: <reason>` — surface the line to the user as-is, then take the **Skip path** (no capture commit, but the ship operation still runs).

#### 4.5.4 Commit captured doc onto the feature branch

Stage and commit the captured file as its own commit on the feature branch, so it joins the ship result (the local merge for Option 1, or the PR for Option 2) in the same operation:

```bash
git add <path-returned-by-compound>
git commit -m "$(cat <<'EOF'
docs(solutions): auto-capture learning from <short-problem-slug>

Captured via sp-compound:finishing-branch auto-capture.
EOF
)"
```

Substitute `<short-problem-slug>` with a kebab-case hint derived from the captured doc's filename (the dated-slug segment), not from free-form invention.

If the commit fails (e.g., hook rejects), do NOT force through — report the failure to the user, then clean up based on whether this capture was a new file or an update:

- **New-file case** (compound did NOT return `pre_state`): the doc did not exist before this turn, so remove the staged + on-disk file:

  ```bash
  git rm --cached <path>
  rm <path>
  ```

- **Update case** (compound returned `pre_state`): an existing doc was overwritten in memory; restore it and unstage so the working tree matches HEAD again:

  ```bash
  # Restore pre-update contents (write the saved pre_state back to the file)
  printf '%s' "$pre_state" > <path>
  git restore --staged <path>
  ```

  Never use `git rm` in the update case — that would delete the existing doc and compound the failure into data loss.

After cleanup, take the **Skip path** — the ship operation must still run.

After the capture commit succeeds, print exactly one line to the user (reusing the line compound emitted):

```
✓ Captured: <path>
```

Then continue with Step 4's remaining state-changing operation:

- **Option 1:** now run `git checkout <base-branch>` → `git pull` → `git merge <feature-branch>` (the capture commit is included in the merge).
- **Option 2:** now run `git push -u origin <feature-branch>` → `gh pr create ...` (the capture commit is included in the PR).

#### 4.5.5 Rollback window

For the remainder of this skill's turn and the next user turn(s), if the user expresses regret about the capture (phrases such as "delete that doc", "revert that capture", "别写那个", "rollback the learning"):

- **If Option 2 and nothing has been pushed yet**: `git rm <path>` then `git commit --amend --no-edit` — replaces the capture commit with the rm; safe because no one has seen it.
- **If Option 1 and merge has not yet run**: same as above on the feature branch.
- **If the capture commit is already pushed or already merged**: create a NEW revert commit (`git revert <capture-commit-sha>`) — never force-push. For Option 1 (already merged locally), run the revert on the base branch and mention the user needs to push separately if they want it reflected upstream. For Option 2 with a pushed PR, the revert goes on the feature branch and joins the existing PR.
- **For update cases** (compound returned `pre_state`): instead of `git rm`, restore the file contents to `pre_state` and commit/revert with the same rules.

Report the rollback action in one line: `✓ Reverted: <path>` (plain restore) or `✓ Revert commit added: <short-sha>` (post-push/merge case).

### Step 5: Cleanup Worktree

For Options 1 and 4 — check if in worktree and remove:
```bash
git worktree list | grep $(git branch --show-current)
git worktree remove <worktree-path>
```

For Options 2 and 3: Keep worktree (may need it for PR revisions or later work).

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch | Auto-Capture |
|--------|-------|------|---------------|----------------|--------------|
| 1. Merge locally | Yes | - | - | Yes | Yes (if gate passes) |
| 2. Create PR | - | Yes | Yes | - | Yes (if gate passes) |
| 3. Keep as-is | - | - | Yes | - | No |
| 4. Discard | - | - | - | Yes (force) | No |

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request
- Run Step 4.5 auto-capture for Options 3 or 4
- Force-push to roll back a capture commit that is already pushed/merged (use `git revert` instead)

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only
- Include the capture commit in the same ship operation (merge for Option 1, push/PR for Option 2) — never as a post-ship dirty change

## Integration

**Called by:**
- **sp-compound:work** (Phase 4) — after review passes
- Any workflow completing a feature branch

**Pairs with:**
- **sp-compound:git-worktree** — cleans up worktree created by that skill
- **sp-compound:review** — should run before finishing
- **sp-compound:compound** — invoked via `mode:auto` from Step 4.5 when conditions are met
