#!/bin/bash
# ============================================
# Configurar red del lab de pentesting
# ============================================

set -e

echo "[*] Configurando red del lab..."

# Detectar VirtualBox
if command -v VBoxManage &> /dev/null; then
    echo "[+] VirtualBox detectado"
    
    # Crear red Host-Only si no existe
    echo "[*] Verificando red Host-Only..."
    HOST_ONLY=$(VBoxManage list hostonlyifs | grep "Name:" | head -1 | awk '{print $2}')
    
    if [ -z "$HOST_ONLY" ]; then
        echo "[*] Creando interfaz Host-Only..."
        VBoxManage hostonlyif create
        HOST_ONLY=$(VBoxManage list hostonlyifs | grep "Name:" | head -1 | awk '{print $2}')
    fi
    
    echo "[+] Usando interfaz: $HOST_ONLY"
    
    # Configurar IP de la interfaz Host-Only
    echo "[*] Configurando IP 192.168.56.1 en $HOST_ONLY..."
    VBoxManage hostonlyif ipconfig "$HOST_ONLY" --ip 192.168.56.1 --netmask 255.255.255.0
    
    echo "[+] Red configurada exitosamente"
    
else
    echo "[-] VirtualBox no encontrado"
    echo "    Instala VirtualBox o configura la red manualmente"
fi

echo ""
echo "============================================"
echo "CONFIGURACIÓN DE RED:"
echo "============================================"
echo ""
echo "  Red:        192.168.56.0/24"
echo "  Gateway:    192.168.56.1 (tu máquina)"
echo "  Kali:       192.168.56.100"
echo "  Metasploit: 192.168.56.200"
echo "  DVWA:       192.168.56.201"
echo "  OWASP BWA:  192.168.56.202"
echo ""
echo "============================================"
