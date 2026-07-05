# Auto-Pentester Pro - Complete Pentesting System

## Description

Automated pentesting system with over 100 Kali Linux tools organized by category and attack phase.

## Structure

```
auto-scanner/
├── pentest.sh              # Unified command
├── autopentest.sh          # Basic scan
├── autopentest-pro.sh      # Pro scan (recommended)
├── quickscan.sh            # Quick scan
├── github-scan.sh          # GitHub scan
├── tool-checker.sh         # Tool checker
├── tools/
│   └── registry.sh         # Tool database
├── reports/                # Generated reports
└── README.md
```

## Commands

### Full Scan (Pro)
```bash
./pentest.sh https://your-site.com
# or
./autopentest-pro.sh https://your-site.com
```

### Quick Scan
```bash
./pentest.sh quick https://your-site.com
```

### GitHub Scan
```bash
./pentest.sh github your-user/your-repo
```

### View Tools
```bash
./pentest.sh tools
```

### View Phase Matrix
```bash
./pentest.sh matrix
```

### Search for a Tool
```bash
./pentest.sh search sql_injection
./pentest.sh search smb
./pentest.sh search wifi
```

### Install Missing Tools
```bash
./pentest.sh install
```

## Tool Matrix by Phase

### PHASE 1: RECONNAISSANCE
| Tool | Usage |
|-------------|-----|
| nmap | Network and port scanning |
| dnsrecon | Advanced DNS reconnaissance |
| theHarvester | Email/subdomain harvesting |
| amass | Attack surface enumeration |
| recon-ng | Reconnaissance framework |
| whois | Domain information |
| dig | DNS queries |

### PHASE 2: SCANNING
| Tool | Usage |
|-------------|-----|
| nikto | Web vulnerability scanner |
| whatweb | Technology detection |
| gobuster | Directory/subdomain brute-force |
| dirb | Directory brute-force |
| wfuzz | Parameter fuzzing |
| ffuf | Fast fuzzing |

### PHASE 3: ENUMERATION
| Tool | Usage |
|-------------|-----|
| enum4linux | SMB enumeration |
| smbclient | SMB share access |
| ldapsearch | LDAP enumeration |
| rpcclient | RPC enumeration |
| snmpwalk | SNMP enumeration |

### PHASE 4: EXPLOITATION
| Tool | Usage |
|-------------|-----|
| sqlmap | Automated SQL injection |
| xsser | Automated XSS |
| wpscan | WordPress vulnerabilities |
| metasploit | Exploitation framework |
| searchsploit | Exploit search |
| msfvenom | Payload generation |

### PHASE 5: POST-EXPLOITATION
| Tool | Usage |
|-------------|-----|
| meterpreter | Advanced shell |
| crackmapexec | Remote SMB execution |
| impacket | Windows tools |
| evil-winrm | WinRM shell |
| chisel | Tunnels/Proxy |

### PHASE 6: ANALYSIS
| Tool | Usage |
|-------------|-----|
| wireshark | Traffic analysis |
| responder | LLMNR/NBT-NS Poisoning |
| ettercap | MITM |
| hashcat | Hash cracking |
| john | Password cracking |

## Tools by Category

### Reconnaissance (12 tools)
nmap, dnsrecon, theHarvester, amass, recon-ng, whois, dig, host, curl, wget, dnsenum, fierce

### Web (14 tools)
nikto, whatweb, gobuster, dirb, wfuzz, ffuf, sqlmap, xsser, wpscan, joomscan, cariddi, dirbuster, commix, xsstrike

### Enumeration (10 tools)
enum4linux, smbclient, nbtscan, ldapsearch, rpcclient, snmpwalk, onesixtyone, snmp-check, smtp-user-enum, ftp-user-enum

### Brute Force (10 tools)
hydra, medusa, ncrack, john, hashcat, cewl, crunch, patator, ophcrack, chntpw

### Exploitation (8 tools)
metasploit, searchsploit, msfvenom, shellnoob, exploitdb, set, king-phisher, gophish

### Post-Exploitation (8 tools)
meterpreter, crackmapexec, impacket, evil-winrm, chisel, responder, lazagne, mimikatz

### Wireless (8 tools)
aircrack-ng, wifite, kismet, reaver, bully, fern, pixiewps, cowpatty

### Traffic Analysis (6 tools)
wireshark, tshark, tcpdump, ettercap, mitmproxy, dsniff

### Forensics (6 tools)
volatility, autopsy, binwalk, foremost, sleuthkit, bulk_extractor

### Reversing (6 tools)
ghidra, radare2, strace, ltrace, objdump, file

## Risk Level by Tool

| Level | Tools |
|-------|--------------|
| Low (1-3) | nmap, dig, whois, whatweb, host |
| Medium (4-6) | nikto, gobuster, enum4linux, hydra, john |
| High (7-9) | sqlmap, metasploit, responder, crackmapexec |
| Critical (10) | meterpreter, mimikatz, empire |

## Tool Installation

### All tools
```bash
./pentest.sh install
```

### By category
```bash
# Reconnaissance
sudo apt install amass theharvester recon-ng

# Web
sudo apt install wfuzz ffuf xsser wpscan

# Enumeration
sudo apt install enum4linux smbclient

# Brute force
sudo apt install hydra medusa john hashcat

# Exploitation
sudo apt install metasploit-framework

# Post-exploitation
sudo apt install crackmapexec impacket-scripts

# Wireless
sudo apt install wifite reaver bully

# Forensics
sudo apt install autopsy sleuthkit binwalk foremost

# Reversing
sudo apt install ghidra radare2
```

## Complete Usage Example

```bash
# 1. Check tools
./pentest.sh tools

# 2. Full scan
./pentest.sh https://example.com

# 3. View report
cat reports/report_example.com_*.md

# 4. If tools are missing
./pentest.sh install
```

## Customization

### Add tool to registry
Edit `tools/registry.sh`:
```bash
TOOLS_NEW[tool]="category|type|function|extra|risk|url"
```

### Modify wordlists
Edit the paths in the scripts:
```bash
-w /usr/share/wordlists/rockyou.txt
```
