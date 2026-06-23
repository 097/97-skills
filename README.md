# 97-skills

一组 [Claude Code](https://claude.com/claude-code) / Claude Agent Skills，每个 skill 一个独立目录，含 `SKILL.md` + 配套脚本/资源。

## 安装

```bash
./install.sh                 # 安装全部 skill（默认软链接到 ~/.claude/skills）
./install.sh md-to-pdf       # 只装指定的一个或多个
./install.sh --copy NAME     # 用拷贝代替软链接，装一份独立副本
./install.sh --force NAME    # 覆盖已存在的同名目标
./install.sh --list          # 列出本仓库可装的 skill
```

默认走**软链接**：`~/.claude/skills/<name>` 指向本仓库对应目录，改源即时生效、无需重装。
想装到别处可设 `CLAUDE_SKILLS_DIR` 环境变量。

## Skills

| 名称 | 说明 | 额外依赖 |
|---|---|---|
| [md-to-pdf](md-to-pdf/) | 把 markdown 报告导出成统一样式的 PDF（钢蓝结构色、CJK 字体、A4 排版、自动内联图片、底部页码） | `pandoc`、Chrome/Chromium、`pypdf`、`reportlab`；Linux 另需 CJK 字体（见下） |

各 skill 的详细用法与依赖见其目录下的 `SKILL.md`。脚本跨平台（macOS / Linux / Windows），在 Linux 上会自动适配 Chrome 二进制名并加 `--no-sandbox`。

### 额外依赖安装（md-to-pdf）

四样东西：`pandoc`（markdown → HTML）、Chrome/Chromium（headless 打印 PDF）、`pypdf` + `reportlab`（叠加底部页码，可选——缺了也能出 PDF，只是没页码）、CJK 字体（中文显示，macOS 自带、Linux 需装）。

**macOS（Homebrew）**

```bash
brew install pandoc                      # markdown 转换
brew install --cask google-chrome        # 已装 Chrome 可跳过
pip3 install pypdf reportlab             # 页码（可选）
# 中文字体：macOS 自带 PingFang SC / Hiragino，无需安装
```

**Ubuntu / Debian**

```bash
sudo apt update
sudo apt install -y pandoc chromium-browser python3-pip fonts-noto-cjk
pip3 install pypdf reportlab             # 页码（可选）
```

> Ubuntu 上 Chrome 包名可能是 `chromium-browser`、`chromium` 或 `google-chrome-stable`，装其中任一即可，脚本会自动在 PATH 里识别。少数较新版本 `apt` 无 `chromium-browser` 时，可用 `sudo snap install chromium` 代替。

## 新增一个 skill

在仓库根新建一个目录，放入 `SKILL.md`（必含 frontmatter 的 `name` / `description`）即可被 `install.sh` 识别。

## License

[MIT](LICENSE)
