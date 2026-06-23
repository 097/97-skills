---
name: md-to-pdf
description: 把 markdown 报告导出成带统一样式的 PDF（单一钢蓝结构色，正文靠字重/斜体/等宽字区分，PingFang 中文字体，A4 排版，自动内联图片）。当用户要把 .md 文档转 PDF、导出报告 PDF、或说"用这套风格/同样配色出 PDF"时使用。
license: MIT
metadata:
  author: sphinxdwood
  version: "1.0"
---

# md-to-pdf：markdown 导出带样式 PDF

把 markdown 渲染成排版精致的 PDF，配色与字体固定为一套已验证好读的方案。

## 适用场景

- 用户要把某个 `.md`（分析报告、复盘、寻优报告等）导出成 PDF
- 用户说"用这套风格 / 同样配色 / 之前那套样式"出 PDF
- 需要中文显示正常、表格/代码块/图片都排版整齐的 PDF

## 依赖

跨平台（macOS / Linux / Windows），脚本会自动适配：

- **pandoc** — macOS `brew install pandoc`；Debian/Ubuntu `apt install pandoc`。
- **Chrome / Chromium**（headless 打印）— 脚本按 macOS 固定路径优先，其次在 PATH 里依次找 `google-chrome` / `google-chrome-stable` / `chromium` / `chromium-browser` / `chrome`。Linux（含 root/容器/CI）会自动加 `--no-sandbox`。
- **中文字体** — macOS 自带 PingFang SC / Hiragino Sans GB，无需安装；Linux 需装 CJK 字体，否则中文显示为 ☐ 豆腐块：`apt install fonts-noto-cjk`。CSS 已配好兜底链（PingFang → Noto Sans CJK → 微软雅黑 → 文泉驿）。
- **`pypdf` + `reportlab`**（`pip install pypdf reportlab`）：底部叠加页码用；缺库时自动跳过页码，PDF 仍正常生成。

## 用法

一行命令（推荐）：

```bash
bash ~/.claude/skills/md-to-pdf/scripts/md2pdf.sh <input.md> [output.pdf]
```

- **输出文件名**：未显式指定第二个参数时，脚本取 markdown 第一个一级标题（`# ...`）作文件名（输出到 md 所在目录），取不到 H1 才回退源文件原名。标题里的空格与非法字符（`/ \ : * ? " < > |`）一律替换为下划线 `_`。想要别的名字，直接把目标路径作为第二个参数传入即可。
- markdown 里的相对路径图片（如 `images/foo.png`）以 **md 所在目录**解析，会被内联进 PDF，无需手动处理。

示例：

```bash
# report.md 的 H1 是「月度复盘」
bash ~/.claude/skills/md-to-pdf/scripts/md2pdf.sh report.md
# -> 月度复盘.pdf  （按标题命名，空格转下划线，输出到 md 同目录）

# 显式指定输出名则不走标题
bash ~/.claude/skills/md-to-pdf/scripts/md2pdf.sh report.md /tmp/out.pdf
```

## 样式说明（assets/report.css）

- **标题**：深板岩蓝 `#223042`（h1/h2 文字，更"董事会"可信）；**结构线/表头**：钢蓝 `#2f6f9f`（h1 下边框、h2 左竖条、表头底色），深浅同系拉层次。
- **强调**：`**加粗**` = 正文同色 + 半粗字重（600，不加黑），纯靠字重轻量突出（中文小字号 700 会结块发糊，故用 600）；`*斜体*` 靠字形区分。正文不用彩色强调。
- **引用块**：淡蓝底（`#eef4f9`），适合放摘要/速览。
- **代码**：行内码正文同色 `#2b2f36` + 浅灰底（靠等宽字 + 底色区分，不上色）；代码块深色主题（`#1f2933`）。
- **表格**：蓝色表头 + 斑马纹（偶数行浅蓝底）。
- **图片**：限宽 + 细边框，`page-break-inside: avoid` 防跨页割裂。
- **页码**：每页底部居中「X / N」灰色小字（Chrome 不支持 CSS 页码，由 `add_page_numbers.py` 后处理叠加）。
- 正文中文字体走跨平台兜底链（macOS PingFang SC / Linux Noto Sans CJK / Windows 微软雅黑），10.5pt，行距 1.7，A4（18mm/16mm 边距）。
- 已加 `print-color-adjust: exact`，确保打印时背景色/表头色不被去掉。

要调配色，直接改 `assets/report.css` 即可，全部报告自动跟随。

## 实现要点（手动复刻时）

脚本本质是三步，必要时可手动执行：

```bash
# 1. markdown -> 自包含 HTML（--embed-resources 内联图片+CSS；--resource-path 指向 md 目录解析相对图片）
pandoc input.md -f markdown -t html5 --standalone --embed-resources --metadata title="" \
  --resource-path="$(dirname input.md)" -c ~/.claude/skills/md-to-pdf/assets/report.css -o /tmp/r.html
# 2. Chrome headless 打印为 PDF（Linux 上把 chrome 换成 google-chrome/chromium，并加 --no-sandbox）
chrome --headless --disable-gpu --no-pdf-header-footer --print-to-pdf=output.pdf "file:///tmp/r.html"
```

导出后建议用 Read 工具看一眼 PDF 首页和含图片/表格的页，确认渲染正常。
