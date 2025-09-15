#!/usr/bin/env bash
set -euo pipefail

# Common helpers for sasuke_short workflow

# slugify keeping Japanese chars, lowercasing ASCII
slugify_bare() {
  local input=${1:-}
  echo "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9一-龯ぁ-んァ-ンー]+/-/g' \
    | sed -E 's/^-+|-+$//g'
}

# Extract a simple YAML front-matter field value from first 80 lines
fm_get() {
  local file=$1
  local key=$2
  head -n 80 "$file" | sed -n "s/^${key}:[[:space:]]*\(.*\)$/\1/p" | head -n1
}

# Determine next available filename; appends -vN if needed
# Args: base_dir, date(YYYY-MM-DD), slug_bare
next_path() {
  local dir=$1
  local date=$2
  local slug=$3
  local base="${dir}/${date}_${slug}.md"
  if [[ ! -e "$base" ]]; then
    echo "$base"
    return 0
  fi
  local n=2
  while true; do
    local cand="${dir}/${date}_${slug}-v${n}.md"
    if [[ ! -e "$cand" ]]; then
      echo "$cand"
      return 0
    fi
    n=$((n+1))
  done
}

# Find latest file for slug in a directory (by date + lexicographic)
# Args: dir, slug_bare
find_latest_by_slug() {
  local dir=$1
  local slug=$2
  local latest
  latest=$(ls -1 "${dir}"/*_"${slug}"*.md 2>/dev/null | sort -r | head -n1 || true)
  echo "$latest"
}

# Resolve slug_bare and title from a source file
# Echos: slug_bare\tTitle
slug_title_from_file() {
  local src=$1
  local slug_field title_field fname slug_from_fname
  slug_field=$(fm_get "$src" slug | tr -d '"')
  title_field=$(fm_get "$src" title | sed -E 's/^"|"$//g')
  fname=$(basename "$src" .md)
  slug_from_fname=${fname#*_}
  local slug_bare
  if [[ -n "$slug_field" ]]; then
    slug_bare=${slug_field#*_}
  else
    slug_bare=$slug_from_fname
  fi
  local title="$title_field"
  if [[ -z "$title" ]]; then
    # fallback to first H1
    title=$(sed -n 's/^# \(.*\)$/\1/p' "$src" | head -n1)
  fi
  echo -e "${slug_bare}\t${title}"
}

