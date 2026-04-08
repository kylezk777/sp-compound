#!/usr/bin/env bash
# Resolve the review base branch and compute the merge-base.
# Handles PR metadata, origin/HEAD, gh repo view, and common branch fallbacks.
#
# Usage: bash references/resolve-base.sh
# Output: BASE:<sha> on success, ERROR:<message> on failure.

set -euo pipefail

REVIEW_BASE_BRANCH=""
BASE_REF=""

# Step 1: Try PR metadata
if command -v gh >/dev/null 2>&1; then
  PR_META=$(gh pr view --json baseRefName 2>/dev/null || true)
  if [ -n "$PR_META" ]; then
    REVIEW_BASE_BRANCH=$(echo "$PR_META" | jq -r '.baseRefName // empty' 2>/dev/null || true)
  fi
fi

# Step 2: Fall back to origin/HEAD
if [ -z "$REVIEW_BASE_BRANCH" ]; then
  REVIEW_BASE_BRANCH=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)
fi

# Step 3: Fall back to gh repo view
if [ -z "$REVIEW_BASE_BRANCH" ] && command -v gh >/dev/null 2>&1; then
  REVIEW_BASE_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || true)
fi

# Step 4: Fall back to common branch names
if [ -z "$REVIEW_BASE_BRANCH" ]; then
  for candidate in main master develop trunk; do
    if git rev-parse --verify "origin/$candidate" >/dev/null 2>&1 || git rev-parse --verify "$candidate" >/dev/null 2>&1; then
      REVIEW_BASE_BRANCH="$candidate"
      break
    fi
  done
fi

# Resolve base ref
if [ -n "$REVIEW_BASE_BRANCH" ]; then
  if git remote get-url origin >/dev/null 2>&1; then
    git rev-parse --verify "origin/$REVIEW_BASE_BRANCH" >/dev/null 2>&1 || git fetch --no-tags origin "$REVIEW_BASE_BRANCH" 2>/dev/null || true
    BASE_REF=$(git rev-parse --verify "origin/$REVIEW_BASE_BRANCH" 2>/dev/null || true)
  fi
  if [ -z "$BASE_REF" ]; then
    BASE_REF=$(git rev-parse --verify "$REVIEW_BASE_BRANCH" 2>/dev/null || true)
  fi
fi

# Compute merge-base
if [ -n "$BASE_REF" ]; then
  BASE=$(git merge-base HEAD "$BASE_REF" 2>/dev/null) || BASE=""
  if [ -z "$BASE" ] && [ "$(git rev-parse --is-shallow-repository 2>/dev/null || echo false)" = "true" ]; then
    git fetch --no-tags --unshallow origin 2>/dev/null || true
    BASE=$(git merge-base HEAD "$BASE_REF" 2>/dev/null) || BASE=""
  fi
else
  BASE=""
fi

if [ -n "$BASE" ]; then
  echo "BASE:$BASE"
else
  echo "ERROR:Unable to resolve review base branch locally. Fetch the base branch and rerun, or provide a PR number so the review scope can be determined from PR metadata."
fi
