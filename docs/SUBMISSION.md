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
| entry | 是 | 入口文件。脚本插件:确切文件名(parser.js)。native 插件:裸库名(如 `cpp_coverage`,客户端按平台解析为 `libcpp_coverage.so` / `cpp_coverage.dll`);显式文件名(`*.so`/`*.dll`)仍兼容 |
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

native 插件:一个包可带多个平台二进制(多平台发布),entry 用裸库名:

```
cpp-coverage-1.0.0.zip
├── plugin.json          # entry: "cpp_coverage"
├── libcpp_coverage.so   # linux-x86_64
├── cpp_coverage.dll     # windows-x86_64 (有则带上)
└── README.md
```

feed 的 `platforms` 由 `update_market_json.py` 从包内二进制自动推断
(`.so`→linux-x86_64,`.dll`→windows-x86_64);脚本插件为空(=全平台)。
如需覆盖,在 `PLUGINS_META[<name>]["version_platforms"]` 中按版本显式指定。

## 审核清单

- [ ] 清单字段完整，中英文齐全
- [ ] protocol_id 全局唯一
- [ ] 无恶意代码 (JS/Lua: 无网络/文件系统访问)
- [ ] 图形插件: render 必须在 100ms 内返回
- [ ] 解析插件: parse 必须在 50ms 内返回
- [ ] 提供 README 说明
