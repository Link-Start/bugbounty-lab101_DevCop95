# Configuración de Red del Lab

## Topología de Red

```
                    INTERNET
                        │
                        │ (NAT)
                        │
    ┌───────────────────┴───────────────────┐
    │              TU MÁQUINA                │
    │              Kali Linux                │
    │           192.168.56.100               │
    └───────────────────┬───────────────────┘
                        │
                        │ (Host-Only)
                        │
    ┌───────────────────┴───────────────────┐
    │         RED HOST-ONLY                  │
    │         192.168.56.0/24                │
    │                                        │
    │  ┌─────────┐  ┌─────────┐  ┌────────┐ │
    │  │  Kali   │  │Metasplo │  │  DVWA  │ │
    │  │ .56.100 │  │ .56.200 │  │ .56.201│ │
    │  └─────────┘  └─────────┘  └────────┘ │
    │                                        │
    │  ┌─────────┐  ┌─────────┐  ┌────────┐ │
    │  │OWASP BWA│  │ Windows │  │ Debian │ │
    │  │ .56.202 │  │ .56.203 │  │ .56.204│ │
    │  └─────────┘  └─────────┘  └────────┘ │
    └────────────────────────────────────────┘
```

## Asignación de IPs

| Dispositivo | IP | Servicios |
|-------------|-----|-----------|
| Kali Linux | 192.168.56.100 | Herramientas de pentesting |
| Metasploitable 2 | 192.168.56.200 | FTP, SSH, HTTP, SMB, MySQL, etc. |
| DVWA | 192.168.56.201 | Apache, MySQL, PHP |
| OWASP BWA | 192.168.56.202 | Múltiples apps web vulnerables |
| Windows XP | 192.168.56.203 | SMB, RDP |
| Debian Server | 192.168.56.204 | Apache, SSH, FTP |

## Configuración en VirtualBox

### Paso 1: Crear Red Host-Only
```bash
# En VirtualBox
File → Host Network Manager → Create
# Nota el nombre de la interfaz (ej: vboxnet0)
```

### Paso 2: Configurar IPs
```bash
# Configurar interfaz Host-Only
sudo ifconfig vboxnet0 192.168.56.1 netmask 255.255.255.0 up
```

### Paso 3: Configurar Cada VM
```
Settings → Network → Adapter 2
  Attached to: Host-Only Adapter
  Name: vboxnet0
  Promiscuous Mode: Allow All
```

## Configuración de IP Estática en Kali

### Editar `/etc/network/interfaces`
```
# Interface Host-Only
auto eth1
iface eth1 inet static
    address 192.168.56.100
    netmask 255.255.255.0
    network 192.168.56.0
    broadcast 192.168.56.255
```

### Restart Networking
```bash
sudo systemctl restart networking
```

## Verificación de Red

```bash
# Ver interfaces
ip addr show

# Ping a targets
ping -c 3 192.168.56.200
ping -c 3 192.168.56.201

# Verificar puertos
nmap -sn 192.168.56.0/24

# Ver tráfico
sudo tcpdump -i vboxnet0
```

## Reglas de Firewall (Opcional)

### Permitir solo tráfico del lab
```bash
# En Kali
sudo iptables -A OUTPUT -d 192.168.56.0/24 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.56.0/24 -j DROP
```

### NAT para acceso a Internet
```bash
# En Kali (si necesitas Internet en las VMs)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
```

## Troubleshooting

### Las VMs no se ven entre sí
1. Verificar que todas estén en Host-Only Adapter
2. Desactivar firewall temporalmente
3. Verificar IPs estáticas

### No hay Internet en Kali
1. Verificar que Adapter 1 esté en NAT
2. Verificar que eth0 tenga IP DHCP

### Servicios no responden
1. Verificar que el servicio esté corriendo en la VM
2. Verificar firewall dentro de la VM
3. Verificar que el puerto esté abierto
