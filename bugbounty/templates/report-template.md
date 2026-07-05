# Bug Bounty Report Template

## 📋 Información del Reporte

| Campo | Valor |
|-------|-------|
| **Programa** | [Nombre del programa] |
| **Plataforma** | HackerOne |
| **Target** | [Dominio/URL/Asset exacto listado en el scope] |
| **Fecha** | [YYYY-MM-DD] |
| **Investigador** | dev101x |
| **Severity** | [Critical/High/Medium/Low/Info] |
| **Weakness (H1 taxonomy)** | [ej. CWE-79: Cross-site Scripting (XSS)] |
| **H1 Report URL** | [Se completa post-envío: hackerone.com/reports/XXXXXX] |
| **Duplicado verificado en Hacktivity** | [Sí/No — ver docs/hackerone-workflow.md] |

---

## 🎯 Resumen Ejecutivo

[Descripción breve del hallazgo en 2-3 oraciones]

---

## 🔍 Detalles de la Vulnerabilidad

### Tipo
[Ej: SQL Injection, XSS, SSRF, IDOR, etc.]

### CWE
[CWE-XXX]

### CVSS Score
[X.X]

### Vector
[AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H]

---

## 📝 Pasos para Reproducir

### 1. Pre-requisitos
```
[Qué se necesita para reproducir]
```

### 2. Pasos detallados

**Paso 1: [Descripción]**
```
[Acción a realizar]
```

**Paso 2: [Descripción]**
```
[Acción a realizar]
```

**Paso 3: [Descripción]**
```
[Acción a realizar]
```

### 3. Resultado esperado
```
[Qué debería pasar]
```

### 4. Resultado actual (con el bug)
```
[Qué pasa con la vulnerabilidad]
```

---

## 💥 Impacto

### Confidencialidad
[Alto/Medio/Bajo - Descripción]

### Integridad
[Alto/Medio/Bajo - Descripción]

### Disponibilidad
[Alto/Medio/Bajo - Descripción]

### Impacto en el Negocio
[Descripción del impacto business]

---

## 📸 Evidencia

### Screenshots
[Adjuntar screenshots relevantes]

### PoC Code
```python
# Proof of Concept code
[ Código que demuestra la vulnerabilidad ]
```

### HTTP Request/Response
```http
POST /vulnerable-endpoint HTTP/1.1
Host: target.com
Content-Type: application/json

{"param": "malicious_value"}
```

```http
HTTP/1.1 200 OK
[Response showing vulnerability]
```

---

## 🔧 Recomendación de Corrección

### Short-term Fix
[Corrección rápida inmediata]

### Long-term Fix
[Corrección completa a largo plazo]

### Code Example
```php
// Ejemplo de código seguro
[ Código corregido ]
```

---

## 📚 Referencias

- [OWASP - Tipo de vulnerabilidad]
- [CWE - CWE-XXX]
- [CVE - Si aplica]
- [Documentación oficial]

---

## 📝 Notas Adicionales

[Información extra relevante]

---

## ✅ Checklist

- [ ] He verificado que la vulnerabilidad es reproducible
- [ ] He documentado todos los pasos claramente
- [ ] He incluido evidencia suficiente
- [ ] He evaluado el impacto correctamente
- [ ] He sugerido una corrección
- [ ] No he ejecutado acciones destructivas
- [ ] He respetado los límites del programa (`programs/<programa>.md`)
- [ ] Busqué el hallazgo en Hacktivity/reportes públicos del programa antes de enviar
- [ ] El título es específico (endpoint + tipo de vuln), no genérico

---

*dev101x — Bug Bounty Framework*
