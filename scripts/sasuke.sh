#!/usr/bin/env bash
set -euo pipefail

# Multiplexer for project slash commands
# Usage examples:
#   scripts/sasuke.sh /memo "タイトル" "tag1,tag2"
#   scripts/sasuke.sh /research <slug|path|topic>
#   scripts/sasuke.sh /draft <slug|clean-path>
#   scripts/sasuke.sh /ship "タイトル" "tag1,tag2"
#   scripts/sasuke.sh /onepass <slug|memo-path>
#   scripts/sasuke.sh /update-index
#   scripts/sasuke.sh /validate

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
  /ship)
    exec "$(dirname "$0")/ship.sh" "$@"
    ;;
  /onepass)
    exec "$(dirname "$0")/onepass.sh" "$@"
    ;;
  /update-index)
    exec "$(dirname "$0")/gen_index.sh" "$@"
    ;;
  /validate)
    exec "$(dirname "$0")/validate_front_matter.sh" "$@"
    ;;
  *)
    echo "Usage: scripts/sasuke.sh /memo|/research|/draft|/ship|/onepass|/update-index|/validate ..." >&2
    exit 1
    ;;
esac
