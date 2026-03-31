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
      "pre_existing": false
    }
  ],
  "residual_risks": ["Description of risk that remains even after fixing findings"],
  "testing_gaps": ["Description of missing test coverage"]
}
```

## Severity Scale

| Level | Meaning | Merge Gate |
|-------|---------|------------|
| **P0** | Critical: crashes, data loss, exploitable vulnerabilities | Must fix before merge |
| **P1** | High: incorrect behavior in normal usage | Should fix before merge |
| **P2** | Moderate: issues in uncommon scenarios | Fix if straightforward |
| **P3** | Low: minor improvements | User's discretion |

## Autofix Classification

| Class | Owner | Description |
|-------|-------|-------------|
| **safe_auto** | review-fixer | Deterministic, local fix. Apply automatically. |
| **gated_auto** | user | Concrete fix exists but changes behavior. Needs confirmation. |
| **manual** | user | Actionable but requires human judgment. |
| **advisory** | user | Report-only. No action expected. |

## Confidence Scale

- **1.0:** Certain — verified by reading code
- **0.8-0.9:** High confidence — clear evidence
- **0.6-0.7:** Moderate — likely issue but some ambiguity
- **< 0.6:** Suppressed by merge pipeline (except P0 at 0.50+)
