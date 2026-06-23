# Configuration

Default configuration lives in `config/default-review.yml`.

```yaml
confidence_threshold: 80
review_modes:
  local_diff: true
  branch_diff: true
  github_pr: true
instruction_files:
  - CLAUDE.md
  - AGENTS.md
  - CODE_REVIEW.md
  - CONTRIBUTING.md
  - .github/pull_request_template.md
  - .github/copilot-instructions.md
output:
  terminal: true
  github_comment: false
filters:
  ignore_style_only: true
  ignore_linter_findings: true
  ignore_pre_existing_issues: true
  require_changed_line_evidence: true
```

## `confidence_threshold`

Minimum confidence score for reporting a validated issue.

Default:

```yaml
confidence_threshold: 80
```

You can override it for one run:

```bash
./scripts/codex-review --threshold 90
```

## `review_modes`

Documents supported targets:

- `local_diff`: staged and unstaged git diff.
- `branch_diff`: `base...HEAD`.
- `github_pr`: GitHub PR through `gh`.

## `instruction_files`

Files Codex should consider as repository guidance.

Names without slashes are searched from each changed file's directory up through parent directories. Paths with slashes are treated as repository-root paths.

Default supported files:

- `CLAUDE.md`
- `AGENTS.md`
- `CODE_REVIEW.md`
- `CONTRIBUTING.md`
- `.github/pull_request_template.md`
- `.github/copilot-instructions.md`

## `output`

Documents output preferences. Terminal output is always supported. GitHub comment output is requested with:

```bash
./scripts/codex-review --pr 123 --comment
```

## `filters`

Documents the false-positive policy enforced by the prompt:

- Ignore style-only comments.
- Ignore ordinary linter or formatter findings.
- Ignore pre-existing issues.
- Require changed-line evidence.

## Environment Overrides

The shell wrapper also supports:

```bash
CODEX_REVIEW_MAX_DIFF_LINES=2000 ./scripts/codex-review --base main
CODEX_REVIEW_MAX_INSTRUCTION_LINES=400 ./scripts/codex-review --diff
CODEX_REVIEW_ALLOW_RERUN=1 ./scripts/codex-review --pr 123
CODEX_REVIEW_SKIP_TRIVIAL_AUTOMATION=0 ./scripts/codex-review --pr 123
```

These overrides affect context collection only. The review policy still comes from the generated prompt.
