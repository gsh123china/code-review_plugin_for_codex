---
name: code-review
description: Review the current git diff, a branch diff, or a GitHub pull request with a high-signal Codex workflow. Supports options including --diff, --base, --pr, --comment, and --threshold.
---

# Codex Code Review

Use this skill to review only the current change. The review must focus on actionable issues that are introduced by the diff and supported by exact code evidence.

## Invocation

Prefer invoking this installed plugin skill explicitly:

```text
Use $codex-code-review-plugin:code-review to review the current diff.
Use $codex-code-review-plugin:code-review with --diff.
Use $codex-code-review-plugin:code-review with --base main.
Use $codex-code-review-plugin:code-review with --pr 123.
Use $codex-code-review-plugin:code-review with --pr 123 --comment.
Use $codex-code-review-plugin:code-review with --threshold 90.
```

Treat supplied option tokens such as `--pr 123 --comment` as review target options and translate them to the same `scripts/codex-review` flags.

If no explicit target is provided, run `scripts/codex-review` and let the wrapper detect the local diff or current branch PR.

This plugin also includes `commands/code-review.md` as an experimental command template for Codex surfaces that explicitly load plugin commands. Do not rely on a bare `/code-review` command in current stable Codex CLI versions. If a slash-style shortcut is required, install the optional custom prompt shim and invoke `/prompts:code-review`.

## Preferred Workflow

1. Run this plugin's bundled wrapper from the plugin root, or invoke it by absolute path, to collect context and print the complete review prompt:

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

3. If the bundled wrapper is not available, read `prompts/code-review.md` and manually collect the same context with non-destructive git and `gh` commands.

## Review Rules

- Inspect only the current change.
- Simulate independent guideline, bug, security, history, regression, and minimality reviewer passes.
- Validate every candidate before reporting it.
- Drop findings below the configured confidence threshold.
- Do not report style-only, speculative, duplicate, pre-existing, or obvious linter findings.
- Do not ask for tests unless repository instructions require tests or the diff clearly removes or breaks coverage.
- When `--comment` was requested, post to GitHub only when a PR context exists, `gh` is authenticated, and the final body would not duplicate an existing plugin comment.
