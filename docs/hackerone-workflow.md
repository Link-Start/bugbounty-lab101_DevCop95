# Flujo de Trabajo HackerOne — dev101x

Metodología de punta a punta para trabajar programas de HackerOne con este lab.
Complementa `bugbounty/QUICK-REFERENCE.md` (comandos y payloads) — este documento
cubre el proceso alrededor de las herramientas: elegir programa, no salirse de
scope, no duplicar reportes, y enviar algo que un triager acepte rápido.

---

## 1. Elegir programa

- Prioriza programas con **respuesta rápida y buen histórico de bounty** (revisa
  las estadísticas públicas del programa en su página de HackerOne: tiempo medio
  de primera respuesta, tiempo medio de bounty, señal de reportes reciente).
- VDPs (Vulnerability Disclosure Program, sin recompensa) son buenos para
  construir reputación/señal en HackerOne cuando el perfil es nuevo.
- Lee la política completa antes de tocar nada: scope, exclusiones, si permiten
  automatización/escaneo activo, y si piden autenticación previa (algunos
  programas exigen registrar tu IP o usar cuentas de prueba específicas).

## 2. Documentar el scope antes de escanear

```bash
cd bugbounty
./bugbounty-hunter.sh new nombre-programa
```

Esto crea `programs/nombre-programa.md`. Copia ahí, literalmente, la sección
"In scope" y "Out of scope" de la política del programa — no una versión
resumida de memoria. `bugbounty-hunter.sh` bloquea cualquier fase activa
(`recon`, `vuln`, `brute`, `secrets`, `api`, `full`) contra un target que no
esté documentado en `programs/`. Ver [`programs/README.md`](../programs/README.md).

Revisa el scope de nuevo si vuelves a un programa después de semanas — los
scopes cambian.

## 3. Metodología de escaneo

1. `recon` — subdominios, HTTP probing, wayback/JS endpoints, parámetros.
2. `vuln` — nuclei, XSS/SQLi/SSRF/redirect/IDOR automatizados.
3. `brute` — directorios, vhosts, parámetros.
4. `secrets` — secretos en JS, dorks de GitHub, buckets cloud.
5. `api` — documentación de API, GraphQL introspection.
6. Revisión **manual** de todo lo anterior — los scanners generan candidatos,
   no hallazgos. Todo lo que vaya a un reporte se re-verifica a mano.
7. `business_logic` / `chain_attacks` como checklists — no se automatizan,
   pero orientan dónde mirar (auth flows, IDOR no obvio, cadenas de bajo
   impacto que combinadas sí importan).
8. **Revisión de código asistida por AI, cuando haya "código" que leer**:
   bundles JS de la SPA, o el repo si el programa incluye software
   self-hosted/open-source. Ver [`docs/ai-assisted-code-review.md`](ai-assisted-code-review.md)
   — el método que gana es cobertura disciplinada archivo-por-archivo con
   reporte estructurado, no un agente autónomo suelto sobre todo el
   codebase con la esperanza de que mire en el lugar correcto.
9. **Fingerprinting contra el watchlist de CVEs conocidos**: si el stack
   detectado coincide con algo de [`docs/known-cve-watchlist.md`](known-cve-watchlist.md)
   (Next.js, Kibana, Langflow, Confluence/Jira, PAN-OS GlobalProtect, etc.),
   probar ese CVE puntual explícitamente en vez de depender solo del
   escaneo genérico de `vuln` — son los que más se siguen encontrando en
   programas reales de HackerOne según Hacktivity.
10. **Si el stack no da un producto/CVE conocido**, caer a
    [`docs/known-cwe-watchlist.md`](known-cwe-watchlist.md) — el ranking por
    clase de vulnerabilidad (XSS, info disclosure, access control/IDOR son,
    en ese orden, la abrumadora mayoría de reportes en HackerOne) para
    decidir dónde priorizar la revisión manual.

## 4. Antes de escribir el reporte: buscar duplicados

La causa #1 de reportes cerrados como "Duplicate" o "Not Applicable" es no
buscar primero. Antes de reportar:

- Busca en **Hacktivity** (`hackerone.com/hacktivity`) reportes públicos del
  mismo programa con palabras clave del hallazgo (endpoint, tecnología, tipo
  de vuln).
- Revisa los "Reportes Enviados" que ya tengas anotados en
  `programs/nombre-programa.md` para ese mismo programa.
- Si el programa tiene reportes públicos de terceros, ojea los títulos — un
  bucket S3 abierto o un CORS misconfiguration ya reportado no vale un
  segundo reporte.

## 5. Calidad del reporte

Usa `bugbounty/templates/report-template.md` como base. Un reporte que se
paga rápido tiene:

- **Título específico**: `Reflected XSS in /search?q= parameter` no
  `XSS vulnerability found`.
- **Pasos numerados y reproducibles por alguien que nunca vio el target** —
  el triager no conoce el contexto que tú tienes.
- **PoC mínimo pero completo**: request/response real, o script, no solo una
  descripción en prosa.
- **Impacto concreto**, no genérico. "Un atacante podría..." conectado a un
  escenario real del negocio del programa (por ejemplo: encadenamiento de
  reconocimiento → SSO config → RBAC bypass → datos sensibles eleva el
  impacto real de hallazgos individuales bajos/medios).
- **CVSS y CWE correctos** — un CVSS inflado o un CWE mal elegido es motivo
  común de re-triage y demora el pago.

## 6. Después de enviar

- Completa el campo "H1 Report URL" en el reporte local y en la tabla
  "Reportes Enviados" de `programs/nombre-programa.md`.
- Responde rápido si el triager pide más info — la velocidad de respuesta del
  hacker también afecta la señal/reputación en HackerOne.
- Si piden retest tras un fix, vuelve a correr `scope` antes de retestear —
  el scope pudo cambiar.
- Respeta el embargo de disclosure del programa; no publiques detalles hasta
  que el programa lo autorice explícitamente.

## 7. Construir reputación como dev101x

- La reputación de HackerOne combina señal (reportes válidos/inválidos),
  impacto acumulado y reactividad. Prioriza calidad sobre volumen: un reporte
  bien encadenado y bien escrito vale más que cinco de "missing security
  header" sin impacto de negocio.
- Los VDPs sin bounty siguen sumando señal y son buen terreno para probar la
  metodología completa (recon → cadena → reporte) sin la presión de un pago.
- Guarda cada reporte enviado (bounty o no) en `programs/*.md` — con el
  tiempo eso es tu propio historial de qué tipo de hallazgo funciona en qué
  tipo de programa.
