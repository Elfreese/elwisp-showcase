# Elwisp Showcase

Elwisp 是 ElBot 生态的外部事件监听器集合。每个 Elwisp 观察一个外部信息源（RSS、Webhook、日志、服务器状态、脚本输出等），按 **Elvena v2** 协议向 **Elnis** 事件枢纽上报事件，由 ElBot 决定记录、通知或交给后台 LLM 分析。

## 链路

```
外部世界
  ↓
Elwisp 监听器
  ↓  Elvena v2 (JSON over HTTP)
Elnis 事件枢纽
  ↓
ElBot: record / direct / llm
```

## 三种模式

| Mode   | 说明                                                   |
|--------|------------------------------------------------------|
| record | 只记录事件，不通知，不分析                                |
| direct | 直接通知到指定 targets（平台、会话）                        |
| llm    | 进入后台 LLM Session，根据 ELyph task 分析并可能调用工具 |

## 快速开始

1. 确保 Elnis 已启动并可访问
2. 复制 `.env.example` 为 `.env`，填入 endpoint 和 token
3. 运行最小示例验证链路

```bash
cd examples/minimal-direct
. ../../.env
./send_event.sh
```

## 目录

```
elwisp-showcase/
├── README.md
├── .env.example                    # 环境变量模板（无真实 token）
├── .gitignore
├── docs/
│   ├── elwisp-overview.md          # Elwisp 概念与职责
│   ├── elvena-v2.md                # 协议字段详解
│   └── security.md                 # 安全注意事项
├── schemas/
│   └── elvena-v2.schema.json
├── scripts/
│   └── curl-healthz.sh
└── examples/
    ├── minimal-direct/
    │   ├── README.md
    │   └── send_event.sh
    └── minimal-llm/
        ├── README.md
        └── send_event.sh
```

## 核心原则

- Elwisp 只观察和上报，不直接向聊天平台发消息
- Token 只从环境变量读取，不硬编码、不打印、不记录
- event id 在同一 source 内稳定且唯一
- targets 由事件明确声明
- 外部工具 endpoint 默认绑定 127.0.0.1

## 许可证

MIT
