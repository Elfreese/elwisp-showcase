# Elvena v3 协议

Elvena v3 是 Elwisp 向 Elnis 投递事件的 JSON over HTTP 协议。v3 在 v2 基础上新增了 `segments`（多模态消息段）和 `calls`（平台动作调用）。

## Endpoint

```
POST /elvena/v2/events
```

endpoint 路径不变，版本通过 payload 中的 `version` 字段区分。

## 鉴权

```
Authorization: Bearer $TOKEN
```

或

```
X-Elnis-Token: $TOKEN
```

## 必填字段

| 字段         | 类型     | 说明                                                        |
|-------------|---------|------------------------------------------------------------|
| version     | string  | 固定值 `"elvena.v3"`                                        |
| elwisp.name | string  | Elwisp 名称，仅允许字母、数字、`_`、`-`；用于日志和追踪          |
| source      | string  | 事件来源，如 `"rss-anime"`、`"github-webhook"`               |
| id          | string  | 事件 ID，同一 source 内稳定且唯一；用于去重                     |
| mode        | string  | 处理模式：`record` / `direct` / `llm`                        |
| content     | string  | 事件内容；direct 时为通知文本，llm 时为 ELyph task 或格式文本  |
| targets     | array   | 目标列表，每个元素包含 platform 及可选的 type、id              |

## 可选字段

| 字段            | 类型     | 说明                                                       |
|-----------------|---------|-----------------------------------------------------------|
| elwisp.tags     | array   | 标签列表，如 `["production", "rss"]`                      |
| created_at      | string  | 事件创建时间（RFC 3339）                                    |
| title           | string  | 事件标题                                                   |
| format          | string  | content 格式：`text` / `elyph`，默认 `text`                |
| model_slot      | string  | 指定模型槽位：`elwisp1` / `elwisp2` / `elwisp3`           |
| tool_list_names | array   | 请求 ElBot 内部工具或 Skill，最终由 Elnis 裁决               |
| tools           | array   | Elwisp 随事件声明的外部工具，适合查询 Elwisp 所在环境状态     |
| segments        | array   | 多模态消息段，支持 text / image / file                      |
| calls           | array   | 平台动作调用，支持 raw API 透传和统一 capability            |
| meta            | object  | 附加元数据，由 Elwisp 自定义                                 |

## targets 格式

```json
{
  "targets": [
    { "platform": "cli" },
    { "platform": "telegram", "type": "private", "id": "123456" },
    { "platform": "qqonebot", "type": "group", "id": "987654321" },
    { "platform": "all" }
  ]
}
```

| 字段      | 说明                                                |
|----------|----------------------------------------------------|
| platform | `cli`、`telegram`、`qqonebot`、`all` 等             |
| type     | 可选，`private` 表示私聊，`group` 表示群聊；省略表示超级管理员 |
| id       | 可选，指定会话 ID；省略表示该平台所有超级管理员        |

`platform=all` 不能同时写 `type` 或 `id`。

## segments（多模态消息段）

通过 `segments` 字段发送图片和文件。`content` 保留为纯文本 fallback。

`segments` 为空时行为不变，非空时优先 segments 渲染，content 作为附加文本。

### Segment 字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| kind | string | 是 | `text`、`image`、`file` |
| text | string | text 必填 | 纯文本内容，不落盘 |
| url  | string | image/file 必填 | `http://`、`https://` 或 `data:` base64 URI |
| name | string | 否 | 文件名，用于下载保存和展示 |
| mime_type | string | 否 | MIME 类型提示 |

### 下载与存储

- Elnis 接收后自动下载到 `sandbox/elnis/<elwisp名>/<事件id>/`
- 发送到 LLM 时使用原始 URL（多模态模型可直接看图），沙盒保留副本
- direct 模式同样支持 image/file 输出，平台不支持时自动降级为文字描述
- 文件大小受 `elnis.toml` 的 `[segment].max_file_bytes` 限制（默认 100MB）
- `data:` URI 仅支持 base64 编码
- `file://` 等本地协议禁止

### segments 示例

```json
{
  "segments": [
    {"kind": "text",  "text": "服务器 CPU 飙到 90%，详见附图。"},
    {"kind": "image", "url": "https://monitor.example.com/chart.png", "name": "cpu_chart.png"},
    {"kind": "file",  "url": "https://logs.example.com/dump.txt", "name": "cpu_dump.txt"}
  ]
}
```

## calls（平台动作调用）

`calls` 字段允许 Elwisp 在 direct 模式下执行平台动作，无需经过 LLM。两种调用方式：

### raw（平台原始 API 透传）

```json
{
  "calls": [
    {
      "kind": "raw",
      "platform": "qqonebot",
      "api": "delete_msg",
      "params": {"message_id": 12345}
    }
  ]
}
```

| 字段     | 类型   | 说明                          |
|---------|--------|------------------------------|
| kind    | string | `raw`                         |
| platform | string | 目标平台                       |
| api     | string | 平台原始 API 名称              |
| params  | object | API 参数                      |

### capability（统一能力名）

使用统一能力名，Elnis 自动映射到对应平台 API。

```json
{
  "calls": [
    {
      "kind": "capability",
      "name": "message.recall",
      "platform": "telegram",
      "target": {"platform": "telegram", "type": "private", "id": "123456"},
      "params": {"message_id": 42}
    }
  ]
}
```

| 字段     | 类型   | 说明                          |
|---------|--------|------------------------------|
| kind    | string | `capability`                  |
| name    | string | 统一能力名                    |
| platform | string | 目标平台                       |
| target  | object | 可选，指定目标会话              |
| params  | object | 能力参数                      |

### 首批 capability

| 能力名 | 参数 | 说明 |
|--------|------|------|
| `message.recall` | `message_id` | 撤回消息 |
| `member.mute` | `user_id`, `duration_seconds` | 禁言群成员；target 需指定 group |
| `chat.leave` | — | 退出群聊；target 需指定 group |

`kind` 可省略：写 `name` 自动推断为 capability，写 `api` 自动推断为 raw。

## 最小 direct payload

```json
{
  "version": "elvena.v3",
  "elwisp": {
    "name": "example-elwisp",
    "tags": ["example"]
  },
  "source": "example-source",
  "id": "stable-event-id",
  "mode": "direct",
  "title": "事件标题",
  "content": "可直接通知给管理员的文本。",
  "targets": [
    { "platform": "cli" }
  ]
}
```

## 最小 llm payload

```json
{
  "version": "elvena.v3",
  "elwisp": {
    "name": "example-elwisp",
    "tags": ["example"]
  },
  "source": "example-source",
  "id": "stable-event-id",
  "mode": "llm",
  "title": "需要分析的事件",
  "format": "elyph",
  "content": "#task review_event - 判断事件是否需要通知\n<- $event:object!\n-> $report:str\n** 基于事件内容、meta 和工具结果判断\n~ 编造日志、指标或结论\n> 如果需要通知，给出原因和建议；否则说明无需打扰。",
  "tool_list_names": [],
  "targets": [
    { "platform": "cli" }
  ],
  "meta": {}
}
```

## 带 segments 的 direct payload

```json
{
  "version": "elvena.v3",
  "elwisp": {"name": "monitor"},
  "source": "prod-server",
  "id": "cpu-chart-002",
  "mode": "direct",
  "title": "CPU 异常",
  "content": "CPU 飙到 90%",
  "segments": [
    {"kind": "text",  "text": "服务器 CPU 飙到 90%，详见附图。"},
    {"kind": "image", "url": "https://monitor.example.com/chart.png", "name": "cpu_chart.png"}
  ],
  "targets": [{"platform": "cli"}]
}
```

## 带 calls 的 direct payload

```json
{
  "version": "elvena.v3",
  "elwisp": {"name": "moderation-bot"},
  "source": "spam-detector",
  "id": "spam-20260617-001",
  "mode": "direct",
  "content": "检测到刷屏消息，已自动撤回并对该用户禁言 60 秒。",
  "calls": [
    {
      "kind": "capability",
      "name": "message.recall",
      "platform": "telegram",
      "target": {"platform": "telegram", "type": "private", "id": "123456"},
      "params": {"message_id": 42}
    },
    {
      "kind": "capability",
      "name": "member.mute",
      "platform": "qqonebot",
      "target": {"platform": "qqonebot", "type": "group", "id": "987654321"},
      "params": {"user_id": 11111, "duration_seconds": 60}
    }
  ],
  "targets": [{"platform": "cli"}]
}
```

## LLM 结果中的 report_segments

后台 LLM 处理事件后，`JSONResult` 的 `report_segments` 可附带图片/文件路径，Elnis 会在报告发送时一并投递。`url` 必须是当前任务工作目录内的相对路径，不能使用绝对路径、`~` 或 `..`。

```json
{
  "completed": true,
  "need_report": true,
  "report": "分析完成，见截图。",
  "report_segments": [
    {"type": "image", "url": "chart.png"}
  ]
}
```

## HTTP 响应

HTTP 响应只表示 Elnis 已接收或拒绝请求，不等待 LLM 完成。

```json
{
  "accepted": true,
  "duplicate": false,
  "event_key": "server-watchdog/minecraft-main/cpu-alert-001",
  "mode": "llm",
  "status": "queued"
}
```

## 健康检查

```
GET /healthz
```

返回 200 表示 Elnis 可接受事件。
