#!/bin/bash
# ============================================
# Bug Bounty Hunter - Framework Completo
# ============================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUGBOUNTY_DIR="$SCRIPT_DIR"
REPORTS_DIR="$BUGBOUNTY_DIR/reports"
TARGETS_DIR="$BUGBOUNTY_DIR/targets"
NOTES_DIR="$BUGBOUNTY_DIR/notes"
PROGRAMS_DIR="$BUGBOUNTY_DIR/../programs"

# HackerOne handle - override with: BB_RESEARCHER=otro-handle ./bugbounty-hunter.sh ...
RESEARCHER="${BB_RESEARCHER:-dev101x}"

mkdir -p "$REPORTS_DIR" "$TARGETS_DIR" "$NOTES_DIR" "$PROGRAMS_DIR"

# ============================================
# FUNCIONES PRINCIPALES
# ============================================

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              BUG BOUNTY HUNTER FRAMEWORK v1.0               ║"
    echo "║                    HackerOne · @${RESEARCHER}"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================
# SCOPE SAFETY CHECK
# ============================================
# Antes de tocar un target, exige un archivo de scope en programs/.
# Esto evita testear activos fuera del alcance autorizado de un programa
# de HackerOne (violar el scope puede anular la recompensa o el acceso
# al programa). Usa `new` para crear el archivo de scope de un programa.

check_scope() {
    local TARGET="$1"
    local MATCH=""
    local f

    if [ -z "$TARGET" ]; then
        echo -e "${RED}[!] Falta el target${NC}"
        return 1
    fi

    # Solo cuenta como "in scope" si el target aparece dentro de la sección
    # "## In Scope" del archivo — un match en cualquier otra parte (email de
    # contacto, URL del handle, notas, etc.) NO cuenta como scope válido.
    for f in "$PROGRAMS_DIR"/*.md; do
        [ -f "$f" ] || continue
        [ "$(basename "$f")" = "_template.md" ] && continue
        if awk '/^## In Scope/{flag=1; next} /^## /{flag=0} flag' "$f" | grep -qF -- "$TARGET"; then
            MATCH="$f"
            break
        fi
    done

    if [ -z "$MATCH" ]; then
        echo -e "${RED}[!] No hay archivo de scope para '$TARGET' en $PROGRAMS_DIR${NC}"
        echo -e "${YELLOW}    Crea uno primero:  $0 new <nombre-programa>${NC}"
        echo -e "${YELLOW}    y agrega '$TARGET' a su sección 'In Scope'.${NC}"
        if [ "$FORCE" != "1" ]; then
            echo -e "${RED}    Abortando. Solo usa FORCE=1 si tienes autorización explícita fuera de un programa formal.${NC}"
            return 1
        fi
        echo -e "${YELLOW}    FORCE=1 activo, continuando sin archivo de scope.${NC}"
        return 0
    fi

    if awk '/## Out of Scope/{flag=1; next} /^## /{flag=0} flag' "$MATCH" | grep -qF -- "$TARGET"; then
        echo -e "${RED}[!] '$TARGET' está listado como OUT OF SCOPE en $MATCH. Abortando.${NC}"
        return 1
    fi

    echo -e "${GREEN}[✓] Scope OK — $TARGET cubierto por $(basename "$MATCH")${NC}"
    return 0
}

# ============================================
# CREAR PROGRAMA (scope tracker)
# ============================================

new_program() {
    local NAME="$1"
    local TEMPLATE="$PROGRAMS_DIR/_template.md"
    local DEST="$PROGRAMS_DIR/$NAME.md"

    if [ -z "$NAME" ]; then
        echo -e "${RED}Uso: $0 new <nombre-programa>${NC}"
        return 1
    fi

    if [ -f "$DEST" ]; then
        echo -e "${YELLOW}[!] Ya existe: $DEST${NC}"
        return 1
    fi

    if [ -f "$TEMPLATE" ]; then
        cp "$TEMPLATE" "$DEST"
        sed -i "s/\[Nombre del Programa\]/$NAME/" "$DEST" 2>/dev/null
    else
        printf '# %s\n\n## In Scope\n- \n\n## Out of Scope\n- \n' "$NAME" > "$DEST"
    fi

    echo -e "${GREEN}[✓] Programa creado: $DEST${NC}"
    echo -e "${YELLOW}    Edítalo y agrega los dominios/assets en 'In Scope' antes de escanear.${NC}"
}

# ============================================
# DETECCIÓN DE DNS HIJACKING / BLOQUEO A NIVEL RED
# ============================================
# Algunas redes (ISP/país) redirigen categorías completas de dominios
# (apuestas, adultos, streaming, etc.) a una IP sinkhole en vez de resolver
# el dominio real. Si no se detecta, cualquier scanner termina "auditando"
# el sinkhole en vez del target real. Compara el resolver local contra DNS
# público (8.8.8.8 / 1.1.1.1) antes de lanzar recon contra un dominio nuevo,
# sobre todo en nichos de apuestas/adulto/streaming.

resolve_check() {
    local HOST="$1"
    local LOCAL_IPS PUBLIC_IPS FIRST_PUBLIC_IP LOCAL_PROBE

    if [ -z "$HOST" ]; then
        echo -e "${RED}Uso: $0 resolve <host>${NC}"
        return 1
    fi

    LOCAL_IPS=$(timeout 5 dig +short "$HOST" A 2>/dev/null | sort -u)
    PUBLIC_IPS=$( { timeout 5 dig +short @8.8.8.8 "$HOST" A 2>/dev/null; timeout 5 dig +short @1.1.1.1 "$HOST" A 2>/dev/null; } | sort -u)
    FIRST_PUBLIC_IP=$(echo "$PUBLIC_IPS" | head -1)

    echo -e "${YELLOW}DNS local:${NC}  $(echo "$LOCAL_IPS" | tr '\n' ' ')"
    echo -e "${YELLOW}DNS público (8.8.8.8+1.1.1.1):${NC} $(echo "$PUBLIC_IPS" | tr '\n' ' ')"

    if [ -z "$LOCAL_IPS" ] || [ -z "$PUBLIC_IPS" ]; then
        echo -e "${YELLOW}[!] No se pudo comparar (alguna consulta no respondió).${NC}"
        return 1
    fi

    # Servicios con anycast/round-robin (GitHub, Cloudflare, etc.) devuelven
    # IPs distintas a resolvers distintos sin que eso sea un hijack, así que
    # un IP-set distinto NO basta como señal. La señal fuerte es el
    # CONTENIDO: si la IP local redirige/sirve una página de bloqueo
    # (dominio .gov, o palabras como blocked/restricted/warning/ilegal),
    # es un sinkhole real, no solo balanceo de carga. Un sinkhole puede
    # además cerrar el puerto 443 sin responder — probamos HTTP:80 como
    # respaldo en ese caso en vez de asumir que "sin respuesta" es limpio.
    local first_local="$(echo "$LOCAL_IPS" | head -1)"
    LOCAL_PROBE=$(timeout 8 curl -s -D - -o /tmp/resolve_check_body_$$ -m 6 --resolve "$HOST:443:$first_local" "https://$HOST/" 2>/dev/null)
    LOCAL_PROBE="$LOCAL_PROBE $(cat /tmp/resolve_check_body_$$ 2>/dev/null)"
    rm -f /tmp/resolve_check_body_$$

    if [ -z "$LOCAL_PROBE" ] || [ "$(echo "$LOCAL_PROBE" | tr -d '[:space:]')" = "" ]; then
        LOCAL_PROBE=$(timeout 8 curl -s -D - -o /tmp/resolve_check_body_$$ -m 6 --resolve "$HOST:80:$first_local" "http://$HOST/" 2>/dev/null)
        LOCAL_PROBE="$LOCAL_PROBE $(cat /tmp/resolve_check_body_$$ 2>/dev/null)"
        rm -f /tmp/resolve_check_body_$$
    fi

    if echo "$LOCAL_PROBE" | grep -qiE '\.gov(\.[a-z]{2})?[/"'\''>]|blocked|restricted|illegal|advertencia|coljuegos|regulat'; then
        echo -e "${RED}[!] La IP local sirve/redirige a lo que parece una página de bloqueo (dominio .gov o keywords de censura).${NC}"
        echo -e "${RED}    Esto SÍ es un sinkhole de red (ISP/país), no el sitio real.${NC}"
        echo -e "${YELLOW}    Usa la IP pública con curl: curl --resolve $HOST:443:$FIRST_PUBLIC_IP https://$HOST/${NC}"
        return 1
    fi

    if [ -z "$LOCAL_PROBE" ] || [ "$(echo "$LOCAL_PROBE" | tr -d '[:space:]')" = "" ]; then
        echo -e "${YELLOW}[!] La IP local no respondió ni por 443 ni por 80 — inconcluso, no asumas que está limpio.${NC}"
        echo -e "${YELLOW}    Si el dominio es de un nicho sensible (apuestas/adultos/streaming), usa la IP pública igual:${NC}"
        echo -e "${YELLOW}    curl --resolve $HOST:443:$FIRST_PUBLIC_IP https://$HOST/${NC}"
        return 1
    fi

    echo -e "${GREEN}[✓] Sin señales de página de bloqueo — la resolución local parece confiable.${NC}"
    [ "$LOCAL_IPS" != "$PUBLIC_IPS" ] && echo -e "${YELLOW}    (IPs distintas entre local y público — normal en CDN/anycast, no es alarma por sí solo)${NC}"
    return 0
}

# ============================================
# FASE 1: RECONOCIMIENTO PROFUNDO
# ============================================

reconnaissance() {
    local TARGET="$1"
    local OUTPUT_DIR="$REPORTS_DIR/$TARGET/recon"
    
    mkdir -p "$OUTPUT_DIR"
    
    echo -e "${CYAN}[1/8] RECONOCIMIENTO PROFUNDO - $TARGET${NC}"
    
    echo -e "${YELLOW}[1.1] Subdomain Enumeration${NC}"
    subfinder -d "$TARGET" -o "$OUTPUT_DIR/subdomains.txt" 2>/dev/null
    amass enum -passive -d "$TARGET" >> "$OUTPUT_DIR/subdomains.txt" 2>/dev/null
    sort -u "$OUTPUT_DIR/subdomains.txt" -o "$OUTPUT_DIR/subdomains.txt"
    
    SUBS=$(wc -l < "$OUTPUT_DIR/subdomains.txt")
    echo -e "${GREEN}  ✓ $SUBS subdominios encontrados${NC}"
    
    echo -e "${YELLOW}[1.2] HTTP probing${NC}"
    httpx -l "$OUTPUT_DIR/subdomains.txt" -o "$OUTPUT_DIR/httpx.txt" -silent 2>/dev/null
    
    echo -e "${YELLOW}[1.3] Wayback URLs${NC}"
    echo "$TARGET" | gau --threads 5 2>/dev/null | sort -u > "$OUTPUT_DIR/wayback.txt"
    waybackurls "$TARGET" >> "$OUTPUT_DIR/wayback.txt" 2>/dev/null
    sort -u "$OUTPUT_DIR/wayback.txt" -o "$OUTPUT_DIR/wayback.txt"
    
    echo -e "${YELLOW}[1.4] JS endpoints${NC}"
    katana -u "https://$TARGET" -d 3 -jc -o "$OUTPUT_DIR/js_endpoints.txt" -silent 2>/dev/null
    
    echo -e "${YELLOW}[1.5] Parameter discovery${NC}"
    cat "$OUTPUT_DIR/wayback.txt" | grep "?" | unfurl keys | sort -u > "$OUTPUT_DIR/params.txt" 2>/dev/null
    
    echo -e "${GREEN}[✓] Reconocimiento completado${NC}"
}

# ============================================
# FASE 2: ESCANEO DE VULNERABILIDADES
# ============================================

vuln_scan() {
    local TARGET="$1"
    local OUTPUT_DIR="$REPORTS_DIR/$TARGET/vulns"
    
    mkdir -p "$OUTPUT_DIR"
    
    echo -e "${CYAN}[2/8] ESCANEO DE VULNERABILIDADES${NC}"
    
    echo -e "${YELLOW}[2.1] Nuclei scan${NC}"
    echo "https://$TARGET" | nuclei -severity critical,high,medium -o "$OUTPUT_DIR/nuclei.txt" -silent 2>/dev/null
    
    echo -e "${YELLOW}[2.2] CORS misconfiguration${NC}"
    nuclei -u "https://$TARGET" -t nuclei-templates/http/misconfiguration/cors* -o "$OUTPUT_DIR/cors.txt" -silent 2>/dev/null
    
    echo -e "${YELLOW}[2.3] XSS detection${NC}"
    cat "$OUTPUT_DIR/../recon/params.txt" 2>/dev/null | head -100 | while read param; do
        echo "https://$TARGET/?$param=test" | dalfox pipe --silence -o "$OUTPUT_DIR/xss.txt" 2>/dev/null
    done
    
    echo -e "${YELLOW}[2.4] SQL Injection${NC}"
    cat "$OUTPUT_DIR/../recon/wayback.txt" 2>/dev/null | grep "=" | head -50 | sqlmap --batch --level=1 --risk=1 --output-dir="$OUTPUT_DIR/sqlmap" 2>/dev/null
    
    echo -e "${YELLOW}[2.5] SSRF detection${NC}"
    echo "https://$TARGET" | nuclei -t nuclei-templates/http/vulnerabilities/ssrf* -o "$OUTPUT_DIR/ssrf.txt" -silent 2>/dev/null
    
    echo -e "${YELLOW}[2.6] Open redirect${NC}"
    echo "https://$TARGET" | nuclei -t nuclei-templates/http/vulnerabilities/redirect* -o "$OUTPUT_DIR/redirect.txt" -silent 2>/dev/null
    
    echo -e "${YELLOW}[2.7] IDOR detection${NC}"
    nuclei -u "https://$TARGET" -t nuclei-templates/http/vulnerabilities/idor* -o "$OUTPUT_DIR/idor.txt" -silent 2>/dev/null
    
    echo -e "${GREEN}[✓] Escaneo de vulnerabilidades completado${NC}"
}

# ============================================
# FASE 3: FUERZA BRUTA AVANZADA
# ============================================

advanced_bruteforce() {
    local TARGET="$1"
    local OUTPUT_DIR="$REPORTS_DIR/$TARGET/brute"
    
    mkdir -p "$OUTPUT_DIR"
    
    echo -e "${CYAN}[3/8] FUERZA BRUTA AVANZADA${NC}"
    
    echo -e "${YELLOW}[3.1] Directory fuzzing${NC}"
    feroxbuster -u "https://$TARGET" -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt -o "$OUTPUT_DIR/dirs.txt" -q 2>/dev/null
    
    echo -e "${YELLOW}[3.2] VHost fuzzing${NC}"
    feroxbuster -u "https://$TARGET" -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt --vhosts -o "$OUTPUT_DIR/vhosts.txt" -q 2>/dev/null
    
    echo -e "${YELLOW}[3.3] Parameter fuzzing${NC}"
    ffuf -u "https://$TARGET/FUZZ" -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt -o "$OUTPUT_DIR/ffuf.txt" -q 2>/dev/null
    
    echo -e "${GREEN}[✓] Fuerza bruta completada${NC}"
}

# ============================================
# FASE 4: SECRETS Y API KEYS
# ============================================

secrets_hunting() {
    local TARGET="$1"
    local OUTPUT_DIR="$REPORTS_DIR/$TARGET/secrets"
    
    mkdir -p "$OUTPUT_DIR"
    
    echo -e "${CYAN}[4/8] HUNTING DE SECRETOS${NC}"
    
    echo -e "${YELLOW}[4.1] JS secrets${NC}"
    cat "$OUTPUT_DIR/../recon/js_endpoints.txt" 2>/dev/null | while read url; do
        curl -s "$url" 2>/dev/null | grep -iE "(api_key|apikey|secret|token|password|aws|azure|gcp|firebase)" >> "$OUTPUT_DIR/js_secrets.txt"
    done
    
    echo -e "${YELLOW}[4.2] GitHub dorking${NC}"
    echo "Repositorios públicos con secretos:"
    echo "  - site:github.com \"$TARGET\" password"
    echo "  - site:github.com \"$TARGET\" api_key"
    echo "  - site:github.com \"$TARGET\" secret"
    
    echo -e "${YELLOW}[4.3] Cloud bucket enumeration${NC}"
    echo "Verificar buckets S3/Azure/GCP:"
    echo "  - https://$TARGET.s3.amazonaws.com"
    echo "  - https://$TARGET.blob.core.windows.net"
    echo "  - https://storage.googleapis.com/$TARGET"
    
    echo -e "${GREEN}[✓] Hunting de secretos completado${NC}"
}

# ============================================
# FASE 5: BUSINESS LOGIC
# ============================================

business_logic() {
    local TARGET="$1"
    
    echo -e "${CYAN}[5/8] BUSINESS LOGIC TESTING${NC}"
    
    echo -e "${YELLOW}Áreas a investigar:${NC}"
    echo "  1. Flujo de autenticación (login, registro, recuperación)"
    echo "  2. Cambio de roles/permisos"
    echo "  3. Rate limiting en acciones sensibles"
    echo "  4. Lógica de pagos/descuentos"
    echo "  5. Manipulación de parámetros ocultos"
    echo "  6. Race conditions"
    echo "  7. Mass assignment"
    echo "  8. IDOR en endpoints no obvios"
    
    echo -e "${GREEN}[✓] Business logic checklist generado${NC}"
}

# ============================================
# FASE 6: API TESTING
# ============================================

api_testing() {
    local TARGET="$1"
    local OUTPUT_DIR="$REPORTS_DIR/$TARGET/api"
    
    mkdir -p "$OUTPUT_DIR"
    
    echo -e "${CYAN}[6/8] API TESTING${NC}"
    
    echo -e "${YELLOW}[6.1] API endpoint discovery${NC}"
    cat "$OUTPUT_DIR/../recon/wayback.txt" 2>/dev/null | grep -iE "(api|v1|v2|v3|graphql|rest)" > "$OUTPUT_DIR/api_endpoints.txt"
    
    echo -e "${YELLOW}[6.2] API documentation${NC}"
    for path in /swagger.json /openapi.json /api-docs /swagger-ui.html /graphql; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$TARGET$path" 2>/dev/null)
        if [ "$STATUS" = "200" ]; then
            echo -e "${GREEN}  ✓ Documentación API encontrada: $path${NC}"
            curl -s "https://$TARGET$path" >> "$OUTPUT_DIR/api_docs.json"
        fi
    done
    
    echo -e "${YELLOW}[6.3] GraphQL introspection${NC}"
    curl -s -X POST "https://$TARGET/graphql" -H "Content-Type: application/json" -d '{"query":"{__schema{types{name,fields{name}}}}"}' > "$OUTPUT_DIR/graphql_schema.json" 2>/dev/null
    
    echo -e "${GREEN}[✓] API testing completado${NC}"
}

# ============================================
# FASE 7: CHAIN ATTACKS
# ============================================

chain_attacks() {
    local TARGET="$1"
    
    echo -e "${CYAN}[7/8] Cadenas de Ataque${NC}"
    
    echo -e "${YELLOW}Combinaciones de alto impacto:${NC}"
    echo ""
    echo "  1. CORS + CSRF → Account takeover"
    echo "  2. XSS + Cookie theft → Session hijacking"
    echo "  3. IDOR + Privilege escalation → Admin access"
    echo "  4. SSRF + Internal services → RCE"
    echo "  5. Open redirect + OAuth → Account takeover"
    echo "  6. Race condition + Financial → Double spending"
    echo "  7. Mass assignment + Role change → Privilege escalation"
    echo "  8. SQL Injection + File read → Full compromise"
}

# ============================================
# FASE 8: REPORTE Y DISCLOSURE
# ============================================

generate_report() {
    local TARGET="$1"
    local OUTPUT_DIR="$REPORTS_DIR/$TARGET"
    local REPORT_FILE="$OUTPUT_DIR/report-$(date +%Y%m%d).md"

    mkdir -p "$OUTPUT_DIR"
    echo -e "${CYAN}[8/8] GENERACIÓN DE REPORTE${NC}"

    cat > "$REPORT_FILE" << 'EOF'
# Bug Bounty Report

## Platform
HackerOne

## Program
[Nombre del programa H1]

## Researcher
RESEARCHER_PLACEHOLDER

## Target
TARGET_PLACEHOLDER

## Date
DATE_PLACEHOLDER

## H1 Report URL
[Se completa después de enviar - hackerone.com/reports/xxxxx]

## Executive Summary
[Brief description of the finding]

## Vulnerability Details

### Type
[SQLi/XSS/SSRF/IDOR/etc.]

### Severity
[HIGH/MEDIUM/LOW]

### CVSS Score
[Score]

### CWE
[CWE-XXX]

## Steps to Reproduce

1. Step 1
2. Step 2
3. Step 3

## Impact
[Description of potential impact]

## Remediation
[Suggested fix]

## References
- [CWE Link]
- [OWASP Link]

## Appendix
[Screenshots, logs, PoC code]
EOF
    
    sed -i "s/TARGET_PLACEHOLDER/$TARGET/" "$REPORT_FILE"
    sed -i "s/DATE_PLACEHOLDER/$(date -Iseconds)/" "$REPORT_FILE"
    sed -i "s/RESEARCHER_PLACEHOLDER/$RESEARCHER/" "$REPORT_FILE"

    echo -e "${GREEN}[✓] Reporte generado: $REPORT_FILE${NC}"
}

# ============================================
# PLATAFORMAS BUG BOUNTY
# ============================================

show_platforms() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  PLATAFORMAS BUG BOUNTY${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Plataformas principales:${NC}"
    echo "  1. HackerOne    - https://hackerone.com"
    echo "  2. Bugcrowd     - https://bugcrowd.com"
    echo "  3. Intigriti    - https://intigriti.com"
    echo "  4. YesWeHack    - https://yeswehack.com"
    echo "  5. Synack       - https://synack.com"
    echo "  6. Cobalt       - https://cobalt.io"
    echo ""
    echo -e "${YELLOW}Programas destacados:${NC}"
    echo "  - Google VRP      - https://bughunters.google.com"
    echo "  - Apple           - https://security.apple.com"
    echo "  - Microsoft       - https://msrc.microsoft.com"
    echo "  - Meta            - https://www.facebook.com白帽"
    echo "  - GitHub          - https://bounty.github.com"
    echo "  - Tesla           - https://www.tesla.com白帽"
}

# ============================================
# 0-DAY RESEARCH
# ============================================

zeroday_research() {
    local TARGET="$1"
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  0-DAY RESEARCH METHODOLOGY${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Pasos para encontrar 0-days:${NC}"
    echo ""
    echo "  1. TARGET SELECTION"
    echo "     - Software open source con gran uso"
    echo "     - Frameworks populares"
    echo "     - Aplicaciones críticas"
    echo ""
    echo "  2. CODE REVIEW"
    echo "     - Auditar código fuente manualmente"
    echo "     - Usar herramientas estáticas (Semgrep, CodeQL)"
    echo "     - Buscar patrones peligrosos"
    echo ""
    echo "  3. FUZZING"
    echo "     - AFL++, LibFuzzer, Honggfuzz"
    echo "     - Mutation-based fuzzing"
    echo "     - Coverage-guided fuzzing"
    echo ""
    echo "  4. ANALYSIS"
    echo "     - Crash analysis"
    echo "     - Root cause analysis"
    echo "     - Exploitability assessment"
    echo ""
    echo "  5. DOCUMENTATION"
    echo "     - PoC creation"
    echo "     - Impact assessment"
    echo "     - Remediation suggestions"
    echo ""
    echo -e "${GREEN}Herramientas para 0-day research:${NC}"
    echo "  - Semgrep      - Static analysis"
    echo "  - CodeQL       - Semantic code analysis"
    echo "  - AFL++        - Fuzzing"
    echo "  - Ghidra       - Reverse engineering"
    echo "  - Binary Ninja - Binary analysis"
    echo "  - Frida        - Dynamic instrumentation"
    echo "  - strace/ltrace - System call tracing"
}

# ============================================
# FASE 9: ENCODING BYPASS TECHNIQUES
# ============================================

encoding_bypass() {
    local TARGET="$1"
    local OUTPUT_DIR="$REPORTS_DIR/$TARGET/encoding"
    
    mkdir -p "$OUTPUT_DIR"
    
    echo -e "${CYAN}[9/9] ENCODING BYPASS TECHNIQUES${NC}"
    
    echo -e "${YELLOW}[9.1] Base64 Encoding${NC}"
    echo "  Payloads para bypass de WAF:"
    echo ""
    echo "  LFI:"
    echo "    Original: url/?f=etc/passwd (403)"
    echo "    Encoded:  url/?f=L2V0Yy9wYXNzd2Q= (200)"
    echo ""
    echo "  Comando para codificar:"
    echo "    echo -n 'etc/passwd' | base64"
    echo "    Resultado: ZXRjL3Bhc3N3ZA=="
    echo ""
    echo "  Payloads comunes:"
    echo "    /etc/passwd        => ZXRjL3Bhc3N3ZA=="
    echo "    /etc/shadow        => ZXRjL3NoYWRvdw=="
    echo "    /etc/hosts         => ZXRjL2hvc3Rz"
    echo "    C:\\Windows\\System32 => QzpcV2luZG93c1xTeXN0ZW0zMg=="
    echo ""
    
    echo -e "${YELLOW}[9.2] Double URL Encoding${NC}"
    echo "  Payloads para bypass:"
    echo ""
    echo "  Single URL encode:"
    echo "    < = %3C"
    echo "    > = %3E"
    echo "    / = %2F"
    echo "    ' = %27"
    echo "    \" = %22"
    echo ""
    echo "  Double URL encode:"
    echo "    < = %253C"
    echo "    > = %253E"
    echo "    / = %252F"
    echo ""
    echo "  Triple encode:"
    echo "    < = %25253C"
    echo ""
    
    echo -e "${YELLOW}[9.3] Unicode Encoding${NC}"
    echo "  Payloads para bypass:"
    echo ""
    echo "  SQL Injection:"
    echo "    ' = \\u0027"
    echo "    \" = \\u0022"
    echo "    OR = \\u004F\\u0052"
    echo ""
    echo "  XSS:"
    echo "    < = \\u003C"
    echo "    > = \\u003E"
    echo "    script = \\u0073\\u0063\\u0072\\u0069\\u0070\\u0074"
    echo ""
    
    echo -e "${YELLOW}[9.4] HTML Entity Encoding${NC}"
    echo "  Payloads para bypass:"
    echo ""
    echo "  < = &#60; or &#x3C;"
    echo "  > = &#62; or &#x3E;"
    echo "  ' = &#39; or &#x27;"
    echo "  \" = &#34; or &#x22;"
    echo "  & = &#38; or &#x26;"
    echo ""
    
    echo -e "${YELLOW}[9.5] Mixed Encoding Attacks${NC}"
    echo "  Combinaciones para bypass:"
    echo ""
    echo "  SQL Injection:"
    echo "    ' OR 1=1 --"
    echo "    => %27%20OR%201%3D1%20--"
    echo "    => %27%20%4F%52%201%3D1%20--"
    echo "    => \\u0027 \\u004F\\u0052 1=1 --"
    echo ""
    echo "  XSS:"
    echo "    <script>alert(1)</script>"
    echo "    => %3Cscript%3Ealert(1)%3C/script%3E"
    echo "    => \\u003Cscript\\u003Ealert(1)\\u003C/script\\u003E"
    echo "    => &#60;script&#62;alert(1)&#60;/script&#62;"
    echo ""
    echo "  LFI:"
    echo "    ../../etc/passwd"
    echo "    => ..%2F..%2F..%2Fetc%2Fpasswd"
    echo "    => ....//....//....//etc/passwd"
    echo "    => ..%252F..%252F..%252Fetc%252Fpasswd"
    echo ""
    
    echo -e "${YELLOW}[9.6] Case Manipulation${NC}"
    echo "  Payloads para bypass:"
    echo ""
    echo "  SQL Keywords:"
    echo "    SELECT => SeLeCt, sElEcT, sELECT"
    echo "    UNION => UnIoN, uNiOn, UNION"
    echo "    FROM => FrOm, fRoM, FROM"
    echo ""
    echo "  Tags HTML:"
    echo "    <ScRiPt>, <SCRIPT>, <sCrIpT>"
    echo ""
    
    echo -e "${YELLOW}[9.7] Null Byte Injection${NC}"
    echo "  Payloads para bypass:"
    echo ""
    echo "  LFI:"
    echo "    /etc/passwd%00"
    echo "    /etc/passwd.jpg%00"
    echo "    /etc/passwd%00.png"
    echo ""
    
    echo -e "${YELLOW}[9.8] Comment Injection${NC}"
    echo "  Payloads para bypass:"
    echo ""
    echo "  SQL Injection:"
    echo "    ' /*!UNION*/ /*!SELECT*/ 1,2,3 --"
    echo "    ' /*!50000UNION*/ /*!50000SELECT*/ 1,2,3 --"
    echo ""
    echo "  PHP:"
    echo "    /?file=....//....//etc/passwd"
    echo ""
    
    echo -e "${YELLOW}[9.9] Encoding Tools${NC}"
    echo "  Herramientas útiles:"
    echo ""
    echo "  Base64:"
    echo "    echo -n 'payload' | base64"
    echo "    echo 'encoded' | base64 -d"
    echo ""
    echo "  URL Encode:"
    echo "    python3 -c 'import urllib.parse; print(urllib.parse.quote(\"payload\"))'"
    echo "    python3 -c 'import urllib.parse; print(urllib.parse.unquote(\"encoded\"))'"
    echo ""
    echo "  Hex:"
    echo "    echo -n 'payload' | xxd -p"
    echo "    echo 'hex' | xxd -r -p"
    echo ""
    
    echo -e "${GREEN}[✓] Encoding bypass techniques listadas${NC}"
}

# ============================================
# MAIN
# ============================================

print_banner

case "${1:-help}" in
    new)
        new_program "$2"
        ;;
    scope)
        check_scope "$2"
        ;;
    resolve)
        resolve_check "$2"
        ;;
    recon)
        check_scope "$2" || exit 1
        reconnaissance "$2"
        ;;
    vuln)
        check_scope "$2" || exit 1
        vuln_scan "$2"
        ;;
    brute)
        check_scope "$2" || exit 1
        advanced_bruteforce "$2"
        ;;
    secrets)
        check_scope "$2" || exit 1
        secrets_hunting "$2"
        ;;
    api)
        check_scope "$2" || exit 1
        api_testing "$2"
        ;;
    report)
        generate_report "$2"
        ;;
    platforms)
        show_platforms
        ;;
    zeroday)
        zeroday_research "$2"
        ;;
    encode|encoding|bypass)
        encoding_bypass "$2"
        ;;
    full)
        TARGET="$2"
        if [ -z "$TARGET" ]; then
            echo -e "${RED}Uso: $0 full <domain>${NC}"
            exit 1
        fi
        check_scope "$TARGET" || exit 1
        reconnaissance "$TARGET"
        vuln_scan "$TARGET"
        advanced_bruteforce "$TARGET"
        secrets_hunting "$TARGET"
        api_testing "$TARGET"
        business_logic "$TARGET"
        chain_attacks "$TARGET"
        encoding_bypass "$TARGET"
        generate_report "$TARGET"
        ;;
    *)
        echo ""
        echo "Uso: $0 <comando> [target]"
        echo ""
        echo "Comandos:"
        echo "  new <programa>    - Crear archivo de scope para un programa H1"
        echo "  scope <domain>    - Verificar si un target está en scope"
        echo "  resolve <host>    - Detectar DNS hijack/bloqueo (local vs 8.8.8.8)"
        echo "  full <domain>     - Pipeline completo (recon->report)"
        echo "  recon <domain>    - Solo reconocimiento"
        echo "  vuln <domain>     - Solo vulnerabilidades"
        echo "  brute <domain>    - Solo fuerza bruta"
        echo "  secrets <domain>  - Solo secretos"
        echo "  api <domain>      - Solo APIs"
        echo "  encode <domain>   - Encoding bypass techniques"
        echo "  report <domain>   - Generar reporte"
        echo "  platforms         - Ver plataformas"
        echo "  zeroday           - Metodología 0-day"
        echo ""
        echo "Researcher actual: $RESEARCHER (cambia con BB_RESEARCHER=handle)"
        echo "Scope tracker: $PROGRAMS_DIR"
        echo ""
        ;;
esac
