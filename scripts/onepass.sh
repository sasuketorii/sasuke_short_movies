#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/onepass.sh <slug|memo-path>
# Pipeline: research -> draft (starting from an existing memo)

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)

INPUT=${1:-}
if [[ -z "$INPUT" ]]; then
  echo "Usage: scripts/onepass.sh <slug|memo-path>" >&2
  exit 1
fi

CLEAN_PATH=$("$HERE/research.sh" "$INPUT")
MANUSCRIPT_PATH=$("$HERE/draft.sh" "$CLEAN_PATH")

if [[ -x "$HERE/gen_index.sh" ]]; then
  "$HERE/gen_index.sh" >/dev/null || true
fi

echo "Created:" >&2
echo "$CLEAN_PATH" >&2
echo "$MANUSCRIPT_PATH" >&2

printf "%s\n%s\n" "$CLEAN_PATH" "$MANUSCRIPT_PATH"

