# Burp Suite Integration

> **Note**: The Burp Suite MCP integration is under evaluation. Scope and feasibility need to be defined before implementation.

Integration of Burp Suite with the automated pentesting system.

## Requirements

1. **Burp Suite Professional or Community** installed
2. **API enabled** in Burp:
   - Burp → Settings → Burp API → Enable
   - Port: 1337 (default)

## Quick Start

```bash
# 1. Launch Burp Suite
./burp.sh launch

# 2. Enable API in Burp (Settings → Burp API → Enable)

# 3. Check status
./burp.sh status

# 4. Add target
./burp.sh target add https://example.com

# 5. Start spider
./burp.sh spider https://example.com

# 6. Start scan
./burp.sh scan https://example.com

# 7. View findings
./burp.sh issues
```

## Available Commands

### Status
```bash
./burp.sh status          # Burp status
./burp.sh config          # View configuration
./burp.sh launch          # Launch Burp Suite
```

### Proxy
```bash
./burp.sh proxy on        # Enable proxy
./burp.sh proxy off       # Disable proxy
./burp.sh proxy history   # View history
```

### Target
```bash
./burp.sh target add https://example.com    # Add URL
./burp.sh target scope                       # View scope
```

### Spider
```bash
./burp.sh spider https://example.com   # Start spider
```

### Scan
```bash
./burp.sh scan https://example.com    # Active scan
./burp.sh scan status                 # Scan status
```

### Issues
```bash
./burp.sh issues              # View issues
./burp.sh issues export       # Export to JSON
./burp.sh issues details 123  # Issue details
```

### Repeater
```bash
./burp.sh repeater https://example.com/api/test
```

## Python API

You can also use the API directly:

```python
from burp_api import BurpAPI

# Connect to Burp
burp = BurpAPI()

# Check status
print(burp.status())

# Add target
burp.add_to_target("https://example.com")

# Start spider
burp.start_spider("https://example.com")

# View issues
issues = burp.get_issues()
for issue in issues:
    print(f"{issue['name']}: {issue['severity']}")
```

## Testing Workflow

### 1. Initial Setup
```bash
./burp.sh launch
./burp.sh proxy on
./burp.sh target add https://target.com
```

### 2. Reconnaissance
```bash
./burp.sh spider https://target.com
./burp.sh issues  # View discovered URLs
```

### 3. Scanning
```bash
./burp.sh scan https://target.com
# Wait for completion
./burp.sh scan status
```

### 4. Analysis
```bash
./burp.sh issues export > findings.json
# Review manually in Burp Suite
```

### 5. Reporting
```bash
# Export from Burp Suite
# Burp → Project options → Save project
```

## Troubleshooting

### Burp is not running
```bash
./burp.sh launch
# Wait for it to start
# Enable API: Settings → Burp API → Enable
```

### API not responding
1. Verify that Burp is running
2. Verify that the API is enabled
3. Verify port (default: 1337)

### Proxy not capturing traffic
1. Verify that the proxy is enabled
2. Configure browser to use proxy
3. Install Burp CA certificate
