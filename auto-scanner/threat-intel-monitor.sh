#!/bin/bash
# ============================================
# Threat Intel Orchestrator
# ============================================
# Monitorea feed de noticias de ciberseguridad/IA
# y genera inteligencia accionable
# ============================================

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

FEED_URL="https://raw.githubusercontent.com/DevCop95/cYHBernews/refs/heads/main/noticias.json"
FEED_DIR="$(dirname "$0")/feeds"
REPORT_DIR="$(dirname "$0")/reports"
DATA_DIR="$(dirname "$0")/threat-intel"

mkdir -p "$FEED_DIR" "$REPORT_DIR" "$DATA_DIR"

# ============================================
# FUNCIONES
# ============================================

fetch_feed() {
    echo -e "${CYAN}[+] Obteniendo feed de noticias...${NC}"
    curl -s "$FEED_URL" -o "$FEED_DIR/noticias.json"
    echo -e "${GREEN}[✓] Feed actualizado${NC}"
}

parse_cves() {
    echo -e "${CYAN}[+] Parseando CVEs...${NC}"
    cat "$FEED_DIR/noticias.json" | jq -r '
        [.[] | select(.iocs.cve != null and (.iocs.cve | length) > 0) | {
            id: .id,
            fecha: .fecha,
            severidad: .severidad,
            titulo: .titulo,
            cves: .iocs.cve,
            ttps: [.ttps[]?.name // empty],
            fuente: .fuente,
            enlace: .enlace_original
        }]
    ' > "$DATA_DIR/cves.json"
    
    COUNT=$(cat "$DATA_DIR/cves.json" | jq 'length')
    echo -e "${GREEN}[✓] $COUNT CVEs encontrados${NC}"
}

parse_critical() {
    echo -e "${CYAN}[+] Filtrando amenazas críticas...${NC}"
    cat "$FEED_DIR/noticias.json" | jq -r '
        [.[] | select(.severidad == "CRITICA" or .severidad == "ALTA") | {
            id: .id,
            fecha: .fecha,
            severidad: .severidad,
            titulo: .titulo,
            categoria: .categoria,
            resumen: .resumen[0:200],
            ttps: [.ttps[]?.name // empty],
            cves: .iocs.cve // [],
            fuente: .fuente
        }]
    ' > "$DATA_DIR/critical.json"
    
    COUNT=$(cat "$DATA_DIR/critical.json" | jq 'length')
    echo -e "${GREEN}[✓] $COUNT amenazas críticas/alta${NC}"
}

parse_ttps() {
    echo -e "${CYAN}[+] Extrayendo TTPs (MITRE ATT&CK)...${NC}"
    cat "$FEED_DIR/noticias.json" | jq -r '
        [.[] | .ttps[]? | select(.id != null) | {
            id: .id,
            name: .name
        }] | unique_by(.id)
    ' > "$DATA_DIR/ttps.json"
    
    COUNT=$(cat "$DATA_DIR/ttps.json" | jq 'length')
    echo -e "${GREEN}[✓] $COUNT TTPs únicos${NC}"
}

generate_threat_report() {
    echo -e "${CYAN}[+] Generando reporte de amenazas...${NC}"
    
    DATE=$(date +%Y-%m-%d)
    REPORT_FILE="$REPORT_DIR/threat-intel-${DATE}.md"
    
    cat > "$REPORT_FILE" << 'HEADER'
# Reporte de Inteligencia de Amenazas

**Generado automáticamente por Threat Intel Orchestrator**

---

## Resumen Ejecutivo

HEADER
    
    # Contar estadísticas
    TOTAL=$(cat "$FEED_DIR/noticias.json" | jq 'length')
    CRITICA=$(cat "$FEED_DIR/noticias.json" | jq '[.[] | select(.severidad == "CRITICA")] | length')
    ALTA=$(cat "$FEED_DIR/noticias.json" | jq '[.[] | select(.severidad == "ALTA")] | length')
    MEDIA=$(cat "$FEED_DIR/noticias.json" | jq '[.[] | select(.severidad == "MEDIA")] | length')
    BAJA=$(cat "$FEED_DIR/noticias.json" | jq '[.[] | select(.severidad == "BAJA")] | length')
    
    cat >> "$REPORT_FILE" << EOF
| Severidad | Cantidad |
|-----------|----------|
| 🔴 CRÍTICA | $CRITICA |
| 🟠 ALTA | $ALTA |
| 🟡 MEDIA | $MEDIA |
| 🟢 BAJA | $BAJA |
| **TOTAL** | **$TOTAL** |

---

## 🔴 Vulnerabilidades Críticas

EOF
    
    # Agregar CVEs críticos
    cat "$DATA_DIR/critical.json" | jq -r '
        .[] | select(.severidad == "CRITICA") |
        "### \(.titulo)\n\n- **Fecha:** \(.fecha)\n- **CVE:** \(.cves | join(", ") | if length > 0 then . else "N/A" end)\n- **TTPs:** \(.ttps | join(", ") | if length > 0 then . else "N/A" end)\n- **Fuente:** \(.fuente)\n\n\(.resumen)\n\n---\n"
    ' >> "$REPORT_FILE"
    
    cat >> "$REPORT_FILE" << 'SECTION'
## 🟠 Vulnerabilidades de Alta Severidad

SECTION
    
    cat "$DATA_DIR/critical.json" | jq -r '
        .[] | select(.severidad == "ALTA") |
        "### \(.titulo)\n\n- **Fecha:** \(.fecha)\n- **CVE:** \(.cves | join(", ") | if length > 0 then . else "N/A" end)\n- **Fuente:** \(.fuente)\n\n\(.resumen)\n\n---\n"
    ' >> "$REPORT_FILE"
    
    cat >> "$REPORT_FILE" << 'SECTION'
## 📊 TTPs MITRE ATT&CK Detectados

SECTION
    
    cat "$DATA_DIR/ttps.json" | jq -r '.[] | "- **\(.id)**: \(.name)"' >> "$REPORT_FILE"
    
    cat >> "$REPORT_FILE" << 'SECTION'

---

## 🛡️ Recomendaciones

### Acciones Inmediatas
1. Revisar y aplicar parches para CVEs críticos
2. Monitorear IPs y dominios IOC
3. Actualizar reglas de WAF/IDS según TTPs detectados

### Monitoreo Continuo
1. Ejecutar `./threat-intel-monitor.sh` cada hora
2. Revisar reportes diarios en `reports/`
3. Actualizar vectores de ataque en el registry

---

*Reporte generado automáticamente*
SECTION
    
    echo -e "${GREEN}[✓] Reporte generado: $REPORT_FILE${NC}"
}

generate_ioc_list() {
    echo -e "${CYAN}[+] Generando lista de IOCs...${NC}"
    
    DATE=$(date +%Y-%m-%d)
    IOC_FILE="$DATA_DIR/iocs-${DATE}.txt"
    
    cat "$FEED_DIR/noticias.json" | jq -r '
        [.[] | 
            (.iocs.cve // [])[]?,
            (.iocs.domain // [])[]?,
            (.iocs.url // [])[]
        ] | unique | .[]
    ' > "$IOC_FILE" 2>/dev/null || echo "" > "$IOC_FILE"
    
    COUNT=$(wc -l < "$IOC_FILE")
    echo -e "${GREEN}[✓] $COUNT IOCs exportados a $IOC_FILE${NC}"
}

show_summary() {
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  RESUMEN DE INTELIGENCIA DE AMENAZAS${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${CYAN}CVEs Críticos:${NC}"
    cat "$DATA_DIR/cves.json" | jq -r '.[] | select(.severidad == "CRITICA") | "  🔴 \(.titulo) - \(.cves | join(", "))"' 2>/dev/null | head -10
    echo ""
    
    echo -e "${CYAN}Amenazas de Alto Nivel:${NC}"
    cat "$DATA_DIR/critical.json" | jq -r '.[] | "  \(.severidad | if . == "CRITICA" then "🔴" else "🟠" end) \(.titulo)"' 2>/dev/null | head -10
    echo ""
    
    echo -e "${CYAN}TTPs Más Comunes:${NC}"
    cat "$DATA_DIR/ttps.json" | jq -r '.[0:5][] | "  • \(.id): \(.name)"' 2>/dev/null
    echo ""
}

# ============================================
# MAIN
# ============================================

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           THREAT INTEL ORCHESTRATOR v1.0                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

case "${1:-full}" in
    fetch)
        fetch_feed
        ;;
    parse)
        parse_cves
        parse_critical
        parse_ttps
        ;;
    report)
        generate_threat_report
        generate_ioc_list
        ;;
    summary)
        show_summary
        ;;
    full)
        fetch_feed
        parse_cves
        parse_critical
        parse_ttps
        generate_threat_report
        generate_ioc_list
        show_summary
        ;;
    *)
        echo "Uso: $0 [fetch|parse|report|summary|full]"
        ;;
esac

echo ""
echo -e "${GREEN}[✓] Proceso completado${NC}"
