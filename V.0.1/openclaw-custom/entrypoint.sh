#!/bin/sh
# First-run bootstrap for OpenClaw. Idempotent: runs once per state volume.
set -eu

STATE_DIR="/home/node/.openclaw"
MARKER="$STATE_DIR/.bootstrap-done"
MODEL="${OPENCLAW_DEFAULT_MODEL}"
HOST_PORT="${OPENCLAW_GATEWAY_PORT}"

if [ ! -f "$MARKER" ]; then
  echo "[bootstrap] first run: applying gateway config"
  openclaw config set --batch-json '[
    {"path":"gateway.mode","value":"local"},
    {"path":"gateway.bind","value":"lan"},
    {"path":"gateway.controlUi.allowedOrigins","value":["http://localhost:'"$HOST_PORT"'","http://127.0.0.1:'"$HOST_PORT"'"]}
  ]'

  openclaw config set memory.search.enabled false

  # Only set the model if a provider is already configured (onboarding done)
  if openclaw models status >/dev/null 2>&1; then
    openclaw models set "$MODEL" || echo "[bootstrap] models set failed; set it manually"
  fi
  touch "$MARKER"
  echo "[bootstrap] done"
fi

# Hand off to the image's original entrypoint (keeps its doctor/migration step)
if [ -n "${ORIG_ENTRYPOINT:-}" ]; then
  exec $ORIG_ENTRYPOINT "$@"
fi
exec "$@"