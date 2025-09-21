#!/usr/bin/env bash
set -euo pipefail

file=${1:-}
if [[ -z "$file" || ! -f "$file" ]]; then
  echo "Usage: scripts/audit_manuscript.sh <manuscript.md>" >&2
  exit 1
fi

# Extract after front matter
content=$(awk 'f{print} /^---[[:space:]]*$/{c++} c==2{f=1} ' "$file")

# Lead line (first non-empty)
lead=$(echo "$content" | awk 'NF{print; exit}')
lead_len=$(echo -n "$lead" | wc -m | tr -d ' ')

# Checks
score=0; max=5

# 1) Lead length ~120 (90-140)
if [[ $lead_len -ge 90 && $lead_len -le 140 ]]; then
  echo "[OK] Lead length: $lead_len"
  score=$((score+1))
else
  echo "[NG] Lead length: $lead_len (expected 90-140)"
fi

# 2) H2/H3 presence
h2=$(echo "$content" | rg -c '^## ' || true)
h3=$(echo "$content" | rg -c '^### ' || true)
if [[ ${h2:-0} -ge 2 ]]; then
  echo "[OK] H2 sections: $h2"
  score=$((score+1))
else
  echo "[NG] H2 sections: $h2 (expected >=2)"
fi

# 3) Has 3行サマリ and 次の一歩
has_sum=$(echo "$content" | rg -q '^## 3行サマリ' && echo 1 || echo 0)
has_next=$(echo "$content" | rg -q '^## 次の一歩' && echo 1 || echo 0)
if [[ $has_sum -eq 1 && $has_next -eq 1 ]]; then
  echo "[OK] Summary and Next steps present"
  score=$((score+1))
else
  echo "[NG] Summary/Next steps missing"
fi

# 4) BE tags presence
if echo "$content" | rg -q '\[(LOSS|FRAM|ANCH|CONT|SOCI|AUTH|SCAR|COMM|IMPL|GOAL|DEFLT|ZEIG|PEAK|ENDW|DECOY|MERE|VAR)\]'; then
  echo "[OK] BE tags present"
  score=$((score+1))
else
  echo "[NG] BE tags not found"
fi

# 5) Metaphor count <=1 (heuristic: count of 比喩 or 「〜みたい」)
metaphor=$(echo "$content" | rg -c '比喩|みたい|まるで' || true)
if [[ ${metaphor:-0} -le 1 ]]; then
  echo "[OK] Metaphor count: ${metaphor:-0}"
  score=$((score+1))
else
  echo "[NG] Metaphor count: ${metaphor:-0} (>1)"
fi

echo "---"
echo "Score: $score/$max"

