#!/usr/bin/env bash
# md2pdf.sh —— 把 markdown 渲染成带配色样式的 PDF
# 用法: md2pdf.sh <input.md> [output.pdf]
#   不给 output 时，输出到与输入同目录的同名 .pdf
# 依赖: pandoc、Google Chrome（headless 打印）
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CSS="$SKILL_DIR/assets/report.css"

IN="${1:?用法: md2pdf.sh <input.md> [output.pdf]}"
RES_DIR="$(cd "$(dirname "$IN")" && pwd)"   # 图片相对路径以 md 所在目录解析

# 输出文件名：未显式指定时，用 markdown 第一个一级标题(# ...)作中文文件名，
# 取不到再回退英文原名。文件名里非法字符(/ \ : 等)与空格一律替换为下划线。
if [ -n "${2:-}" ]; then
  OUT="$2"
else
  TITLE="$(grep -m1 '^# ' "$IN" | sed 's/^# *//; s/[[:space:]]*$//' | tr '/\\:*?"<>| ' '__________')"
  if [ -n "$TITLE" ]; then
    OUT="$RES_DIR/$TITLE.pdf"
  else
    OUT="${IN%.md}.pdf"
  fi
fi

# 跨平台定位 Chrome/Chromium：macOS 固定路径优先，其次按常见二进制名在 PATH 里找
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$CHROME" ]; then
  CHROME=""
  for c in google-chrome google-chrome-stable chromium chromium-browser chrome; do
    if command -v "$c" >/dev/null 2>&1; then CHROME="$(command -v "$c")"; break; fi
  done
fi
[ -n "$CHROME" ] || { echo "找不到 Chrome/Chromium，无法打印 PDF" >&2; exit 1; }

# Linux（尤其 root/容器/CI）下 headless Chrome 需要 --no-sandbox，否则直接崩
CHROME_FLAGS=(--headless --disable-gpu --no-pdf-header-footer)
if [ "$(uname -s)" = "Linux" ]; then CHROME_FLAGS+=(--no-sandbox); fi

TMP_HTML="$(mktemp).html"   # 不用 -t（GNU/BSD 语义不同），裸 mktemp 两边都生成临时文件
trap 'rm -f "$TMP_HTML"' EXIT

# markdown -> 自包含 HTML（图片/CSS 全部内联，确保 PDF 不丢资源）
pandoc "$IN" \
  -f markdown -t html5 --standalone --embed-resources --metadata title="" \
  --resource-path="$RES_DIR" -c "$CSS" -o "$TMP_HTML"

# Chrome headless 打印为 PDF
"$CHROME" "${CHROME_FLAGS[@]}" \
  --print-to-pdf="$OUT" "file://$TMP_HTML" 2>/dev/null

# 底部叠加页码「X / N」(Chrome --print-to-pdf 不支持 CSS @page 计数器，故后处理)。
# 缺 pypdf/reportlab 时跳过，PDF 仍可用。
if python3 -c "import pypdf, reportlab" 2>/dev/null; then
  python3 "$SKILL_DIR/scripts/add_page_numbers.py" "$OUT" \
    || echo "（页码叠加失败，PDF 已生成但无页码）" >&2
else
  echo "（未安装 pypdf/reportlab，跳过页码：pip install pypdf reportlab）" >&2
fi

echo "已生成: $OUT"
