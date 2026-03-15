#!/usr/bin/env bash
set -euo pipefail

if [ -z "${TMUX:-}" ]; then
  echo "This launcher must be run inside a tmux session (TMUX is not set)."
  exit 1
fi

SESSION_ROOT="/Users/shunsukehayashi/dev/03-products/miso"
WATCH_CMD="cd ${SESSION_ROOT} && ./scripts/miso-tmux-monitor.sh"

tmux split-window -v "$WATCH_CMD"

echo "MISO Mission Control monitor pane opened." >&2
