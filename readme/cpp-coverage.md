# C++ 信号覆盖 (cpp-coverage) v1.0.0

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

- v1.0.0: `linux-x86_64` (`libcpp_coverage.so`)
- Windows 版 (`cpp_coverage.dll`) 后续版本提供。
  Windows build (`cpp_coverage.dll`) will ship in a later version.

## 版本历史 / Changelog

- v1.0.0 (2026-10-02): 首次发布。First release.
