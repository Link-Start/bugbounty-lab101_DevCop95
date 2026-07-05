# Learning Resources — Pentesting

## Bug Bounty / HackerOne (priority for dev101x)

### Hacker101
- **URL:** https://www.hacker101.com/
- **By:** HackerOne
- **Type:** Videos + CTFs with badges redeemable for private program invitations
- **Recommendation:** Mandatory starting point; the CTFs teach report thinking, not just exploitation

### HackerOne Hacktivity
- **URL:** https://hackerone.com/hacktivity
- **Type:** Public disclosed reports, filterable by program/type/severity
- **Use:** Review before reporting (avoid duplicates) and to study how to write a report that gets paid quickly

### HackerOne Directory
- **URL:** https://hackerone.com/directory/programs
- **Type:** Public program listings with scope, policies, and response statistics
- **Recommendation:** Filter by "response efficiency" and average bounty before choosing where to invest time

### Disclosed Reports Search (cross-search)
- **URL:** https://github.com/reddelexc/hackerone-reports
- **Type:** Index of disclosed HackerOne reports, searchable by technology/vulnerability
- **Use:** Search for previous reports on the same technology/CMS/framework used by the target

### Bug Bounty Bootcamp / written methodologies
- **Bug Bounty Bootcamp** - Vickie Li (book, complete methodology recon → report)
- **The Bug Hunter's Methodology (TBHM)** - Jason Haddix (talks and repo, large-scale recon reference)

## Practice Platforms

### HackTheBox
- **URL:** https://www.hackthebox.com/
- **Level:** Intermediate-Advanced
- **Type:** Machines, Challenges, Labs
- **Recommendation:** Start with Easy and Medium machines

### TryHackMe
- **URL:** https://tryhackme.com/
- **Level:** Beginner-Intermediate
- **Type:** Learning Paths, Rooms
- **Recommendation:** Follow the "Complete Beginner" or "Jr Penetration Tester" path

### VulnHub
- **URL:** https://www.vulnhub.com/
- **Level:** Variable
- **Type:** Downloadable VMs
- **Recommendation:** Download and practice in your local lab

### OverTheWire
- **URL:** https://overthewire.org/wargames/
- **Level:** Beginner
- **Type:** Wargames (Bandit, Natas, Leviathan)
- **Recommendation:** Start with Bandit to learn Linux

### PentesterLab
- **URL:** https://pentesterlab.com/
- **Level:** Intermediate
- **Type:** Exercises and badges
- **Recommendation:** Excellent for web hacking practice

### picoCTF
- **URL:** https://picoctf.org/
- **Level:** Beginner-Intermediate
- **Type:** CTF challenges
- **Recommendation:** Ideal for learning fundamental concepts

## Certifications

### OSCP (Offensive Security Certified Professional)
- **URL:** https://www.offensive-security.com/pwk-oscp/
- **Level:** Intermediate-Advanced
- **Focus:** Practical pentesting
- **Preparation:** PEN-200 course + 90 days of lab

### CEH (Certified Ethical Hacker)
- **URL:** https://www.eccouncil.org/programs/certified-ethical-hacker-ceh/
- **Level:** Intermediate
- **Focus:** Ethical hacking theory and practice

### CompTIA PenTest+
- **URL:** https://www.comptia.org/certifications/pentest
- **Level:** Intermediate
- **Focus:** Pentesting methodology

## Courses and Material

### YouTube
- **John Hammond** - CTF walkthroughs
- **IppSec** - HackTheBox walkthroughs
- **NetworkChuck** - Networking and hacking
- **The Cyber Mentor** - Pentesting from scratch

### Books
- "The Web Application Hacker's Handbook" - Dafydd Stuttard
- "Metasploit: The Penetration Tester's Guide" - David Kennedy
- "Hacking: The Art of Exploitation" - Jon Erickson
- "Penetration Testing" - Georgia Weidman

### Blogs and Articles
- **PortSwigger Web Security Academy** - https://portswigger.net/web-security
- **OWASP Testing Guide** - https://owasp.org/www-project-web-security-testing-guide/
- **HackTricks** - https://book.hacktricks.xyz/

## Essential Tools

### Kali Linux Tools
```bash
# View all tools
ls /usr/share/wordlists/

# Wordlists
/usr/share/wordlists/rockyou.txt
/usr/share/wordlists/dirb/common.txt
/usr/share/seclists/Discovery/Web-Content/
```

### Additional Resources
- **PayloadsAllTheThings:** https://github.com/swisskyrepo/PayloadsAllTheThings
- **GTFOBins:** https://gtfobins.github.io/ (Linux privilege escalation)
- **LOLBAS:** https://lolbas-project.github.io/ (Windows privilege escalation)
- **RevShells:** https://www.revshells.com/ (Reverse shell generator)

## Communities

- **Reddit:** r/netsec, r/hacking, r/AskNetsec
- **Discord:** HackTheBox, TryHackMe servers
- **Forums:** Exploit-DB, OffSec Forums

## Daily Practice

### Suggested Routine
1. **Monday:** 1 hour of TryHackMe/HackTheBox
2. **Tuesday:** Practice tools (nmap, metasploit)
3. **Wednesday:** Read a security article
4. **Thursday:** Solve 1-2 CTF challenges
5. **Friday:** Document findings and learn
6. **Weekend:** Personal project or full CTF
