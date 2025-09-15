#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/research.sh <slug|path|topic> [--date YYYY-MM-DD]
# Creates 02_クリーン/YYYY-MM-DD_<slug>[ -vN].md based on templates/clean.md
# - If input is a path or slug that matches a memo, sets source to that memo path
# - If input is a free topic, source will be empty

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
. "$HERE/lib.sh"

INPUT=${1:-}
DATE_OUT=${2:-}

if [[ -z "$INPUT" ]]; then
  echo "Usage: scripts/research.sh <slug|path|topic> [--date YYYY-MM-DD]" >&2
  exit 1
fi

# Optional date flag
if [[ "$DATE_OUT" == "--date" ]]; then
  DATE_OUT=${3:-}
  if [[ -z "$DATE_OUT" ]]; then
    echo "--date requires YYYY-MM-DD" >&2
    exit 1
  fi
else
  DATE_OUT=$(date +%F)
fi

SRC_PATH=""
SLUG_BARE=""
TITLE=""
TAGS_LINE=""

# Determine mode: path, slug, or topic
if [[ -f "$INPUT" ]]; then
  SRC_PATH=$INPUT
elif [[ -f "$ROOT/$INPUT" ]]; then
  SRC_PATH=$ROOT/$INPUT
fi

if [[ -n "$SRC_PATH" ]]; then
  read -r SLUG_BARE TITLE < <(slug_title_from_file "$SRC_PATH")
  TAGS_LINE=$(fm_get "$SRC_PATH" tags | tr -d '[]')
else
  # Try resolve slug from memo dir
  CAND=$(find_latest_by_slug "$ROOT/01_メモ" "$INPUT")
  if [[ -n "$CAND" ]]; then
    SRC_PATH=$CAND
    read -r SLUG_BARE TITLE < <(slug_title_from_file "$SRC_PATH")
    TAGS_LINE=$(fm_get "$SRC_PATH" tags | tr -d '[]')
  else
    # Treat as topic
    SLUG_BARE=$(slugify_bare "$INPUT")
    TITLE="$INPUT"
  fi
fi

OUT_DIR="$ROOT/02_クリーン"
mkdir -p "$OUT_DIR"
OUT_PATH=$(next_path "$OUT_DIR" "$DATE_OUT" "$SLUG_BARE")

TAGS_LINE=$(echo "$TAGS_LINE" | sed -E 's/[ ,]+/, /g')

if [[ -f "$ROOT/templates/clean.md" ]]; then
  sed -e "s/{{TITLE}}/${TITLE}/g" \
      -e "s/{{DATE}}/${DATE_OUT}/g" \
      -e "s/{{SLUG}}/${SLUG_BARE}/g" \
      -e "s/{{TAGS}}/${TAGS_LINE}/g" \
      "$ROOT/templates/clean.md" > "$OUT_PATH"
else
  cat > "$OUT_PATH" <<EOF
---
title: ${TITLE}
slug: ${DATE_OUT}_${SLUG_BARE}
phase: clean
status: draft
tags: [${TAGS_LINE}]
created: ${DATE_OUT}
updated: ${DATE_OUT}
source: ""
---

# 一文サマリ
> 読者の利得が一目で分かる1文を書きます。

## 目的・読者
- 目的：
- 読者：

## 要点（最大5つ）
1.
2.

## 本文構成
### 主張

### 根拠（出典つき）

### 具体例

### 反論・限界

### 未解決/要確認
- 誰が / 何を / どこで / いつまで

---
## 参考URL（必ず一次情報を優先）
- [タイトル — ドメイン](URL)
EOF
fi

# Fix source path if memo was found
if [[ -n "${SRC_PATH}" ]]; then
  # make SRC relative to repo root
  SRC_REL=$(python3 - <<PY
import os,sys
root=os.path.abspath("$ROOT")
src=os.path.abspath("$SRC_PATH")
print(os.path.relpath(src, root))
PY
)
  # Replace source line
  if command -v gsed >/dev/null 2>&1; then
    gsed -i "s|^source:.*$|source: ${SRC_REL}|" "$OUT_PATH"
  else
    sed -i '' -e "s|^source:.*$|source: ${SRC_REL}|" "$OUT_PATH"
  fi
fi

echo "$OUT_PATH"

# Optionally update index
if [[ -x "$ROOT/scripts/gen_index.sh" ]]; then
  "$ROOT/scripts/gen_index.sh" >/dev/null || true
fi

