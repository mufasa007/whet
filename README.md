# Whet

> Sharpen Claude Code into a full product team.

**Whet** is a Claude Code plugin that ships a professional agent team plus the
workflows that make them effective on real projects: long-horizon task
orchestration, automatic model selection, token-consumption optimization, and
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
| `task-reviewer` | Adversarial completion audit — gates every phase commit |
| `quick-scout` | Cheap, fast runner for small well-defined tasks (haiku) |

### Skills (`skills/`)

| Skill | What it does |
|---|---|
| `long-task-scheduler` | Orchestrates multi-session work from a per-batch ledger (`.whet/plan/{date}-{seq}-{slug}/`): serial/parallel dispatch by conflict domain, execution/review separation, one-time pre-authorization, decision archiving, per-phase commits |
| `model-router` | Platform-agnostic tier abstraction (T1 deep reasoning / T2 balanced / T3 fast / T4 extreme) with a runtime model-selection protocol — no hardcoded model names, evidence-based escalation |
| `token-optimizer` | In-flight techniques (input minimization, cache-friendly prompts, output discipline) plus a four-layer project audit with quality red lines |
| `spec-workflow` | Gated requirements → design → tasks flow with specs versioned in `spec/` |

### Commands (`commands/`)

| Command | Effect |
|---|---|
| `/whet:spec <feature>` | Spec-driven development for a feature |
| `/whet:plan <goal>` | Create a long-horizon batch ledger and start orchestrating |
| `/whet:resume` | Resume the latest batch ledger from where it left off |
| `/whet:review [base]` | Parallel QA + code review of current changes |
| `/whet:optimize [scope]` | Read-only project-level token audit |

### Hooks (`hooks/`)

- **SessionStart** — detects the latest `.whet/plan/` batch ledger and prompts resumption.
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
idea ──/whet:spec──▶ spec/<feature>/                    (spec-workflow)
                          │
   big effort? ──/whet:plan──▶ .whet/plan/{batch}/      (long-task-scheduler)
                          │        plan / issues / progress / archives
                          ▼
              orchestration loop: pick batch by conflict domain
                          │
        dispatch executors (frontend/backend/mobile-dev, quick-scout…)
        tier per task via model-router; token-optimizer keeps cost down
                          │
              task-reviewer: adversarial audit ──▶ pass → phase commit
                          │                        fail → redispatch (escalate tier)
                 /whet:review ──▶ qa-tester + code-reviewer
```

Key design points (borrowed from battle-tested long-horizon agent crews):

- **Execution/review separation** — executors only bring work to
  "ready for review"; only `task-reviewer`'s explicit verdict unlocks a commit.
- **One continuous run** — clarification & authorization are front-loaded;
  mid-run decisions are made autonomously and archived to `issues.md` for
  post-run human review, never stalling the run.
- **Tiers, not model names** — plans mark T1–T4 capability tiers; actual
  models are matched at runtime from what the platform exposes, so new
  flagships are adopted automatically.
- **Conflict domains** — same file / config / DB target / port ⇒ serial;
  disjoint ⇒ parallel batch.

## Repository layout

```
whet/
├── .claude-plugin/       # plugin + marketplace manifests
├── agents/               # 11 professional subagents
├── skills/               # 4 workflow skills (+ ledger templates)
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

- **专业 Agent（11 个）**：产品经理、架构师、UI/UX 设计师、前端、后端、移动端、测试、运维、代码评审、**任务审核器**（对抗式完成度审计，把关每个阶段提交）、**轻量执行员**（haiku 档，跑小而明确的任务）。
- **长程任务调度**（`long-task-scheduler`）：每个长程任务在 `.whet/plan/{日期}-{序号}-{简名}/` 下建立独立台账（执行计划 / 问题列表 / 进度记录 / 决策归档）；按依赖与**冲突域**串并行派发、执行与审核分离、一次性前置授权、重大决策自主决断并归档待事后人工审核、审核通过按阶段自动提交——启动后一次性跑完，执行期零人工介入。
- **自动模型选择**（`model-router`）：平台无关的 **T1~T4 能力档位抽象**（强推理/均衡/快速/极限），运行时按平台实际可选模型动态落地，不硬编码模型名；从最低够用档起步，凭证据升档，升档决策留痕。
- **Token 消耗优化**（`token-optimizer`）：会话内手法（输入最小化、缓存友好的稳定前缀、输出纪律）+ **项目级四层诊断**（会话/常驻配置/仓库结构/流程），并设质量红线——损害判断质量的"节省"一律否决。
- **规格驱动开发**（`spec-workflow`）：需求 → 设计 → 任务三段门控流程，规格随代码版本化在 `spec/`。

### 安装

```bash
# 在 Claude Code 中
/plugin marketplace add mufasa007/whet
/plugin install whet@whet
```

### 常用命令

- `/whet:spec <功能描述>` — 为功能启动规格驱动开发
- `/whet:plan <目标>` — 创建长程任务台账并开始编排
- `/whet:resume` — 从最新台账断点继续
- `/whet:review [基准分支]` — QA + 代码评审并行审查当前改动
- `/whet:optimize [范围]` — 项目级 token 消耗只读审计
