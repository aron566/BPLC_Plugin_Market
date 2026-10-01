# JS 拓扑图 (js-topo)

测试插件：从解析帧中提取 TEI，绘制网络拓扑图，支持点击节点选中。

## 功能

- 实时拓扑绘制：节点 = STA（TEI），边 = 邻居/代理关系
- 右侧映射表：TEI / MAC / 状态 / 层级 / 邻居 / 代理
- 底部帧记录：Frame / Time / Type / NID / Description
- 双击帧记录：调用 `host.jumpToFrame` 让主界面定位到该帧
- 历史冻结：单击主界面较早的帧时，拓扑按完整事件日志重放冻结到该帧

## 插件设置

| 设置 | 说明 | 默认值 |
|---|---|---|
| `max_nodes` | 拓扑图最多绘制的节点数 | 200 |
| `show_labels` | 是否显示节点 TEI/MAC 标签 | true |
| `layout` | 布局算法：`auto` / `circular` / `grid` | `auto` |

脚本内读取示例：

```js
const maxNodes = host.getSetting("max_nodes", 200);
const appVer = host.getEnv("BPLC_APP_VERSION");
```

## 版本历史

- v1.1.0：当前版本
- v1.0.0：初始测试版本

---

## English

Test plugin: draws the network topology from frame TEIs, click a node to select.

Settings: `max_nodes` (default 200), `show_labels` (default true),
`layout` (`auto`/`circular`/`grid`, default `auto`).
Read them in script via `host.getSetting(key, default)`; common
environment variables via `host.getEnv(name)` (e.g. `BPLC_APP_VERSION`).
