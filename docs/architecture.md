# Architecture

This plugin is built around a simple Codex-oriented flow: collect context with a shell wrapper, review with Markdown prompts, validate candidates, score confidence, and report only high-signal findings.

## Invocation Surface

The plugin exposes one Codex skill named `code-review`. When installed and enabled, users should invoke the workflow explicitly as `$codex-code-review-plugin:code-review`.

The skill maps command-style arguments such as `--pr 123 --comment` to the existing `scripts/codex-review` wrapper. The plugin keeps `plugin.json` limited to documented manifest fields. `commands/code-review.md` is retained only as an experimental command template for Codex surfaces that explicitly load plugin commands; current stable Codex CLI versions should not be expected to expose a bare `/code-review` alias from that file.

For users who need slash-style local invocation, the repository provides an optional deprecated custom prompt shim at `prompts/custom-prompts/code-review.md`. When explicitly copied to the Codex prompts directory, it is invoked as `/prompts:code-review`.

## Context Collection

`scripts/codex-review` collects:

- Review target metadata.
- Changed files.
- Diff content.
- Pull request title and description when available.
- Repository instruction files.

Instruction collection is path-aware. For each changed file, the script searches the file directory and parent directories for configured instruction files such as `AGENTS.md`, `CODE_REVIEW.md`, and `CONTRIBUTING.md`. Repository-level `.github` instruction files are collected from the root.

The script uses read-only git and `gh` commands. It does not fetch, reset, checkout, add, commit, push, or write repository files.

## Reviewer Passes

Codex simulates independent reviewer passes inside `prompts/code-review.md`:

- Guideline Reviewer checks explicit repository rules and verifies scope.
- Bug Reviewer checks correctness issues introduced by the diff.
- Security Reviewer checks concrete security issues introduced by the diff.
- History Reviewer uses blame and history when it helps validate local invariants.
- Regression Reviewer checks compatibility, behavior, default, and edge-case changes.
- Minimality Reviewer removes subjective, duplicate, speculative, or non-actionable findings.

Supplemental reviewer prompts live in `prompts/reviewers/`.

## Candidate Issue Validation

Every candidate must pass these checks:

- Introduced by the current change.
- Not pre-existing.
- Not style-only.
- Not an ordinary linter or formatter finding.
- Supported by exact code evidence.
- Actionable by the author.
- Not a duplicate.
- Tied to a changed line or directly affected line.

Candidates that fail any check are removed before output.

## Confidence Scoring

Validated findings are scored from 0 to 100:

- 0 means almost certainly false positive.
- 25 means possible but weak evidence.
- 50 means plausible but uncertain.
- 75 means likely real but not fully certain.
- 80 means high confidence and worth human attention.
- 100 means definitely real and clearly introduced by the change.

The default threshold is `80`, configured in `config/default-review.yml`.

## Deduplication

Deduplication happens in two places:

- Candidate findings are merged when they describe the same root cause.
- GitHub comment mode checks for the `<!-- codex-code-review-plugin -->` marker before posting a summary comment.

When two findings overlap, keep the one with clearer changed-code evidence and a more actionable fix.

## Reporting

Terminal output follows `prompts/templates/terminal-report.md`.

Each reported issue includes:

- Title.
- Severity.
- Confidence.
- Category.
- File and line range.
- Evidence.
- Why it matters.
- Suggested fix.
- Whether a small committable suggestion is possible.

If no issues pass the threshold, the output is the standard no-issues message.

## GitHub Integration

GitHub integration is intentionally conservative.

The shell wrapper can collect PR metadata and diff content through `gh`. In `--comment` mode, it marks the generated prompt so Codex can post the final review when safe.

Codex should post only when:

- A PR context exists.
- `gh` is installed and authenticated.
- The final report has issues worth posting.
- No duplicate plugin marker already exists.
- Inline positions can be resolved safely, or a summary comment is acceptable.

If posting is unsafe, Codex should print the GitHub-ready body instead of posting.
