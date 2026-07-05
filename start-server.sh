#!/usr/bin/env bash
# ── T3MP3ST Server Launcher ──────────────────────────────────────────
# Starts the T3MP3ST War Room (API + UI) on http://127.0.0.1:3333/ui/
#
# Usage:
#   ./start-server.sh          # default, loopback only
#   ./start-server.sh --prod   # built JS (requires npm run build first)
#
# Requires: Node.js >= 18
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T3MP3ST_DIR="$SCRIPT_DIR/t3mp3st"

# ── Preflight checks ──
if [ ! -d "$T3MP3ST_DIR/node_modules" ]; then
    echo "[*] Installing T3MP3ST dependencies..."
    (cd "$T3MP3ST_DIR" && npm install)
fi

if [ ! -f "$T3MP3ST_DIR/.env" ]; then
    echo "[!] No .env found in t3mp3st/. Copy .env.example and fill in your API key(s)."
    echo "    cp t3mp3st/.env.example t3mp3st/.env"
    exit 1
fi

# ── Launch ──
MODE="${1:-dev}"
cd "$T3MP3ST_DIR"

if [ "$MODE" = "--prod" ] || [ "$MODE" = "prod" ]; then
    echo "[*] Starting T3MP3ST (production)..."
    npm run server:prod
else
    echo "[*] Starting T3MP3ST (dev)..."
    npm run server
fi
