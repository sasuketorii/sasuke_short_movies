#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/new_memo.sh "タイトル" [tags comma separated]

TITLE=${1:-}
if [[ -z "${TITLE}" ]]; then
  echo "Usage: scripts/new_memo.sh \"タイトル\" [tags]" >&2
  exit 1
fi

RAW_TAGS=${2:-}
DATE=$(date +%F)

# slugify: lower, spaces/symbols -> hyphen, trim hyphens
SLUG_BARE=$(echo "$TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9一-龯ぁ-んァ-ンー]+/-/g' \
  | sed -E 's/^-+|-+$//g')

SLUG_FILE="${DATE}_${SLUG_BARE}"
DIR="01_メモ"
FILE_PATH="${DIR}/${SLUG_FILE}.md"

mkdir -p "$DIR"

if [[ -f "$FILE_PATH" ]]; then
  echo "File already exists: $FILE_PATH" >&2
  exit 1
fi

TAGS_LINE=""
if [[ -n "$RAW_TAGS" ]]; then
  # convert comma/space separated to YAML array string
  TMP=$(echo "$RAW_TAGS" | sed -E 's/[ ,]+/, /g')
  TAGS_LINE="$TMP"
fi

if [[ -f templates/memo.md ]]; then
  sed -e "s/{{TITLE}}/${TITLE}/g" \
      -e "s/{{DATE}}/${DATE}/g" \
      -e "s/{{SLUG}}/${SLUG_BARE}/g" \
      -e "s/{{TAGS}}/${TAGS_LINE}/g" \
      templates/memo.md > "$FILE_PATH"
else
  cat > "$FILE_PATH" <<EOF
---
title: ${TITLE}
slug: ${SLUG_FILE}
phase: memo
status: draft
tags: [${TAGS_LINE}]
created: ${DATE}
updated: ${DATE}
source: ""
---

# ${TITLE}

## メモ
- 

## 出典URL
- 

## 気づき
- 
EOF
fi

echo "$FILE_PATH"

