#!/bin/bash
# ============================================
# GitHub Repo Scanner
# ============================================
# Uso: ./github-scan.sh <usuario/repo>
# 
# Escanea un repositorio de GitHub en busca de:
# - Archivos sensibles expuestos
# - Secrets hardcodeados
# - Configuraciones inseguras
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
    echo -e "${RED}Uso: $0 <usuario/repo>${NC}"
    echo "Ejemplo: $0 tu-usuario/tu-repo"
    exit 1
fi

REPO="$1"
REPO_URL="https://github.com/$REPO"
API_URL="https://api.github.com/repos/$REPO"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                GITHUB REPO SCANNER v1.0                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}Repositorio:${NC} $REPO_URL"
echo ""

# 1. Información del repo
echo -e "${YELLOW}[1/6]${NC} Obteniendo información del repositorio..."
REPO_INFO=$(curl -s "$API_URL")

if echo "$REPO_INFO" | grep -q '"message": "Not Found"'; then
    echo -e "${RED}  ✗ Repositorio no encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ Repositorio encontrado${NC}"
echo "    Nombre: $(echo "$REPO_INFO" | grep -o '"full_name":"[^"]*"' | cut -d'"' -f4)"
echo "    Descripción: $(echo "$REPO_INFO" | grep -o '"description":"[^"]*"' | cut -d'"' -f4)"
echo "    Estrellas: $(echo "$REPO_INFO" | grep -o '"stargazers_count":[0-9]*' | cut -d: -f2)"
echo "    Issues: $(echo "$REPO_INFO" | grep -o '"open_issues_count":[0-9]*' | cut -d: -f2)"
echo ""

# 2. Verificar archivos sensibles
echo -e "${YELLOW}[2/6]${NC} Buscando archivos sensibles..."
echo ""

SENSITIVE_FILES=(
    ".env"
    ".env.local"
    ".env.production"
    ".env.development"
    ".git/config"
    ".git/credentials"
    "config/database.yml"
    "config/secrets.yml"
    "wp-config.php"
    "config.php"
    "configuration.php"
    "settings.py"
    "credentials.json"
    "service-account.json"
    "id_rsa"
    "id_dsa"
    "id_ecdsa"
    "id_ed25519"
    ".htpasswd"
    ".htaccess"
    "web.config"
    "appsettings.json"
    "appsettings.Development.json"
    "local.settings.json"
    "firebase.json"
    "gcloud.json"
    "key.json"
    "private.key"
    "private.pem"
)

FOUND_SENSITIVE=0

for file in "${SENSITIVE_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://raw.githubusercontent.com/$REPO/master/$file" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${RED}  ✗ $file - EXPUESTO${NC}"
        FOUND_SENSITIVE=$((FOUND_SENSITIVE + 1))
    fi
    
    # También verificar rama main
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://raw.githubusercontent.com/$REPO/main/$file" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${RED}  ✗ $file (main) - EXPUESTO${NC}"
        FOUND_SENSITIVE=$((FOUND_SENSITIVE + 1))
    fi
done

if [ $FOUND_SENSITIVE -eq 0 ]; then
    echo -e "${GREEN}  ✓ No se encontraron archivos sensibles expuestos${NC}"
fi
echo ""

# 3. Verificar .git expuesto
echo -e "${YELLOW}[3/6]${NC} Verificando si .git está expuesto..."
GIT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$REPO_URL/.git/config" 2>/dev/null)

if [ "$GIT_STATUS" = "200" ]; then
    echo -e "${RED}  ✗ .git está expuesto públicamente${NC}"
else
    echo -e "${GREEN}  ✓ .git no está expuesto${NC}"
fi
echo ""

# 4. Buscar secrets en el código
echo -e "${YELLOW}[4/6]${NC} Buscando potenciales secrets hardcodeados..."
echo ""

# Usar la API de búsqueda de GitHub
SEARCH_QUERIES=(
    "password"
    "api_key"
    "secret"
    "token"
    "AWS_ACCESS_KEY"
    "PRIVATE KEY"
)

for query in "${SEARCH_QUERIES[@]}"; do
    RESULTS=$(curl -s "https://api.github.com/search/code?q=$query+repo:$REPO&per_page=3" 2>/dev/null)
    COUNT=$(echo "$RESULTS" | grep -o '"total_count":[0-9]*' | cut -d: -f2)
    
    if [ -n "$COUNT" ] && [ "$COUNT" -gt 0 ]; then
        echo -e "${YELLOW}  ⚠ $query - $COUNT resultados${NC}"
    fi
done
echo ""

# 5. Verificar dependencias
echo -e "${YELLOW}[5/6]${NC} Verificando archivos de dependencias..."
echo ""

DEP_FILES=("package.json" "requirements.txt" "Gemfile" "composer.json" "go.mod" "Cargo.toml")

for file in "${DEP_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://raw.githubusercontent.com/$REPO/master/$file" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${GREEN}  ✓ $file encontrado${NC}"
    fi
done
echo ""

# 6. Verificar CI/CD
echo -e "${YELLOW}[6/6]${NC} Verificando configuración CI/CD..."
echo ""

CI_FILES=(".github/workflows" ".travis.yml" "Jenkinsfile" ".circleci/config.yml" "azure-pipelines.yml")

for file in "${CI_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://raw.githubusercontent.com/$REPO/master/$file" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${GREEN}  ✓ $file encontrado${NC}"
    fi
done
echo ""

# Resumen
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Escaneo completado${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ $FOUND_SENSITIVE -gt 0 ]; then
    echo -e "${RED}⚠ ADVERTENCIA: Se encontraron $FOUND_SENSITIVE archivos sensibles expuestos${NC}"
    echo ""
    echo "ACCIONES RECOMENDADAS:"
    echo "1. Mover los archivos sensibles a .gitignore"
    echo "2. Rotar todos los secrets expuestos"
    echo "3. Usar variables de entorno o GitHub Secrets"
    echo "4. Revisar el historial de git para secrets anteriores"
else
    echo -e "${GREEN}✓ No se encontraron problemas críticos de seguridad${NC}"
fi
echo ""
echo "Para más información:"
echo "  https://github.com/$REPO"
echo ""
