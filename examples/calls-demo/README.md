# calls-demo

演示 Elvena v3 `calls` 字段：在 direct 模式下执行平台动作调用。

## 用途

展示如何通过 `calls` 让 Elwisp 直接执行平台动作（撤回消息、禁言、退群），无需经过 LLM。

## 使用

```bash
# 设置环境变量
export ELNIS_ENDPOINT=http://127.0.0.1:32170/elvena/v2/events
export ELNIS_TOKEN=your-token-here

# 发送事件
./send_event.sh
```

## 效果

Elnis 收到事件后，会依次执行 `calls` 中的动作调用，然后将 `content` 作为通知文本发送到 `targets`。

## calls 说明

本示例演示三种 capability：

1. `message.recall` — 撤回指定消息
2. `member.mute` — 禁言群成员
3. `chat.leave` — 退出群聊

`kind` 可省略：写 `name` 自动推断为 capability，写 `api` 自动推断为 raw。

完整字段说明见 [Elvena v3 协议](../../docs/elvena-v3.md#calls平台动作调用)。

---

# calls-demo

Demonstrates the Elvena v3 `calls` field: executing platform actions in direct mode.

## Purpose

Shows how to use `calls` to let Elwisp directly execute platform actions (recall messages, mute members, leave groups) without going through LLM.

## Usage

```bash
# Set environment variables
export ELNIS_ENDPOINT=http://127.0.0.1:32170/elvena/v2/events
export ELNIS_TOKEN=your-token-here

# Send the event
./send_event.sh
```

## Result

Elnis receives the event, executes the actions in `calls` sequentially, then sends `content` as notification text to `targets`.

## calls notes

This example demonstrates three capabilities:

1. `message.recall` — Recall a specified message
2. `member.mute` — Mute a group member
3. `chat.leave` — Leave a group chat

`kind` can be omitted: writing `name` infers capability, writing `api` infers raw.

Full field reference: [Elvena v3 Protocol](../../docs/elvena-v3.md#calls平台动作调用).
