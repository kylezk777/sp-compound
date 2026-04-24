# Triage Reviewer Test Scenarios

These scenarios are synthetic reference cases for verifying the `triage-reviewer` agent, the merge pipeline's Step 5.5, and the rubric in `triage-rubric.md`. Each scenario shows the merged finding (what Stage 5 of the pipeline emits) and the expected triage verdict.

Scenarios are grouped by expected verdict. A correct implementation of the triager + pipeline + rubric will produce the listed verdicts under the given inputs.

## Scenario 1: DROP — linter-catchable style nit

**Merged finding (input to Step 5.5):**

```json
{
  "reviewer": "correctness-reviewer",
  "title": "Variable name does not follow snake_case",
  "severity": "P3",
  "file": "lib/parser.py",
  "line": 42,
  "confidence": 0.88,
  "autofix_class": "advisory",
  "owner": "human",
  "requires_verification": false,
  "pre_existing": false,
  "why_it_matters": "Project style uses snake_case for locals",
  "evidence": ["line 42: `def parse(inputData):`"]
}
```

**Expected verdict:** `DROP`
**Expected `confidence_in_verdict`:** ≥ 0.90
**Expected `verdict_reason` (example):** "Project ships ruff/flake8 in CI — this rename is caught by formatter tooling. No runtime consequence. (anchored to `pyproject.toml` ruff config)"

## Scenario 2: DROP — already contained by framework middleware

**Merged finding:**

```json
{
  "reviewer": "security-reviewer",
  "title": "Missing CSRF token check on POST handler",
  "severity": "P1",
  "file": "app/handlers/profile.py",
  "line": 88,
  "confidence": 0.80,
  "autofix_class": "gated_auto",
  "owner": "downstream-resolver",
  "requires_verification": true,
  "pre_existing": false,
  "why_it_matters": "CSRF vulnerabilities allow cross-site request forgery",
  "evidence": ["line 88 defines a POST handler without explicit CSRF verify"]
}
```

**Expected verdict:** `DROP` — BUT ONLY IF the rubric can cite concrete framework middleware evidence (e.g., `app/__init__.py` installs `CSRFProtect()` globally). If the evidence is unverifiable from diff+intent+file list alone, expected verdict is `KEEP` (evidence-anchoring safety rail R17).
**Hard red-line check:** Even with strong evidence, this finding is from `security-reviewer` at P1. R15 forbids DROP if the path is auth/payment/data-mutation/external-API. A POST handler for profile edits touches data mutation → DROP forbidden. Expected verdict adjusts to `DOWNGRADE` (P1 → P2) at most, or `KEEP`.

**This scenario exercises the intersection of containment evidence and the safety rail.**

## Scenario 3: DOWNGRADE — low-reachability edge case

**Merged finding:**

```json
{
  "reviewer": "performance-reviewer",
  "title": "N+1 query pattern in admin dashboard loop",
  "severity": "P1",
  "file": "app/admin/reports.py",
  "line": 220,
  "confidence": 0.85,
  "autofix_class": "manual",
  "owner": "downstream-resolver",
  "requires_verification": false,
  "pre_existing": false,
  "why_it_matters": "Can exceed DB timeout under load",
  "evidence": ["line 220 iterates users and queries orders inline"]
}
```

**Expected verdict:** `DOWNGRADE` (P1 → P2)
**Expected `confidence_in_verdict`:** ≥ 0.70
**Expected `verdict_reason`:** "Admin dashboard is gated behind staff-only auth middleware (`app/middleware/staff.py:12`); max concurrent users ≤ 20 per existing Grafana data. Real-world reach is present but blast radius is bounded."

## Scenario 4: KEEP — P0 with high triager confidence in "fake" label

**Merged finding:**

```json
{
  "reviewer": "security-reviewer",
  "title": "SQL injection via unescaped user input",
  "severity": "P0",
  "file": "app/api/search.py",
  "line": 55,
  "confidence": 0.92,
  "autofix_class": "gated_auto",
  "owner": "downstream-resolver",
  "requires_verification": true,
  "pre_existing": false,
  "why_it_matters": "Exploitable data exfiltration",
  "evidence": ["line 55 concatenates `user_q` into raw SQL"]
}
```

**Triager reasoning (hypothetical):** "The query uses SQLAlchemy ORM — input is parameterized further down."
**Expected verdict:** `KEEP` — hard red-line R15 (severity P0) forbids DROP regardless of triager confidence. Maximum allowed effect is DOWNGRADE to P1, and only if evidence is anchored (R17).

**This scenario exercises the P0 red-line.**

## Scenario 5: KEEP — cross-reviewer consensus protection

**Merged finding (2 reviewers):**

```json
{
  "reviewer": "correctness-reviewer, adversarial-reviewer",
  "title": "Off-by-one in pagination offset",
  "severity": "P2",
  "file": "app/api/list.py",
  "line": 110,
  "confidence": 0.90,
  "autofix_class": "safe_auto",
  "owner": "review-fixer",
  "requires_verification": false,
  "pre_existing": false,
  "why_it_matters": "First row of second page is skipped",
  "evidence": ["correctness: line 110 uses `offset = page * size`, should be `(page-1) * size`", "adversarial: same issue, confirms via call trace"]
}
```

**Expected verdict:** `KEEP` — 2+ reviewer consensus (R15) forbids DROP. DOWNGRADE is allowed only with explicit evidence; default is KEEP.

**This scenario exercises the cross-reviewer consensus red-line.**

## Scenario 6: KEEP — invalid verdict reverted (no code anchor)

**Merged finding:**

```json
{
  "reviewer": "testing-reviewer",
  "title": "Missing test for error branch",
  "severity": "P2",
  "file": "app/services/email.py",
  "line": 30,
  "confidence": 0.72,
  "autofix_class": "safe_auto",
  "owner": "review-fixer",
  "requires_verification": false,
  "pre_existing": false,
  "why_it_matters": "Error branch has no coverage",
  "evidence": ["no tests/test_email.py covers SMTP connection error"]
}
```

**Triager emits:** `DROP` with `verdict_reason: "low risk in practice"` and `confidence_in_verdict: 0.92`.
**Expected pipeline effect:** `KEEP` — verdict_reason is NOT anchored to a concrete `file:line`, middleware, config, or PR-text quote (R17). Pipeline invalidates the DROP and reverts to KEEP. Coverage line records this invalidation.

**This scenario exercises the evidence-anchoring safety rail.**

## Scenario 7: SKIP — PR labeled `hotfix`

**PR metadata:**

```
PR title: "hotfix: ship payment timeout fix"
PR labels: ["hotfix"]
```

**Merged findings:** 8 findings, severity mix.
**Expected pipeline effect:** Step 5.5 is skipped entirely per R16. No verdicts generated. Coverage line: `Triage: skipped (PR labeled hotfix).` All 8 findings flow to Step 7 unchanged.

**This scenario exercises PR-label bypass.**

## Scenario 8: Threshold not met

**Merged findings:** 4 findings.
**Expected pipeline effect:** Step 5.5 is a no-op (threshold is 5 per R9). Coverage line omits the triage entry. No artifact written.

**This scenario exercises the trigger threshold.**

## Scenario 9: Overflow warning

**Merged findings:** 12 findings. Triager DROPs 7 (58%).
**Expected pipeline effect:** Main report prepends `⚠  Triage dropped >50% of findings in this run. Inspect triage.json before trusting the verdict.` before the findings tables (R18).

**This scenario exercises the overflow warning.**

## Scenario 10: Fail-open on triager error

**Trigger:** Triager subagent returns malformed JSON (no `findings` key).
**Expected pipeline effect (R28):** Step 5.5 treated as no-op. All 12 findings pass through unchanged. Coverage line: `Triage: failed (reason: malformed-output). All findings shown unfiltered.` No artifact written. Review does NOT abort.

**This scenario exercises fail-open behavior.**

## Verification Checklist (for Task 6 green pass)

After all implementation tasks, walk each scenario against:
1. The rubric in `triage-rubric.md` — does it provide clear guidance for the expected verdict?
2. The agent persona in `agents/review/triage-reviewer.md` — would its prompt produce the expected verdict?
3. The pipeline Step 5.5 in `merge-pipeline.md` — do the red-lines and evidence-anchoring rules fire as specified?
4. The output template — do the Coverage line, DOWNGRADE annotation, and overflow warning render correctly?

If any scenario would produce an unexpected outcome, iterate on the responsible file (rubric, persona, pipeline, or template) and re-walk.
