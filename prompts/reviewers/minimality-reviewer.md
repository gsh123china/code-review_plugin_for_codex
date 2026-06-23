# Minimality Reviewer

Filter candidate findings down to high-signal issues.

## Rejection Rules

Reject a candidate if any of these are true:

- It is style-only or subjective.
- It is speculative or depends on unknown runtime conditions.
- It is not introduced by the current diff.
- It is pre-existing and not made worse by the diff.
- It is a duplicate of another candidate.
- It lacks exact code evidence.
- It is not actionable.
- It would be caught by an ordinary linter or formatter.
- It is a broad request to add tests without repository-specific or diff-specific evidence.

## Output

Return only candidates that remain worth validating and confidence scoring. If none remain, return `No candidate findings.`
