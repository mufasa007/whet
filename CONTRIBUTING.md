# Contributing to Whet

感谢你的贡献！Whet 是一个 Claude Code 插件，提供一支专业 Agent 团队及配套工作流。

## 环境准备

本地加载插件进行验证：

```bash
claude --plugin-dir .
```

启动后检查 `/agents` 和 `/help` 确认插件正常加载。

## 代码规范

### Agent 约定

- `name` 必须匹配文件名（不含 `.md` 后缀）。
- `description` 采用触发式描述：1–2 句说明**何时调用**该 agent，≤200 字符。
- `model` 字段禁止硬编码具体模型名，只允许 `inherit` 或家族别名（`haiku` / `sonnet` / `opus`）。

### Skill 命名规范

- 目录名与 `SKILL.md` frontmatter 的 `name` 必须一致。
- 描述同样采用触发式，说明何时使用以及提供的能力。

### Hook 脚本约定

- 所有 `.sh` 脚本必须包含 `set -euo pipefail`。
- 不依赖 `jq`；使用 `sed` / `grep` / `python3` 进行 JSON 提取。
- 新增 hook 后必须在 `hooks/hooks.json` 中注册，并在 `scripts/regression-test.sh` 中补充测试用例。

## 测试

每次提交前必须运行：

```bash
bash scripts/regression-test.sh
```

要求：**0 失败**。回归测试覆盖 hook 脚本行为、agent/skills frontmatter、JSON 清单与版本一致性、命令与模板存在性。

## 提交 PR

请使用 [PR 模板](./.github/pull_request_template.md)，并包含：

1. 修改的文件列表及修改原因。
2. `bash scripts/regression-test.sh` 的完整输出（或明确说明 0 失败）。
3. 是否有破坏性变更（按 SemVer 标注 MAJOR / MINOR / PATCH）。

## 双语支持

如果修改了功能或用户可见的文本，请同步更新 `README.md` 中的英文和中文说明。

## 目录结构速查

```
whet/
├── .claude-plugin/       # plugin.json + marketplace.json
├── agents/               # 11 个 agent 定义
├── skills/               # 4 个 workflow skill
├── commands/             # /whet:* 命令定义
├── hooks/                # PreToolUse / SessionStart hook
├── spec/templates/       # requirements / design / tasks 模板
├── scripts/              # regression-test.sh
├── CHANGELOG.md          # 版本历史 (SemVer)
└── CLAUDE.md             # 开发指南与发布流程
```

如有疑问，请直接开 Issue 讨论。
