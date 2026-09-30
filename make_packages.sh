#!/bin/bash
# 为 4 个测试插件制作多版本发布包
set -e

MARKET_DIR="$(cd "$(dirname "$0")" && pwd)"
EXAMPLES_DIR="$HOME/workspace/HPLC_Wireshark/src/plugin/examples"
PLUGINS_DIR="$MARKET_DIR/plugins"

mkdir -p "$PLUGINS_DIR"

# 插件列表: 目录名|插件名|版本1|版本2
PLUGINS=(
    "js_replay|js-replay|1.0.0|1.1.0"
    "js_topo|js-topo|1.0.0|1.1.0"
    "lua_diag|lua-diag|1.0.0|1.1.0"
    "lua_report|lua-report|1.0.0|1.1.0"
)

for entry in "${PLUGINS[@]}"; do
    IFS='|' read -r src_dir plugin_name v1 v2 <<< "$entry"
    src_path="$EXAMPLES_DIR/$src_dir"
    
    if [ ! -d "$src_path" ]; then
        echo "SKIP: $src_path not found"
        continue
    fi
    
    plugin_dir="$PLUGINS_DIR/$plugin_name"
    mkdir -p "$plugin_dir"
    
    for ver in "$v1" "$v2"; do
        # 创建版本目录
        ver_dir="/tmp/pkg_${plugin_name}_${ver}"
        rm -rf "$ver_dir"
        mkdir -p "$ver_dir"
        
        # 复制插件文件
        cp "$src_path/plugin.json" "$ver_dir/"
        # 复制脚本文件(js/lua)
        for f in "$src_path"/*.js "$src_path"/*.lua; do
            [ -f "$f" ] && cp "$f" "$ver_dir/"
        done
        
        # 更新版本号
        if [ "$ver" != "$v1" ]; then
            # v1.1.0: 更新 plugin.json 中的版本
            python3 -c "
import json
with open('$ver_dir/plugin.json', 'r') as f:
    m = json.load(f)
m['version'] = '$ver'
with open('$ver_dir/plugin.json', 'w') as f:
    json.dump(m, f, ensure_ascii=False, indent=2)
"
        fi
        
        # 创建 README
        cat > "$ver_dir/README.md" << REOF
# $plugin_name v$ver

测试插件,用于验证 BPLC 插件系统。

## 版本历史

- v$ver: 当前版本
REOF
        
        # 打包为 zip
        zip_name="${plugin_name}-${ver}.zip"
        (cd "$ver_dir" && zip -q -r "$plugin_dir/$zip_name" .)
        
        # 计算 SHA256
        sha256=$(sha256sum "$plugin_dir/$zip_name" | cut -d' ' -f1)
        echo "$plugin_name v$ver: $sha256"
        echo "$sha256" > "$plugin_dir/${zip_name}.sha256"
        
        rm -rf "$ver_dir"
    done
done

echo ""
echo "All packages created in $PLUGINS_DIR"
ls -la "$PLUGINS_DIR"/*/
