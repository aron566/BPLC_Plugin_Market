# Lua 诊断 (lua-diag)

测试插件：基于解析结果做通信诊断，输出告警列表。

## 功能

- 逐帧检查：CRC 错误、重传、异常帧类型统计
- 告警面板：时间 / 级别 / 描述
- 成功率低于阈值时产生告警

## 插件设置

| 设置 | 说明 | 默认值 |
|---|---|---|
| `max_alarms` | 诊断面板保留的告警条数上限 | 100 |
| `strict_mode` | 启用后将可疑帧也计入告警 | false |
| `warn_rate` | 通信成功率告警阈值（%） | 80.0 |

脚本内读取示例：

```lua
local maxAlarms = host.getSetting("max_alarms", 100)
local lang = host.getEnv("BPLC_LANG")  -- "zh" 或 "en"
```

## 版本历史

- v1.1.0：当前版本
- v1.0.0：初始测试版本

---

## English

Test plugin: frame-based communication diagnostics with an alarm list.

Settings: `max_alarms` (default 100), `strict_mode` (default false),
`warn_rate` (default 80.0). Read via `host.getSetting(key, default)`;
common environment via `host.getEnv(name)` (e.g. `BPLC_LANG`).
