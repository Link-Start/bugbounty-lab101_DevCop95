# Known-CWE Watchlist (fuente: HackerOne Hacktivity — CWE Discovery)

Ranking de clases de vulnerabilidad (CWE) por cantidad total de reportes en
HackerOne. A diferencia de [`known-cve-watchlist.md`](known-cve-watchlist.md)
(CVEs puntuales en productos específicos), esto es la vista de "qué tipo de
bug es más probable encontrar" — sirve para priorizar en qué gastar tiempo
manual cuando el recon no apunta a un producto/CVE concreto.

| Rank | CWE | Nombre | Reportes |
|---|---|---|---|
| 1 | CWE-79 | Cross-Site Scripting (XSS) | 123,455 |
| 2 | CWE-200 | Exposure of Sensitive Information to an Unauthorized Actor | 87,610 |
| 3 | CWE-284 | Improper Access Control | 59,818 |
| 4 | CWE-639 | Authorization Bypass Through User-Controlled Key (IDOR) | 35,859 |
| 5 | CWE-287 | Improper Authentication | 24,533 |
| 6 | CWE-657 | Violation of Secure Design Principles | 22,498 |
| 7 | CWE-601 | URL Redirection to Untrusted Site (Open Redirect) | 17,230 |
| 8 | CWE-352 | Cross-Site Request Forgery (CSRF) | 16,613 |
| 9 | CWE-89 | SQL Injection | 14,604 |
| 10 | CWE-444 | HTTP Request/Response Smuggling | 12,934 |
| 11 | CWE-94 | Code Injection | 9,818 |
| 12 | CWE-918 | Server-Side Request Forgery (SSRF) | 9,664 |
| 13 | CWE-285 | Improper Authorization | 8,642 |
| 14 | CWE-20 | Improper Input Validation | 7,816 |
| 15 | CWE-400 | Uncontrolled Resource Consumption | 7,518 |
| 16 | CWE-307 | Improper Restriction of Excessive Authentication Attempts | 7,414 |
| 17 | CWE-922 | Insecure Storage of Sensitive Information | 6,679 |
| 18 | CWE-215 | Insertion of Sensitive Information Into Debugging Code | 6,166 |
| 19 | CWE-807 | Reliance on Untrusted Inputs in a Security Decision | 6,134 |
| 20 | CWE-312 | Cleartext Storage of Sensitive Information | 6,005 |
| 21 | CWE-22 | Path Traversal | 5,765 |
| 22 | CWE-78 | OS Command Injection | 5,757 |
| 23 | CWE-610 | Externally Controlled Reference to a Resource in Another Sphere | 5,514 |
| 24 | CWE-77 | Command Injection | 5,089 |
| 25 | CWE-80 | Basic XSS (script-related HTML tags) | 5,036 |

## Cómo aplicar esto en este lab

- **Los primeros 4 (XSS, info disclosure, access control, IDOR) suman más
  reportes que todo el resto combinado.** Si el tiempo de un engagement es
  limitado, la revisión manual de auth/autorización (checklist de
  `business_logic` en `bugbounty-hunter.sh`) y el chequeo sistemático de
  parámetros/endpoints por XSS reflejado/almacenado siguen siendo lo que
  más rinde, no las clases "exóticas".
- **CWE-639 (IDOR) y CWE-285/CWE-284 juntas son ~104K reportes** — todo lo
  que sea "cambiar un ID/parámetro y ver si accedo a algo que no debería"
  sigue siendo la mina de oro más consistente. Correlaciona directo con
  patrones de RBAC bypass en `/file-service/static/` y con flags como
  `withVip`/`withHidden` donde la lógica de "flag controlado por el cliente
  que el backend no valida" es exactamente este bucket.
- **CWE-200 (info disclosure)** es la categoría más común de hallazgos reales:
  `issuer` OIDC filtrado, buckets S3 expuestos, Sentry DSNs, URLs de
  Kubernetes. Es la clase más común de hallazgo que este lab produce — vale
  la pena seguir el mismo patrón (leer JS/config inline, revisar discovery
  docs estándar) en cada target nuevo.
- **CWE-215 (secrets en código de debug)** — información sensible que termina
  en algo que se loguea/cachea: `auth_secret`/`token` en URLs archivadas,
  debug output, comentarios de código.
- Combina con [`docs/known-cve-watchlist.md`](known-cve-watchlist.md): si
  el fingerprinting de stack no da un producto/CVE conocido, cae de nuevo
  a este ranking por clase para decidir dónde mirar manualmente.
