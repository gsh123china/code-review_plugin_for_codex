# codex-code-review-plugin

一个通用的 Codex 兼容代码审查插件，用于对本地 diff、分支 diff 和 GitHub Pull Request 进行高信噪比审查。

本项目在概念上参考了 Anthropic Claude Code 官方 code-review 插件，但面向 Codex 工作流设计。它不会复制 Claude 专用的 agent 语法或实现细节，不绑定任何特定技术栈，也不假设项目使用 Spring Boot、Java、Node.js、Python、React 或其他框架。

## 提供内容

- Codex 插件 manifest：`.codex-plugin/plugin.json`。
- 可复用的 Codex skill：`skills/code-review/SKILL.md`。
- 自包含的代码审查主提示词：`prompts/code-review.md`。
- 独立 reviewer 提示词文件，覆盖规范、缺陷、安全、历史上下文、回归、最小化过滤和置信度评分。
- 可移植 shell wrapper：`scripts/codex-review`，用于收集仓库上下文并输出可直接交给 Codex 使用的完整提示词。
- 默认审查配置：`config/default-review.yml`。

## 与 Claude Code 插件的区别

Claude Code 的插件模型可以使用 Claude 专用 agent 定义。本项目改用更适合 Codex 的组成方式：

- Markdown 提示词，可由 Codex 直接读取和遵循。
- shell wrapper 使用 git 和 `gh` 收集上下文，不执行破坏性操作。
- 在一次 Codex 审查中模拟多 reviewer 工作流。
- 在报告任何发现前，先进行显式验证和置信度评分。
- 可选 GitHub 评论模式以提示词规则表达，因为 shell wrapper 本身不生成 AI 审查结果。

## 安装

可以直接在仓库中运行：

```bash
./scripts/codex-review --help
```

也可以将 `codex-review` 命令安装到 `~/.local/bin`：

```bash
./scripts/install.sh
```

安装到其他目录：

```bash
./scripts/install.sh --prefix "$HOME/bin"
```

安装脚本默认创建符号链接；如果符号链接不可用，会回退为复制文件。若目标命令已存在，除非显式提供 `--force`，否则不会覆盖。

## 使用方式

审查当前 staged 和 unstaged diff：

```bash
codex-review --diff
```

审查当前分支相对 `main` 的差异：

```bash
codex-review --base main
```

审查 GitHub Pull Request：

```bash
codex-review --pr 123
```

请求 GitHub 评论模式：

```bash
codex-review --pr 123 --comment
```

覆盖置信度阈值：

```bash
codex-review --base main --threshold 90
```

该命令会输出一段完整提示词。可以将其粘贴给 Codex，或在本地 Codex CLI 支持标准输入或提示词参数时直接传入。

## 本地 Diff 审查

`codex-review --diff` 会审查 `git diff --cached` 和 `git diff` 中的 staged 与 unstaged 变更。

未跟踪文件只会被列出，不会进入 diff。若新文件也需要审查，请先 stage：

```bash
git add path/to/new-file
codex-review --diff
```

## 分支 Diff 审查

`codex-review --base main` 会审查 `main...HEAD`。base 分支必须已经存在于本地。脚本不会 fetch，也不会修改远端或本地分支状态。

## GitHub PR 审查

`codex-review --pr <number>` 需要 GitHub CLI：

```bash
gh auth status
codex-review --pr 123
```

在可检测的情况下，脚本会跳过不应审查的 PR：

- 已关闭或已合并的 PR。
- Draft PR。
- 已经包含本插件审查标记的 PR。
- 明显简单的自动化依赖或维护类 PR。

设置 `CODEX_REVIEW_ALLOW_RERUN=1` 可以忽略已有插件标记并重新审查。设置 `CODEX_REVIEW_SKIP_TRIVIAL_AUTOMATION=0` 可以审查简单 bot PR。

## `--comment` 行为

shell wrapper 不会自行发布评论，因为它本身没有执行 AI 审查。`--comment` 只是把生成的提示词标记为评论模式。

当 Codex 遵循该提示词时，应当：

- 仅在存在 PR 上下文时发布评论。
- 仅在 `gh` 可用且已认证时使用 `gh`。
- 通过检查 `<!-- codex-code-review-plugin -->` 避免重复评论。
- 只有在能够安全解析精确 changed-line 位置时，才优先使用 inline comment。
- 否则发布一条 summary comment。
- 如果无法安全发布，则打印评论正文并说明未发布原因。

## 配置

默认配置位于 `config/default-review.yml`。

关键字段：

- `confidence_threshold`：报告问题所需的最低置信度，默认 `80`。
- `review_modes`：支持的审查目标。
- `instruction_files`：需要收集的仓库指导文件。
- `filters`：提示词强制执行的误报过滤策略。

当前 shell wrapper 会读取 `confidence_threshold` 和 `instruction_files`。其余字段用于记录并稳定提示词采用的审查策略。

## 设计原则

- 跨语言、跨框架通用。
- 只审查当前变更。
- 宁可漏报，也避免误报。
- 要求精确的变更代码证据。
- 报告前验证每个候选问题。
- 只保留可执行、高信噪比发现。
- 避免风格类、猜测类、重复、既有问题或 linter 级别评论。
- 只有在能实质提高置信度时才使用 git 历史上下文。

## 已知限制

- 脚本只输出提示词；实际审查由 Codex 完成。
- GitHub inline comment 需要 Codex 能够安全解析 PR diff 中的精确位置。
- 很大的 diff 和指导文件会按行数截断，以保持提示词可用。
- shell wrapper 中的 YAML 解析有意保持轻量，仅支持当前提供的简单配置结构。
- 当前不包含 CI 服务集成。CI-friendly 用法见 `docs/workflow.md`。

## 文档

- `README.md`：英文 README。
- `docs/architecture.md`
- `docs/workflow.md`
- `docs/configuration.md`
- `docs/examples.md`
