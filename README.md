# BPLC 插件市场

BPLC STA Monitor 的官方插件市场。所有插件经过审核，支持在线安装与离线安装。

## 市场结构

```
BPLC_Plugin_Market/
├── market.json          # 插件索引(市场清单)
├── plugins/             # 插件包(每个子目录一个插件)
│   ├── js-echo/
│   │   ├── plugin.json  # 插件清单
│   │   ├── parser.js    # 插件代码
│   │   └── README.md    # 插件说明
│   └── ...
└── docs/
    ├── SUBMISSION.md    # 插件提交规范
    └── API.md           # 插件 API 文档
```

## market.json 格式

```json
{
  "version": 1,
  "updated": "2026-10-01T00:00:00Z",
  "plugins": [
    {
      "id": "js-echo",
      "name": "js-echo",
      "display_name": "JS 回显解析器",
      "display_name_en": "JS Echo Parser",
      "description": "...",
      "description_en": "...",
      "version": "1.0.0",
      "author": "bplc",
      "protocol_id": "JSECHO_2024",
      "runtime": "js",
      "graphics": false,
      "download_url": "plugins/js-echo/js-echo-1.0.0.zip",
      "sha256": "...",
      "min_app_version": "1.3.0"
    }
  ]
}
```

## 插件分类

- **协议解析**: 扩展协议解析能力
- **诊断**: 帧异常检测、链路诊断
- **报表分析**: 统计、报表生成
- **图形**: 自定义可视化

## 安装方式

### 在线安装
主程序 → 插件市场 → 浏览 → 安装

### 离线安装
主程序 → 插件管理 → 从文件安装 → 选择 .zip 包

## 安全

- 所有官方插件经代码审核
- 插件运行在独立进程，崩溃不影响主程序
- 插件权限声明在清单中
