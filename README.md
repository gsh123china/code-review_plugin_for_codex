# codex-code-review-plugin

中文 README: [README_CN.md](README_CN.md)

A generic Codex-compatible code review plugin for high-signal review of local diffs, branch diffs, and GitHub pull requests.

The project is conceptually inspired by Anthropic Claude Code's official code-review plugin, but it is designed for Codex workflows. It does not copy Claude-specific agent syntax, does not depend on any language stack, and does not assume Spring Boot, Java, Node.js, Python, React, or any other framework.

## What It Provides

- A Codex plugin manifest at `.codex-plugin/plugin.json`.
- A reusable Codex skill at `skills/code-review/SKILL.md`, preferably invoked as `$codex-code-review-plugin:code-review`.
- An experimental command template at `commands/code-review.md` for Codex surfaces that explicitly load plugin commands; bare `/code-review` is not a current stable guarantee.
- An optional custom prompt shim at `prompts/custom-prompts/code-review.md` for `/prompts:code-review`.
- A self-contained review prompt at `prompts/code-review.md`.
- Independent reviewer prompt files for guideline, bug, security, history, regression, minimality, and confidence scoring passes.
- A portable shell wrapper at `scripts/codex-review` that gathers repository context and prints a ready-to-use Codex prompt.
- Default review configuration at `config/default-review.yml`.
- A Codex marketplace catalog at `.agents/plugins/marketplace.json` for CLI and app installation.

## What Is Different For Codex

Claude Code's plugin model can use Claude-specific agent definitions. This project instead uses Codex-friendly building blocks:

- Markdown prompts that can be read and followed directly by Codex.
- A shell wrapper that collects git and `gh` context without destructive operations.
- A simulated multi-reviewer workflow inside one Codex review pass.
- Explicit validation and confidence scoring before any finding is reported.
- Optional GitHub comment mode expressed as prompt instructions, because the shell wrapper does not generate the AI review by itself.

## Installation

Install and enable the plugin in Codex so the bundled `code-review` skill is available. In current Codex CLI versions, plugin `commands/` files are not a stable source for a bare `/code-review` command, so do not use `/code-review` as the installation acceptance check.

### Install The Codex Plugin

Add this repository as a Codex marketplace source, then install the plugin from that marketplace:

```bash
codex plugin marketplace add gsh123china/code-review_plugin_for_codex --ref main
codex plugin list --json --available --marketplace gsh-code-review
codex plugin add codex-code-review-plugin@gsh-code-review
```

In current Codex CLI versions, `--available` is only supported with `--json`. To list installed plugins only, omit `--available`.

Start a new Codex thread after installing. The plugin's marketplace name is `gsh-code-review`, and the plugin id is `codex-code-review-plugin`.

If you are developing from a local checkout, add the local repository path instead:

```bash
git clone https://github.com/gsh123china/code-review_plugin_for_codex.git /absolute/path/to/code-review_plugin_for_codex
codex plugin marketplace add /absolute/path/to/code-review_plugin_for_codex
codex plugin add codex-code-review-plugin@gsh-code-review
```

You can also open the plugin browser with `/plugins`, choose the **GSH Code Review** marketplace, and install **Codex Code Review** from there.

### Optional Shell Command And Prompt Shim

The Codex plugin installation makes the `code-review` skill available in Codex. If you also want a `codex-review` shell command on `PATH`, install the wrapper separately from a cloned checkout:

```bash
./scripts/codex-review --help
./scripts/install.sh
```

To install the wrapper somewhere else:

```bash
./scripts/install.sh --prefix "$HOME/bin"
```

The installer symlinks by default, falls back to copying if symlinks are unavailable, and refuses to replace an existing command unless `--force` is provided.

If you want a local slash-style shortcut, explicitly install the deprecated Codex custom prompt shim:

```bash
./scripts/install.sh --prompt-shim --no-command
```

The shim is copied to `${CODEX_HOME:-$HOME/.codex}/prompts/code-review.md`. After restarting Codex, invoke it as `/prompts:code-review`, not `/code-review`. Existing prompt files are not overwritten unless you pass `--force`.

## Updating

For the GitHub marketplace source, refresh the marketplace snapshot and reinstall the plugin:

```bash
codex plugin marketplace upgrade gsh-code-review
codex plugin add codex-code-review-plugin@gsh-code-review
```

For a local checkout, update the checkout first, then reinstall the plugin from the configured marketplace:

```bash
git -C /absolute/path/to/code-review_plugin_for_codex pull --ff-only
codex plugin add codex-code-review-plugin@gsh-code-review
```

Start a new Codex thread after updating so Codex reloads the plugin bundle. If you installed the optional shell command by symlink, it follows the checkout automatically. If you installed it with `--copy`, rerun `./scripts/install.sh --force` from the updated checkout.

Maintainers should bump `.codex-plugin/plugin.json`'s `version` when publishing plugin changes so Codex installs a distinct updated bundle.

## Uninstalling

Remove the installed plugin:

```bash
codex plugin remove codex-code-review-plugin@gsh-code-review
```

If you no longer want this marketplace source in Codex, remove it as well:

```bash
codex plugin marketplace remove gsh-code-review
```

If you installed the optional shell command, remove the installed command from the prefix you used:

```bash
rm -f "$HOME/.local/bin/codex-review"
```

## Usage

### Codex Skill (Recommended)

After the plugin is installed and enabled, start a new Codex thread and explicitly mention the skill:

```text
Use $codex-code-review-plugin:code-review to review the current diff.
Use $codex-code-review-plugin:code-review with --diff.
Use $codex-code-review-plugin:code-review with --base main.
Use $codex-code-review-plugin:code-review with --pr 123.
Use $codex-code-review-plugin:code-review with --pr 123 --comment.
Use $codex-code-review-plugin:code-review with --threshold 90.
```

The skill tells Codex to translate those arguments to the same `scripts/codex-review` flags, run the bundled wrapper, then follow the generated review prompt. If no target is provided, the wrapper auto-detects a local diff or current branch PR when possible.

### Optional Custom Prompt Shim

If you explicitly installed the custom prompt shim, you can use:

```text
/prompts:code-review
/prompts:code-review --diff
/prompts:code-review --base main
/prompts:code-review --pr 123
/prompts:code-review --pr 123 --comment
/prompts:code-review --threshold 90
```

Codex custom prompts are local and deprecated. This shim is a compatibility entry point for machines that need slash-style invocation; it is not installed or shared automatically by the plugin.

### Experimental Command Template

The repository still includes `commands/code-review.md` for future Codex surfaces that explicitly support plugin command templates. The current stable entry points are `$codex-code-review-plugin:code-review`, the `codex-review` shell wrapper, or `/prompts:code-review` after explicit shim installation.

### Shell Wrapper

Review the current staged and unstaged diff:

```bash
codex-review --diff
```

Review the current branch against `main`:

```bash
codex-review --base main
```

Review a GitHub pull request:

```bash
codex-review --pr 123
```

Request GitHub comment mode:

```bash
codex-review --pr 123 --comment
```

Override the confidence threshold:

```bash
codex-review --base main --threshold 90
```

The command prints a complete prompt. Paste that prompt into Codex, or pass it to your local Codex CLI if your CLI supports stdin or prompt arguments.

## Local Diff Review

`codex-review --diff` reviews staged and unstaged changes from `git diff --cached` and `git diff`.

Untracked files are listed but not diffed. Stage them first if they should be reviewed:

```bash
git add path/to/new-file
codex-review --diff
```

## Branch Diff Review

`codex-review --base main` reviews `main...HEAD`. The base branch must exist locally. The script does not fetch or modify remotes.

## GitHub PR Review

`codex-review --pr <number>` requires the GitHub CLI:

```bash
gh auth status
codex-review --pr 123
```

When possible, the script skips PRs that should not be reviewed:

- Closed or merged PRs.
- Draft PRs.
- PRs already reviewed by this plugin marker.
- Trivial automated dependency or maintenance PRs.

Set `CODEX_REVIEW_ALLOW_RERUN=1` to ignore the existing plugin marker. Set `CODEX_REVIEW_SKIP_TRIVIAL_AUTOMATION=0` to review trivial bot PRs.

## `--comment` Behavior

The shell wrapper does not post comments by itself because it has not performed the AI review. Instead, `--comment` marks the generated prompt as comment mode.

When Codex follows that prompt, it should:

- Post only when a PR context exists.
- Use `gh` only when it is available and authenticated.
- Avoid duplicate comments by checking for `<!-- codex-code-review-plugin -->`.
- Prefer inline comments only when exact changed-line positions can be resolved safely.
- Otherwise post one summary comment.
- Print the comment body and explain why it was not posted when posting is unsafe.

## Configuration

Defaults live in `config/default-review.yml`.

Key fields:

- `confidence_threshold`: default minimum score for reporting, initially `80`.
- `review_modes`: supported review targets.
- `instruction_files`: repository guidance files to collect.
- `filters`: false-positive filters that the prompt enforces.

The shell wrapper currently reads `confidence_threshold` and `instruction_files`. The remaining fields document and stabilize the review policy used by the prompt.

## Design Principles

- Generic across languages and frameworks.
- Review only the current change.
- Prefer false negatives over false positives.
- Require exact changed-code evidence.
- Validate every candidate issue before reporting.
- Keep findings actionable and high signal.
- Avoid style-only, speculative, duplicate, pre-existing, or linter-level comments.
- Use git history only when it materially improves confidence.

## Known Limitations

- The script prints a prompt; Codex performs the actual review.
- Inline GitHub comments require Codex to resolve exact PR diff positions safely.
- Very large diffs and instruction files are truncated by line count to keep prompts usable.
- The YAML parsing in the shell wrapper is intentionally minimal and supports the provided simple config shape.
- No CI service integration is included. See `docs/workflow.md` for CI-friendly usage.

## Documentation

- `docs/architecture.md`
- `docs/workflow.md`
- `docs/configuration.md`
- `docs/examples.md`
