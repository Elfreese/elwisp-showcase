#!/bin/bash
# minimal-direct: 发送一条 direct 事件到 Elnis

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
      "name": "minimal-direct-example",
      "tags": ["example", "minimal"]
    },
    "source": "minimal-direct-example",
    "id": "test-"'"$(date +%s)"'",
    "mode": "direct",
    "title": "测试事件",
    "content": "Elwisp Showcase minimal-direct 示例发送成功。",
    "targets": [
      { "platform": "cli" }
    ]
  }' | python3 -m json.tool
