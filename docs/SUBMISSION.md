# 插件提交规范

## 清单 (plugin.json)

所有字段：

| 字段 | 必填 | 说明 |
|------|------|------|
| api_version | 是 | 固定 1 |
| name | 是 | 插件唯一名 (小写, 连字符) |
| display_name | 是 | 显示名 (中文) |
| display_name_en | 是 | 显示名 (英文) |
| description | 否 | 描述 (中文) |
| description_en | 否 | 描述 (英文) |
| version | 是 | 语义版本 (x.y.z) |
| author | 否 | 作者 |
| protocol_id | 是 | 协议 ID (大写, 下划线) |
| runtime | 是 | js / lua / native |
| entry | 是 | 入口文件 (parser.js / parser.lua / libxxx.so) |
| graphics | 否 | 是否提供图形能力 (默认 false) |
| id | 否 | 兼容字段, 同 name |

## 打包

插件目录打包为 zip，结构：

```
js-echo-1.0.0.zip
├── plugin.json
├── parser.js
└── README.md
```

## 审核清单

- [ ] 清单字段完整，中英文齐全
- [ ] protocol_id 全局唯一
- [ ] 无恶意代码 (JS/Lua: 无网络/文件系统访问)
- [ ] 图形插件: render 必须在 100ms 内返回
- [ ] 解析插件: parse 必须在 50ms 内返回
- [ ] 提供 README 说明
