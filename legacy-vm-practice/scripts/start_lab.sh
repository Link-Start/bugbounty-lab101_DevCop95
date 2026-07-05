#!/bin/bash
# ============================================
# Iniciar lab de pentesting
# ============================================

set -e

echo "[*] Iniciando lab de pentesting..."
echo ""

# Verificar que VirtualBox esté instalado
if ! command -v VBoxManage &> /dev/null; then
    echo "[-] VirtualBox no encontrado. Instálalo primero."
    exit 1
fi

# Listar VMs disponibles
echo "[*] VMs disponibles:"
VBoxManage list vms | grep -E "Metasploitable|DVWA|OWASP|Windows|Debian"
echo ""

# Función para iniciar VM
start_vm() {
    local vm_name="$1"
    local vm_state=$(VBoxManage showvminfo "$vm_name" --machinereadable 2>/dev/null | grep "VMState=" | cut -d'"' -f2)
    
    if [ "$vm_state" = "running" ]; then
        echo "[+] $vm_name ya está corriendo"
    else
        echo "[*] Iniciando $vm_name..."
        VBoxManage startvm "$vm_name" --type headless 2>/dev/null || echo "[-] No se pudo iniciar $vm_name"
    fi
}

# Iniciar VMs del lab
echo "[*] Iniciando VMs del lab..."
echo ""

# Intentar iniciar cada VM (ignorar si no existe)
for vm in "Metasploitable2" "Metasploitable" "DVWA" "OWASP_BWA" "Windows XP" "Windows 7"; do
    VBoxManage showvminfo "$vm" &>/dev/null && start_vm "$vm" &
done

wait

echo ""
echo "[*] Esperando a que las VMs estén listas..."
sleep 10

echo ""
echo "============================================"
echo "LAB INICIADO"
echo "============================================"
echo ""
echo "Verificar con: ./verify_lab.sh"
echo ""
echo "IPs del lab:"
echo "  Kali:       192.168.56.100"
echo "  Metasploit: 192.168.56.200"
echo "  DVWA:       http://192.168.56.201"
echo "  OWASP BWA:  http://192.168.56.202"
echo ""
echo "============================================"
