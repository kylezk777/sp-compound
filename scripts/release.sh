#!/usr/bin/env bash
#
# scripts/release.sh — one-shot plugin release
#
# Usage:
#   scripts/release.sh           # patch bump (0.7.1 → 0.7.2)
#   scripts/release.sh minor     # 0.7.1 → 0.8.0
#   scripts/release.sh major     # 0.7.1 → 1.0.0
#
# Commits any dirty working tree, bumps version in both .claude-plugin
# JSONs, creates vX.Y.Z tag, pushes branch + tag to origin. Done.
#
set -euo pipefail

BUMP="${1:-patch}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$REPO_ROOT"

PLUGIN_JSON=".claude-plugin/plugin.json"
MARKETPLACE_JSON=".claude-plugin/marketplace.json"

# 1. Commit dirty tree (if any) with auto-generated message
if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  git add -A
  CHANGED=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
  MORE=$(git diff --cached --name-only | sed -n '6p')
  [[ -n "$MORE" ]] && CHANGED="${CHANGED}..."
  git commit -m "update: ${CHANGED}"
fi

# 2. Compute new version
CURRENT=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])")
NEW=$(python3 - "$CURRENT" "$BUMP" <<'PY'
import sys
current, bump = sys.argv[1], sys.argv[2]
major, minor, patch = map(int, current.split('.'))
if bump == 'patch': patch += 1
elif bump == 'minor': minor, patch = minor + 1, 0
elif bump == 'major': major, minor, patch = major + 1, 0, 0
else: sys.exit(f"unknown bump: {bump}")
print(f"{major}.{minor}.{patch}")
PY
)
TAG="v$NEW"

# 3. Bump both JSONs, commit, tag, push
NEW_V="$NEW" PLUGIN_JSON="$PLUGIN_JSON" MARKETPLACE_JSON="$MARKETPLACE_JSON" python3 - <<'PY'
import json, os
new = os.environ["NEW_V"]
for path in (os.environ["PLUGIN_JSON"], os.environ["MARKETPLACE_JSON"]):
    with open(path) as f: data = json.load(f)
    if "version" in data: data["version"] = new
    if "plugins" in data:
        for p in data["plugins"]:
            if "version" in p: p["version"] = new
    with open(path, "w") as f:
        json.dump(data, f, indent=2); f.write("\n")
PY

git add "$PLUGIN_JSON" "$MARKETPLACE_JSON"
git commit -m "Release $TAG"
git tag -a "$TAG" -m "$TAG"
git push origin HEAD
git push origin "$TAG"

echo "✓ Released $TAG"
