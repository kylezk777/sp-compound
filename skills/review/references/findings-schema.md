# Review Findings Schema

Every reviewer agent returns findings in this JSON format:

```json
{
  "reviewer": "reviewer-name",
  "findings": [
    {
      "severity": "P0|P1|P2|P3",
      "confidence": 0.0-1.0,
      "file": "path/to/file.ext",
      "line": 42,
      "title": "Short description (< 80 chars)",
      "detail": "Full explanation: what's wrong, why it matters, how to fix",
      "autofix_class": "safe_auto|gated_auto|manual|advisory",
      "owner": "review-fixer|downstream-resolver|human|release",
      "requires_verification": false,
      "suggested_fix": "Concrete minimal fix or null",
      "pre_existing": false
    }
  ],
  "residual_risks": ["Description of risk that remains even after fixing findings"],
  "testing_gaps": ["Description of missing test coverage"]
}
```

## Required Fields

**Top-level:** reviewer (string), findings (array), residual_risks (array), testing_gaps (array).

**Per-finding:** title, severity, file, line, confidence, autofix_class, owner, requires_verification, pre_existing.

**Optional per-finding:** suggested_fix (include when fix is obvious and correct; a bad suggestion is worse than none), detail (full explanation).

## Value Constraints

- severity: P0 | P1 | P2 | P3
- autofix_class: safe_auto | gated_auto | manual | advisory
- owner: review-fixer | downstream-resolver | human | release
- confidence: numeric, 0.0-1.0
- line: positive integer
- pre_existing, requires_verification: boolean

## Severity Scale

| Level | Meaning | Merge Gate |
|-------|---------|------------|
| **P0** | Critical: crashes, data loss, exploitable vulnerabilities | Must fix before merge |
| **P1** | High: incorrect behavior in normal usage | Should fix before merge |
| **P2** | Moderate: issues in uncommon scenarios | Fix if straightforward |
| **P3** | Low: minor improvements | User's discretion |

## Autofix Classification

| Class | Default Owner | Description |
|-------|---------------|-------------|
| **safe_auto** | review-fixer | Local, deterministic fix. Apply automatically. Examples: extract duplicated helper, add missing nil check, fix off-by-one, add missing test. |
| **gated_auto** | downstream-resolver or human | Concrete fix exists but changes behavior/contracts. Needs approval. Examples: add auth to unprotected endpoint, change API response shape. |
| **manual** | downstream-resolver or human | Actionable but requires design judgment. Examples: redesign data model, add pagination strategy. |
| **advisory** | human or release | Report-only. No action expected. Examples: design asymmetry, residual risk, deployment notes. |

## Owner Routing

| Owner | Meaning |
|-------|---------|
| **review-fixer** | In-skill fixer can own this when policy allows. |
| **downstream-resolver** | Turn into residual work for later resolution. |
| **human** | A person must make a judgment call. |
| **release** | Operational/rollout follow-up; not code-fix work. |

## Confidence Scale

- **0.85-1.00:** Certain -- verifiable from code alone
- **0.70-0.84:** High confidence -- real and important
- **0.60-0.69:** Moderate -- include only when clearly actionable
- **< 0.60:** Suppressed by merge pipeline (except P0 at 0.50+)
- **< 0.30:** Do not report -- likely false positive

## False-Positive Suppression

Actively suppress:
- Pre-existing issues unrelated to this diff
- Pedantic style nitpicks that a linter/formatter would catch
- Code that looks wrong but is intentional (check comments, PR description)
- Issues already handled elsewhere (callers, guards, middleware)
- Generic "consider adding" advice without a concrete failure mode
