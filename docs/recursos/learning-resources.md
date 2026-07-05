# Recursos de Aprendizaje - Pentesting

## Bug Bounty / HackerOne (prioridad para dev101x)

### Hacker101
- **URL:** https://www.hacker101.com/
- **De:** HackerOne
- **Tipo:** Videos + CTFs con badges canjeables por invitaciones a programas privados
- **Recomendación:** Punto de partida obligado; los CTFs enseñan la mentalidad de reporte, no solo la explotación

### HackerOne Hacktivity
- **URL:** https://hackerone.com/hacktivity
- **Tipo:** Reportes públicos divulgados, filtrables por programa/tipo/severidad
- **Uso:** Revisar antes de reportar (evitar duplicados) y para estudiar cómo se escribe un reporte que se paga rápido

### HackerOne Directory
- **URL:** https://hackerone.com/directory/programs
- **Tipo:** Listado de programas públicos con scope, políticas y estadísticas de respuesta
- **Recomendación:** Filtrar por "response efficiency" y bounty promedio antes de elegir dónde invertir tiempo

### Disclosed Reports Search (búsqueda cruzada)
- **URL:** https://github.com/reddelexc/hackerone-reports
- **Tipo:** Índice de reportes divulgados de HackerOne, buscable por tecnología/vulnerabilidad
- **Uso:** Buscar reportes previos sobre la misma tecnología/CMS/framework que usa el target

### Bug Bounty Bootcamp / metodologías escritas
- **Bug Bounty Bootcamp** - Vickie Li (libro, metodología completa recon → reporte)
- **The Bug Hunter's Methodology (TBHM)** - Jason Haddix (charlas y repo, referencia de recon a gran escala)

## Plataformas de Práctica

### HackTheBox
- **URL:** https://www.hackthebox.com/
- **Nivel:** Intermedio-Avanzado
- **Tipo:** Machines, Challenges, Labs
- **Recomendación:** Comienza con Easy y Medium machines

### TryHackMe
- **URL:** https://tryhackme.com/
- **Nivel:** Principiante-Intermedio
- **Tipo:** Learning Paths, Rooms
- **Recomendación:** Sigue el path "Complete Beginner" o "Jr Penetration Tester"

### VulnHub
- **URL:** https://www.vulnhub.com/
- **Nivel:** Variable
- **Tipo:** VMs descargables
- **Recomendación:** Descarga y practica en tu lab local

### OverTheWire
- **URL:** https://overthewire.org/wargames/
- **Nivel:** Principiante
- **Tipo:** Wargames (Bandit, Natas, Leviathan)
- **Recomendación:** Comienza con Bandit para aprender Linux

### PentesterLab
- **URL:** https://pentesterlab.com/
- **Nivel:** Intermedio
- **Tipo:** Ejercicios y badges
- **Recomendación:** Excelente para prácticas de web hacking

### picoCTF
- **URL:** https://picoctf.org/
- **Nivel:** Principiante-Intermedio
- **Tipo:** CTF challenges
- **Recomendación:** Ideal para aprender conceptos fundamentales

## Certificaciones

### OSCP (Offensive Security Certified Professional)
- **URL:** https://www.offensive-security.com/pwk-oscp/
- **Nivel:** Intermedio-Avanzado
- **Enfoque:** Pentesting práctico
- **Preparación:** Curso PEN-200 + 90 días de lab

### CEH (Certified Ethical Hacker)
- **URL:** https://www.eccouncil.org/programs/certified-ethical-hacker-ceh/
- **Nivel:** Intermedio
- **Enfoque:** Teoría y práctica de hacking ético

### CompTIA PenTest+
- **URL:** https://www.comptia.org/certifications/pentest
- **Nivel:** Intermedio
- **Enfoque:** Metodología de pentesting

## Cursos y Material

### YouTube
- **John Hammond** - CTF walkthroughs ytools
- **IppSec** - HackTheBox walkthroughs
- **NetworkChuck** - Redes y hacking
- **The Cyber Mentor** - Pentesting desde cero

### Libros
- "The Web Application Hacker's Handbook" - Dafydd Stuttard
- "Metasploit: The Penetration Tester's Guide" - David Kennedy
- "Hacking: The Art of Exploitation" - Jon Erickson
- "Penetration Testing" - Georgia Weidman

### Blogs y Artículos
- **PortSwigger Web Security Academy** - https://portswigger.net/web-security
- **OWASP Testing Guide** - https://owasp.org/www-project-web-security-testing-guide/
- **HackTricks** - https://book.hacktricks.xyz/

## Herramientas Esenciales

### Kali Linux Tools
```bash
# Ver todas las herramientas
ls /usr/share/wordlists/

# Wordlists
/usr/share/wordlists/rockyou.txt
/usr/share/wordlists/dirb/common.txt
/usr/share/seclists/Discovery/Web-Content/
```

### Recursos Adicionales
- **PayloadsAllTheThings:** https://github.com/swisskyrepo/PayloadsAllTheThings
- **GTFOBins:** https://gtfobins.github.io/ (Linux privilege escalation)
- **LOLBAS:** https://lolbas-project.github.io/ (Windows privilege escalation)
- **RevShells:** https://www.revshells.com/ (Reverse shell generator)

## Comunidades

- **Reddit:** r/netsec, r/hacking, r/AskNetsec
- **Discord:** Serveres de HackTheBox, TryHackMe
- **Foros:** Exploit-DB, OffSec Forums

## Práctica Diaria

### Rutina Sugerida
1. **Lunes:** 1 hora de TryHackMe/HackTheBox
2. **Martes:** Practicar herramientas (nmap, metasploit)
3. **Miércoles:** Leer un artículo de seguridad
4. **Jueves:** Resolver 1-2 challenges de CTF
5. **Viernes:** Documentar hallazgos y aprender
6. **Fin de semana:** Proyecto personal o CTF completo
