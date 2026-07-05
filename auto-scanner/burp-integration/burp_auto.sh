#!/bin/bash
# ============================================
# Burp Suite GUI Automation
# ============================================
# Controla Burp Suite mediante capturas de pantalla,
# clicks y movimientos de mouse/teclado.
#
# Uso: ./burp_auto.sh <comando> [opciones]
# ============================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCREENSHOTS_DIR="$SCRIPT_DIR/screenshots"
mkdir -p "$SCREENSHOTS_DIR"

# ============================================
# FUNCIONES AUXILIARES
# ============================================

# Tomar captura de pantalla
take_screenshot() {
    local name="${1:-screenshot_$(date +%Y%m%d_%H%M%S)}"
    scrot "$SCREENSHOTS_DIR/${name}.png" 2>/dev/null
    echo -e "${GREEN}[✓] Captura: $SCREENSHOTS_DIR/${name}.png${NC}"
}

# Buscar ventana por nombre
find_window() {
    local title="$1"
    xdotool search --name "$title" 2>/dev/null | head -1
}

# Activar ventana
activate_window() {
    local wid="$1"
    if [ -n "$wid" ]; then
        xdotool windowactivate "$wid" 2>/dev/null
        xdotool windowfocus "$wid" 2>/dev/null
        sleep 0.5
        return 0
    fi
    return 1
}

# Click en coordenadas
click_at() {
    local x="$1"
    local y="$2"
    local delay="${3:-0.3}"
    xdotool mousemove "$x" "$y"
    sleep 0.2
    xdotool click 1
    sleep "$delay"
}

# Double click
double_click_at() {
    local x="$1"
    local y="$2"
    xdotool mousemove "$x" "$y"
    sleep 0.2
    xdotool click --repeat 2 1
    sleep 0.5
}

# Escribir texto
type_text() {
    local text="$1"
    local delay="${2:-0.05}"
    xdotool type --delay "$(echo "$delay * 1000" | bc)" "$text"
    sleep 0.3
}

# Pegar desde clipboard
paste_text() {
    local text="$1"
    echo -n "$text" | xclip -selection clipboard
    xdotool key ctrl+v
    sleep 0.3
}

# Presionar tecla
press_key() {
    local key="$1"
    xdotool key "$key"
    sleep 0.2
}

# Buscar texto en pantalla usando OCR (si está disponible)
find_text_on_screen() {
    local text="$1"
    local screenshot="$SCREENSHOTS_DIR/current.png"
    
    # Tomar captura
    scrot "$screenshot" 2>/dev/null
    
    # Buscar texto usando tesseract (si está disponible)
    if command -v tesseract &>/dev/null; then
        tesseract "$screenshot" stdout 2>/dev/null | grep -n "$text" | head -5
    else
        echo -e "${YELLOW}[!] tesseract no instalado para OCR${NC}"
        return 1
    fi
}

# ============================================
# COMANDOS DE BURP SUITE
# ============================================

# Lanzar Burp Suite
launch_burp() {
    echo -e "${YELLOW}[→] Lanzando Burp Suite...${NC}"
    
    # Buscar Burp Suite
    BURP_PATHS=(
        "/usr/bin/burpsuite"
        "/opt/BurpSuiteCommunity/burpsuite"
        "/opt/BurpSuiteProfessional/burpsuite"
        "$HOME/BurpSuiteCommunity/burpsuite"
        "$HOME/BurpSuiteProfessional/burpsuite"
    )
    
    for path in "${BURP_PATHS[@]}"; do
        if [ -f "$path" ] || [ -f "$path.sh" ]; then
            "$path" &
            sleep 5
            take_screenshot "burp_launched"
            echo -e "${GREEN}[✓] Burp Suite lanzado${NC}"
            return 0
        fi
    done
    
    # Intentar con comando
    if command -v burpsuite &>/dev/null; then
        burpsuite &
        sleep 5
        take_screenshot "burp_launched"
        echo -e "${GREEN}[✓] Burp Suite lanzado${NC}"
        return 0
    fi
    
    echo -e "${RED}[✗] No se encontró Burp Suite${NC}"
    return 1
}

# Esperar a que Burp esté listo
wait_for_burp() {
    echo -e "${YELLOW}[→] Esperando a que Burp Suite esté listo...${NC}"
    
    local max_wait=30
    local count=0
    
    while [ $count -lt $max_wait ]; do
        local wid=$(find_window "Burp Suite")
        if [ -n "$wid" ]; then
            echo -e "${GREEN}[✓] Burp Suite está listo${NC}"
            take_screenshot "burp_ready"
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    echo -e "${RED}[✗] Timeout esperando Burp Suite${NC}"
    return 1
}

# Habilitar Proxy en Burp
enable_proxy() {
    echo -e "${YELLOW}[→] Habilitando Proxy en Burp...${NC}"
    
    local wid=$(find_window "Burp Suite")
    if [ -z "$wid" ]; then
        echo -e "${RED}[✗] Burp Suite no encontrado${NC}"
        return 1
    fi
    
    activate_window "$wid"
    
    # Click en tab "Proxy"
    click_at 150 120
    sleep 0.5
    
    # Click en "Options"
    click_at 250 150
    sleep 0.5
    
    # Click en "Intercept" tab
    click_at 350 150
    sleep 0.5
    
    # Click en "Intercept is on/off"
    click_at 200 300
    sleep 0.5
    
    take_screenshot "proxy_enabled"
    echo -e "${GREEN}[✓] Proxy habilitado${NC}"
}

# Abrir Target en Burp
open_target() {
    local url="$1"
    echo -e "${YELLOW}[→] Abriendo $url en Burp...${NC}"
    
    local wid=$(find_window "Burp Suite")
    if [ -z "$wid" ]; then
        echo -e "${RED}[✗] Burp Suite no encontrado${NC}"
        return 1
    fi
    
    activate_window "$wid"
    
    # Click en tab "Target"
    click_at 50 120
    sleep 0.5
    
    # Click en "Scope"
    click_at 100 200
    sleep 0.5
    
    # Click en "Add"
    click_at 400 250
    sleep 0.5
    
    # Escribir URL
    type_text "$url"
    sleep 0.3
    
    # Click en OK
    click_at 400 350
    sleep 0.5
    
    take_screenshot "target_added"
    echo -e "${GREEN}[✓] Target agregado: $url${NC}"
}

# Iniciar Spider
start_spider() {
    local url="$1"
    echo -e "${YELLOW}[→] Iniciando Spider para $url...${NC}"
    
    local wid=$(find_window "Burp Suite")
    if [ -z "$wid" ]; then
        echo -e "${RED}[✗] Burp Suite no encontrado${NC}"
        return 1
    fi
    
    activate_window "$wid"
    
    # Click en tab "Target"
    click_at 50 120
    sleep 0.5
    
    # Click derecho en la URL
    click_at 200 250  # Click izquierdo primero
    sleep 0.3
    
    # Buscar "Spider this host"
    # (Esto varía según la versión de Burp)
    
    take_screenshot "spider_started"
    echo -e "${GREEN}[✓] Spider iniciado${NC}"
}

# Iniciar Active Scan
start_scan() {
    local url="$1"
    echo -e "${YELLOW}[→] Iniciando Active Scan para $url...${NC}"
    
    local wid=$(find_window "Burp Suite")
    if [ -z "$wid" ]; then
        echo -e "${RED}[✗] Burp Suite no encontrado${NC}"
        return 1
    fi
    
    activate_window "$wid"
    
    # Click en tab "Target"
    click_at 50 120
    sleep 0.5
    
    # Click derecho en la URL
    click_at 200 250
    sleep 0.3
    
    # Buscar "Scan"
    # (Esto varía según la versión de Burp)
    
    take_screenshot "scan_started"
    echo -e "${GREEN}[✓] Active Scan iniciado${NC}"
}

# Ver Issues
view_issues() {
    echo -e "${YELLOW}[→] Abriendo Issues...${NC}"
    
    local wid=$(find_window "Burp Suite")
    if [ -z "$wid" ]; then
        echo -e "${RED}[✗] Burp Suite no encontrado${NC}"
        return 1
    fi
    
    activate_window "$wid"
    
    # Click en tab "Target"
    click_at 50 120
    sleep 0.5
    
    # Click en "Issues"
    click_at 100 400
    sleep 0.5
    
    take_screenshot "issues_view"
    echo -e "${GREEN}[✓] Issues mostrados${NC}"
}

# Exportar Issues
export_issues() {
    echo -e "${YELLOW}[→] Exportando Issues...${NC}"
    
    local wid=$(find_window "Burp Suite")
    if [ -z "$wid" ]; then
        echo -e "${RED}[✗] Burp Suite no encontrado${NC}"
        return 1
    fi
    
    activate_window "$wid"
    
    # Click en "Project"
    click_at 50 50
    sleep 0.5
    
    # Click en "Save project"
    click_at 100 100
    sleep 0.5
    
    # Escribir nombre
    type_text "burp_project_$(date +%Y%m%d)"
    sleep 0.3
    
    # Click en Save
    click_at 400 400
    sleep 1
    
    take_screenshot "project_saved"
    echo -e "${GREEN}[✓] Proyecto guardado${NC}"
}

# Tomar captura y analizar
analyze_screen() {
    echo -e "${YELLOW}[→] Analizando pantalla...${NC}"
    
    take_screenshot "analysis_$(date +%Y%m%d_%H%M%S)"
    
    # Verificar si tesseract está disponible
    if command -v tesseract &>/dev/null; then
        local screenshot="$SCREENSHOTS_DIR/analysis_$(date +%Y%m%d_%H%M%S).png"
        tesseract "$screenshot" stdout 2>/dev/null | head -50
    else
        echo -e "${YELLOW}[!] Para OCR instala: sudo apt install tesseract-ocr${NC}"
    fi
}

# Mostrar estado de Burp
show_burp_status() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Estado de Burp Suite${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Verificar si Burp está corriendo
    local burp_pid=$(pgrep -f "burpsuite" 2>/dev/null)
    if [ -n "$burp_pid" ]; then
        echo -e "${GREEN}[✓] Burp Suite está corriendo (PID: $burp_pid)${NC}"
    else
        echo -e "${RED}[✗] Burp Suite NO está corriendo${NC}"
    fi
    
    # Verificar ventana
    local wid=$(find_window "Burp Suite")
    if [ -n "$wid" ]; then
        echo -e "${GREEN}[✓] Ventana de Burp Suite encontrada (WID: $wid)${NC}"
    else
        echo -e "${RED}[✗] Ventana de Burp Suite no encontrada${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}Herramientas disponibles:${NC}"
    echo "  xdotool: $(which xdotool 2>/dev/null || echo 'no')"
    echo "  scrot: $(which scrot 2>/dev/null || echo 'no')"
    echo "  xclip: $(which xclip 2>/dev/null || echo 'no')"
    echo "  tesseract: $(which tesseract 2>/dev/null || echo 'no')"
}

# ============================================
# MAIN
# ============================================

case "${1:-help}" in
    launch)
        launch_burp
        ;;
    wait)
        wait_for_burp
        ;;
    proxy)
        enable_proxy
        ;;
    target)
        open_target "$2"
        ;;
    spider)
        start_spider "$2"
        ;;
    scan)
        start_scan "$2"
        ;;
    issues)
        view_issues
        ;;
    export)
        export_issues
        ;;
    screenshot)
        take_screenshot "${2:-manual}"
        ;;
    analyze)
        analyze_screen
        ;;
    status)
        show_burp_status
        ;;
    click)
        click_at "$2" "$3"
        ;;
    type)
        type_text "$2"
        ;;
    paste)
        paste_text "$2"
        ;;
    key)
        press_key "$2"
        ;;
    *)
        echo ""
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║         Burp Suite GUI Automation - Help                    ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "Uso: $0 <comando> [opciones]"
        echo ""
        echo "Comandos:"
        echo "  launch              - Lanzar Burp Suite"
        echo "  wait                - Esperar a que Burp esté listo"
        echo "  status              - Ver estado de Burp"
        echo "  proxy               - Habilitar Proxy"
        echo "  target <url>        - Agregar target"
        echo "  spider <url>        - Iniciar Spider"
        echo "  scan <url>          - Iniciar Active Scan"
        echo "  issues              - Ver Issues"
        echo "  export              - Exportar proyecto"
        echo "  screenshot [name]   - Tomar captura"
        echo "  analyze             - Analizar pantalla"
        echo "  click <x> <y>       - Click en coordenadas"
        echo "  type <text>         - Escribir texto"
        echo "  paste <text>        - Pegar texto"
        echo "  key <key>           - Presionar tecla"
        echo ""
        echo "Ejemplos:"
        echo "  $0 launch"
        echo "  $0 target https://ejemplo.com"
        echo "  $0 scan https://ejemplo.com"
        echo "  $0 screenshot burp_test"
        echo ""
        ;;
esac
