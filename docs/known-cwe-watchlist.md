# Known-CWE Watchlist (source: HackerOne Hacktivity — CWE Discovery)

Ranking of vulnerability classes (CWE) by total report count on
HackerOne. Unlike [`known-cve-watchlist.md`](known-cve-watchlist.md)
(specific CVEs in specific products), this is the "what type of
bug is most likely to be found" view — useful for prioritizing where to spend
manual time when recon doesn't point to a specific product/CVE.

| Rank | CWE | Name | Reports |
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

## How to apply this in this lab

- **The top 4 (XSS, info disclosure, access control, IDOR) account for more
  reports than everything else combined.** If engagement time is
  limited, manual review of auth/authorization (`business_logic` checklist
  in `bugbounty-hunter.sh`) and systematic checking of
  parameters/endpoints for reflected/stored XSS still yields the most results, not "exotic" classes.
- **CWE-639 (IDOR) and CWE-285/CWE-284 together are ~104K reports** — anything
  that's "change an ID/parameter and see if I can access something I shouldn't" is
  still the most consistent gold mine. Directly correlates with
  RBAC bypass patterns in `/file-service/static/` and with flags like
  `withVip`/`withHidden` where the "client-controlled flag that the
  backend doesn't validate" logic is exactly this bucket.
- **CWE-200 (info disclosure)** is the most common category of real findings:
  leaked OIDC `issuer`, exposed S3 buckets, Sentry DSNs, Kubernetes
  URLs. It's the most common finding type this lab produces — worth
  following the same pattern (read inline JS/config, check standard
  discovery docs) on every new target.
- **CWE-215 (secrets in debug code)** — sensitive information that ends up
  in something that gets logged/cached: `auth_secret`/`token` in archived
  URLs, debug output, code comments.
- Combine with [`docs/known-cve-watchlist.md`](known-cve-watchlist.md): if
  stack fingerprinting doesn't match a known product/CVE, fall back to
  this class-based ranking to decide where to look manually.
