#!/bin/bash
# minimal-llm: 发送一条 llm 事件到 Elnis，启动后台 LLM 分析

ENDPOINT="${ELNIS_ENDPOINT:-http://127.0.0.1:32170/elvena/v2/events}"
TOKEN="${ELNIS_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "错误: 请设置 ELNIS_TOKEN 环境变量"
    exit 1
fi

read -r -d '' ELYPH_CONTENT <<'EOF'
#task review_event - 判断事件是否需要通知
<- $event:object!
-> $report:str
** 基于事件内容、meta 和工具结果判断
~ 编造日志、指标或结论
> 如果需要通知，给出原因和建议；否则说明无需打扰。
EOF

# 将 ELyph 内容转为转义字符串（用于 JSON）
ELYPH_ESCAPED=$(python3 -c "import json; print(json.dumps(open('/dev/stdin').read()))" <<< "$ELYPH_CONTENT")

curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{
    \"version\": \"elvena.v3\",
    \"elwisp\": {
      \"name\": \"minimal-llm-example\",
      \"tags\": [\"example\", \"minimal\"]
    },
    \"source\": \"minimal-llm-example\",
    \"id\": \"test-$(date +%s)\",
    \"mode\": \"llm\",
    \"title\": \"测试 LLM 事件\",
    \"format\": \"elyph\",
    \"content\": $ELYPH_ESCAPED,
    \"tool_list_names\": [],
    \"targets\": [
      { \"platform\": \"cli\" }
    ],
    \"meta\": {}
  }" | python3 -m json.tool
