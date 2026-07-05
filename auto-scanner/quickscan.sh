#!/bin/bash
# ============================================
# Quick Scan - Escaneo Rápido
# ============================================
# Uso: ./quickscan.sh https://tu-sitio.com
# 
# Escaneo rápido para cuando necesitas resultados rápidos
# ============================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Verificar argumentos
if [ $# -eq 0 ]; then
    echo -e "${RED}Uso: $0 <url>${NC}"
    exit 1
fi

TARGET_URL="$1"
DOMAIN=$(echo "$TARGET_URL" | sed -E 's|^https?://||' | sed 's|/.*||')
TARGET_IP=$(dig +short "$DOMAIN" | head -1)

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   QUICK SCAN v1.0                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Objetivo:${NC} $TARGET_URL"
echo -e "${BLUE}IP:${NC} $TARGET_IP"
echo ""

# 1. Verificar si está online
echo -e "${YELLOW}[1/5]${NC} Verificando conectividad..."
if curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL" | grep -q "200\|301\|302"; then
    echo -e "${GREEN}  ✓ Online${NC}"
else
    echo -e "${RED}  ✗ Offline o no accesible${NC}"
    exit 1
fi

# 2. Headers HTTP
echo -e "${YELLOW}[2/5]${NC} Analizando headers HTTP..."
echo ""
curl -sI "$TARGET_URL" | head -15
echo ""

# 3. Puertos abiertos
echo -e "${YELLOW}[3/5]${NC} Escaneando puertos principales..."
echo ""
nmap -sT --top-ports 20 -T4 "$TARGET_IP" 2>/dev/null | grep -E "^[0-9]+/tcp|^PORT"
echo ""

# 4. Verificar HTTPS
echo -e "${YELLOW}[4/5]${NC} Verificando HTTPS..."
if echo "$TARGET_URL" | grep -q "^https"; then
    echo -e "${GREEN}  ✓ HTTPS habilitado${NC}"
    
    # Verificar certificado
    EXPIRY=$(echo | openssl s_client -connect "$DOMAIN":443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        echo "  Certificado expira: $EXPIRY"
    fi
else
    echo -e "${RED}  ✗ HTTP solamente (sin cifrar)${NC}"
fi

# 5. Archivos sensibles
echo -e "${YELLOW}[5/5]${NC} Buscando archivos sensibles..."
echo ""

SENSITIVE=("/.env" "/.git/config" "/wp-config.php" "/phpinfo.php" "/robots.txt" "/sitemap.xml")
FOUND=0

for file in "${SENSITIVE[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${TARGET_URL}${file}" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${RED}  ✗ ${file} - EXPUESTO${NC}"
        FOUND=$((FOUND + 1))
    fi
done

if [ $FOUND -eq 0 ]; then
    echo -e "${GREEN}  ✓ No se encontraron archivos sensibles${NC}"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Escaneo rápido completado${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Para un escaneo completo ejecuta:"
echo "  ./autopentest.sh $TARGET_URL"
echo ""
