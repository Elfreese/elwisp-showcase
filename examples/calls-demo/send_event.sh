#!/bin/bash
# calls-demo: 演示 Elvena v3 calls 字段（平台动作调用）

ENDPOINT="${ELNIS_ENDPOINT:-http://127.0.0.1:32170/elvena/v2/events}"
TOKEN="${ELNIS_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "错误: 请设置 ELNIS_TOKEN 环境变量"
    exit 1
fi

curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "version": "elvena.v3",
    "elwisp": {
      "name": "calls-demo-example",
      "tags": ["example", "calls"]
    },
    "source": "calls-demo-example",
    "id": "test-"'"'$(date +%s)'"'",
    "mode": "direct",
    "title": "calls 动作调用演示",
    "content": "已执行以下平台动作：撤回消息、禁言成员、退出群聊。",
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
      },
      {
        "kind": "capability",
        "name": "chat.leave",
        "platform": "qqonebot",
        "target": {"platform": "qqonebot", "type": "group", "id": "987654321"}
      }
    ],
    "targets": [
      { "platform": "cli" }
    ]
  }' | python3 -m json.tool
