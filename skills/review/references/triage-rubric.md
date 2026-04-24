# Triage Rubric

This rubric governs how `triage-reviewer` evaluates each merged finding from the review pipeline. The rubric is consumed by:
- `agents/review/triage-reviewer.md` — the agent reads this to emit verdicts
- `skills/review/references/merge-pipeline.md` Step 5.5 — the pipeline reads this to validate verdicts before applying

## Verdicts

Exactly one of:

| Verdict | Effect | Minimum `confidence_in_verdict` |
|---------|--------|--------------------------------|
| `KEEP` (default) | Finding passes through unchanged | no threshold |
| `DOWNGRADE` | Severity lowered one level (P0→P1, P1→P2, P2→P3) | 0.70 |
| `DROP` | Finding removed from main report; full record preserved in artifact | 0.90 |

Any verdict with `confidence_in_verdict < 0.70` is invalidated by the pipeline and the finding reverts to `KEEP`.

## Rubric Dimensions (MUST address in every verdict)

For every finding, the agent produces `reach_evidence` and `impact_evidence` by reasoning through these six dimensions. The verdict_reason text should synthesize the findings across them.

### 1. Reachability
Is the flagged code path reachable under realistic runtime inputs? Cite evidence: caller path, middleware, config, feature flag. "A malicious internal caller constructs this state directly" is NOT reachable — internal callers have the same trust as the code under review.

### 2. Triggering Input
What concrete real-world input or state triggers the issue? If the only trigger is a theoretical adversary bypassing upstream layers, the finding is low-reach.

### 3. Blast Radius
What observable negative outcome follows triggering — user-visible error, data corruption, SLO violation, compliance breach, secret exposure? Findings with no observable outcome trend toward DROP.

### 4. Containment
Is the issue already mitigated by another layer: schema validation, ORM parameterization, reverse proxy, framework middleware (CSRF, CORS, auth), type system, or existing code guard? Containment requires a cited `file:line` or config reference — not an assumption.

### 5. Business Alignment
Does the finding align with the PR's stated intent, or is it tangential? An internal refactor PR that triggers "consider adding pagination to public API" is tangential and usually DROP or DOWNGRADE.

### 6. Linter-Catchable
Would a formatter or linter already catch this? If yes, the finding is low-value regardless of severity. Examples: naming conventions, import ordering, trailing whitespace, unused imports.

## Hard Red-Lines (DROP forbidden)

The following findings MUST NOT receive a `DROP` verdict. DOWNGRADE by one level is allowed if evidence warrants:

1. **P0 severity.** Any `severity: P0` finding is KEEP or DOWNGRADE-to-P1 only.
2. **Cross-reviewer consensus.** Any finding whose `evidence` field lists 2 or more reviewers. Disagreement already handled by Step 5; consensus is a strong signal.
3. **Security/correctness on sensitive paths.** Any finding from `security-reviewer` or `correctness-reviewer` at severity ≥ P1 where the code path touches:
   - Authentication / authorization / session handling
   - Payment / billing / financial data
   - Data mutation (write, update, delete) on persistent storage
   - External API calls (outbound or inbound)

## PR-Label Bypass

If the PR title, body, or any label contains any of the following substrings (case-insensitive), the entire triage step is SKIPPED: all findings flow through unchanged.

- `hotfix`
- `security`
- `cve`
- `p0`
- `p1-prod`

Coverage line records: `Triage: skipped (PR labeled <matched-term>).`

## Evidence Anchoring Rule

Every `verdict_reason` MUST anchor to at least one of:
- A specific `file:line` in the diff or repository
- A caller/upstream file path (`app/middleware/auth.py`)
- A config file reference (`pyproject.toml`, `Dockerfile`, `.github/workflows/ci.yml`)
- A direct quote from the PR title, body, or labels

Verdicts with abstract justifications only ("this is low risk", "unlikely in practice", "edge case") are INVALID. The pipeline MUST revert such findings to `KEEP`.

## Verdict Output Fields

Every verdict MUST include:

```json
{
  "finding_id": "<stable_identifier_or_file:line>",
  "verdict": "KEEP | DOWNGRADE | DROP",
  "verdict_reason": "Anchored reasoning (must cite file:line, middleware, config, or PR text)",
  "reach_evidence": "Why the path is/isn't reachable — cite caller or middleware",
  "impact_evidence": "What observable outcome triggering produces (or doesn't)",
  "confidence_in_verdict": 0.0
}
```

## Self-Audit Requirement

The agent MUST also emit a top-level `kept_with_justification` array listing findings where the agent considered downgrading or dropping but chose KEEP, with a one-sentence reason each. This exposes the agent's reasoning bias for human audit.

## Examples

### Example A: Clean DROP
Finding: "Variable name does not follow snake_case" on `lib/parser.py:42`. Rubric dimensions: Reachability present (normal code path); Triggering input exists; Blast radius: none — no runtime consequence; Containment: CI linter; Business alignment: tangential to PR; Linter-catchable: yes (flake8).
Verdict: DROP at confidence 0.92. Reason: "CI runs flake8 per `pyproject.toml:18` — this is linter-catchable style. No runtime impact."

### Example B: Red-line forced KEEP
Finding: P0 SQL-injection flagged by security-reviewer. Triager suspects ORM parameterization downstream but cannot cite the call site.
Verdict: KEEP. Reason: "P0 severity + security-reviewer on data-mutation path — hard red-line R15. ORM containment unverified."

### Example C: Valid DOWNGRADE
Finding: P1 N+1 query on admin dashboard. Triager finds admin-only middleware at `app/middleware/staff.py:12` and SLO data capping concurrent users at 20.
Verdict: DOWNGRADE (P1 → P2) at confidence 0.82. Reason: "Reach present but bounded — staff-only via `app/middleware/staff.py:12`, concurrent users ≤ 20 per Grafana. Blast radius reduced."
