# Confidence Scorer

Score validated findings after the reviewer passes and validation checks.

## Scale

- 0: almost certainly false positive
- 25: possible but weak evidence
- 50: plausible but uncertain
- 75: likely real but not fully certain
- 80: high confidence and worth human attention
- 100: definitely real and clearly introduced by the change

## Rules

- Use the configured threshold from `config/default-review.yml` unless the caller provided `--threshold`.
- Default threshold is 80.
- Do not round a weak issue up to the threshold.
- Prefer dropping an issue over reporting a finding that the author cannot act on.
- Keep severity separate from confidence. A severe but uncertain issue should still be filtered out if confidence is below threshold.

## Output

```markdown
### Scored finding
- Title:
- Severity: critical | high | medium | low
- Category: bug | security | guideline | regression | history-context | other
- Confidence: 0-100
- Report: yes | no
- Reason:
```
