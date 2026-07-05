# Auto-Pentester Pro - Sistema Completo de Pentesting

## Descripción

Sistema automatizado de pentesting con más de 100 herramientas Kali Linux organizadas por categoría y fase de ataque.

## Estructura

```
auto-scanner/
├── pentest.sh              # Comando unificado
├── autopentest.sh          # Escaneo básico
├── autopentest-pro.sh      # Escaneo Pro (recomendado)
├── quickscan.sh            # Escaneo rápido
├── github-scan.sh          # Escaneo GitHub
├── tool-checker.sh         # Verificador de herramientas
├── tools/
│   └── registry.sh         # Base de datos de herramientas
├── reports/                # Reportes generados
└── README.md
```

## Comandos

### Escaneo Completo (Pro)
```bash
./pentest.sh https://tu-sitio.com
# o
./autopentest-pro.sh https://tu-sitio.com
```

### Escaneo Rápido
```bash
./pentest.sh quick https://tu-sitio.com
```

### Escaneo GitHub
```bash
./pentest.sh github tu-usuario/tu-repo
```

### Ver Herramientas
```bash
./pentest.sh tools
```

### Ver Matriz de Fases
```bash
./pentest.sh matrix
```

### Buscar Herramienta
```bash
./pentest.sh search sql_injection
./pentest.sh search smb
./pentest.sh search wifi
```

### Instalar Herramientas Faltantes
```bash
./pentest.sh install
```

## Matriz de Herramientas por Fase

### FASE 1: RECONOCIMIENTO
| Herramienta | Uso |
|-------------|-----|
| nmap | Escaneo de red y puertos |
| dnsrecon | Reconocimiento DNS avanzado |
| theHarvester | Recopilación de emails/subdominios |
| amass | Enumeración de superficie de ataque |
| recon-ng | Framework de reconocimiento |
| whois | Información de dominio |
| dig | Consultas DNS |

### FASE 2: ESCANEO
| Herramienta | Uso |
|-------------|-----|
| nikto | Scanner de vulnerabilidades web |
| whatweb | Detección de tecnologías |
| gobuster | Fuerza bruta de directorios/subdominios |
| dirb | Fuerza bruta de directorios |
| wfuzz | Fuzzing de parámetros |
| ffuf | Fuzzing rápido |

### FASE 3: ENUMERACIÓN
| Herramienta | Uso |
|-------------|-----|
| enum4linux | Enumeración SMB |
| smbclient | Acceso a shares SMB |
| ldapsearch | Enumeración LDAP |
| rpcclient | Enumeración RPC |
| snmpwalk | Enumeración SNMP |

### FASE 4: EXPLOTACIÓN
| Herramienta | Uso |
|-------------|-----|
| sqlmap | Inyección SQL automática |
| xsser | XSS automático |
| wpscan | Vulnerabilidades WordPress |
| metasploit | Framework de explotación |
| searchsploit | Búsqueda de exploits |
| msfvenom | Generación de payloads |

### FASE 5: POST-EXPLOTACIÓN
| Herramienta | Uso |
|-------------|-----|
| meterpreter | Shell avanzada |
| crackmapexec | Ejecución remota SMB |
| impacket | Herramientas Windows |
| evil-winrm | Shell WinRM |
| chisel | Tunnels/Proxy |

### FASE 6: ANÁLISIS
| Herramienta | Uso |
|-------------|-----|
| wireshark | Análisis de tráfico |
| responder | Poisoning LLMNR/NBT-NS |
| ettercap | MITM |
| hashcat | Cracking de hashes |
| john | Cracking de contraseñas |

## Herramientas por Categoría

### Reconocimiento (12 herramientas)
nmap, dnsrecon, theHarvester, amass, recon-ng, whois, dig, host, curl, wget, dnsenum, fierce

### Web (14 herramientas)
nikto, whatweb, gobuster, dirb, wfuzz, ffuf, sqlmap, xsser, wpscan, joomscan, cariddi, dirbuster, commix, xsstrike

### Enumeración (10 herramientas)
enum4linux, smbclient, nbtscan, ldapsearch, rpcclient, snmpwalk, onesixtyone, snmp-check, smtp-user-enum, ftp-user-enum

### Fuerza Bruta (10 herramientas)
hydra, medusa, ncrack, john, hashcat, cewl, crunch, patator, ophcrack, chntpw

### Explotación (8 herramientas)
metasploit, searchsploit, msfvenom, shellnoob, exploitdb, set, king-phisher, gophish

### Post-Exploitación (8 herramientas)
meterpreter, crackmapexec, impacket, evil-winrm, chisel, responder, lazagne, mimikatz

### Wireless (8 herramientas)
aircrack-ng, wifite, kismet, reaver, bully, fern, pixiewps, cowpatty

### Análisis de Tráfico (6 herramientas)
wireshark, tshark, tcpdump, ettercap, mitmproxy, dsniff

### Forensics (6 herramientas)
volatility, autopsy, binwalk, foremost, sleuthkit, bulk_extractor

### Reversing (6 herramientas)
ghidra, radare2, strace, ltrace, objdump, file

## Nivel de Riesgo por Herramienta

| Nivel | Herramientas |
|-------|--------------|
| Bajo (1-3) | nmap, dig, whois, whatweb, host |
| Medio (4-6) | nikto, gobuster, enum4linux, hydra, john |
| Alto (7-9) | sqlmap, metasploit, responder, crackmapexec |
| Crítico (10) | meterpreter, mimikatz, empire |

## Instalación de Herramientas

### Todas las herramientas
```bash
./pentest.sh install
```

### Por categoría
```bash
# Reconocimiento
sudo apt install amass theharvester recon-ng

# Web
sudo apt install wfuzz ffuf xsser wpscan

# Enumeración
sudo apt install enum4linux smbclient

# Fuerza bruta
sudo apt install hydra medusa john hashcat

# Explotación
sudo apt install metasploit-framework

# Post-explotación
sudo apt install crackmapexec impacket-scripts

# Wireless
sudo apt install wifite reaver bully

# Forensics
sudo apt install autopsy sleuthkit binwalk foremost

# Reversing
sudo apt install ghidra radare2
```

## Ejemplo de Uso Completo

```bash
# 1. Verificar herramientas
./pentest.sh tools

# 2. Escaneo completo
./pentest.sh https://ejemplo.com

# 3. Ver reporte
cat reports/report_ejemplo.com_*.md

# 4. Si faltan herramientas
./pentest.sh install
```

## Personalización

### Agregar herramienta al registry
Editar `tools/registry.sh`:
```bash
TOOLS_NUEVA[herramienta]="categoria|tipo|funcion|extra|risk|url"
```

### Modificar wordlists
Editar las rutas en los scripts:
```bash
-w /usr/share/wordlists/rockyou.txt
```
