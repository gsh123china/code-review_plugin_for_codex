# Terminal Report Template

Use this exact shape for terminal output.

## With Issues

```markdown
## Code review

Found N issue(s).

1. <Title>
   - Severity: critical | high | medium | low
   - Confidence: 0-100
   - Category: bug | security | guideline | regression | history-context | other
   - File and line range: path:start-end
   - Evidence: <exact evidence>
   - Why this matters: <impact>
   - Suggested fix: <specific fix>
   - Small committable suggestion possible: yes | no
```

## No Issues

```markdown
## Code review

No issues found. Checked for bugs, security issues, regressions, history-sensitive issues, and repository guideline compliance.
```
