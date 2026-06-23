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
| [md-to-pdf](md-to-pdf/) | 把 markdown 报告导出成统一样式的 PDF（钢蓝结构色、CJK 字体、A4 排版、自动内联图片、底部页码） | `pandoc`、Chrome/Chromium、`pip install pypdf reportlab`；Linux 需 CJK 字体 `apt install fonts-noto-cjk` |

各 skill 的详细用法与依赖见其目录下的 `SKILL.md`。脚本跨平台（macOS / Linux / Windows），在 Linux 上会自动适配 Chrome 二进制名并加 `--no-sandbox`。

## 新增一个 skill

在仓库根新建一个目录，放入 `SKILL.md`（必含 frontmatter 的 `name` / `description`）即可被 `install.sh` 识别。

## License

[MIT](LICENSE)
