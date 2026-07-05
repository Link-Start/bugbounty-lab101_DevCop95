#!/bin/bash
# ============================================
# Auto-Scan Daemon - Integración Threat Intel + Auto Scanner
# ============================================
# Cuando detecta nuevos CVEs o amenazas críticas,
# ejecuta escaneos automáticos contra targets
# ============================================

set -e

# Configuración
FEED_URL="https://raw.githubusercontent.com/DevCop95/cYHBernews/refs/heads/main/noticias.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/threat-intel"
REPORT_DIR="$SCRIPT_DIR/reports"
LOG_DIR="$SCRIPT_DIR/logs"
SCAN_QUEUE="$DATA_DIR/scan_queue.json"
LAST_CHECK="$DATA_DIR/last_check_daemon.json"
CONFIG_FILE="$SCRIPT_DIR/daemon.conf"

mkdir -p "$DATA_DIR" "$REPORT_DIR" "$LOG_DIR"

# Colores
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuración por defecto
SCAN_INTERVAL=${SCAN_INTERVAL:-3600}  # 1 hora
TARGETS_FILE=${TARGETS_FILE:-"$DATA_DIR/targets.json"}
AUTO_SCAN=${AUTO_SCAN:-true}
MAX_CONCURRENT=${MAX_CONCURRENT:-3}
LOG_FILE="$LOG_DIR/daemon-$(date +%Y-%m-%d).log"

# ============================================
# FUNCIONES DE LOG
# ============================================

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" >> "$LOG_FILE"
    echo -e "${CYAN}$msg${NC}"
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg" >> "$LOG_FILE"
    echo -e "${RED}$msg${NC}"
}

log_success() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] OK: $1"
    echo "$msg" >> "$LOG_FILE"
    echo -e "${GREEN}$msg${NC}"
}

# ============================================
# FUNCIONES DE MONITOREO
# ============================================

fetch_feed() {
    log "Obteniendo feed de amenazas..."
    curl -s "$FEED_URL" -o "$DATA_DIR/noticias.json" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_success "Feed actualizado"
        return 0
    else
        log_error "Error al obtener feed"
        return 1
    fi
}

detect_new_threats() {
    log "Detectando nuevas amenazas..."
    
    # Obtener ID más reciente
    CURRENT_ID=$(cat "$DATA_DIR/noticias.json" | jq -r '.[0].id')
    
    # Verificar último check
    if [ -f "$LAST_CHECK" ]; then
        LAST_ID=$(cat "$LAST_CHECK")
    else
        LAST_ID=$CURRENT_ID
        echo "$CURRENT_ID" > "$LAST_CHECK"
    fi
    
    if [ "$CURRENT_ID" != "$LAST_ID" ]; then
        log "Nuevas amenazas detectadas (IDs: $LAST_ID -> $CURRENT_ID)"
        
        # Extraer amenazas nuevas críticas/alta
        NEW_THREATS=$(cat "$DATA_DIR/noticias.json" | jq -r "
            [.[] | select(.id > $LAST_ID and (.severidad == \"CRITICA\" or .severidad == \"ALTA\"))] |
            length
        ")
        
        if [ "$NEW_THREATS" -gt 0 ]; then
            log "$NEW_THREATS nuevas amenazas críticas/alta"
            
            # Guardar en cola de escaneo
            cat "$DATA_DIR/noticias.json" | jq -r "
                [.[] | select(.id > $LAST_ID and (.severidad == \"CRITICA\" or .severidad == \"ALTA\"))] |
                [.[] | {
                    id: .id,
                    titulo: .titulo,
                    severidad: .severidad,
                    cves: .iocs.cve // [],
                    ttps: [.ttps[]?.name // empty],
                    necesita_escaneo: (if (.iocs.cve | length) > 0 or (.resumen | test(\"exploit|remote|code execution|rce|privilege\"; \"i\")) then true else false end)
                }]
            " > "$SCAN_QUEUE"
            
            echo "$CURRENT_ID" > "$LAST_CHECK"
            return 0
        else
            log "Sin amenazas nuevas críticas"
            echo "$CURRENT_ID" > "$LAST_CHECK"
            return 1
        fi
    else
        log "Sin cambios en el feed"
        return 1
    fi
}

# ============================================
# FUNCIONES DE ESCANEO AUTOMÁTICO
# ============================================

scan_target() {
    local target="$1"
    local threat_info="$2"
    
    log "Escaneando target: $target"
    
    # Crear directorio de reporte
    local scan_dir="$REPORT_DIR/auto-scan-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$scan_dir"
    
    # Ejecutar escaneo rápido
    "$SCRIPT_DIR/quickscan.sh" "$target" > "$scan_dir/quick-scan.txt" 2>&1
    
    # Verificar si hay servicios vulnerables
    local vulns_found=$(grep -ci "vulnerability\|vuln\|cve\|exploit" "$scan_dir/quick-scan.txt" 2>/dev/null || echo "0")
    
    if [ "$vulns_found" -gt 0 ]; then
        log "Vulnerabilidades potenciales encontradas en $target"
        
        # Ejecutar escaneo completo
        "$SCRIPT_DIR/autopentest-pro.sh" "$target" > "$scan_dir/full-scan.txt" 2>&1 &
        local scan_pid=$!
        
        # Guardar info de la amenaza
        cat > "$scan_dir/threat-info.json" << EOF
{
    "target": "$target",
    "scan_date": "$(date -Iseconds)",
    "threat_info": $threat_info,
    "vulnerabilities_found": $vulns_found,
    "scan_pid": $scan_pid
}
EOF
        
        log_success "Escaneo completo iniciado (PID: $scan_pid)"
        return 0
    else
        log "Sin vulnerabilidades detectadas en $target"
        return 1
    fi
}

auto_scan_for_threats() {
    if [ ! -f "$SCAN_QUEUE" ]; then
        return 0
    fi
    
    local queue_length=$(cat "$SCAN_QUEUE" | jq 'length')
    
    if [ "$queue_length" -eq 0 ]; then
        return 0
    fi
    
    log "Procesando cola de escaneo ($queue_length amenazas)..."
    
    # Cargar targets
    if [ ! -f "$TARGETS_FILE" ]; then
        log "No hay targets configurados. Creando archivo de ejemplo..."
        create_targets_file
        return 0
    fi
    
    # Procesar cada amenaza que necesita escaneo
    cat "$SCAN_QUEUE" | jq -c '.[] | select(.necesita_escaneo == true)' | while read -r threat; do
        local threat_id=$(echo "$threat" | jq -r '.id')
        local cves=$(echo "$threat" | jq -r '.cves | join(", ")')
        
        log "Procesando amenaza ID: $threat_id (CVEs: $cves)"
        
        # Escanear cada target
        cat "$TARGETS_FILE" | jq -r '.targets[].url' | while read -r target; do
            if [ -n "$target" ]; then
                scan_target "$target" "$threat" || true
            fi
        done
    done
    
    # Limpiar cola
    echo "[]" > "$SCAN_QUEUE"
    log_success "Cola de escaneo procesada"
}

create_targets_file() {
    cat > "$TARGETS_FILE" << 'EOF'
{
    "targets": [
        {
            "name": "Target Example A",
            "url": "https://example-a.com",
            "type": "web",
            "priority": "high"
        },
        {
            "name": "Target Example B",
            "url": "https://example-b.com",
            "type": "web",
            "priority": "high"
        }
    ],
    "scan_options": {
        "quick_scan": true,
        "full_scan_on_vuln": true,
        "max_concurrent": 3
    }
}
EOF
    log "Archivo de targets creado en $TARGETS_FILE"
    log "Edita este archivo para agregar tus targets"
}

# ============================================
# FUNCIONES DE ESCANEO POR CVE
# ============================================

scan_for_specific_cve() {
    local cve="$1"
    local target="$2"
    
    log "Escaneando para $cve en $target"
    
    # Buscar exploits para el CVE
    local exploit_info=$(searchsploit "$cve" 2>/dev/null | head -20 || echo "No exploits found")
    
    # Verificar si el target es vulnerable
    local scan_result="$REPORT_DIR/cve-scan-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$scan_result" << EOF
# Escaneo CVE: $cve

**Target:** $target
**Fecha:** $(date -Iseconds)

## Exploits Disponibles

\`\`\`
$exploit_info
\`\`\`

## Resultado del Escaneo

EOF
    
    # Ejecutar nmap con scripts específicos
    nmap -sV --script "*$cve*" "$target" >> "$scan_result" 2>/dev/null || true
    
    log_success "Escaneo CVE completado: $scan_result"
}

scan_critical_cves() {
    log "Escaneando CVEs críticos recientes..."
    
    # Obtener CVEs críticos de los últimos 7 días
    local critical_cves=$(cat "$DATA_DIR/noticias.json" | jq -r "
        [.[] | select(
            .severidad == \"CRITICA\" and
            (.iocs.cve | length) > 0
        )] | .[0:10][] | .iocs.cve[]
    " 2>/dev/null | sort -u)
    
    if [ -z "$critical_cves" ]; then
        log "Sin CVEs críticos recientes"
        return 0
    fi
    
    log "CVEs críticos a escanear:"
    echo "$critical_cves" | while read -r cve; do
        echo "  - $cve"
        
        # Escanear cada target
        if [ -f "$TARGETS_FILE" ]; then
            cat "$TARGETS_FILE" | jq -r '.targets[].url' | while read -r target; do
                if [ -n "$target" ]; then
                    scan_for_specific_cve "$cve" "$target"
                fi
            done
        fi
    done
}

# ============================================
# FUNCIONES DE INTEGRACIÓN
# ============================================

update_registry_with_threats() {
    log "Actualizando registry con nuevas amenazas..."
    
    # Extraer herramientas mencionadas en amenazas
    local new_tools=$(cat "$DATA_DIR/noticias.json" | jq -r "
        [.[] | select(.severidad == \"CRITICA\" or .severidad == \"ALTA\")] |
        .[].resumen | scan(\"(metasploit|sqlmap|nmap|hydra|burp|nuclei|gobuster)\") | 
        unique | .[]
    " 2>/dev/null)
    
    if [ -n "$new_tools" ]; then
        log "Herramientas relevantes detectadas: $new_tools"
    fi
}

generate_daily_brief() {
    log "Generando brief diario..."
    
    local brief_file="$REPORT_DIR/daily-brief-$(date +%Y-%m-%d).md"
    
    cat > "$brief_file" << 'EOF'
# Brief Diario de Amenazas

**Fecha:** DATE_PLACEHOLDER

---

## Resumen

EOF
    
    # Agregar estadísticas
    local stats=$(cat "$DATA_DIR/noticias.json" | jq -r "
        \"| Métrica | Valor |\n|---------|-------|\n\",
        \"| Total noticias | \([.[]] | length) |\n\",
        \"| Críticas | \([.[] | select(.severidad == \"CRITICA\")] | length) |\n\",
        \"| Alta | \([.[] | select(.severidad == \"ALTA\")] | length) |\n\",
        \"| Media | \([.[] | select(.severidad == \"MEDIA\")] | length) |\n\",
        \"| Con CVEs | \([.[] | select(.iocs.cve | length > 0)] | length) |\n\"
    ")
    
    echo "$stats" >> "$brief_file"
    
    # Agregar CVEs críticos
    cat >> "$brief_file" << 'EOF'

## CVEs Críticos Recientes

EOF
    
    cat "$DATA_DIR/noticias.json" | jq -r '
        [.[] | select(.severidad == "CRITICA" and (.iocs.cve | length) > 0)] | .[0:5][] |
        "- **\(.titulo)**: \(.iocs.cve | join(", "))\n  \(.resumen[0:150])...\n"
    ' >> "$brief_file" 2>/dev/null
    
    # Agregar acciones tomadas
    cat >> "$brief_file" << 'EOF'

## Acciones Automáticas

- Escaneos ejecutados contra targets
- IOCs exportados para bloqueo
- Registry de herramientas actualizado

---

*Generado automáticamente por Threat Intel Daemon*
EOF
    
    sed -i "s/DATE_PLACEHOLDER/$(date -Iseconds)/" "$brief_file"
    
    log_success "Brief diario generado: $brief_file"
}

# ============================================
# FUNCIONES DE NOTIFICACIÓN
# ============================================

send_notification() {
    local message="$1"
    local severity="$2"
    
    # Log
    log "NOTIFICACIÓN [$severity]: $message"
    
    # Guardar en archivo de notificaciones
    echo "[$(date -Iseconds)] [$severity] $message" >> "$LOG_DIR/notifications.log"
    
    # Aquí puedes agregar integración con:
    # - Telegram bot
    # - Discord webhook
    # - Email
    # - Slack
}

notify_critical_threat() {
    local threat_info="$1"
    
    local title=$(echo "$threat_info" | jq -r '.titulo')
    local severity=$(echo "$threat_info" | jq -r '.severidad')
    local cves=$(echo "$threat_info" | jq -r '.cves | join(", ")')
    
    send_notification "NUEVA AMENAZA CRÍTICA: $title (CVEs: $cves)" "CRITICAL"
}

# ============================================
# MAIN LOOP
# ============================================

show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║         AUTO-SCAN DAEMON - Threat Intel Integration        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}Targets:${NC}"
    if [ -f "$TARGETS_FILE" ]; then
        cat "$TARGETS_FILE" | jq -r '.targets[] | "  - \(.name): \(.url)"' 2>/dev/null
    else
        echo "  (No configurado - ejecuta: $0 setup)"
    fi
    echo ""
    echo -e "${YELLOW}Intervalo:${NC} ${SCAN_INTERVAL}s"
    echo -e "${YELLOW}Log:${NC} $LOG_FILE"
    echo ""
}

run_daemon() {
    show_banner
    
    log "Iniciando daemon..."
    
    while true; do
        log "=== Ciclo de verificación ==="
        
        # 1. Obtener feed
        fetch_feed || true
        
        # 2. Detectar nuevas amenazas
        if detect_new_threats; then
            # 3. Notificar amenazas críticas
            cat "$SCAN_QUEUE" | jq -c '.[] | select(.severidad == "CRITICA")' 2>/dev/null | while read -r threat; do
                notify_critical_threat "$threat"
            done
            
            # 4. Ejecutar escaneos automáticos
            if [ "$AUTO_SCAN" = "true" ]; then
                auto_scan_for_threats
            fi
        fi
        
        # 5. Escanear CVEs críticos periódicamente
        scan_critical_cves
        
        # 6. Generar brief diario (una vez al día)
        if [ "$(date +%H)" = "08" ] && [ ! -f "$REPORT_DIR/daily-brief-$(date +%Y-%m-%d).md" ]; then
            generate_daily_brief
        fi
        
        log "Próximo ciclo en ${SCAN_INTERVAL}s"
        sleep "$SCAN_INTERVAL"
    done
}

# ============================================
# PUNTO DE ENTRADA
# ============================================

case "${1:-daemon}" in
    daemon)
        run_daemon
        ;;
    once)
        fetch_feed
        detect_new_threats
        auto_scan_for_threats
        scan_critical_cves
        ;;
    setup)
        create_targets_file
        echo -e "${GREEN}[✓] Configuración inicial completada${NC}"
        echo -e "${YELLOW}Edita $TARGETS_FILE para agregar tus targets${NC}"
        ;;
    status)
        echo -e "${CYAN}=== Estado del Daemon ===${NC}"
        echo "Último check: $(cat "$LAST_CHECK" 2>/dev/null || echo 'Nunca')"
        echo "Targets: $(cat "$TARGETS_FILE" | jq '.targets | length' 2>/dev/null || echo '0')"
        echo "Cola de escaneo: $(cat "$SCAN_QUEUE" | jq 'length' 2>/dev/null || echo '0')"
        echo "Log actual: $LOG_FILE"
        ;;
    *)
        echo "Uso: $0 [daemon|once|setup|status]"
        echo ""
        echo "  daemon  - Ejecutar daemon en loop (default)"
        echo "  once    - Ejecutar una sola vez"
        echo "  setup   - Configurar targets iniciales"
        echo "  status  - Ver estado del daemon"
        ;;
esac
