#!/usr/bin/env bash
set -euo pipefail

# Multiplexer for project slash commands
# Usage examples:
#   scripts/sasuke.sh /memo "タイトル" "tag1,tag2"
#   scripts/sasuke.sh /research <slug|path|topic>
#   scripts/sasuke.sh /draft <slug|clean-path>

CMD=${1:-}
shift || true

case "$CMD" in
  /memo)
    exec "$(dirname "$0")/new_memo.sh" "$@"
    ;;
  /research)
    exec "$(dirname "$0")/research.sh" "$@"
    ;;
  /draft)
    exec "$(dirname "$0")/draft.sh" "$@"
    ;;
  *)
    echo "Usage: scripts/sasuke.sh /memo|/research|/draft ..." >&2
    exit 1
    ;;
esac

