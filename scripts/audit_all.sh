#!/usr/bin/env bash
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)

found=0
for f in "$ROOT"/03_原稿/*.md; do
  [[ -f "$f" ]] || continue
  found=1
  echo "==> $(basename "$f")"
  "$HERE/audit_manuscript.sh" "$f" || true
  echo ""
done

if [[ $found -eq 0 ]]; then
  echo "No manuscripts to audit."
fi

