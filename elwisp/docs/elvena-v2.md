# Elvena v2 协议（归档）

> **当前版本为 Elvena v3**，见 [Elvena v3 协议](elvena-v3.md)。v3 在 v2 基础上新增了 `segments`（多模态消息段）和 `calls`（平台动作调用），其余字段完全兼容。本文档保留作为 v2 参考。


Elvena v2 是 Elwisp 向 Elnis 投递事件的 JSON over HTTP 协议。

## Endpoint

```
POST /elvena/v2/events
```

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
| version     | string  | 固定值 `"elvena.v2"`                                        |
| elwisp.name | string  | Elwisp 名称，用于日志和追踪                                   |
| source      | string  | 事件来源，如 `"rss-anime"`、`"github-webhook"`               |
| id          | string  | 事件 ID，同一 source 内稳定且唯一；用于去重                     |
| mode        | string  | 处理模式：`record` / `direct` / `llm`                        |
| content     | string  | 事件内容；direct 时为通知文本，llm 时为 ELyph task 或格式文本  |
| targets     | array   | 目标列表，每个元素包含 platform 及可选的 type、id              |

## 可选字段

| 字段            | 类型     | 说明                                                       |
|-----------------|---------|-----------------------------------------------------------|
| elwisp.tags     | array   | 标签列表，如 `["production", "rss"]`                      |
| created_at      | string  | 事件创建时间（ISO 8601）                                    |
| title           | string  | 事件标题                                                   |
| format          | string  | content 格式，如 `"elyph"`、`"text"`、`"markdown"`        |
| model_slot      | string  | 指定模型槽位：`elwisp1` / `elwisp2` / `elwisp3`           |
| tool_list_names | array   | 请求 ElBot 内部工具或 Skill，最终由 Elnis 裁决               |
| tools           | object  | Elwisp 随事件声明的外部工具，适合查询 Elwisp 所在环境状态     |
| meta            | object  | 附加元数据，由 Elwisp 自定义                                 |

## targets 格式

```json
{
  "targets": [
    { "platform": "cli" },
    { "platform": "telegram", "type": "private", "id": "123456" },
    { "platform": "all" }
  ]
}
```

| 字段      | 说明                                                |
|----------|----------------------------------------------------|
| platform | `cli`、`telegram`、`all` 等                        |
| type     | 可选，`private` 表示私聊，省略表示超级管理员          |
| id       | 可选，指定会话 ID；省略表示该平台所有超级管理员        |

## 最小 direct payload

```json
{
  "version": "elvena.v2",
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
  "version": "elvena.v2",
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

## 健康检查

```
GET /healthz
```

返回 200 表示 Elnis 可接受事件。
