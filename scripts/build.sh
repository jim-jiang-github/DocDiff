#!/usr/bin/env bash
# DocDiff 构建脚本
#
# 用途：把纯静态站点整理成可发布的 dist/ 目录，并把版本号写入页脚与 version.json。
# 用法：
#   bash scripts/build.sh            # 本地构建，版本标记为 dev
#   bash scripts/build.sh v0.0.1     # 构建指定版本（v 前缀可省略）
set -euo pipefail

VERSION="${1:-dev}"
VERSION="${VERSION#v}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/dist"

# 版本号只允许语义化版本，避免把奇怪的东西写进产物
if [ "$VERSION" != "dev" ] && ! [[ "$VERSION" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z]+(\.[0-9A-Za-z]+)*)?$ ]]; then
  echo "✗ 版本号不合法：$VERSION（应形如 0.0.1 或 0.2.0-beta.1）" >&2
  exit 1
fi

REQUIRED_LIBS=(
  mammoth.browser.min.js
  pdf.min.js
  pdf.worker.min.js
  jszip.min.js
  docx-preview.min.js
)
for f in "${REQUIRED_LIBS[@]}"; do
  if [ ! -s "$ROOT/lib/$f" ]; then
    echo "✗ 缺少依赖文件：lib/$f" >&2
    exit 1
  fi
done

if [ ! -s "$ROOT/index.html" ]; then
  echo "✗ 缺少 index.html" >&2
  exit 1
fi

rm -rf "$DIST"
mkdir -p "$DIST/lib"

cp "$ROOT/index.html" "$DIST/index.html"
cp "$ROOT/favicon.ico" "$DIST/favicon.ico"
cp "$ROOT/LICENSE" "$DIST/LICENSE"
cp -R "$ROOT/lib/." "$DIST/lib/"
# 以 Actions 方式部署 Pages 时用不到，但手工推到分支时能避免 Jekyll 处理
: > "$DIST/.nojekyll"

# 注入版本号：index.html 中预留了 <span id="appVer">dev</span>
if [ "$VERSION" != "dev" ]; then
  TMP="$DIST/index.html.tmp"
  sed "s|id=\"appVer\">dev<|id=\"appVer\">v${VERSION}<|" "$DIST/index.html" > "$TMP"
  mv "$TMP" "$DIST/index.html"
  if ! grep -q "id=\"appVer\">v${VERSION}<" "$DIST/index.html"; then
    echo "✗ 版本号注入失败：index.html 中未找到 <span id=\"appVer\">dev</span> 占位符" >&2
    exit 1
  fi
fi

cat > "$DIST/version.json" <<JSON
{
  "name": "DocDiff",
  "version": "${VERSION}",
  "commit": "${GITHUB_SHA:-local}",
  "builtAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON

echo "✓ 构建完成：dist/（版本 ${VERSION}）"
