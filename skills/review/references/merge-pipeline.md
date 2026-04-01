# Review Merge Pipeline

The orchestrator runs this 7-step pipeline on combined reviewer outputs.

## Step 1: Validate Format

Drop findings missing required fields (severity, file, title). Record drop count for coverage report.

## Step 2: Confidence Gate

- Suppress findings with `confidence < 0.60`
- Exception: P0 findings survive at `confidence >= 0.50`
- Suppressed findings counted in coverage report

## Step 3: Deduplicate

Fingerprint each finding by: `normalized(file) + line_bucket(+/-3) + normalized(title)`

When duplicates found:
- Keep highest severity
- Keep highest confidence
- Merge evidence from all reviewers
- Record all contributing reviewers

## Step 3.5: Pre-Existing Detection

For each finding, check if the flagged code existed before this PR:

```bash
git blame -L <line>,<line> <file> -- <merge-base>
```

- If the blamed commit is BEFORE the merge-base → mark `pre_existing: true`
- If the blamed commit is AFTER the merge-base → `pre_existing: false` (default)

Pre-existing findings are:
- Separated from new findings in the report (own section)
- Excluded from merge-gate verdict (P0/P1 pre-existing don't block merge)
- Still reported for visibility
- NOT eligible for auto-fix (changing pre-existing code is out of scope)

## Step 5: Cross-Reviewer Boost

When 2+ independent reviewers flag the same issue (after dedup):
- Boost confidence by +0.10 (capped at 1.0)
- Record cross-reviewer agreement in evidence

## Step 6: Route Classification

Set final `autofix_class` for each finding:
- Disagreements between reviewers → use most conservative route
- `safe_auto` → only if ALL reviewers agree on safe_auto
- Upgrade path: safe_auto → gated_auto → manual (never downgrade)

## Step 7: Sort

Order findings by:
1. Severity (P0 first)
2. Confidence (descending)
3. File path (alphabetical)
4. Line number (ascending)

## Output

The pipeline produces:
- **Fixer queue:** safe_auto findings (applied automatically)
- **Gated queue:** gated_auto findings (user confirmation needed)
- **Report queue:** manual + advisory findings (reported only)
- **Pre-existing queue:** pre_existing findings (reported separately, excluded from verdict)
- **Coverage:** suppressed count, residual risks, testing gaps
