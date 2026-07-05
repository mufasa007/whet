# Whet

> Sharpen Claude Code into a full product team.

[![Version](https://img.shields.io/badge/version-0.4.0-blue)](./CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](./LICENSE)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-plugin-orange)](https://docs.anthropic.com/en/docs/claude-code)

**Whet** is a Claude Code plugin that ships a professional agent team plus the
workflows that make them effective on real projects: long-horizon task
orchestration, automatic model selection, token-consumption optimization, and
spec-driven development.

[English](#quick-start) | [中文](#中文说明)

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

### Updating

```bash
/plugin marketplace update whet   # refresh the marketplace listing
/plugin update whet@whet          # update the installed plugin
```

Updates take effect in **new sessions**. Your project data — `.whet/plan/**`
ledgers and `spec/**` documents — lives in your own repository and is never
touched by plugin updates. See [CHANGELOG.md](./CHANGELOG.md) for what changed
in each release; breaking releases (MAJOR) always include a migration note.

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
| `security-engineer` | Security audits, threat modeling, dependency vulnerability scanning |
| `data-engineer` | Data modeling, SQL optimization, ETL design, schema migration |
| `tech-writer` | Documentation, API docs, release notes, README maintenance |

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
- **PreToolUse (Task/Agent)** — while a batch ledger is active, blocks dispatching a whet agent without an explicit `model`, so every dispatch makes a deliberate tier choice per model-router (quick-scout is exempt — it pins the fast family).

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
├── scripts/              # repo maintenance (regression-test.sh)
├── CHANGELOG.md          # release history (SemVer)
└── CLAUDE.md             # dev guide & release process
```

## Versioning & releases

Whet follows [SemVer](https://semver.org/):

- **MAJOR** — breaking: rename/remove an agent, skill, or command; change the
  `.whet/plan/` ledger layout; tighten hook blocking rules. Always ships with
  a migration note in the changelog.
- **MINOR** — new agents/skills/commands and capabilities.
- **PATCH** — prompt tuning, wording and doc fixes.

`main` is the distribution channel and is always installable; releases are
tagged `vX.Y.Z`. Contributor workflow lives in [CLAUDE.md](./CLAUDE.md).

## Contributing

Issues and PRs are welcome. Before opening a PR:

1. Validate locally with `claude --plugin-dir .` (check `/agents` and `/help`).
2. `bash scripts/regression-test.sh` — self-test all components; then
   `bash -n hooks/scripts/*.sh` and JSON-validate the manifests.
3. Follow the conventions in [CLAUDE.md](./CLAUDE.md) — notably: agent
   `description` states *when* to invoke; never hardcode model names (use
   T1–T4 tiers); keep every document token-lean.

## License

[MIT](./LICENSE)

---

## 中文说明

**Whet** 是一个 Claude Code 插件，提供一支专业 Agent 团队及配套工作流：

- **专业 Agent（14 个）**：产品经理、架构师、UI/UX 设计师、前端、后端、移动端、测试、运维、代码评审、**任务审核器**（对抗式完成度审计，把关每个阶段提交）、**轻量执行员**（haiku 档，跑小而明确的任务）、**安全工程师**（安全审计、威胁建模、依赖漏洞扫描）、**数据工程师**（数据建模、SQL 优化、ETL 设计、schema migration）、**技术文档工程师**（文档撰写、API 文档、发布说明、README 维护）。
- **长程任务调度**（`long-task-scheduler`）：每个长程任务在 `.whet/plan/{日期}-{序号}-{简名}/` 下建立独立台账（执行计划 / 问题列表 / 进度记录 / 决策归档）；按依赖与**冲突域**串并行派发、执行与审核分离、一次性前置授权、重大决策自主决断并归档待事后人工审核、审核通过按阶段自动提交——启动后一次性跑完，执行期零人工介入。
- **自动模型选择**（`model-router`）：平台无关的 **T1~T4 能力档位抽象**（强推理/均衡/快速/极限），运行时按平台实际可选模型动态落地，不硬编码模型名；从最低够用档起步，凭证据升档，升档决策留痕。长程任务台账激活期间，配套 hook 会硬拦截未显式指定 `model` 的 whet agent 派发，确保每次派发都是有意识的档位选择。
- **Token 消耗优化**（`token-optimizer`）：会话内手法（输入最小化、缓存友好的稳定前缀、输出纪律）+ **项目级四层诊断**（会话/常驻配置/仓库结构/流程），并设质量红线——损害判断质量的"节省"一律否决。
- **规格驱动开发**（`spec-workflow`）：需求 → 设计 → 任务三段门控流程，规格随代码版本化在 `spec/`。

### 安装

```bash
# 在 Claude Code 中
/plugin marketplace add mufasa007/whet
/plugin install whet@whet
```

### 更新

```bash
/plugin marketplace update whet   # 刷新市场清单
/plugin update whet@whet          # 更新已安装插件
```

更新在**新会话**中生效。你项目里的 `.whet/plan/**` 台账与 `spec/**` 规格属于
用户数据，插件更新不会改动它们。各版本变更见 [CHANGELOG.md](./CHANGELOG.md)；
破坏性版本（MAJOR）必附迁移说明。

### 常用命令

- `/whet:spec <功能描述>` — 为功能启动规格驱动开发
- `/whet:plan <目标>` — 创建长程任务台账并开始编排
- `/whet:resume` — 从最新台账断点继续
- `/whet:review [基准分支]` — QA + 代码评审并行审查当前改动
- `/whet:optimize [范围]` — 项目级 token 消耗只读审计

### 架构总览

```
idea ──/whet:spec──▶ spec/<功能名>/                    (spec-workflow)
                          │
   大工程? ──/whet:plan──▶ .whet/plan/{批次}/      (long-task-scheduler)
                          │        plan / issues / progress / archives
                          ▼
              编排循环：按冲突域选批次
                          │
        派发执行员（frontend/backend/mobile-dev, quick-scout…）
        按 model-router 定档位；token-optimizer 全程压低成本
                          │
              task-reviewer：对抗式审核 ──▶ 通过 → 阶段提交
                          │                        未通过 → 重派（升档）
                 /whet:review ──▶ qa-tester + code-reviewer
```

关键设计点（来自经实战验证的长程 Agent 班组）：

- **执行与审核分离** —— 执行员只把工作做到「可供审核」；只有 `task-reviewer` 明确给出「允许提交」裁决，才会解锁该阶段的 commit。
- **一次连续运行** —— 澄清与授权全部前置；运行中的决策自主决断并归档到 `issues.md` 供事后人工审阅，绝不中途停下来问你。
- **档位而非模型名** —— 计划里只标 T1–T4 能力档位，实际模型在运行时按平台暴露的选项动态匹配，新旗舰自动纳入。
- **冲突域** —— 触碰同一文件 / 配置 / 数据库写入目标 / 端口的任务必须串行；彼此无交集的任务并入同一批次并行跑。

### 仓库布局

```
whet/
├── .claude-plugin/       # 插件 + 市场清单
├── agents/               # 11 个专业 Agent
├── skills/               # 4 个工作流技能（+ 台账模板）
├── commands/             # /whet:* 斜杠命令
├── hooks/                # 会话与安全钩子
├── spec/templates/       # 需求 / 设计 / 任务模板
├── scripts/              # 仓库维护（regression-test.sh）
├── CHANGELOG.md          # 发布历史（SemVer）
└── CLAUDE.md             # 开发指南与发布流程
```

### 版本策略

遵循 SemVer：**MAJOR** = 破坏性（重命名/删除 agent、skill、command，或改台账
结构，必附迁移说明）；**MINOR** = 新增能力；**PATCH** = 提示词与文档修正。
`main` 分支即分发渠道，始终保持可安装；发布打 `vX.Y.Z` 标签。
