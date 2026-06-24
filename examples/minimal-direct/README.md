# minimal-direct

最小的 direct 模式示例。

## 用途

验证 Elwisp → Elnis 链路是否通畅。发送一条 direct 事件，Elnis 会直接通知 targets。

## 使用

```bash
# 设置环境变量
export ELNIS_ENDPOINT=http://127.0.0.1:32170/elvena/v2/events
export ELNIS_TOKEN=your-token-here

# 发送事件
./send_event.sh
```

## 效果

如果链路正常，你会在 targets 指定的平台收到通知消息。

## 自定义

修改 `send_event.sh` 中的 payload 即可：

- `title` — 通知标题
- `content` — 通知正文
- `targets` — 推送到哪些平台
- `source` / `id` — 去重标识（同 source+id 只投递一次）
