#!/bin/bash
# 为 3 个测试插件制作多版本发布包
set -e

MARKET_DIR="$(cd "$(dirname "$0")" && pwd)"
EXAMPLES_DIR="$HOME/workspace/HPLC_Wireshark/src/plugin/examples"
PLUGINS_DIR="$MARKET_DIR/plugins"

mkdir -p "$PLUGINS_DIR"

# 插件列表: 目录名|插件名|版本1|版本2
PLUGINS=(
    "js_topo|js-topo|1.0.0|1.1.0"
    "lua_diag|lua-diag|1.0.0|1.1.0"
    "lua_report|lua-report|1.0.0|1.1.0"
)

# ---- native 插件:cpp-coverage(需编译出各平台动态库) ----
# 约定:构建产物目录 $BUILD_TMP/cpp_coverage-<ver>/ 下含 plugin.json + 平台库
build_native_cpp_coverage() {
    local ver="$1" out_dir="$2"
    local src_path="$EXAMPLES_DIR/cpp_coverage"
    local build_dir="/tmp/natbuild_cpp_coverage_${ver}"
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    local qmake_bin=""
    if command -v qmake6 >/dev/null 2>&1; then qmake_bin=qmake6;
    elif command -v qmake >/dev/null 2>&1; then qmake_bin=qmake; fi
    if [ -z "$qmake_bin" ]; then
        echo "SKIP native build: qmake not found" >&2
        return 1
    fi
    (cd "$build_dir" && "$qmake_bin" "$src_path/cpp_coverage.pro" CONFIG+=release >/dev/null \
        && make -j"$(nproc)" >/dev/null) || return 1
    mkdir -p "$out_dir"
    # Linux 产物
    if [ -f "$build_dir/libcpp_coverage.so" ]; then
        cp "$build_dir/libcpp_coverage.so" "$out_dir/"
        # 注入 Linux ABI(Qt 大版本 + gcc, 与 plugin_host_abi() 一致),
        # 覆盖源码 plugin.json 里可能的旧值
        local qt_ver qt_major
        qt_ver=$("$qmake_bin" -query QT_VERSION 2>/dev/null)
        qt_major=${qt_ver%%.*}
        if [ -n "$qt_major" ]; then
            python3 - "$src_path/plugin.json" "$out_dir/plugin.json" "qt${qt_major}-gcc-x64" <<'EOF'
import json, sys
src, dst, abi = sys.argv[1], sys.argv[2], sys.argv[3]
d = json.load(open(src))
d["abi"] = abi
json.dump(d, open(dst, "w"), ensure_ascii=False, indent=2)
print(f"linux abi injected: {abi}", file=sys.stderr)
EOF
        else
            cp "$src_path/plugin.json" "$out_dir/"
        fi
    else
        cp "$src_path/plugin.json" "$out_dir/"
    fi
    rm -rf "$build_dir"
    return 0
}

# Windows 预编译 dll 捆入(本机无法交叉编译 Qt 插件):
# CPP_COVERAGE_WIN_DLL 指向已编好的 cpp_coverage.dll( CI / Windows 真机产物),
# 为空则只打 Linux 包。包内可同时含 .so + .dll,feed 平台自动推断。
bundle_win_dll() {
    local out_dir="$1"
    if [ -n "$CPP_COVERAGE_WIN_DLL" ] && [ -f "$CPP_COVERAGE_WIN_DLL" ]; then
        cp "$CPP_COVERAGE_WIN_DLL" "$out_dir/cpp_coverage.dll"
        echo "bundled windows dll: $CPP_COVERAGE_WIN_DLL" >&2
    fi
}

package_cpp_coverage() {
    local ver="${1:-1.0.0}"
    local plugin_name="cpp-coverage"
    local plugin_dir="$PLUGINS_DIR/$plugin_name"
    mkdir -p "$plugin_dir"
    local ver_dir="/tmp/pkg_${plugin_name}_${ver}"
    rm -rf "$ver_dir"
    mkdir -p "$ver_dir"
    if ! build_native_cpp_coverage "$ver" "$ver_dir"; then
        echo "SKIP: $plugin_name native build failed"
        rm -rf "$ver_dir"
        return 1
    fi
    if [ ! -f "$ver_dir/libcpp_coverage.so" ] && [ ! -f "$ver_dir/cpp_coverage.dll" ]; then
        echo "SKIP: $plugin_name no binary produced"
        rm -rf "$ver_dir"
        return 1
    fi
    # 多平台:捆入 Windows 预编译 dll(若提供)
    bundle_win_dll "$ver_dir"
    # README
    if [ -f "$MARKET_DIR/readme/$plugin_name.md" ]; then
        cp "$MARKET_DIR/readme/$plugin_name.md" "$ver_dir/README.md"
    fi
    local zip_name="${plugin_name}-${ver}.zip"
    (cd "$ver_dir" && zip -q -r "$plugin_dir/$zip_name" .)
    local sha256
    sha256=$(sha256sum "$plugin_dir/$zip_name" | cut -d' ' -f1)
    echo "$plugin_name v$ver: $sha256"
    echo "$sha256" > "$plugin_dir/${zip_name}.sha256"
    rm -rf "$ver_dir"
}

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
        
        # 创建 README:优先用市场仓库 readme/<插件名>.md,缺失则生成桩
        if [ -f "$MARKET_DIR/readme/$plugin_name.md" ]; then
            cp "$MARKET_DIR/readme/$plugin_name.md" "$ver_dir/README.md"
        else
            cat > "$ver_dir/README.md" << REOF
# $plugin_name v$ver

测试插件,用于验证 BPLC 插件系统。

## 版本历史

- v$ver: 当前版本
REOF
        fi
        
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
echo "--- native plugins ---"
package_cpp_coverage 1.1.0 || echo "cpp-coverage packaging skipped"

echo ""
echo "All packages created in $PLUGINS_DIR"
ls -la "$PLUGINS_DIR"/*/
