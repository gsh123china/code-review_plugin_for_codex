---
description: Review the current git diff, a branch diff, or a GitHub pull request with the Codex Code Review workflow.
argument-hint: "[--diff] [--base <branch>] [--pr <number>] [--comment] [--threshold <0-100>]"
---

# Experimental code-review command template

Run a high-signal code review for the current change when the current Codex surface explicitly loads plugin command templates.

This file is packaged for forward compatibility. Current stable Codex CLI versions do not reliably expose plugin `commands/` files as a bare `/code-review` command. Prefer the installed skill `$codex-code-review-plugin:code-review`, the `scripts/codex-review` wrapper, or the optional `/prompts:code-review` custom prompt shim.

## Arguments

The user invoked this command with: $ARGUMENTS

Supported arguments are:

- `--diff`: review the current staged and unstaged local diff.
- `--base <branch>`: review `HEAD` against a local base branch.
- `--pr <number>`: review a GitHub pull request with `gh` context.
- `--comment`: prepare or post a GitHub-ready review comment when safe.
- `--threshold <0-100>`: override the confidence threshold.

Reject unsupported flags instead of inventing behavior.

## Workflow

1. Read `skills/code-review/SKILL.md` from this plugin for the authoritative review workflow.
2. Parse `$ARGUMENTS` as the supported `scripts/codex-review` options. Do not use `eval`, unreviewed command substitution, or user-provided shell metacharacters.
3. Run this plugin's bundled `scripts/codex-review` wrapper with the parsed arguments. Resolve it from the plugin root that contains this `commands/` directory, not from the target repository.
4. Follow the generated prompt exactly. It contains the review target, changed files, diff, repository instructions, PR metadata when available, and confidence threshold.

## Guardrails

- Inspect only the current change.
- Use read-only git and `gh` context collection unless the generated prompt explicitly reaches a safe GitHub comment step.
- Do not fetch, reset, checkout, add, commit, push, or rewrite repository files as part of context collection.
- When `--comment` is requested, post only when the generated prompt says it is safe; otherwise print the GitHub-ready body and the reason it was not posted.

## Output

Return the final review report. If no issues pass the configured confidence threshold, return the standard no-issues result from the generated prompt.
