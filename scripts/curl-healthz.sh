#!/bin/bash
# 检查 Elnis 健康状态

HEALTHZ="${ELNIS_HEALTHZ:-http://127.0.0.1:32170/healthz}"

echo "检查 Elnis: $HEALTHZ"
response=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTHZ")

if [ "$response" = "200" ]; then
    echo "Elnis 健康 (HTTP $response)"
else
    echo "Elnis 无响应 (HTTP $response)"
    exit 1
fi
