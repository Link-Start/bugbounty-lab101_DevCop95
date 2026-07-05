#!/bin/bash
# ============================================
# Burp Suite Integration - Shell Wrapper
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="$SCRIPT_DIR/burp_api.py"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuración por defecto
BURP_HOST="localhost"
BURP_PORT="1337"

show_help() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           Burp Suite Integration - Shell Wrapper            ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Uso: $0 <comando> [opciones]"
    echo ""
    echo "Comandos:"
    echo "  status              - Estado de Burp"
    echo "  proxy on/off        - Habilitar/deshabilitar proxy"
    echo "  proxy history       - Ver historial del proxy"
    echo "  target add <url>    - Agregar URL al target"
    echo "  target scope        - Ver scope del target"
    echo "  spider <url>        - Iniciar spider"
    echo "  scan <url>          - Escaneo activo"
    echo "  issues              - Ver hallazgos"
    echo "  issues export       - Exportar hallazgos"
    echo "  repeater <url>      - Enviar a Repeater"
    echo "  launch              - Lanzar Burp Suite"
    echo "  config              - Ver configuración"
    echo ""
    echo "Ejemplos:"
    echo "  $0 status"
    echo "  $0 proxy on"
    echo "  $0 target add https://ejemplo.com"
    echo "  $0 scan https://ejemplo.com"
    echo "  $0 issues export"
}

check_burp_running() {
    if curl -s "http://$BURP_HOST:$BURP_PORT/burp/api" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

launch_burp() {
    echo -e "${YELLOW}Lanzando Burp Suite...${NC}"
    
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
            echo -e "${GREEN}Encontrado: $path${NC}"
            "$path" &
            echo -e "${GREEN}Burp Suite lanzado${NC}"
            echo -e "${YELLOW}Recuerda habilitar la API: Burp → Settings → Burp API → Enable${NC}"
            return 0
        fi
    done
    
    # Intentar con comando
    if command -v burpsuite &>/dev/null; then
        burpsuite &
        echo -e "${GREEN}Burp Suite lanzado${NC}"
        return 0
    fi
    
    echo -e "${RED}No se encontró Burp Suite${NC}"
    return 1
}

show_config() {
    echo -e "${CYAN}Configuración actual:${NC}"
    echo "  Host: $BURP_HOST"
    echo "  Port: $BURP_PORT"
    echo "  API URL: http://$BURP_HOST:$BURP_PORT/burp/api"
    echo ""
    
    if check_burp_running; then
        echo -e "${GREEN}✓ Burp Suite está corriendo${NC}"
    else
        echo -e "${RED}✗ Burp Suite NO está corriendo${NC}"
        echo "  Ejecuta: $0 launch"
    fi
}

# Verificar si Burp está corriendo
if ! check_burp_running && [ "$1" != "launch" ] && [ "$1" != "config" ] && [ "$1" != "help" ] && [ "$1" != "--help" ]; then
    echo -e "${RED}Burp Suite no está corriendo${NC}"
    echo -e "${YELLOW}Ejecuta: $0 launch${NC}"
    echo ""
    read -p "¿Lanzar Burp Suite ahora? (s/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        launch_burp
        sleep 5
    fi
fi

# Ejecutar comando
case "${1:-help}" in
    status)
        python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" status
        ;;
    proxy)
        case "${2:-}" in
            on|enable)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" proxy --enable
                ;;
            off|disable)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" proxy --disable
                ;;
            history)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" proxy --history
                ;;
            *)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" proxy
                ;;
        esac
        ;;
    target)
        case "${2:-}" in
            add)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" target add "$3"
                ;;
            scope|list)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" target scope
                ;;
            *)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" target scope
                ;;
        esac
        ;;
    spider)
        python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" spider start "$2"
        ;;
    scan)
        if [ -n "$2" ]; then
            python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" scan start "$2"
        else
            python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" scan status
        fi
        ;;
    issues)
        case "${2:-}" in
            export)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" issues export
                ;;
            details)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" issues details "$3"
                ;;
            *)
                python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" issues list
                ;;
        esac
        ;;
    repeater)
        python3 "$PYTHON" --host "$BURP_HOST" --port "$BURP_PORT" repeater --url "$2"
        ;;
    launch)
        launch_burp
        ;;
    config)
        show_config
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
