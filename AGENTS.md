# Repository Guidelines

## Project Structure & Module Organization

This repository contains a generic Codex code review plugin. The plugin manifest lives at `.codex-plugin/plugin.json`. The executable wrapper is `scripts/codex-review`, with installer support in `scripts/install.sh`. Review prompts are stored in `prompts/`, including reviewer-specific files under `prompts/reviewers/` and output templates under `prompts/templates/`. The reusable Codex skill is `skills/code-review/SKILL.md`. Default behavior is configured in `config/default-review.yml`. Project documentation lives in `docs/`, and `tests/fixtures/` is reserved for future sample repositories, diffs, and prompt rendering tests.

## Build, Test, and Development Commands

- `./scripts/codex-review --help`: verify the wrapper is executable and inspect supported options.
- `./scripts/codex-review --diff`: collect context for staged and unstaged local changes.
- `./scripts/codex-review --base main`: collect a branch diff using `main...HEAD`; the script does not fetch.
- `gh auth status && ./scripts/codex-review --pr 123`: collect GitHub PR context when `gh` is installed and authenticated.
- `./scripts/install.sh --dry-run`: validate installation paths without writing files.

There is no language package manager or compiled build step in this project.

## Coding Style & Naming Conventions

Shell scripts use POSIX `sh`, `set -eu`, two-space indentation inside functions and control blocks, lowercase function names, and uppercase constants or environment variables such as `CODEX_REVIEW_HOME`. Keep Markdown prompts direct, evidence-based, and consistent with the high-signal review policy. YAML config should stay simple enough for the shell parser in `scripts/codex-review`.

## Testing Guidelines

No automated test runner is currently defined. For script changes, run `./scripts/codex-review --help`, `./scripts/install.sh --dry-run`, and at least one context collection command such as `./scripts/codex-review --diff`. For prompt or config changes, inspect the generated prompt output and ensure truncation limits, instruction-file collection, and confidence threshold behavior remain clear.

## Commit & Pull Request Guidelines

Recent history includes a concise `feat:` commit and an initial commit; prefer short Conventional Commit-style prefixes when appropriate, such as `feat: add reviewer prompt`. Pull requests should explain the review workflow impact, list validation commands run, and mention changes to prompts, config defaults, or GitHub comment behavior. Link related issues when available and include screenshots only for rendered documentation or marketplace presentation changes.

## Agent-Specific Instructions

Do not run destructive git operations from automation. The wrapper intentionally uses read-only git and `gh` context collection; preserve that behavior unless a change explicitly documents and justifies otherwise.
