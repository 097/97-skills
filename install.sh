#!/usr/bin/env bash
# install.sh -- install this repo's skills into ~/.claude/skills (symlink by default, so edits take effect immediately)
#
# Usage:
#   ./install.sh                 install all skills
#   ./install.sh md-to-pdf       install only the named skill(s)
#   ./install.sh --copy NAME     copy instead of symlink (install a standalone copy)
#   ./install.sh --force NAME    overwrite an existing target of the same name
#   ./install.sh --list          list installable skills in this repo
#
# Symlink by default: source stays in this repo, ~/.claude/skills/<name> points to it,
# so editing the source takes effect immediately with no reinstall needed.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

MODE="link"   # link | copy
FORCE=0
SKILLS=()

# Any subdirectory containing a SKILL.md is an installable skill
list_skills() {
  for d in "$REPO_DIR"/*/; do
    [ -f "${d}SKILL.md" ] && basename "$d"
  done
}

for arg in "$@"; do
  case "$arg" in
    --copy)  MODE="copy" ;;
    --link)  MODE="link" ;;
    --force) FORCE=1 ;;
    --list)  list_skills; exit 0 ;;
    -h|--help) sed -n '2,11p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown option: $arg" >&2; exit 2 ;;
    *)  SKILLS+=("$arg") ;;
  esac
done

# No specific skill given: install all
if [ "${#SKILLS[@]}" -eq 0 ]; then
  while IFS= read -r s; do SKILLS+=("$s"); done < <(list_skills)
fi
[ "${#SKILLS[@]}" -gt 0 ] || { echo "No installable skills in this repo (missing SKILL.md)" >&2; exit 1; }

mkdir -p "$DEST_DIR"

for name in "${SKILLS[@]}"; do
  src="$REPO_DIR/$name"
  dst="$DEST_DIR/$name"

  if [ ! -f "$src/SKILL.md" ]; then
    echo "x ${name}: source dir missing or no SKILL.md ($src)" >&2
    continue
  fi

  # Target already exists: skip idempotently if it's a symlink already pointing at this source; otherwise need --force
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ] && [ "$MODE" = "link" ]; then
      echo "= ${name}: already linked, skipping"
      continue
    fi
    if [ "$FORCE" -ne 1 ]; then
      echo "x ${name}: $dst already exists (use --force to overwrite)" >&2
      continue
    fi
    rm -rf "$dst"
  fi

  if [ "$MODE" = "link" ]; then
    ln -s "$src" "$dst"
    echo "-> ${name}: symlinked $dst -> $src"
  else
    cp -R "$src" "$dst"
    echo "copied ${name}: to $dst"
  fi
done
