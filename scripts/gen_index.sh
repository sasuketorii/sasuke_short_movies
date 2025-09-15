#!/usr/bin/env bash
set -euo pipefail

OUT="INDEX.md"

echo "# INDEX" > "$OUT"
echo "" >> "$OUT"
echo "| Date | Title | Phase | Status | Path |" >> "$OUT"
echo "|---|---|---|---|---|" >> "$OUT"

shopt -s nullglob
FILES=(01_メモ/*.md 02_クリーン/*.md 03_原稿/*.md)
for f in "${FILES[@]}"; do
  # Read first 60 lines for front matter fields
  head -n 60 "$f" > .index_tmp
  TITLE=$(sed -n 's/^title:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
  PHASE=$(sed -n 's/^phase:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
  STATUS=$(sed -n 's/^status:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
  DATE=$(basename "$f" | cut -d'_' -f1)
  rm -f .index_tmp

  # Escape pipes in title for markdown table
  TITLE_ESC=${TITLE//|/\\|}
  echo "| ${DATE} | ${TITLE_ESC} | ${PHASE} | ${STATUS} | ${f} |" >> "$OUT"
done

echo "Updated ${OUT}" >&2

# Append Knowledge section if any
if ls knowledge/*.md >/dev/null 2>&1; then
  {
    echo ""
    echo "## Knowledge"
    echo ""
    echo "| Date | Title | Path |"
    echo "|---|---|---|"
  } >> "$OUT"

  for f in knowledge/*.md; do
    head -n 40 "$f" > .index_tmp
    TITLE=$(sed -n 's/^title:[[:space:]]*\(.*\)$/\1/p' .index_tmp | head -n1)
    DATE=$(basename "$f" | cut -d'_' -f1)
    rm -f .index_tmp
    TITLE_ESC=${TITLE//|/\\|}
    echo "| ${DATE} | ${TITLE_ESC} | ${f} |" >> "$OUT"
  done
fi
