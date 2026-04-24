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
- Record all contributing reviewers in the `reviewer` field as a comma-separated list (e.g., `correctness-reviewer, security-reviewer`). The `reviewer` field is the canonical source for cross-reviewer consensus detection downstream (Step 4 boost and Step 5.5 red-line #2).

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

## Step 5.5: Adversarial Triage

This step filters fake/low-value findings by dispatching the `triage-reviewer` agent (see `agents/review/triage-reviewer.md`) to emit verdicts per finding.

### Trigger

Run this step only when **both** conditions hold:
- The merged new-finding count (after Step 5, excluding pre-existing findings) is >= 5
- The run does not include the `mode:no-triage` argument

If either condition fails, this step is a no-op and findings flow to Step 6 unchanged.

### PR-Label Bypass

Before dispatching the agent, scan the PR title, body, and labels for any of these substrings (case-insensitive):
- `hotfix`
- `security`
- `cve`
- `p0`
- `p1-prod`

If any match, skip this step entirely. Record the skip in the Coverage line as `Triage: skipped (PR labeled <match>).`

### Dispatch

Dispatch `triage-reviewer` with:
- The merged new-finding list (excluding `pre_existing: true`)
- The diff (`git diff -U10 <base>..<head>`)
- Intent summary
- PR metadata (title, body, labels, URL) when available
- File list
- The rubric reference `skills/review/references/triage-rubric.md`

The triage-reviewer sub-agent uses the highest model tier available to the orchestrator (NOT the mid-tier default used by other reviewers). Counterfactual reasoning about reachability and containment is the core competency this step requires.

### Verdict Validation

For each verdict returned by the agent, validate in this order. Any validation failure reverts the verdict to `KEEP`:

1. **Confidence gate:** `confidence_in_verdict < 0.70` → revert to KEEP
2. **DROP confidence gate:** If `verdict == DROP` and `confidence_in_verdict < 0.90` → revert to KEEP
3. **Evidence anchor:** `verdict_reason` MUST contain at least one of: a `file:line` citation, a caller/middleware/config path, or a direct quote from PR text. If not → revert to KEEP.
   **3a. Non-tautological anchor (DROP only):** If `verdict == DROP`, the verdict_reason's cited file(s) MUST include at least one path different from the finding's own `file`. A DROP whose sole anchor is the finding's own `file` (optionally with any `:line` suffix) is tautological — it restates the target rather than evidencing containment. Revert such DROPs to KEEP. DOWNGRADE verdicts are not subject to this rule.
4. **Red-line enforcement:** If `verdict == DROP` and any of:
   - finding's `severity == P0`
   - finding's `reviewer` field names 2+ reviewers (comma-separated after Step 3 dedup)
   - finding is from `security-reviewer` or `correctness-reviewer` at P1+ AND the file path matches auth/payment/data-mutation/external-API heuristics. Match triggers on ANY of:
     - **Auth / session / identity:** path contains (case-insensitive) `auth`, `session`, `login`, `logout`, `signin`, `signup`, `token`, `jwt`, `oauth`, `saml`, `sso`, `credential`, `password`, `secret`, `admin`
     - **Authorization / access control:** `permission`, `role`, `acl`, `rbac`, `privilege`, `grant`, `policy`
     - **Crypto:** `crypto`, `cipher`, `encrypt`, `decrypt`, `hash`, `signature`, `verify`
     - **Payment / finance:** `pay`, `billing`, `checkout`, `payment`, `invoice`, `subscription`, `charge`, `refund`
     - **External API boundary:** `api/`, `webhook`, `callback`, `oauth/`, `/v1/`, `/v2/`, `endpoint`
     - **Data layer / mutation:** `models/`, `db/`, `repository/`, `repositories/`, `dao/`, `store/`, `storage/`, `migrations/`, `handlers/`, `controllers/`, `routes/`, `views/`, `middleware/`
     - **Mutation verb in diff:** diff contains any of `INSERT`, `UPDATE`, `DELETE`, `DROP TABLE`, `TRUNCATE`, `.save(`, `.create(`, `.update(`, `.destroy(`, `.delete(`, `.bulk_create(`, `.bulk_update(`, `.execute(`, `.raw(`, or equivalent idioms for the project's ORM/DB layer
   → revert to `DOWNGRADE` (one-level lowering) instead of DROP.

If the diff touches paths or idioms you cannot confidently classify against this list, the red-line is presumed to fire and DROP is reverted to DOWNGRADE. Over-protection is preferred over under-protection at this gate.

### Apply Verdicts

- `KEEP`: finding unchanged.
- `DOWNGRADE`: reduce `severity` by one level (P0→P1, P1→P2, P2→P3). Set `original_severity` to the pre-downgrade value. Annotate in Reviewer column: `<reviewer> (<orig>→<new>, triage)`. **P3 floor:** DOWNGRADE on a P3 finding is treated as KEEP and recorded as invalidated in the artifact.
- `DROP`: remove finding from the main pipeline output. Preserve the full record in the artifact (see below). **Mode restriction:** DROP is DISABLED in `report-only` mode (the artifact is suppressed in report-only, so a DROP would make the finding irrecoverable). In report-only, any DROP verdict is downgraded to DOWNGRADE, and findings that would have been dropped are kept in the main output at their new severity. Record in the Coverage line: `Triage: DROPs disabled in report-only mode — K would-be drops converted to downgrades.`

Every finding (kept, downgraded, or dropped) gets these pipeline-added fields stored in the artifact:
- `triage_verdict`, `triage_verdict_reason`, `triage_confidence`, `original_severity` (when applicable)

### Overflow Warning

Compute `dropped_count / total_new_findings`. If the ratio exceeds 0.5, set a run-level flag `triage_overflow_warning: true`. The report renderer MUST prepend this warning line before the findings tables in all modes:

```
⚠  Triage dropped >50% of findings in this run. Inspect triage.json before trusting the verdict.
```

### Artifact

Write triage detail to `.sp-compound/review-runs/<run-id>/triage.json` in `interactive`, `autofix`, and `headless` modes. Do NOT write in `report-only` mode (consistent with report-only's "no artifacts" contract).

The artifact contains, for each finding the triager examined:
- Original finding payload (verbatim)
- All triager fields: `verdict`, `verdict_reason`, `reach_evidence`, `impact_evidence`, `confidence_in_verdict`
- Validation outcome: whether the verdict was applied or reverted (and why)
- `original_severity` when DOWNGRADE applied
- Reviewer source list (for cross-reviewer consensus audit)

Also include the triager's top-level `kept_with_justification` array.

### Fail-Open

If the triage-reviewer subagent fails, times out, or returns malformed output (missing `verdicts` or `reviewer` keys), treat Step 5.5 as a no-op:
- All findings pass through unchanged at their original severity.
- Do NOT write the artifact.
- Record failure in the Coverage line: `Triage: failed (reason: <agent-error|timeout|malformed-output>). All findings shown unfiltered.`
- The review does NOT abort.

If the triager returns some valid verdicts and some malformed ones (individual verdict missing fields or failing validation), apply the valid verdicts and revert the malformed ones to KEEP. Coverage line notes: `Triage: applied N verdicts, M invalidated (missing evidence or low confidence).`

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
