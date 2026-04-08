# Review Merge Pipeline

The orchestrator runs this pipeline on combined reviewer outputs.

## Step 1: Validate Format

Check each return for required top-level and per-finding fields, plus value constraints. Drop malformed returns or findings. Record drop count.

- **Top-level required:** reviewer (string), findings (array), residual_risks (array), testing_gaps (array). Drop entire return if missing.
- **Per-finding required:** title, severity, file, line, confidence, autofix_class, owner, requires_verification, pre_existing
- **Value constraints:** severity (P0-P3), autofix_class (safe_auto/gated_auto/manual/advisory), owner (review-fixer/downstream-resolver/human/release), confidence (0.0-1.0), line (positive integer), booleans for pre_existing and requires_verification.

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

- If the blamed commit is BEFORE the merge-base -> mark `pre_existing: true`
- If the blamed commit is AFTER the merge-base -> `pre_existing: false` (default)

Pre-existing findings are:
- Separated from new findings in the report (own section)
- Excluded from merge-gate verdict (P0/P1 pre-existing don't block merge)
- Still reported for visibility
- NOT eligible for auto-fix (changing pre-existing code is out of scope)

## Step 4: Cross-Reviewer Boost

When 2+ independent reviewers flag the same issue (after dedup):
- Boost confidence by +0.10 (capped at 1.0)
- Record cross-reviewer agreement in evidence

## Step 5: Resolve Disagreements

When reviewers flag the same code region but disagree on severity, autofix_class, or owner:
- Keep the most conservative route
- Annotate the Reviewer column (e.g., "security (P0), correctness (P1) -- kept P0")
- May narrow safe_auto -> gated_auto -> manual, but never widen without evidence

## Step 6: Route Classification

Set final `autofix_class`, `owner`, and `requires_verification` for each finding:
- Only `safe_auto -> review-fixer` enters the fixer queue automatically
- `requires_verification: true` means fix is incomplete without tests or re-review

## Step 7: Partition

Build three queues:
- **Fixer queue:** `safe_auto -> review-fixer` (applied automatically)
- **Residual actionable:** `gated_auto` or `manual` -> `downstream-resolver` (handed off)
- **Report-only:** `advisory` + anything owned by `human` or `release`
- **Pre-existing:** `pre_existing: true` findings (reported separately, excluded from verdict)

## Step 8: Sort

Order findings by:
1. Severity (P0 first)
2. Confidence (descending)
3. File path (alphabetical)
4. Line number (ascending)

## Step 9: Collect Coverage

Union residual_risks and testing_gaps across all reviewers. Record suppressed count, failed/timed-out reviewers.
