#!/bin/bash
# ============================================
# Script para descargar VMs vulnerables
# ============================================

set -e

DOWNLOAD_DIR="$(dirname "$0")/../vms"
mkdir -p "$DOWNLOAD_DIR"

echo "============================================"
echo "  Descargador de VMs Vulnerables"
echo "============================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para mostrar menú
show_menu() {
    echo "Selecciona las VMs a descargar:"
    echo ""
    echo "  1) Metasploitable 2 (Linux vulnerable) - 1.8GB"
    echo "  2) DVWA (Web vulnerable) - Docker"
    echo "  3) OWASP BWA (Web apps vulnerables) - 4GB"
    echo "  4) Windows XP (Legacy vulnerable) - 1.5GB"
    echo "  5) Todas las anteriores"
    echo "  0) Salir"
    echo ""
}

# Metasploitable 2
download_metasploitable() {
    echo ""
    echo -e "${GREEN}[*] Metasploitable 2${NC}"
    echo "URL: https://sourceforge.net/projects/metasploitable/files/Metasploitable2/metasploitable2-vm-0.0.1.zip"
    echo ""
    echo "Pasos:"
    echo "  1. Descarga el ZIP desde la URL anterior"
    echo "  2. Descomprime en: $DOWNLOAD_DIR/"
    echo "  3. Importa en VirtualBox (Archivo → Importar)"
    echo "  4. Configura red: Host-Only Adapter"
    echo "  5. IP estática: 192.168.56.200"
    echo ""
}

# DVWA con Docker
setup_dvwa_docker() {
    echo ""
    echo -e "${GREEN}[*] DVWA con Docker${NC}"
    echo ""
    
    if command -v docker &> /dev/null; then
        echo "Docker detectado. Instalando DVWA..."
        echo ""
        
        # Pull image
        docker pull vulnerables/web-dvwa
        
        # Run container
        echo "Iniciando DVWA..."
        docker run --rm -d --name dvwa -p 80:80 vulnerables/web-dvwa
        
        echo ""
        echo -e "${GREEN}[+] DVWA ejecutándose en: http://localhost${NC}"
        echo "Credenciales: admin / password"
        echo ""
        echo "Para detener: docker stop dvwa"
    else
        echo -e "${YELLOW}[!] Docker no encontrado${NC}"
        echo ""
        echo "Opción 1: Instalar Docker"
        echo "  sudo apt install docker.io"
        echo "  sudo usermod -aG docker \$USER"
        echo "  newgrp docker"
        echo ""
        echo "Opción 2: Descargar VM"
        echo "  Busca 'DVWA' en: https://www.vulnhub.com/"
    fi
}

# OWASP BWA
download_owasp_bwa() {
    echo ""
    echo -e "${GREEN}[*] OWASP Broken Web Applications${NC}"
    echo "URL: https://sourceforge.net/projects/owaspbwa/files/"
    echo ""
    echo "Pasos:"
    echo "  1. Descarga el ISO/OVA desde SourceForge"
    echo "  2. Importa en VirtualBox"
    echo "  3. Configura red: Host-Only Adapter"
    echo "  4. IP estática: 192.168.56.202"
    echo ""
}

# Windows XP
download_windows_xp() {
    echo ""
    echo -e "${GREEN}[*] Windows XP${NC}"
    echo "NOTA: Necesitas una licencia de Windows XP"
    echo ""
    echo "Alternativa: Usa Windows 7 Enterprise trial"
    echo "URL: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-7-enterprise"
    echo ""
    echo "Pasos:"
    echo "  1. Descarga la ISO"
    echo "  2. Crea VM en VirtualBox"
    echo "  3. Instala Windows"
    echo "  4. Configura red: Host-Only Adapter"
    echo "  5. IP estática: 192.168.56.203"
    echo ""
}

# Menú principal
while true; do
    show_menu
    read -p "Selecciona una opción: " choice
    
    case $choice in
        1)
            download_metasploitable
            ;;
        2)
            setup_dvwa_docker
            ;;
        3)
            download_owasp_bwa
            ;;
        4)
            download_windows_xp
            ;;
        5)
            download_metasploitable
            setup_dvwa_docker
            download_owasp_bwa
            download_windows_xp
            ;;
        0)
            echo ""
            echo "¡Buena suerte con tu lab!"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción no válida${NC}"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
    clear
done
