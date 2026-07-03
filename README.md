# Whet

> Sharpen Claude Code into a full product team.

**Whet** is a Claude Code plugin that ships a professional agent team plus the
workflows that make them effective on real projects: long-horizon task
scheduling, automatic model selection, token-consumption optimization, and
spec-driven development.

[English](#quick-start) | [中文](#中文说明)

## What's inside

### Agents (`agents/`)

| Agent | Role |
|---|---|
| `product-manager` | Requirements, PRDs, user stories, prioritization |
| `architect` | System design, tech selection, contracts |
| `uiux-designer` | Interaction design, wireframes, design systems, a11y |
| `frontend-dev` | Web UI implementation (React/Vue/TS) |
| `backend-dev` | APIs, data modeling, business logic, security |
| `mobile-dev` | iOS / Android / Flutter / React Native |
| `qa-tester` | Test planning, edge-case hunting, bug reproduction |
| `devops-engineer` | CI/CD, containers, IaC, observability |
| `code-reviewer` | Diff review: correctness, security, perf, maintainability |

### Skills (`skills/`)

| Skill | What it does |
|---|---|
| `long-task-scheduler` | Persists multi-session work in a `.whet/plan/` task ledger so any session can resume from disk, not memory |
| `model-router` | Routes each task/subagent to the cheapest model tier that can do it reliably (haiku/sonnet/opus rubric) |
| `token-optimizer` | Context hygiene, output discipline, and fan-out cost control |
| `spec-workflow` | Gated requirements → design → tasks flow with specs versioned in `spec/` |

### Commands (`commands/`)

| Command | Effect |
|---|---|
| `/whet:spec <feature>` | Spec-driven development for a feature |
| `/whet:plan <goal>` | Create a persistent long-horizon task ledger |
| `/whet:resume` | Resume the active ledger from where it left off |
| `/whet:review [base]` | Parallel QA + code review of current changes |

### Hooks (`hooks/`)

- **SessionStart** — detects an active `.whet/plan/` ledger and prompts resumption.
- **PreToolUse (Write/Edit)** — blocks accidental writes to sensitive files (`.env`, keys, credentials).

## Quick start

```bash
# In Claude Code
/plugin marketplace add mufasa007/whet
/plugin install whet@whet
```

Or clone and use as a local plugin:

```bash
git clone https://github.com/mufasa007/whet.git
claude --plugin-dir ./whet
```

## How the pieces fit together

```
idea ──/whet:spec──▶ spec/<feature>/          (spec-workflow)
                        │
   big effort? ──/whet:plan──▶ .whet/plan/    (long-task-scheduler)
                        │
                 implementation ──▶ frontend/backend/mobile-dev agents
                        │                     (model-router picks tiers,
                        │                      token-optimizer keeps cost down)
                 /whet:review ──▶ qa-tester + code-reviewer
```

## Repository layout

```
whet/
├── .claude-plugin/       # plugin + marketplace manifests
├── agents/               # 9 professional subagents
├── skills/               # 4 workflow skills
├── commands/             # /whet:* slash commands
├── hooks/                # session & safety hooks
├── spec/templates/       # requirements / design / tasks templates
└── CLAUDE.md
```

## License

[MIT](./LICENSE)

---

## 中文说明

**Whet** 是一个 Claude Code 插件，提供一支专业 Agent 团队及配套工作流：

- **专业 Agent**：产品经理、架构师、UI/UX 设计师、前端、后端、移动端、测试、运维、代码评审，共 9 个角色，按需自动或手动调用。
- **长程任务调度**（`long-task-scheduler`）：把跨会话的大任务落盘为 `.whet/plan/` 任务台账（PLAN.md / tasks.md / journal.md），任何新会话都能从磁盘状态无损续作。
- **自动模型选择**（`model-router`）：按推理深度、出错代价、上下文规模三个维度，把每个任务/子代理路由到能可靠完成的最便宜模型档位。
- **Token 消耗优化**（`token-optimizer`）：上下文卫生、输出纪律、并发扇出成本控制的具体手法清单。
- **规格驱动开发**（`spec-workflow`）：需求 → 设计 → 任务三段门控流程，规格随代码一起版本化在 `spec/` 目录。

### 安装

```bash
# 在 Claude Code 中
/plugin marketplace add mufasa007/whet
/plugin install whet@whet
```

### 常用命令

- `/whet:spec <功能描述>` — 为功能启动规格驱动开发
- `/whet:plan <目标>` — 创建长程任务台账并开始执行
- `/whet:resume` — 从台账断点继续
- `/whet:review [基准分支]` — QA + 代码评审并行审查当前改动
