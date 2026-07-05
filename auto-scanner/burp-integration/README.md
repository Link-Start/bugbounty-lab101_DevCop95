# Burp Suite Integration

> **Nota**: La integración MCP de Burp Suite está en evaluación. Pendiente definir alcance y viabilidad antes de implementar.

Integración de Burp Suite con el sistema de pentesting automatizado.

## Requisitos

1. **Burp Suite Professional o Community** instalado
2. **API habilitada** en Burp:
   - Burp → Settings → Burp API → Enable
   - Puerto: 1337 (default)

## Inicio Rápido

```bash
# 1. Lanzar Burp Suite
./burp.sh launch

# 2. Habilitar API en Burp (Settings → Burp API → Enable)

# 3. Verificar estado
./burp.sh status

# 4. Agregar target
./burp.sh target add https://example.com

# 5. Iniciar spider
./burp.sh spider https://example.com

# 6. Iniciar escaneo
./burp.sh scan https://example.com

# 7. Ver hallazgos
./burp.sh issues
```

## Comandos Disponibles

### Estado
```bash
./burp.sh status          # Estado de Burp
./burp.sh config          # Ver configuración
./burp.sh launch          # Lanzar Burp Suite
```

### Proxy
```bash
./burp.sh proxy on        # Habilitar proxy
./burp.sh proxy off       # Deshabilitar proxy
./burp.sh proxy history   # Ver historial
```

### Target
```bash
./burp.sh target add https://ejemplo.com    # Agregar URL
./burp.sh target scope                       # Ver scope
```

### Spider
```bash
./burp.sh spider https://ejemplo.com   # Iniciar spider
```

### Escaneo
```bash
./burp.sh scan https://ejemplo.com    # Escaneo activo
./burp.sh scan status                 # Estado del escaneo
```

### Hallazgos
```bash
./burp.sh issues              # Ver issues
./burp.sh issues export       # Exportar a JSON
./burp.sh issues details 123  # Detalles de issue
```

### Repeater
```bash
./burp.sh repeater https://ejemplo.com/api/test
```

## Python API

También puedes usar la API directamente:

```python
from burp_api import BurpAPI

# Conectar a Burp
burp = BurpAPI()

# Ver estado
print(burp.status())

# Agregar target
burp.add_to_target("https://ejemplo.com")

# Iniciar spider
burp.start_spider("https://ejemplo.com")

# Ver issues
issues = burp.get_issues()
for issue in issues:
    print(f"{issue['name']}: {issue['severity']}")
```

## Workflow de Testing

### 1. Setup Inicial
```bash
./burp.sh launch
./burp.sh proxy on
./burp.sh target add https://target.com
```

### 2. Reconocimiento
```bash
./burp.sh spider https://target.com
./burp.sh issues  # Ver URLs encontradas
```

### 3. Escaneo
```bash
./burp.sh scan https://target.com
# Esperar a que termine
./burp.sh scan status
```

### 4. Análisis
```bash
./burp.sh issues export > hallazgos.json
# Revisar manualmente en Burp Suite
```

### 5. Reporte
```bash
# Exportar de Burp Suite
# Burp → Project options → Save project
```

## Solución de Problemas

### Burp no está corriendo
```bash
./burp.sh launch
# Esperar a que inicie
# Habilitar API: Settings → Burp API → Enable
```

### API no responde
1. Verificar que Burp esté corriendo
2. Verificar que la API esté habilitada
3. Verificar puerto (default: 1337)

### Proxy no captura tráfico
1. Verificar que el proxy esté habilitado
2. Configurar navegador para usar proxy
3. Instalar certificado CA de Burp
