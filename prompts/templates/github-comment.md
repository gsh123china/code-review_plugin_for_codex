# GitHub Comment Template

GitHub summary comments should start with the marker below so future runs can avoid duplicates.

```markdown
<!-- codex-code-review-plugin -->
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

Do not post a no-issue comment unless the user explicitly asks for one.
