#!/usr/bin/env bash
set -euo pipefail

ROOT_OPENCLAW="/Users/shunsukehayashi/.openclaw"
SESSIONS_JSON="${ROOT_OPENCLAW}/agents/main/sessions/sessions.json"
LOG_FILE="${ROOT_OPENCLAW}/logs/gateway.log"
OPENCLAW_GATEWAY="${ROOT_OPENCLAW}/openclaw.json"

# Minimal terminal dashboard for Miyabi/OpenClaw/MISO session visibility.
while true; do
  clear
  echo "🛰  Miyabi Mission Control (tmux)
"

  if command -v jq >/dev/null 2>&1; then
    if [ -f "$OPENCLAW_GATEWAY" ]; then
      port="$(jq -r '.gateway.port // "N/A"' "$OPENCLAW_GATEWAY")"
      mode="$(jq -r '.gateway.mode // "N/A"' "$OPENCLAW_GATEWAY")"
      bind="$(jq -r '.gateway.bind // "N/A"' "$OPENCLAW_GATEWAY")"
      echo "OpenClaw Gateway: mode=$mode bind=$bind port=$port"
      echo "Reactions mode: $(jq -r '.channels.telegram.reactionLevel // "not set"' "$OPENCLAW_GATEWAY")"
      echo
    else
      echo "OpenClaw config: not found"
      echo
    fi

    if [ -f "$SESSIONS_JSON" ]; then
      echo "Active sessions:"
      jq -r 'to_entries[] | "- " + .key + " | " + (.value.sessionId // "-") + " | lastTo=" + (.value.lastTo // "-") + " | updated=" + ((.value.updatedAt // 0) / 1000 | tostring) | gsub("\.[0-9]+$";"")' "$SESSIONS_JSON"
    else
      echo "Active sessions: sessions.json missing"
    fi
    echo
  else
    echo "jq is required for session parsing. Install jq and retry."
  fi

  echo "Recent OpenClaw gateway activity:"
  if [ -f "$LOG_FILE" ]; then
    tail -n 40 "$LOG_FILE" | sed -E 's/\x1b\[[0-9;]*[A-Za-z]//g'
  else
    echo "  (gateway.log not found)"
  fi

  echo "\nLast updated: $(date '+%Y-%m-%d %H:%M:%S')"
  sleep 3
done
