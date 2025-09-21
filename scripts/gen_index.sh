#!/usr/bin/env bash
set -euo pipefail

OUT="INDEX.md"

echo "# INDEX" > "$OUT"
echo "" >> "$OUT"
echo "| Title | Phase | Status | Path | Date |" >> "$OUT"
echo "|---|---|---|---|---|" >> "$OUT"

shopt -s nullglob
FILES=(01_メモ/*.md 02_クリーン/*.md 03_原稿/*.md)
for f in "${FILES[@]}"; do
  # Read first 60 lines for front matter fields
  head -n 60 "$f" > .index_tmp
  TITLE=$(sed -n 's/^title:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
  PHASE=$(sed -n 's/^phase:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
  STATUS=$(sed -n 's/^status:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
  # Extract date from filename regardless of position
  DATE=$(basename "$f" .md | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n1)
  if [[ -z "$DATE" ]]; then
    DATE=$(sed -n 's/^created:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
  fi
  rm -f .index_tmp

  # Escape pipes in title for markdown table
  TITLE_ESC=${TITLE//|/\\|}
  TITLE_WITH_DATE="${TITLE_ESC} — ${DATE}"
  echo "| ${TITLE_WITH_DATE} | ${PHASE} | ${STATUS} | ${f} | ${DATE} |" >> "$OUT"
done

echo "Updated ${OUT}" >&2

# Append Knowledge section if any
if ls knowledge/*.md >/dev/null 2>&1; then
  {
    echo ""
    echo "## Knowledge"
    echo ""
    echo "| Title | Path | Date |"
    echo "|---|---|---|"
  } >> "$OUT"

  for f in knowledge/*.md; do
    head -n 40 "$f" > .index_tmp
    TITLE=$(sed -n 's/^title:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
    DATE=$(basename "$f" .md | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n1)
    if [[ -z "$DATE" ]]; then
      DATE=$(sed -n 's/^created:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
    fi
    rm -f .index_tmp
    TITLE_ESC=${TITLE//|/\\|}
    TITLE_WITH_DATE="${TITLE_ESC} — ${DATE}"
    echo "| ${TITLE_WITH_DATE} | ${f} | ${DATE} |" >> "$OUT"
  done
fi

# Append Knowledge (Human) section if any
if ls knowledge_human/*.md >/dev/null 2>&1; then
  {
    echo ""
    echo "## Knowledge (Human)"
    echo ""
    echo "| Title | Path | Date |"
    echo "|---|---|---|"
  } >> "$OUT"

  for f in knowledge_human/*.md; do
    head -n 40 "$f" > .index_tmp
    TITLE=$(sed -n 's/^title:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
    DATE=$(basename "$f" .md | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n1)
    if [[ -z "$DATE" ]]; then
      DATE=$(sed -n 's/^created:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
    fi
    rm -f .index_tmp
    TITLE_ESC=${TITLE//|/\\|}
    TITLE_WITH_DATE="${TITLE_ESC} — ${DATE}"
    echo "| ${TITLE_WITH_DATE} | ${f} | ${DATE} |" >> "$OUT"
  done
fi
