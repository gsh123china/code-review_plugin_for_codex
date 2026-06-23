# codex-code-review-plugin

一个通用的 Codex 兼容代码审查插件，用于对本地 diff、分支 diff 和 GitHub Pull Request 进行高信噪比审查。

本项目在概念上参考了 Anthropic Claude Code 官方 code-review 插件，但面向 Codex 工作流设计。它不会复制 Claude 专用的 agent 语法或实现细节，不绑定任何特定技术栈，也不假设项目使用 Spring Boot、Java、Node.js、Python、React 或其他框架。

## 提供内容

- Codex 插件 manifest：`.codex-plugin/plugin.json`。
- 可复用的 Codex skill：`skills/code-review/SKILL.md`，推荐通过 `$codex-code-review-plugin:code-review` 显式调用。
- 实验性 command template：`commands/code-review.md`，保留给明确加载 plugin commands 的 Codex 界面；当前不承诺裸 `/code-review`。
- 可选 custom prompt shim：`prompts/custom-prompts/code-review.md`，安装后可通过 `/prompts:code-review` 调用。
- 自包含的代码审查主提示词：`prompts/code-review.md`。
- 独立 reviewer 提示词文件，覆盖规范、缺陷、安全、历史上下文、回归、最小化过滤和置信度评分。
- 可移植 shell wrapper：`scripts/codex-review`，用于收集仓库上下文并输出可直接交给 Codex 使用的完整提示词。
- 默认审查配置：`config/default-review.yml`。
- Codex marketplace 目录：`.agents/plugins/marketplace.json`，用于在 CLI 和 Codex app 中安装插件。

## 与 Claude Code 插件的区别

Claude Code 的插件模型可以使用 Claude 专用 agent 定义。本项目改用更适合 Codex 的组成方式：

- Markdown 提示词，可由 Codex 直接读取和遵循。
- shell wrapper 使用 git 和 `gh` 收集上下文，不执行破坏性操作。
- 在一次 Codex 审查中模拟多 reviewer 工作流。
- 在报告任何发现前，先进行显式验证和置信度评分。
- 可选 GitHub 评论模式以提示词规则表达，因为 shell wrapper 本身不生成 AI 审查结果。

## 安装

在 Codex 中安装并启用该插件后，稳定入口是插件 skill：`$codex-code-review-plugin:code-review`。当前 Codex CLI 不稳定支持把插件包内的 `commands/` 文件注册为裸 slash command，因此不要把 `/code-review` 作为安装验收标准。

### 安装 Codex 插件

先将该仓库添加为 Codex marketplace source，然后从该 marketplace 安装插件：

```bash
codex plugin marketplace add gsh123china/code-review_plugin_for_codex --ref main
codex plugin list --json --available --marketplace gsh-code-review
codex plugin add codex-code-review-plugin@gsh-code-review
```

当前 Codex CLI 中，`--available` 只支持配合 `--json` 使用。如果只想列出已安装插件，请省略 `--available`。

安装后开启一个新的 Codex 线程。该插件的 marketplace 名称是 `gsh-code-review`，plugin id 是 `codex-code-review-plugin`。

如果你正在从本地 checkout 开发，可以改为添加本地仓库路径：

```bash
git clone https://github.com/gsh123china/code-review_plugin_for_codex.git /absolute/path/to/code-review_plugin_for_codex
codex plugin marketplace add /absolute/path/to/code-review_plugin_for_codex
codex plugin add codex-code-review-plugin@gsh-code-review
```

也可以在 Codex CLI 中打开 `/plugins`，选择 **GSH Code Review** marketplace，然后安装 **Codex Code Review**。

### 可选 shell 命令与 prompt shim

Codex 插件安装会让 `code-review` skill 在 Codex 中可用。如果还希望在 `PATH` 中使用 `codex-review` shell 命令，需要在 cloned checkout 中单独安装 wrapper：

```bash
./scripts/codex-review --help
./scripts/install.sh
```

安装 wrapper 到其他目录：

```bash
./scripts/install.sh --prefix "$HOME/bin"
```

安装脚本默认创建符号链接；如果符号链接不可用，会回退为复制文件。若目标命令已存在，除非显式提供 `--force`，否则不会覆盖。

如果希望使用本地 slash-style 快捷入口，可以显式安装 deprecated Codex custom prompt shim：

```bash
./scripts/install.sh --prompt-shim --no-command
```

该 shim 会复制到 `${CODEX_HOME:-$HOME/.codex}/prompts/code-review.md`。重启 Codex 后，调用名是 `/prompts:code-review`，不是 `/code-review`。如果目标文件已经存在，需要显式添加 `--force` 才会覆盖。

## 更新

如果使用 GitHub marketplace source，先刷新 marketplace 快照，再重新安装插件：

```bash
codex plugin marketplace upgrade gsh-code-review
codex plugin add codex-code-review-plugin@gsh-code-review
```

如果使用本地 checkout，先更新本地仓库，再从已配置的 marketplace 重新安装插件：

```bash
git -C /absolute/path/to/code-review_plugin_for_codex pull --ff-only
codex plugin add codex-code-review-plugin@gsh-code-review
```

更新后开启一个新的 Codex 线程，以便 Codex 重新加载插件包。如果可选 shell 命令是通过符号链接安装的，它会自动指向更新后的 checkout；如果是通过 `--copy` 安装的，请在更新后的 checkout 中重新运行 `./scripts/install.sh --force`。

维护者发布插件变更时，应同步更新 `.codex-plugin/plugin.json` 中的 `version`，让 Codex 安装到一个明确的新插件包版本。

## 卸载

移除已安装的插件：

```bash
codex plugin remove codex-code-review-plugin@gsh-code-review
```

如果不再需要该 marketplace source，也可以移除 marketplace：

```bash
codex plugin marketplace remove gsh-code-review
```

如果安装过可选 shell 命令，请从当时使用的安装目录删除该命令：

```bash
rm -f "$HOME/.local/bin/codex-review"
```

## 使用方式

### Codex Skill（推荐）

插件安装并启用后，开启一个新的 Codex 线程，用 skill mention 明确选择该工作流：

```text
Use $codex-code-review-plugin:code-review to review the current diff.
Use $codex-code-review-plugin:code-review with --diff.
Use $codex-code-review-plugin:code-review with --base main.
Use $codex-code-review-plugin:code-review with --pr 123.
Use $codex-code-review-plugin:code-review with --pr 123 --comment.
Use $codex-code-review-plugin:code-review with --threshold 90.
```

该 skill 会要求 Codex 将这些参数映射为相同的 `scripts/codex-review` 参数，运行插件内置 wrapper，然后严格遵循生成的审查提示词。如果没有提供目标参数，wrapper 会尽量自动检测本地 diff 或当前分支对应的 PR。

### 可选 Custom Prompt Shim

如果已经显式安装 custom prompt shim，可以使用：

```text
/prompts:code-review
/prompts:code-review --diff
/prompts:code-review --base main
/prompts:code-review --pr 123
/prompts:code-review --pr 123 --comment
/prompts:code-review --threshold 90
```

Codex custom prompts 是本地 deprecated 能力，不会通过插件自动安装或共享。该 shim 只是为需要 slash-style 调用的本机环境提供兼容入口。

### 实验性 Command Template

仓库仍保留 `commands/code-review.md`，用于兼容未来明确支持 plugin command template 的 Codex 界面。当前稳定入口仍然是 `$codex-code-review-plugin:code-review`、`codex-review` shell wrapper，或显式安装后的 `/prompts:code-review`。

### Shell Wrapper

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
