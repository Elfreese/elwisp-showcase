# minimal-llm

最小的 llm 模式示例。

## 用途

验证 Elwisp → Elnis → 后台 LLM Session 链路。发送一条 llm 事件，Elnis 会启动后台 Session，用 ELyph task 分析事件并可能调用工具。

## 使用

```bash
# 设置环境变量
export ELNIS_ENDPOINT=http://127.0.0.1:32170/elvena/v2/events
export ELNIS_TOKEN=your-token-here

# 发送事件
./send_event.sh
```

## 效果

如果链路正常，后台 LLM 会分析事件并返回结果到 targets 指定平台。

## content 说明

content 中的 ELyph task 是 LLM 的指令。本示例中的 `#task review_event` 会：

1. 接收事件对象
2. 根据事件内容和工具结果判断
3. 如果需要通知，给出原因和建议；否则说明无需打扰

## 添加工具

在 `tool_list_names` 数组中声明需要的工具：

```json
"tool_list_names": ["web_search", "read_file"]
```

最终可用的工具由 Elnis `allowed_tools` 裁决。
