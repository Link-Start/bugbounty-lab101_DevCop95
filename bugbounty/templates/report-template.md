# Bug Bounty Report Template

## 📋 Report Information

| Field | Value |
|-------|-------|
| **Program** | [Program name] |
| **Platform** | HackerOne |
| **Target** | [Exact domain/URL/asset listed in scope] |
| **Date** | [YYYY-MM-DD] |
| **Researcher** | dev101x |
| **Severity** | [Critical/High/Medium/Low/Info] |
| **Weakness (H1 taxonomy)** | [e.g. CWE-79: Cross-site Scripting (XSS)] |
| **H1 Report URL** | [Completed after submission: hackerone.com/reports/XXXXXX] |
| **Duplicate verified in Hacktivity** | [Yes/No — see docs/hackerone-workflow.md] |

---

## 🎯 Executive Summary

[Brief description of the finding in 2-3 sentences]

---

## 🔍 Vulnerability Details

### Type
[e.g: SQL Injection, XSS, SSRF, IDOR, etc.]

### CWE
[CWE-XXX]

### CVSS Score
[X.X]

### Vector
[AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H]

---

## 📝 Steps to Reproduce

### 1. Prerequisites
```
[What is needed to reproduce]
```

### 2. Detailed steps

**Step 1: [Description]**
```
[Action to perform]
```

**Step 2: [Description]**
```
[Action to perform]
```

**Step 3: [Description]**
```
[Action to perform]
```

### 3. Expected result
```
[What should happen]
```

### 4. Actual result (with the bug)
```
[What happens with the vulnerability]
```

---

## 💥 Impact

### Confidentiality
[High/Medium/Low - Description]

### Integrity
[High/Medium/Low - Description]

### Availability
[High/Medium/Low - Description]

### Business Impact
[Description of business impact]

---

## 📸 Evidence

### Screenshots
[Attach relevant screenshots]

### PoC Code
```python
# Proof of Concept code
[ Code demonstrating the vulnerability ]
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

## 🔧 Remediation Recommendation

### Short-term Fix
[Quick immediate fix]

### Long-term Fix
[Complete long-term fix]

### Code Example
```php
// Secure code example
[ Corrected code ]
```

---

## 📚 References

- [OWASP - Vulnerability type]
- [CWE - CWE-XXX]
- [CVE - If applicable]
- [Official documentation]

---

## 📝 Additional Notes

[Extra relevant information]

---

## ✅ Checklist

- [ ] I have verified that the vulnerability is reproducible
- [ ] I have documented all steps clearly
- [ ] I have included sufficient evidence
- [ ] I have assessed the impact correctly
- [ ] I have suggested a fix
- [ ] I have not performed destructive actions
- [ ] I have respected the program limits (`programs/<program>.md`)
- [ ] I searched for the finding in Hacktivity/program public reports before submitting
- [ ] The title is specific (endpoint + vuln type), not generic

---

*dev101x — Bug Bounty Framework*
