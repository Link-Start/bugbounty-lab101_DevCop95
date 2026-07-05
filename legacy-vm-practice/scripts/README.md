# Scripts del Lab

## Scripts Disponibles

### 1. download_vms.sh
Script interactivo para descargar VMs vulnerables.

```bash
chmod +x scripts/download_vms.sh
./scripts/download_vms.sh
```

### 2. setup_network.sh
Configura la red Host-Only para el lab.

```bash
chmod +x scripts/setup_network.sh
sudo ./scripts/setup_network.sh
```

### 3. start_lab.sh
Inicia todas las VMs del lab.

```bash
chmod +x scripts/start_lab.sh
./scripts/start_lab.sh
```

### 4. verify_lab.sh
Verifica el estado de todas las VMs.

```bash
chmod +x scripts/verify_lab.sh
./scripts/verify_lab.sh
```

## Inicio Rápido

```bash
# 1. Dar permisos a todos los scripts
chmod +x scripts/*.sh

# 2. Configurar red
sudo ./scripts/setup_network.sh

# 3. Descargar VMs
./scripts/download_vms.sh

# 4. Iniciar lab
./scripts/start_lab.sh

# 5. Verificar
./scripts/verify_lab.sh
```

## Requisitos

- VirtualBox 7.x
- Docker (opcional, para DVWA)
- nmap (pre-instalado en Kali)
- curl

## Solución de Problemas

### Las VMs no se comunican
1. Verificar que todas estén en Host-Only Adapter
2. Desactivar firewall temporalmente
3. Verificar IPs estáticas

### Docker no funciona
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### No hay Internet en Kali
```bash
# Verificar interfaz NAT
ip addr show

# Restart networking
sudo systemctl restart networking
```
