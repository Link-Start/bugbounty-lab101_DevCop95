#!/bin/bash
# ============================================
# Threat Intel Real-Time Monitor
# ============================================
# Monitorea el feed cada N minutos y alerta
# sobre nuevas amenazas
# ============================================

FEED_URL="https://raw.githubusercontent.com/DevCop95/cYHBernews/refs/heads/main/noticias.json"
CHECK_INTERVAL=${1:-3600}  # Default: 1 hora
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
    # Obtener feed actual
    CURRENT=$(curl -s "$FEED_URL" | jq '.[0].id')
    
    # Verificar último check
    if [ -f "$LAST_CHECK" ]; then
        LAST=$(cat "$LAST_CHECK")
    else
        LAST=$CURRENT
        echo "$CURRENT" > "$LAST_CHECK"
    fi
    
    if [ "$CURRENT" != "$LAST" ]; then
        echo -e "${RED}[!] NUEVAS AMENAZAS DETECTADAS${NC}"
        echo ""
        
        # Obtener artículos nuevos
        curl -s "$FEED_URL" | jq -r "
            [.[] | select(.id > $LAST)] | 
            sort_by(.severidad) | reverse |
            .[] |
            \"\(.severidad | if . == \"CRITICA\" then \"🔴\" elif . == \"ALTA\" then \"🟠\" elif . == \"MEDIA\" then \"🟡\" else \"🟢\" end) [\(.severidad)] \(.titulo)\n   \(.resumen[0:150])...\n   Fuente: \(.fuente)\n\"
        "
        
        echo "$CURRENT" > "$LAST_CHECK"
        
        # Guardar en log
        curl -s "$FEED_URL" | jq -r "
            [.[] | select(.id > $LAST)] |
            .[] |
            \"\(.fecha) [\(.severidad)] \(.titulo)\"
        " >> "$DATA_DIR/alerts.log"
        
        return 0
    else
        echo -e "${GREEN}[✓] Sin nuevas amenazas ($(date '+%H:%M:%S'))${NC}"
        return 1
    fi
}

# Bucle principal
while true; do
    check_for_new_threats
    sleep "$CHECK_INTERVAL"
done
