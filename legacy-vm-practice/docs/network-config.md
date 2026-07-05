# Lab Network Configuration

## Network Topology

```
                    INTERNET
                        │
                        │ (NAT)
                        │
    ┌───────────────────┴───────────────────┐
    │              YOUR MACHINE              │
    │              Kali Linux                │
    │           192.168.56.100               │
    └───────────────────┬───────────────────┘
                        │
                        │ (Host-Only)
                        │
    ┌───────────────────┴───────────────────┐
    │         HOST-ONLY NETWORK              │
    │         192.168.56.0/24                │
    │                                        │
    │  ┌─────────┐  ┌─────────┐  ┌────────┐ │
    │  │  Kali   │  │Metasplo │  │  DVWA  │ │
    │  │ .56.100 │  │ .56.200 │  │ .56.201│ │
    │  └─────────┘  └─────────┘  └────────┘ │
    │                                        │
    │  ┌─────────┐  ┌─────────┐  ┌────────┐ │
    │  │OWASP BWA│  │ Windows │  │ Debian │ │
    │  │ .56.202 │  │ .56.203 │  │ .56.204│ │
    │  └─────────┘  └─────────┘  └────────┘ │
    └────────────────────────────────────────┘
```

## IP Assignment

| Device | IP | Services |
|-------------|-----|-----------|
| Kali Linux | 192.168.56.100 | Pentesting tools |
| Metasploitable 2 | 192.168.56.200 | FTP, SSH, HTTP, SMB, MySQL, etc. |
| DVWA | 192.168.56.201 | Apache, MySQL, PHP |
| OWASP BWA | 192.168.56.202 | Multiple vulnerable web apps |
| Windows XP | 192.168.56.203 | SMB, RDP |
| Debian Server | 192.168.56.204 | Apache, SSH, FTP |

## VirtualBox Configuration

### Step 1: Create Host-Only Network
```bash
# In VirtualBox
File → Host Network Manager → Create
# Note the interface name (e.g., vboxnet0)
```

### Step 2: Configure IPs
```bash
# Configure Host-Only interface
sudo ifconfig vboxnet0 192.168.56.1 netmask 255.255.255.0 up
```

### Step 3: Configure Each VM
```
Settings → Network → Adapter 2
  Attached to: Host-Only Adapter
  Name: vboxnet0
  Promiscuous Mode: Allow All
```

## Static IP Configuration on Kali

### Edit `/etc/network/interfaces`
```
# Interface Host-Only
auto eth1
iface eth1 inet static
    address 192.168.56.100
    netmask 255.255.255.0
    network 192.168.56.0
    broadcast 192.168.56.255
```

### Restart Networking
```bash
sudo systemctl restart networking
```

## Network Verification

```bash
# View interfaces
ip addr show

# Ping targets
ping -c 3 192.168.56.200
ping -c 3 192.168.56.201

# Verify ports
nmap -sn 192.168.56.0/24

# View traffic
sudo tcpdump -i vboxnet0
```

## Firewall Rules (Optional)

### Allow only lab traffic
```bash
# On Kali
sudo iptables -A OUTPUT -d 192.168.56.0/24 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.56.0/24 -j DROP
```

### NAT for internet access
```bash
# On Kali (if you need internet on the VMs)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
```

## Troubleshooting

### VMs cannot see each other
1. Verify that all are on Host-Only Adapter
2. Disable firewall temporarily
3. Verify static IPs

### No internet on Kali
1. Verify that Adapter 1 is on NAT
2. Verify that eth0 has a DHCP IP

### Services not responding
1. Verify that the service is running on the VM
2. Check the firewall inside the VM
3. Verify that the port is open