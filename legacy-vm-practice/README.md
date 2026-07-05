# Legacy VM Practice Lab

This is the original practice lab: local vulnerable VMs (DVWA,
Metasploitable 2, OWASP BWA, Windows XP/7 legacy) on a VirtualBox Host-Only
network — designed for learning fundamentals (SQLi, XSS, SMB, known exploits
with Metasploit) in a controlled and disposable environment.

**It is not part of the HackerOne bug bounty workflow.** The targets here are
private IPs (`192.168.56.0/24`) that you spin up and control yourself — there
is no program scope to respect because there is no program: they are yours. For
real work against HackerOne programs, use `../bugbounty/` and
`../programs/` at the lab root.

Use this folder when you want to practice a new technique (a vulnerability
class, a tool) without touching any external target, before applying it in a
real program.

## Structure

```
legacy-vm-practice/
├── docs/
│   ├── quickstart.md              # First guided pentest against Metasploitable 2
│   ├── network-config.md          # Host-Only network configuration
│   ├── cheatsheets/pentesting-quickref.md
│   └── hallazgos/template-hallazgo.md
├── scripts/                        # download_vms.sh, setup_network.sh, start_lab.sh, verify_lab.sh
├── targets/README.md               # Configuration for each vulnerable VM
├── vms/                             # Downloaded VMs (empty until you run download_vms.sh)
└── network/                         # Generated network configuration
```

## Quick Start

The scripts assume you are standing inside this folder:

```bash
cd legacy-vm-practice
chmod +x scripts/*.sh
sudo ./scripts/setup_network.sh
./scripts/download_vms.sh
./scripts/start_lab.sh
./scripts/verify_lab.sh
```

See `docs/quickstart.md` for the first guided pentest.