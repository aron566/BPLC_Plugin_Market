#!/usr/bin/env python3
"""Generate market.json with real SHA256 and URLs."""
import json, os, hashlib

MARKET_DIR = os.path.dirname(os.path.abspath(__file__))
PLUGINS_DIR = os.path.join(MARKET_DIR, "plugins")
BASE_URL = "https://github.com/aron566/BPLC_Plugin_Market/raw/main/plugins"

# 插件元数据
PLUGINS_META = {
    "js-topo": {
        "display_name": "JS 拓扑视图(测试)",
        "display_name_en": "JS Topology View (test)",
        "description": "拓扑图形插件:显示 CCO/STA 网络拓扑,支持点击选择节点。",
        "description_en": "Topology graphics plugin: displays CCO/STA network topology with clickable nodes.",
        "category": "graphics",
        "author": "bplc",
        "min_app_version": "1.3.0",
    },
    "lua-diag": {
        "display_name": "Lua 帧诊断(测试)",
        "display_name_en": "Lua Frame Diagnostics (test)",
        "description": "诊断插件:检查帧长度、TEI、全零载荷等异常。",
        "description_en": "Diagnostic plugin: checks frame length, TEI, all-zero payload anomalies.",
        "category": "diagnosis",
        "author": "bplc",
        "min_app_version": "1.3.0",
    },
    "lua-report": {
        "display_name": "Lua 统计报表(测试)",
        "display_name_en": "Lua Statistics Report (test)",
        "description": "报表插件:统计帧类型与 TEI 分布,生成 JSON 报表。",
        "description_en": "Report plugin: statistics on frame types and TEI distribution, generates JSON report.",
        "category": "report",
        "author": "bplc",
        "min_app_version": "1.3.0",
    },
}

plugins = []
for plugin_name, meta in PLUGINS_META.items():
    plugin_dir = os.path.join(PLUGINS_DIR, plugin_name)
    if not os.path.isdir(plugin_dir):
        print(f"SKIP: {plugin_name} not found")
        continue
    
    versions = []
    for fname in sorted(os.listdir(plugin_dir)):
        if not fname.endswith(".zip"):
            continue
        # 解析版本号: js-replay-1.0.0.zip
        ver = fname[len(plugin_name)+1:-4]
        fpath = os.path.join(plugin_dir, fname)
        
        # 计算 SHA256
        with open(fpath, "rb") as f:
            sha256 = hashlib.sha256(f.read()).hexdigest()
        
        size = os.path.getsize(fpath)
        url = f"{BASE_URL}/{plugin_name}/{fname}"
        
        versions.append({
            "version": ver,
            "url": url,
            "sha256": sha256,
            "size": size,
            "min_app_version": meta["min_app_version"],
        })
    
    # 按版本排序
    versions.sort(key=lambda v: v["version"])
    
    plugins.append({
        "name": plugin_name,
        "display_name": meta["display_name"],
        "display_name_en": meta["display_name_en"],
        "description": meta["description"],
        "description_en": meta["description_en"],
        "category": meta["category"],
        "author": meta["author"],
        "versions": versions,
    })

market = {
    "version": 1,
    "updated": "2026-10-01T00:00:00Z",
    "plugins": plugins,
}

with open(os.path.join(MARKET_DIR, "market.json"), "w", encoding="utf-8") as f:
    json.dump(market, f, ensure_ascii=False, indent=2)

print(f"market.json updated with {len(plugins)} plugins")
for p in plugins:
    print(f"  {p['name']}: {len(p['versions'])} versions")
