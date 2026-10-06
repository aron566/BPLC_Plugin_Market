# C++ 信号覆盖 (cpp-coverage) v1.4.5

Native 信号覆盖插件:全网节点在一张图上展示,每个节点自带覆盖圈,
圈内为其邻居表覆盖范围,节点颜色表示通信成功率。点击节点可切换选中。

Native signal-coverage plugin: all network nodes on one map, each node
with its own coverage circle derived from its neighbor table; node colors
show communication success rates. Click a node to re-center.

## 布局语义 / Layout semantics

- 节点离中心距离:依据该节点在中心节点处的**下行**通信成功率
  (成功率高 → 靠近中心)。
  Node distance from center follows the **downlink** success rate seen
  at the centered node (higher rate → closer to center).
- 节点自己的圈/颜色:依据该节点自身的**上行**通信成功率。
  Each node's own circle and color follow its **uplink** success rate.
- 内圈角度:按发现帧个数排序,越常被发现越靠上。
  Inner-ring angle follows discovery-frame count (more often discovered
  → higher up).
- 连线只画父子关系(来自路由表),箭头方向子 → 父。
  Only parent-child links are drawn (from the route table), arrows point
  child → parent.
- 父节点位于中心/内圈时,其子节点嵌入父节点的圈内。
  When a parent sits at the center/inner ring, its children are nested
  inside the parent's own circle.

## 平台 / Platforms

- Windows x86_64: `cpp_coverage.dll`(v1.2.0 起)
- Linux x86_64: `libcpp_coverage.so`(v1.0.0 / v1.1.0)

## 版本历史 / Changelog

- v1.4.5 (2026-10-06): MDS 异步化不再阻塞 GUI;纯数据帧跳过 MDS 重算
  (修复回放卡顿);去掉工作线程跨线程重绘回调;查看节点下拉框展开与
  选中节点标题重叠修复。
- v1.3.0 (2026-10-04): ABI 纳入结构体布局指纹(-l 后缀);主题跟随;抗锯齿。
- v1.2.0 (2026-10-02): Windows x86_64 首次发布。
- v1.1.0 (2026-10-03): ABI 标识修复。
- v1.0.0 (2026-10-02): 首次发布 (Linux)。First release.
