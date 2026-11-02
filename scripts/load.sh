#!/usr/bin/env bash
# download (skips what exists) -> split logs -> empty targets -> run every pipeline in pipelines/.
# Jobs run from the lab folder on purpose: a .env copied from the repo's .env.example breaks the HTTP source.
# usage: load.sh [name-filter]     e.g.  load.sh mongo_    (runs only matching pipelines, without emptying targets)
set -uo pipefail
LAB=$(cd "$(dirname "$0")/.." && pwd); [ -f "$LAB/.env" ] && set -a && . "$LAB/.env" && set +a
REPO=$(cd "$LAB" && cd "${OPENETL_REPO:-../openetl}" && pwd)
EXTRAS="--extra postgres --extra mongodb --extra clickhouse --extra elasticsearch --extra qdrant"
mkdir -p "$LAB/logs"
if [ -z "${1:-}" ]; then "$LAB/scripts/download.sh" >/dev/null; python3 "$LAB/scripts/split_logs.py" "${LINES_PER_PART:-40}" "${MAX_LOG_LINES:-200000}"; python3 "$LAB/scripts/split_json.py"; python3 "$LAB/scripts/gen_pipelines.py"; "$LAB/scripts/reset.sh"; fi
for p in "$LAB"/pipelines/*${1:-}*.toml; do
  n=$(basename "$p" .toml); s=$(date +%s)
  (cd "$LAB" && uv run --project "$REPO" $EXTRAS openetl job run "$p") >"$LAB/logs/$n.log" 2>&1
  printf '%-20s %-9s files=%s records=%s warnings=%s  %ss\n' "$n" "$(grep -oE 'COMPLETED|FAILED|PARTIAL' "$LAB/logs/$n.log" | tail -1)" \
    "$(grep -oE 'files: +[0-9]+' "$LAB/logs/$n.log" | grep -oE '[0-9]+')" "$(grep -oE 'records: +[0-9]+' "$LAB/logs/$n.log" | grep -oE '[0-9]+')" \
    "$(grep -oE 'warnings: +[0-9]+' "$LAB/logs/$n.log" | grep -oE '[0-9]+')" "$(( $(date +%s) - s ))"
done
