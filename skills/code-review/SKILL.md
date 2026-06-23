---
name: code-review
description: Review the current git diff, a branch diff, or a GitHub pull request with a generic high-signal Codex workflow. Use when the user asks for code review, PR review, regression review, security review, guideline review, or GitHub-ready review comments.
---

# Codex Code Review

Use this skill to review only the current change. The review must focus on actionable issues that are introduced by the diff and supported by exact code evidence.

## Preferred Workflow

1. Run the repository script to collect context and print the complete review prompt:

```bash
scripts/codex-review
```

Common variants:

```bash
scripts/codex-review --diff
scripts/codex-review --base main
scripts/codex-review --pr 123
scripts/codex-review --pr 123 --comment
scripts/codex-review --threshold 90
```

2. Follow the generated prompt exactly. It contains the changed files, diff, repository instruction files, PR metadata when available, and the configured confidence threshold.

3. If the script is not available, read `prompts/code-review.md` and manually collect the same context with non-destructive git and `gh` commands.

## Review Rules

- Inspect only the current change.
- Simulate independent guideline, bug, security, history, regression, and minimality reviewer passes.
- Validate every candidate before reporting it.
- Drop findings below the configured confidence threshold.
- Do not report style-only, speculative, duplicate, pre-existing, or obvious linter findings.
- Do not ask for tests unless repository instructions require tests or the diff clearly removes or breaks coverage.
- When `--comment` was requested, post to GitHub only when a PR context exists, `gh` is authenticated, and the final body would not duplicate an existing plugin comment.
