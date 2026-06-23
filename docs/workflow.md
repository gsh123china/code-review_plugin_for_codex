# Workflow

## Codex Slash Workflow

After the plugin is installed and enabled in Codex, invoke the bundled skill from the composer:

```text
/code-review
/code-review --diff
/code-review --base main
/code-review --pr 123
/code-review --pr 123 --comment
```

This is the Codex equivalent of a Claude Code `commands/code-review.md` entry. The slash invocation activates the `code-review` skill, maps the supplied arguments to `scripts/codex-review`, and then follows the generated prompt.

## Typical Local Workflow

1. Make code changes.
2. Run the wrapper:

```bash
./scripts/codex-review --diff
```

3. Give the generated prompt to Codex.
4. Let Codex review the diff and produce terminal output.
5. Apply any accepted fixes manually or ask Codex to implement them.

Untracked files are not included in `git diff`. Stage new files before review:

```bash
git add path/to/new-file
./scripts/codex-review --diff
```

## Typical Branch Workflow

Review the current branch against a local base branch:

```bash
./scripts/codex-review --base main
```

This uses:

```bash
git diff main...HEAD
```

The script does not fetch the base branch. Fetch or update your local branch separately if needed.

## Typical PR Workflow

Review a pull request with GitHub CLI context:

```bash
gh auth status
./scripts/codex-review --pr 123
```

Request comment mode:

```bash
./scripts/codex-review --pr 123 --comment
```

The generated prompt tells Codex to avoid duplicate comments, skip unsafe posting, and print the comment body when posting is not possible.

## CI-Friendly Workflow

This project does not ship a CI service integration. A CI job can still use the wrapper to prepare review context:

```bash
./scripts/codex-review --base origin/main > codex-review-prompt.md
```

A separate Codex execution step can consume `codex-review-prompt.md` and publish the result according to the prompt rules.

Recommended CI constraints:

- Use read-only repository tokens for context collection.
- Require explicit opt-in before posting GitHub comments.
- Store generated prompts as short-lived artifacts only.
- Keep `CODEX_REVIEW_MAX_DIFF_LINES` low for very large repositories.
- Do not fail builds only because the review found low-confidence candidates.
