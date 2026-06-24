# Elwisp Showcase

让 ElBot 听到外部世界的声音——一条 curl 命令就能打通。

**Elwisp Showcase** 是一套开箱即用的参考仓库，帮你用最短时间把任何外部信号（RSS、Webhook、日志、服务器状态……）接入 ElBot，让它替你记录、通知或智能分析，无需从零研究协议。

> Give ElBot ears to the outside world — just a single curl command away.
>
> **Elwisp Showcase** is a ready-to-use reference repository that lets you connect any external signal (RSS, webhook, logs, server status…) to ElBot in minutes, so it can record, notify, or analyze for you — no need to study the protocol from scratch.

---

## 你能用它做什么

| 场景 | 一句话 |
|------|--------|
| 服务器挂了自动通知 | 定时探活，宕机立刻推送到手机/桌面 |
| RSS 更新摘要推送到聊天 | 动画更新、博客发布、安全公告，让 LLM 帮你总结后再通知 |
| GitHub webhook 转通知 | star、issue、PR、CI 失败，实时推送到管理会话 |
| 日志异常告警 | tail 日志文件，发现错误立即上报分析 |
| 脚本/定时任务结果回传 | cron 跑完直接通知结果，不用开屏幕看 |
| 游戏/设备状态监控 | Minecraft 服务器、传感器、智能家居事件 |

**本质一句话：把任何"外面发生了什么"变成 ElBot 能处理的事件。**

## What you can do

| Scenario | In a nutshell |
|----------|---------------|
| Uptime alerts | Ping your server; if it's down, get notified instantly on your chat app |
| RSS-to-chat summaries | New anime episode, blog post, or CVE — let the LLM summarize before notifying you |
| GitHub events in chat | Star, issue, PR, CI failure — stream them to your admin session in real time |
| Log anomaly detection | Tail your log files; if something breaks, ElBot analyzes and alerts you |
| Script/cron result delivery | Get cron job results pushed to chat, no need to SSH and check manually |
| Game / device monitoring | Minecraft server status, sensors, smart home events |

**In short: turn anything that happens outside into an event ElBot can handle.**

---

## 为什么值得用

- **零学习曲线**：复制 `send_event.sh`，改几行 payload，一条 curl 就能通
- **安全优先**：所有示例遵循 token 环境变量、127.0.0.1 绑定、不硬编码等安全规范
- **三种模式覆盖所有需求**：只记录 / 直接通知 / 交给 LLM 分析，按需选择
- **协议文档齐全**：Elvena v2 字段说明、JSON Schema 校验、targets 用法一应俱全
- **拿来即用，也可扩展**：最小示例验证链路后，可直接改造成生产监听器

## Why this matters

- **Zero learning curve** — copy `send_event.sh`, tweak a few payload fields, one curl, done
- **Secure by default** — all examples respect token-in-env, 127.0.0.1 binding, no hardcoded secrets
- **Three modes, one protocol** — record, direct notify, or LLM-powered analysis; pick what fits
- **Complete protocol reference** — Elvena v2 field guide, JSON Schema, and targets documentation
- **Copy, paste, adapt** — minimal examples validate the pipeline, then evolve into production watchers

---

## 链路 / Pipeline

```
外部世界 / Outside World
  ↓
Elwisp 监听器 / Watcher
  ↓  Elvena v2 (JSON over HTTP)
Elnis 事件枢纽 / Event Hub
  ↓
ElBot: record / direct / llm
```

## 三种模式 / Three Modes

| Mode   | 说明 / Description |
|--------|--------------------|
| record | 只记录 / Log only |
| direct | 直接通知到聊天平台 / Push notification to chat |
| llm    | 后台 LLM 分析并决定是否通知 / Background LLM analysis with tool access |

## 快速开始 / Quick Start

```bash
# 1. 确保 Elnis 已启动 / Make sure Elnis is running
git clone https://github.com/Elfreese/elwisp-showcase.git
cd elwisp-showcase

# 2. 设置 token / Set your token
cp .env.example .env
# 编辑 .env，填入真实 ELNIS_TOKEN / Edit .env with your real token

# 3. 发送第一条测试事件 / Send your first test event
cd examples/minimal-direct
. ../../.env
./send_event.sh

# 如果你的聊天客户端收到了 "测试事件"，链路就通了！
# If you received "测试事件" in your chat client, the pipeline is live!
```

## 目录 / Directory

```
elwisp-showcase/
├── README.md                         # 你在这里 / You are here
├── .env.example                      # 环境变量模板 (no real token)
├── .gitignore
├── LICENSE
├── docs/
│   ├── elwisp-overview.md            # Elwisp 是什么、角色分工
│   ├── elvena-v2.md                  # 协议字段、必填/可选、payload 示例
│   └── security.md                   # Token、网络绑定、事件安全
├── schemas/
│   └── elvena-v2.schema.json         # JSON Schema 校验定义
├── scripts/
│   └── curl-healthz.sh               # 一键检查 Elnis 健康
└── examples/
    ├── minimal-direct/               # direct 模式：最简通知
    │   ├── README.md
    │   └── send_event.sh
    └── minimal-llm/                  # llm 模式：带 ELyph task 的后台分析
        ├── README.md
        └── send_event.sh
```

## 核心原则 / Core Principles

- Elwisp 只观察和上报，不直接向聊天平台发消息 / Elwisp only observes and reports; never sends chat messages directly
- Token 只从环境变量读取 / Token only from environment variables
- event id 在同一 source 内稳定且唯一 / event id is stable and unique within each source
- targets 由事件明确声明 / targets are explicitly declared per event
- 外部工具 endpoint 默认绑定 127.0.0.1 / External tool endpoints default to 127.0.0.1

## 许可证 / License

MIT

---

> 冰与火双生 · Elfreese & Elflare
