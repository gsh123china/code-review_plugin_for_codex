---
description: Review the current git diff, a branch diff, or a GitHub pull request with the Codex Code Review workflow.
argument-hint: "[--diff] [--base <branch>] [--pr <number>] [--comment] [--threshold <0-100>]"
---

Use the installed Codex Code Review plugin workflow to review only the current change.

Arguments: $ARGUMENTS

Prefer the installed plugin skill `$$codex-code-review-plugin:code-review` if it is available. Treat the arguments above as review target options and map them to the same `scripts/codex-review` flags:

- `--diff`: review the current staged and unstaged local diff.
- `--base <branch>`: review `HEAD` against a local base branch.
- `--pr <number>`: review a GitHub pull request with `gh` context.
- `--comment`: prepare or post a GitHub-ready review comment when safe.
- `--threshold <0-100>`: override the confidence threshold.

If the plugin skill is not available but `codex-review` is on `PATH`, run `codex-review` with the same arguments and follow the generated prompt exactly. If neither entry point is available, explain that the plugin skill or shell wrapper must be installed before the review can run.
