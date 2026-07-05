# Lab Scripts

## Available Scripts

### 1. download_vms.sh
Interactive script to download vulnerable VMs.

```bash
chmod +x scripts/download_vms.sh
./scripts/download_vms.sh
```

### 2. setup_network.sh
Configures the Host-Only network for the lab.

```bash
chmod +x scripts/setup_network.sh
sudo ./scripts/setup_network.sh
```

### 3. start_lab.sh
Starts all lab VMs.

```bash
chmod +x scripts/start_lab.sh
./scripts/start_lab.sh
```

### 4. verify_lab.sh
Verifies the status of all VMs.

```bash
chmod +x scripts/verify_lab.sh
./scripts/verify_lab.sh
```

## Quick Start

```bash
# 1. Grant permissions to all scripts
chmod +x scripts/*.sh

# 2. Configure network
sudo ./scripts/setup_network.sh

# 3. Download VMs
./scripts/download_vms.sh

# 4. Start lab
./scripts/start_lab.sh

# 5. Verify
./scripts/verify_lab.sh
```

## Requirements

- VirtualBox 7.x
- Docker (optional, for DVWA)
- nmap (pre-installed on Kali)
- curl

## Troubleshooting

### VMs cannot communicate
1. Verify that all are on Host-Only Adapter
2. Disable firewall temporarily
3. Verify static IPs

### Docker does not work
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### No internet on Kali
```bash
# Verify NAT interface
ip addr show

# Restart networking
sudo systemctl restart networking
```