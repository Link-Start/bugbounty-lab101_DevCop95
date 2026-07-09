#!/bin/bash
# ============================================
# common.sh — Shared library for auto-scanner
# ============================================
# Source this file from any script:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
# or from within lib/:
#   source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
# ============================================

# Version
BB_VERSION="1.1"

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ── Logging ─────────────────────────────────────────────────────────
log_info()    { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; }
log_action()  { echo -e "${BLUE}[→]${NC} $1"; }
log_tool()    { echo -e "${WHITE}[⚙]${NC} Using: $1"; }

# ── Domain parsing ──────────────────────────────────────────────────
# Usage: DOMAIN=$(parse_domain "https://example.com/path")
parse_domain() {
    echo "$1" | sed -E 's|^https?://||' | sed 's|/.*||' | sed 's|:.*||'
}

# Usage: PROTOCOL=$(parse_protocol "https://example.com")
parse_protocol() {
    echo "$1" | grep -q "^https" && echo "https" || echo "http"
}

# ── Tool checking ──────────────────────────────────────────────────
# Usage: if check_tool nmap; then ... fi
check_tool() {
    command -v "$1" &>/dev/null
}

# ── Safe temporary directory ────────────────────────────────────────
# Usage: TEMP_DIR=$(safe_tmpdir "autopentest")
# Automatically registers a cleanup trap on EXIT.
safe_tmpdir() {
    local prefix="${1:-bblab}"
    local tmpdir
    tmpdir=$(mktemp -d "/tmp/${prefix}.XXXXXX")
    # Register cleanup — appends to any existing EXIT trap
    trap "rm -rf '$tmpdir'" EXIT
    echo "$tmpdir"
}

# ── Script directory resolution ─────────────────────────────────────
# Usage: SCRIPT_DIR=$(resolve_script_dir)
resolve_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")" && pwd
}

# ── Banner printer ──────────────────────────────────────────────────
print_banner() {
    local title="$1"
    local subtitle="${2:-}"
    local width=66
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    printf "║  %-62s  ║\n" "$title"
    if [ -n "$subtitle" ]; then
        printf "║  %-62s  ║\n" "$subtitle"
    fi
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ── Section printer ────────────────────────────────────────────────
print_section() {
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}
