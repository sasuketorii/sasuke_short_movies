#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/draft.sh <slug|clean-path> [--date YYYY-MM-DD]
# Creates 03_原稿/<slug>_YYYY-MM-DD[-vN].md based on templates/manuscript.md

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
. "$HERE/lib.sh"

INPUT=${1:-}
DATE_OUT=${2:-}

if [[ -z "$INPUT" ]]; then
  echo "Usage: scripts/draft.sh <slug|clean-path> [--date YYYY-MM-DD]" >&2
  exit 1
fi

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

if [[ -f "$INPUT" ]]; then
  SRC_PATH=$INPUT
elif [[ -f "$ROOT/$INPUT" ]]; then
  SRC_PATH=$ROOT/$INPUT
else
  CAND=$(find_latest_by_slug "$ROOT/02_クリーン" "$INPUT")
  if [[ -n "$CAND" ]]; then
    SRC_PATH=$CAND
  fi
fi

if [[ -z "$SRC_PATH" ]]; then
  echo "Clean file for slug/path not found: $INPUT" >&2
  exit 1
fi

read -r SLUG_BARE TITLE < <(slug_title_from_file "$SRC_PATH")
TAGS_LINE=$(fm_get "$SRC_PATH" tags | tr -d '[]')

OUT_DIR="$ROOT/03_原稿"
mkdir -p "$OUT_DIR"
OUT_PATH=$(next_path "$OUT_DIR" "$DATE_OUT" "$SLUG_BARE")

TAGS_LINE=$(echo "$TAGS_LINE" | sed -E 's/[ ,]+/, /g')

LEAD="TODO: 読者の価値を120字前後で要約してください。"

if [[ -f "$ROOT/templates/manuscript.md" ]]; then
  sed -e "s/{{TITLE}}/${TITLE}/g" \
      -e "s/{{DATE}}/${DATE_OUT}/g" \
      -e "s/{{SLUG}}/${SLUG_BARE}/g" \
      -e "s/{{TAGS}}/${TAGS_LINE}/g" \
      -e "s/{{LEAD}}/${LEAD}/g" \
      "$ROOT/templates/manuscript.md" > "$OUT_PATH"
else
  cat > "$OUT_PATH" <<EOF
---
title: ${TITLE}
slug: ${SLUG_BARE}_${DATE_OUT}
phase: manuscript
status: draft
tags: [${TAGS_LINE}]
created: ${DATE_OUT}
updated: ${DATE_OUT}
source: ""
---

${LEAD}

## 見出し1
段落冒頭に主張の要約文。続けて根拠→例→補足の順。

## 見出し2

---
## 3行サマリ
- 
- 
- 

## 次の一歩（行動喚起）
- 
EOF
fi

# Fix source path to clean file
SRC_REL=$(python3 - <<PY
import os
root=os.path.abspath("$ROOT")
src=os.path.abspath("$SRC_PATH")
print(os.path.relpath(src, root))
PY
)

if command -v gsed >/dev/null 2>&1; then
  gsed -i "s|^source:.*$|source: ${SRC_REL}|" "$OUT_PATH"
else
  sed -i '' -e "s|^source:.*$|source: ${SRC_REL}|" "$OUT_PATH"
fi

echo "$OUT_PATH"

# Optionally update index
if [[ -x "$ROOT/scripts/gen_index.sh" ]]; then
  "$ROOT/scripts/gen_index.sh" >/dev/null || true
fi
