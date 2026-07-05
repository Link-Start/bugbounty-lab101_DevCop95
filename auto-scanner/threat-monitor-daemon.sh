#!/bin/bash
# ============================================
# Threat Intel Real-Time Monitor
# ============================================
# Monitors the feed every N minutes and alerts
# about new threats
# ============================================

FEED_URL="https://raw.githubusercontent.com/DevCop95/cYHBernews/refs/heads/main/noticias.json"
CHECK_INTERVAL=${1:-3600}  # Default: 1 hour
DATA_DIR="$(dirname "$0")/threat-intel"
LAST_CHECK="$DATA_DIR/last_check.json"

mkdir -p "$DATA_DIR"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  THREAT INTEL MONITOR - Intervalo: ${CHECK_INTERVAL}s${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_for_new_threats() {
    # Get current feed
    CURRENT=$(curl -s "$FEED_URL" | jq '.[0].id')
    
    # Verify last check
    if [ -f "$LAST_CHECK" ]; then
        LAST=$(cat "$LAST_CHECK")
    else
        LAST=$CURRENT
        echo "$CURRENT" > "$LAST_CHECK"
    fi
    
    if [ "$CURRENT" != "$LAST" ]; then
        echo -e "${RED}[!] NEW THREATS DETECTED${NC}"
        echo ""
        
        # Get new articles
        curl -s "$FEED_URL" | jq -r "
            [.[] | select(.id > $LAST)] | 
            sort_by(.severidad) | reverse |
            .[] |
            \"\(.severidad | if . == \"CRITICA\" then \"🔴\" elif . == \"ALTA\" then \"🟠\" elif . == \"MEDIA\" then \"🟡\" else \"🟢\" end) [\(.severidad)] \(.titulo)\n   \(.resumen[0:150])...\n   Source: \(.fuente)\n\"
        "
        
        echo "$CURRENT" > "$LAST_CHECK"
        
        # Save to log
        curl -s "$FEED_URL" | jq -r "
            [.[] | select(.id > $LAST)] |
            .[] |
            \"\(.fecha) [\(.severidad)] \(.titulo)\"
        " >> "$DATA_DIR/alerts.log"
        
        return 0
    else
        echo -e "${GREEN}[✓] No new threats ($(date '+%H:%M:%S'))${NC}"
        return 1
    fi
}

# Main loop
while true; do
    check_for_new_threats
    sleep "$CHECK_INTERVAL"
done
