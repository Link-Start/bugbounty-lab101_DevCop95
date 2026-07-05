# Legacy VM Practice Lab

Este es el lab de práctica original: VMs vulnerables locales (DVWA,
Metasploitable 2, OWASP BWA, Windows XP/7 legacy) sobre una red Host-Only de
VirtualBox — pensado para aprender fundamentos (SQLi, XSS, SMB, exploits
conocidos con Metasploit) en un entorno controlado y desechable.

**No forma parte del flujo de bug bounty de HackerOne.** Los targets aquí son
IPs privadas (`192.168.56.0/24`) que tú mismo levantas y controlas — no hay
scope de programa que respetar porque no hay programa: son tuyas. Para
trabajo real contra programas de HackerOne, usa `../bugbounty/` y
`../programs/` en la raíz del lab.

Usa esta carpeta cuando quieras practicar una técnica nueva (una clase de
vulnerabilidad, una herramienta) sin tocar ningún target externo, antes de
aplicarla en un programa real.

## Estructura

```
legacy-vm-practice/
├── docs/
│   ├── quickstart.md              # Primer pentest guiado contra Metasploitable 2
│   ├── network-config.md          # Configuración de red Host-Only
│   ├── cheatsheets/pentesting-quickref.md
│   └── hallazgos/template-hallazgo.md
├── scripts/                        # download_vms.sh, setup_network.sh, start_lab.sh, verify_lab.sh
├── targets/README.md               # Configuración de cada VM vulnerable
├── vms/                             # VMs descargadas (vacío hasta que corras download_vms.sh)
└── network/                         # Configuración de red generada
```

## Inicio rápido

Los scripts asumen que estás parado dentro de esta carpeta:

```bash
cd legacy-vm-practice
chmod +x scripts/*.sh
sudo ./scripts/setup_network.sh
./scripts/download_vms.sh
./scripts/start_lab.sh
./scripts/verify_lab.sh
```

Ver `docs/quickstart.md` para el primer pentest guiado.
