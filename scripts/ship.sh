#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/ship.sh "タイトル" [tags]
# Pipeline: memo -> research -> draft -> index

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)

TITLE=${1:-}
RAW_TAGS=${2:-}

if [[ -z "$TITLE" ]]; then
  echo "Usage: scripts/ship.sh \"タイトル\" [tags]" >&2
  exit 1
fi

MEMO_PATH=$("$HERE/new_memo.sh" "$TITLE" "${RAW_TAGS}")

# research from memo path (captures slug/title internally)
CLEAN_PATH=$("$HERE/research.sh" "$MEMO_PATH")

# draft from clean path
MANUSCRIPT_PATH=$("$HERE/draft.sh" "$CLEAN_PATH")

# ensure index updated (scripts already try, but run explicitly)
if [[ -x "$HERE/gen_index.sh" ]]; then
  "$HERE/gen_index.sh" >/dev/null || true
fi

echo "Created:" >&2
echo "$MEMO_PATH" >&2
echo "$CLEAN_PATH" >&2
echo "$MANUSCRIPT_PATH" >&2

printf "%s\n%s\n%s\n" "$MEMO_PATH" "$CLEAN_PATH" "$MANUSCRIPT_PATH"

