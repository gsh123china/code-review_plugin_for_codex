# Examples

## Terminal Output With Issues

```markdown
## Code review

Found 2 issue(s).

1. Rejects valid empty configuration files
   - Severity: medium
   - Confidence: 90
   - Category: bug
   - File and line range: src/config-loader.ts:42-45
   - Evidence: The new check returns an error when `raw.length === 0`, but the existing default path treats an empty file as `{}`.
   - Why this matters: Repositories with intentionally empty local config files will fail to start after this change.
   - Suggested fix: Preserve the previous empty-file behavior by returning the default configuration before parsing.
   - Small committable suggestion possible: yes

2. Removes authorization check from the update path
   - Severity: high
   - Confidence: 95
   - Category: security
   - File and line range: app/controllers/projects_controller.rb:88-92
   - Evidence: The changed action now calls `Project.update!(params)` before checking whether the current user can modify the project.
   - Why this matters: A user who can reach the route could modify projects they do not own.
   - Suggested fix: Restore the authorization check before the update call and keep the existing forbidden response.
   - Small committable suggestion possible: no
```

## Terminal Output With No Issues

```markdown
## Code review

No issues found. Checked for bugs, security issues, regressions, history-sensitive issues, and repository guideline compliance.
```

## GitHub Comment Body

```markdown
<!-- codex-code-review-plugin -->
## Code review

Found 1 issue(s).

1. Cache key no longer includes locale
   - Severity: medium
   - Confidence: 85
   - Category: regression
   - File and line range: lib/cache/key_builder.go:31-34
   - Evidence: The changed key builder removes `locale` from the generated key while callers still request locale-specific content.
   - Why this matters: Users can receive cached content in a different language after this change.
   - Suggested fix: Include `locale` in the cache key or document and migrate all callers to locale-independent content.
   - Small committable suggestion possible: yes
```
