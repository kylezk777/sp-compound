#!/usr/bin/env bash
#
# scripts/release.sh — sp-compound plugin release helper
#
# Runs the full release flow for the sp-compound Claude plugin:
#   1. If working tree is dirty → commit all changes with a user-supplied
#      message (free-form, multi-line supported).
#   2. Bump the version in .claude-plugin/plugin.json AND
#      .claude-plugin/marketplace.json (kept in sync).
#   3. Commit the version bump with message `Release vX.Y.Z`.
#   4. Create annotated tag `vX.Y.Z`.
#   5. Push the branch + tag to origin so plugin consumers can update.
#
# USAGE
#   scripts/release.sh                                # interactive: prompts for bump + message
#   scripts/release.sh patch                          # 0.7.0 → 0.7.1
#   scripts/release.sh minor                          # 0.7.0 → 0.8.0
#   scripts/release.sh major                          # 0.7.0 → 1.0.0
#   scripts/release.sh set 1.2.3                      # explicit version
#   scripts/release.sh patch -m "fix: typo in brainstorm skill"
#   scripts/release.sh minor --no-push                # build locally; push manually later
#   scripts/release.sh minor --dry-run                # print the plan; do nothing
#
# OPTIONS
#   -m, --message "..."        commit message for the pre-bump commit (if dirty)
#   -t, --tag-message "..."    annotated tag message (default: tag name)
#   --no-push                  skip `git push` (local-only)
#   --allow-branch             allow releasing from a branch other than main
#   --dry-run                  print the plan without executing
#   -h, --help                 show this help
#
# SAFETY
#   - Refuses to run outside a git repo or with an inconsistent version
#     between plugin.json and marketplace.json.
#   - Refuses if the computed tag already exists.
#   - Refuses to run off main unless --allow-branch is passed.
#
set -euo pipefail

# ------------------------------------------------------------------
# Paths
# ------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"

export PLUGIN_JSON MARKETPLACE_JSON

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------
err() { printf 'release.sh: %s\n' "$*" >&2; }
die() { err "$*"; exit 1; }

usage() {
  sed -n '2,/^set -euo pipefail$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//; /^set -euo pipefail$/d'
  exit "${1:-0}"
}

parse_semver() {
  local v="$1"
  [[ "$v" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || die "invalid semver: $v (expected X.Y.Z)"
  printf '%s %s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
}

current_version() {
  python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])"
}

check_version_sync() {
  local plugin_v marketplace_v
  plugin_v=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")
  marketplace_v=$(python3 -c "import json; print(json.load(open('$MARKETPLACE_JSON'))['plugins'][0]['version'])")
  [[ "$plugin_v" == "$marketplace_v" ]] || die "version mismatch: plugin.json=$plugin_v marketplace.json=$marketplace_v — fix manually before releasing"
}

set_version() {
  NEW_V="$1" python3 - <<'PY'
import json, os
new = os.environ["NEW_V"]
for path in (os.environ["PLUGIN_JSON"], os.environ["MARKETPLACE_JSON"]):
    with open(path) as f:
        data = json.load(f)
    if "version" in data:
        data["version"] = new
    if "plugins" in data:
        for p in data["plugins"]:
            if "version" in p:
                p["version"] = new
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
PY
}

bump_version() {
  local current="$1" bump="$2"
  # shellcheck disable=SC2046
  read -r major minor patch <<< "$(parse_semver "$current")"
  case "$bump" in
    patch) patch=$((patch + 1)) ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    major) major=$((major + 1)); minor=0; patch=0 ;;
    *) die "unknown bump type: $bump (expected patch/minor/major)" ;;
  esac
  printf '%s.%s.%s\n' "$major" "$minor" "$patch"
}

working_tree_dirty() {
  # returns 0 (true) if tree has modifications, staged changes, or untracked files
  if ! git diff --quiet 2>/dev/null; then return 0; fi
  if ! git diff --cached --quiet 2>/dev/null; then return 0; fi
  if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then return 0; fi
  return 1
}

run_or_echo() {
  # print the command then run it unless DRY_RUN
  printf '  $ %s\n' "$*"
  if [[ "$DRY_RUN" != "true" ]]; then
    "$@"
  fi
}

# ------------------------------------------------------------------
# Parse args
# ------------------------------------------------------------------
BUMP=""
EXPLICIT_VERSION=""
COMMIT_MSG=""
TAG_MSG=""
NO_PUSH=false
DRY_RUN=false
ALLOW_BRANCH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    patch|minor|major)
      BUMP="$1"; shift ;;
    set)
      shift
      EXPLICIT_VERSION="${1:-}"
      [[ -n "$EXPLICIT_VERSION" ]] || die "'set' requires a version argument"
      shift ;;
    -m|--message)
      shift; COMMIT_MSG="${1:-}"; shift ;;
    -t|--tag-message)
      shift; TAG_MSG="${1:-}"; shift ;;
    --no-push) NO_PUSH=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --allow-branch) ALLOW_BRANCH=true; shift ;;
    -h|--help) usage ;;
    *) die "unknown arg: $1 (run with --help)" ;;
  esac
done

# ------------------------------------------------------------------
# Preflight
# ------------------------------------------------------------------
command -v python3 >/dev/null || die "python3 required"
command -v git >/dev/null || die "git required"

cd "$REPO_ROOT"
git rev-parse --git-dir >/dev/null 2>&1 || die "not a git repo"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" != "main" && "$ALLOW_BRANCH" != "true" ]]; then
  die "current branch is '$BRANCH', not main. Use --allow-branch to override."
fi

[[ -f "$PLUGIN_JSON" ]] || die "missing $PLUGIN_JSON"
[[ -f "$MARKETPLACE_JSON" ]] || die "missing $MARKETPLACE_JSON"
check_version_sync

CURRENT=$(current_version)

# ------------------------------------------------------------------
# Determine new version
# ------------------------------------------------------------------
if [[ -n "$EXPLICIT_VERSION" ]]; then
  parse_semver "$EXPLICIT_VERSION" >/dev/null
  NEW_VERSION="$EXPLICIT_VERSION"
elif [[ -n "$BUMP" ]]; then
  NEW_VERSION=$(bump_version "$CURRENT" "$BUMP")
else
  # interactive bump selection
  echo "Current version: $CURRENT"
  PATCH_PREVIEW=$(bump_version "$CURRENT" patch)
  MINOR_PREVIEW=$(bump_version "$CURRENT" minor)
  MAJOR_PREVIEW=$(bump_version "$CURRENT" major)
  PS3="Choose bump type: "
  select _ in "patch ($CURRENT → $PATCH_PREVIEW)" "minor ($CURRENT → $MINOR_PREVIEW)" "major ($CURRENT → $MAJOR_PREVIEW)" "cancel"; do
    case "$REPLY" in
      1) NEW_VERSION="$PATCH_PREVIEW"; break ;;
      2) NEW_VERSION="$MINOR_PREVIEW"; break ;;
      3) NEW_VERSION="$MAJOR_PREVIEW"; break ;;
      4) die "cancelled" ;;
      *) echo "invalid choice" ;;
    esac
  done
fi

NEW_TAG="v$NEW_VERSION"

if git rev-parse -q --verify "refs/tags/$NEW_TAG" >/dev/null; then
  die "tag $NEW_TAG already exists — pick a different version"
fi

# ------------------------------------------------------------------
# Plan summary
# ------------------------------------------------------------------
DIRTY=false
if working_tree_dirty; then DIRTY=true; fi

echo ""
echo "=== Release plan ==="
printf '  current version : %s\n' "$CURRENT"
printf '  new version     : %s\n' "$NEW_VERSION"
printf '  new tag         : %s\n' "$NEW_TAG"
printf '  branch          : %s\n' "$BRANCH"
printf '  working tree    : %s\n' "$([[ "$DIRTY" == "true" ]] && echo 'dirty (will commit before bump)' || echo 'clean')"
printf '  push            : %s\n' "$([[ "$NO_PUSH" == "true" ]] && echo 'NO (local only)' || echo 'yes (origin)')"
printf '  dry run         : %s\n' "$DRY_RUN"
echo ""

# ------------------------------------------------------------------
# Pre-bump commit (if dirty)
# ------------------------------------------------------------------
if [[ "$DIRTY" == "true" ]]; then
  if [[ -z "$COMMIT_MSG" ]]; then
    echo "Working tree is dirty. Enter commit message:"
    echo "(blank line ends multi-line input; Ctrl-C to cancel)"
    COMMIT_MSG=""
    first_line=true
    while IFS= read -r line; do
      if [[ -z "$line" ]]; then
        # blank line — end input only if we already have content
        $first_line && continue
        break
      fi
      first_line=false
      COMMIT_MSG+="${line}"$'\n'
    done
    [[ -n "$COMMIT_MSG" ]] || die "empty commit message"
    # strip trailing newline
    COMMIT_MSG="${COMMIT_MSG%$'\n'}"
  fi

  echo ""
  echo "--- Pre-bump commit ---"
  run_or_echo git add -A
  # commit via temp file so multi-line message survives verbatim
  MSG_FILE=$(mktemp /tmp/release-msg.XXXXXX)
  trap 'rm -f "$MSG_FILE"' EXIT
  printf '%s\n' "$COMMIT_MSG" > "$MSG_FILE"
  if [[ "$DRY_RUN" != "true" ]]; then
    git commit -F "$MSG_FILE"
  else
    printf '  $ git commit -F <msg-file>\n'
    printf '    ┌ message ┐\n'
    sed 's/^/    │ /' "$MSG_FILE"
    printf '    └─────────┘\n'
  fi
fi

# ------------------------------------------------------------------
# Bump version
# ------------------------------------------------------------------
echo ""
echo "--- Version bump ---"
printf '  $ set_version %s\n' "$NEW_VERSION"
if [[ "$DRY_RUN" != "true" ]]; then
  set_version "$NEW_VERSION"
fi

run_or_echo git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
BUMP_MSG="Release $NEW_TAG"
if [[ "$DRY_RUN" != "true" ]]; then
  git commit -m "$BUMP_MSG"
else
  printf '  $ git commit -m %q\n' "$BUMP_MSG"
fi

# ------------------------------------------------------------------
# Tag
# ------------------------------------------------------------------
echo ""
echo "--- Tag ---"
[[ -n "$TAG_MSG" ]] || TAG_MSG="$NEW_TAG"
if [[ "$DRY_RUN" != "true" ]]; then
  git tag -a "$NEW_TAG" -m "$TAG_MSG"
  printf '  $ git tag -a %s -m %q\n' "$NEW_TAG" "$TAG_MSG"
else
  printf '  $ git tag -a %s -m %q\n' "$NEW_TAG" "$TAG_MSG"
fi

# ------------------------------------------------------------------
# Push
# ------------------------------------------------------------------
echo ""
echo "--- Push ---"
if [[ "$NO_PUSH" == "true" ]]; then
  echo "  (skipped: --no-push)"
  echo ""
  echo "To publish later, run:"
  printf '  git push origin %s && git push origin %s\n' "$BRANCH" "$NEW_TAG"
else
  run_or_echo git push origin "$BRANCH"
  run_or_echo git push origin "$NEW_TAG"
fi

echo ""
echo "=== Done: $NEW_TAG ==="
