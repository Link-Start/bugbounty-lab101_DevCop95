#!/bin/bash
# ============================================
# GitHub Repo Scanner
# ============================================
# Usage: ./github-scan.sh <user/repo>
# 
# Scans a GitHub repository for:
# - Exposed sensitive files
# - Hardcoded secrets
# - Insecure configurations
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <user/repo>${NC}"
    echo "Example: $0 your-user/your-repo"
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

echo -e "${BLUE}Repository:${NC} $REPO_URL"
echo ""

# 1. Repository information
echo -e "${YELLOW}[1/6]${NC} Getting repository information..."
REPO_INFO=$(curl -s "$API_URL")

if echo "$REPO_INFO" | grep -q '"message": "Not Found"'; then
    echo -e "${RED}  ✗ Repository not found${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ Repository found${NC}"
echo "    Name: $(echo "$REPO_INFO" | grep -o '"full_name":"[^"]*"' | cut -d'"' -f4)"
echo "    Description: $(echo "$REPO_INFO" | grep -o '"description":"[^"]*"' | cut -d'"' -f4)"
echo "    Stars: $(echo "$REPO_INFO" | grep -o '"stargazers_count":[0-9]*' | cut -d: -f2)"
echo "    Issues: $(echo "$REPO_INFO" | grep -o '"open_issues_count":[0-9]*' | cut -d: -f2)"
echo ""

# 2. Check sensitive files
echo -e "${YELLOW}[2/6]${NC} Searching for sensitive files..."
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
        echo -e "${RED}  ✗ $file - EXPOSED${NC}"
        FOUND_SENSITIVE=$((FOUND_SENSITIVE + 1))
    fi
    
    # Also check main branch
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://raw.githubusercontent.com/$REPO/main/$file" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${RED}  ✗ $file (main) - EXPOSED${NC}"
        FOUND_SENSITIVE=$((FOUND_SENSITIVE + 1))
    fi
done

if [ $FOUND_SENSITIVE -eq 0 ]; then
    echo -e "${GREEN}  ✓ No exposed sensitive files found${NC}"
fi
echo ""

# 3. Check exposed .git
echo -e "${YELLOW}[3/6]${NC} Checking if .git is exposed..."
GIT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$REPO_URL/.git/config" 2>/dev/null)

if [ "$GIT_STATUS" = "200" ]; then
    echo -e "${RED}  ✗ .git is publicly exposed${NC}"
else
    echo -e "${GREEN}  ✓ .git is not exposed${NC}"
fi
echo ""

# 4. Search for secrets in code
echo -e "${YELLOW}[4/6]${NC} Searching for potential hardcoded secrets..."
echo ""

# Use GitHub search API
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
        echo -e "${YELLOW}  ⚠ $query - $COUNT results${NC}"
    fi
done
echo ""

# 5. Check dependencies
echo -e "${YELLOW}[5/6]${NC} Checking dependency files..."
echo ""

DEP_FILES=("package.json" "requirements.txt" "Gemfile" "composer.json" "go.mod" "Cargo.toml")

for file in "${DEP_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://raw.githubusercontent.com/$REPO/master/$file" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${GREEN}  ✓ $file encontrado${NC}"
    fi
done
echo ""

# 6. Check CI/CD
echo -e "${YELLOW}[6/6]${NC} Checking CI/CD configuration..."
echo ""

CI_FILES=(".github/workflows" ".travis.yml" "Jenkinsfile" ".circleci/config.yml" "azure-pipelines.yml")

for file in "${CI_FILES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://raw.githubusercontent.com/$REPO/master/$file" 2>/dev/null)
    
    if [ "$STATUS" = "200" ]; then
        echo -e "${GREEN}  ✓ $file encontrado${NC}"
    fi
done
echo ""

# Summary
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Scan completed${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ $FOUND_SENSITIVE -gt 0 ]; then
    echo -e "${RED}⚠ WARNING: $FOUND_SENSITIVE exposed sensitive files found${NC}"
    echo ""
    echo "RECOMMENDED ACTIONS:"
    echo "1. Move sensitive files to .gitignore"
    echo "2. Rotate all exposed secrets"
    echo "3. Use environment variables or GitHub Secrets"
    echo "4. Review git history for previous secrets"
else
    echo -e "${GREEN}✓ No critical security issues found${NC}"
fi
echo ""
echo "For more information:"
echo "  https://github.com/$REPO"
echo ""
