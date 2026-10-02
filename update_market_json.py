#!/usr/bin/env python3
"""Generate market.json with real SHA256 and URLs."""
import json, os, hashlib, zipfile

MARKET_DIR = os.path.dirname(os.path.abspath(__file__))
PLUGINS_DIR = os.path.join(MARKET_DIR, "plugins")
BASE_URL = "https://github.com/aron566/BPLC_Plugin_Market/raw/main/plugins"
RAW_BASE = "https://raw.githubusercontent.com/aron566/BPLC_Plugin_Market/main"

# 各版本更新时间(测试固件用固定日期,保证可复现)
VERSION_DATES = {
    "1.0.0": "2026-09-28",
    "1.1.0": "2026-10-02",
}

def detect_platforms(zip_path):
    """从包内二进制推断适用平台。

    仅 runtime=native 的插件返回非空列表;脚本插件返回 [] (=全平台)。
    一个包可带多个平台二进制(如 libcpp_coverage.so + cpp_coverage.dll),
    此时返回多个平台 ID。显式配置 version_platforms 时优先采用配置值。
    """
    try:
        with zipfile.ZipFile(zip_path) as z:
            names = z.namelist()
            try:
                m = json.loads(z.read("plugin.json").decode("utf-8"))
            except KeyError:
                return []
            if m.get("runtime") != "native":
                return []
            plats = []
            if any(n.endswith(".dll") for n in names):
                plats.append("windows-x86_64")
            if any(n.endswith(".so") for n in names):
                plats.append("linux-x86_64")
            # .dylib 无法从扩展名区分 arm64/x86_64,暂不自动推断(可用配置覆盖)
            return plats
    except Exception as e:
        print(f"WARN: detect_platforms {zip_path}: {e}")
        return []


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
    "cpp-coverage": {
        "display_name": "C++ 信号覆盖",
        "display_name_en": "C++ Signal Coverage",
        "description": "信号覆盖插件:全网节点在一张图上展示,每节点自带覆盖圈,圈内为其邻居表覆盖范围,节点颜色表示通信成功率。点击节点可切换选中。",
        "description_en": "Signal coverage plugin: all nodes on one map, each with its own coverage circle from its neighbor table; node colors show comm success rates. Click a node to select.",
        "category": "graphics",
        "author": "BPLC Team",
        "min_app_version": "1.3.0",
        # version_platforms 缺省时从包内二进制自动推断(见 detect_platforms);
        # 如需覆盖可按版本显式指定,如 "1.0.0": ["linux-x86_64"]
        "version_platforms": {},
        "version_dates": {
            "1.0.0": "2026-10-02",
        },
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
        
        # 平台:显式配置优先,否则 native 插件从包内二进制自动推断,
        # 脚本插件为空(=全平台)
        plats = meta.get("version_platforms", {}).get(ver)
        if plats is None:
            plats = detect_platforms(fpath)
        versions.append({
            "version": ver,
            "url": url,
            "sha256": sha256,
            "size": size,
            "min_app_version": meta["min_app_version"],
            "updated_at": meta.get("version_dates", {}).get(
                ver, VERSION_DATES.get(ver, "2026-10-02")),
            "platforms": plats,
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
        "readme_url": f"{RAW_BASE}/readme/{plugin_name}.md",
        "versions": versions,
    })

market = {
    "version": 1,
    "updated": "2026-10-02T00:00:00Z",
    "plugins": plugins,
}

with open(os.path.join(MARKET_DIR, "market.json"), "w", encoding="utf-8") as f:
    json.dump(market, f, ensure_ascii=False, indent=2)

print(f"market.json updated with {len(plugins)} plugins")
for p in plugins:
    print(f"  {p['name']}: {len(p['versions'])} versions")
