#!/bin/bash
# ============================================
# Verificar estado del lab
# ============================================

echo "[*] Verificando estado del lab..."
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar conectividad
check_host() {
    local ip="$1"
    local name="$2"
    
    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        echo -e "${GREEN}[+]${NC} $name ($ip) - ONLINE"
        return 0
    else
        echo -e "${RED}[-]${NC} $name ($ip) - OFFLINE"
        return 1
    fi
}

# Verificar servicios HTTP
check_web() {
    local url="$1"
    local name="$2"
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|301\|302"; then
        echo -e "${GREEN}[+]${NC} $name - RESPONDIENDO"
        return 0
    else
        echo -e "${RED}[-]${NC} $name - NO RESPONDE"
        return 1
    fi
}

echo "============================================"
echo "VERIFICACIÓN DEL LAB"
echo "============================================"
echo ""

# Verificar hosts
echo "[*] Hosts:"
check_host "192.168.56.100" "Kali Linux"
check_host "192.168.56.200" "Metasploitable"
check_host "192.168.56.201" "DVWA"
check_host "192.168.56.202" "OWASP BWA"
echo ""

# Verificar servicios web
echo "[*] Servicios Web:"
check_web "http://192.168.56.200" "Metasploitable Web"
check_web "http://192.168.56.201" "DVWA"
check_web "http://192.168.56.202" "OWASP BWA"
echo ""

# Verificar puertos abiertos en Metasploitable
echo "[*] Puertos abiertos en Metasploitable (192.168.56.200):"
if command -v nmap &> /dev/null; then
    nmap -sT --top-ports 20 192.168.56.200 -oG - 2>/dev/null | grep "open" | awk '{print "    " $2 ": " $3}' | sed 's/\/open//g'
else
    echo "    [!] nmap no encontrado. Instálalo con: sudo apt install nmap"
fi
echo ""

echo "============================================"
echo "COMANDOS ÚTILES"
echo "============================================"
echo ""
echo "  Escaneo completo:    nmap -sV -sC 192.168.56.200"
echo "  Escaneo web:         nikto -h http://192.168.56.201"
echo "  Dirbusting:          dirb http://192.168.56.201"
echo "  SQL Injection:       sqlmap -u 'http://192.168.56.201/vulnerabilities/sqli/'"
echo ""
echo "============================================"
