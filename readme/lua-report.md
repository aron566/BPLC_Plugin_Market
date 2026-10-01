# Lua 报表 (lua-report)

测试插件：按帧统计生成文本报表，支持导出。

## 功能

- 帧类型 / TEI 分布统计
- 文本报表生成（`get_report_data`）
- 多格式导出：PDF / HTML / CSV

## 插件设置

| 设置 | 说明 | 默认值 |
|---|---|---|
| `page_size` | 报表每页显示的数据行数 | 50 |
| `include_charts` | 报表中是否嵌入统计图表 | true |
| `format` | 默认导出格式：`pdf` / `html` / `csv` | `pdf` |

脚本内读取示例：

```lua
local fmt = host.getSetting("format", "pdf")
local dataDir = host.getEnv("BPLC_DATA_DIR")
```

## 版本历史

- v1.1.0：当前版本
- v1.0.0：初始测试版本

---

## English

Test plugin: text report generation from frame statistics, exportable.

Settings: `page_size` (default 50), `include_charts` (default true),
`format` (`pdf`/`html`/`csv`, default `pdf`).
Read via `host.getSetting(key, default)`; common environment via
`host.getEnv(name)` (e.g. `BPLC_DATA_DIR`).
