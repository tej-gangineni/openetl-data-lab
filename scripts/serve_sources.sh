#!/usr/bin/env bash
# Local web server for the http / rss / website lab sources: http://127.0.0.1:8765
# Serves sources/www (index.html, feed.xml, pages/ -> downloads/web). Read-only, localhost only.
# Usage: scripts/serve_sources.sh start|stop|status
set -euo pipefail
LAB="$(cd "$(dirname "$0")/.." && pwd)"
PORT=8765
PIDFILE="$LAB/state/serve_sources.pid"
mkdir -p "$LAB/state"
running() { [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }
case "${1:-status}" in
  start)
    if running; then echo "already running (pid $(cat "$PIDFILE"))"; exit 0; fi
    nohup python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$LAB/sources/www" >"$LAB/state/serve_sources.log" 2>&1 &
    echo $! >"$PIDFILE"; sleep 1
    running && echo "started on http://127.0.0.1:$PORT (pid $(cat "$PIDFILE"))" || { echo "failed, see state/serve_sources.log"; exit 1; } ;;
  stop)
    if running; then kill "$(cat "$PIDFILE")"; rm -f "$PIDFILE"; echo stopped; else echo "not running"; fi ;;
  status)
    if running; then echo "running on http://127.0.0.1:$PORT (pid $(cat "$PIDFILE"))"; else echo "not running"; fi ;;
  *) echo "usage: $0 start|stop|status"; exit 2 ;;
esac
