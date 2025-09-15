#!/usr/bin/env bash
set -euo pipefail

errors=0

check_file() {
  local f="$1"
  local head_tmp
  head_tmp=$(mktemp)
  head -n 60 "$f" > "$head_tmp"

  local title phase status slug created updated source
  title=$(sed -n 's/^title:[[:space:]]*\(.*\)$/\1/p' "$head_tmp" | head -n1)
  phase=$(sed -n 's/^phase:[[:space:]]*\(.*\)$/\1/p' "$head_tmp" | head -n1)
  status=$(sed -n 's/^status:[[:space:]]*\(.*\)$/\1/p' "$head_tmp" | head -n1)
  slug=$(sed -n 's/^slug:[[:space:]]*\(.*\)$/\1/p' "$head_tmp" | head -n1)
  created=$(sed -n 's/^created:[[:space:]]*\(.*\)$/\1/p' "$head_tmp" | head -n1)
  updated=$(sed -n 's/^updated:[[:space:]]*\(.*\)$/\1/p' "$head_tmp" | head -n1)
  source=$(sed -n 's/^source:[[:space:]]*\(.*\)$/\1/p' "$head_tmp" | head -n1)
  rm -f "$head_tmp"

  local rel="$f"
  local base
  base=$(basename "$f")
  local expected_slug=${base%.md}

  # Basic checks
  [[ -n "$title" ]] || { echo "[ERR] title missing: $rel"; errors=$((errors+1)); }
  [[ -n "$phase" ]] || { echo "[ERR] phase missing: $rel"; errors=$((errors+1)); }
  [[ -n "$status" ]] || { echo "[ERR] status missing: $rel"; errors=$((errors+1)); }
  [[ -n "$slug" ]] || { echo "[ERR] slug missing: $rel"; errors=$((errors+1)); }
  [[ -n "$created" ]] || { echo "[ERR] created missing: $rel"; errors=$((errors+1)); }
  [[ -n "$updated" ]] || { echo "[ERR] updated missing: $rel"; errors=$((errors+1)); }

  # Slug matches filename
  if [[ -n "$slug" && "$slug" != "$expected_slug" ]]; then
    echo "[WARN] slug differs from filename: slug=$slug file=$expected_slug ($rel)"
  fi

  # Phase-specific checks
  case "$phase" in
    memo)
      ;; # source may be empty
    clean)
      if [[ -z "$source" ]]; then echo "[ERR] clean requires source (memo path): $rel"; errors=$((errors+1)); fi
      ;;
    manuscript)
      if [[ -z "$source" ]]; then echo "[ERR] manuscript requires source (clean path): $rel"; errors=$((errors+1)); fi
      ;;
    *)
      echo "[WARN] unknown phase: $phase ($rel)"
      ;;
  esac
}

shopt -s nullglob
files=(01_メモ/*.md 02_クリーン/*.md 03_原稿/*.md knowledge/*.md)
for f in "${files[@]}"; do
  check_file "$f"
done

if [[ $errors -gt 0 ]]; then
  echo "Validation failed with $errors error(s)." >&2
  exit 1
else
  echo "All front matter looks good."
fi

