# AI-Assisted Code Review — Method

Source: [Local AI for Cybersecurity](https://projectblack.io/blog/local-ai-for-cyber-security/)
(Project Black). Adapted here for bug bounty work on HackerOne, not just
local-model research.

## The core finding: harness beats model

The article compares four approaches to finding vulnerabilities in a real
codebase (benchmark: an LFI in PHPIPAM). Ranked worst to best:

1. **Semgrep (`semgrep scan --config auto`)** — rule-based SAST. Missed the
   bug entirely. Limitation: "you can only write rules for dangerous
   patterns that you already know exist."
2. **Cloud agentic workflow (Strix + GLM 5.1)** — autonomous repo
   exploration or full agentic run. ~$30–300 in tokens (GLM vs
   GPT-5.4/Sonnet 4.6), 60M tokens burned, **still missed the bug**.
   Unconstrained autonomy on a large codebase wastes budget without
   guaranteeing coverage.
3. **Cloud models + Markdown "skills" (Claude Code / Cursor / Copilot)** —
   sub-agents per vulnerability category, more guidance. **Inconsistent**:
   found it sometimes, missed it other times, depending on which files the
   agent happened to pick.
4. **Local model + disciplined file-by-file harness (Qwen 3.6 27B, ~170K
   context)** — **won, every run.** Architecture:
   ```
   for each source file:
       model reviews ONE file + relevant context
       writes a structured report
   collect all reports
   ```
   ~120M tokens for an ~800-file codebase, but 100% hit rate on the
   benchmark, plus a real find in the wild: **myVesta authenticated RCE**
   (username param passed straight into `exec()`).

**Takeaway**: an unconstrained agent given a whole codebase and told "find
bugs" burns huge budget and is unreliable — coverage depends on what it
happens to look at. A disciplined pass that guarantees every file gets
reviewed, one at a time, with a fixed report format, is what actually
produces repeatable hits. This maps directly onto **loop-until-dry / full
coverage** patterns, not "smart autonomous agent, hope it looks in the
right place."

## Where this applies to bug bounty (most targets are closed-source)

Straight source-code review only works when source is actually available:

- **Self-hosted/open-source software in scope** — some programs include
  forked CMS, admin panels, or internal tools built on open-source bases
  (like PHPIPAM, myVesta in the article). If a program's scope includes
  something you can `git clone` or download, this is directly applicable.
- **Client-side JS bundles of closed-source SPAs** — this is the
  adaptation that matters for most bug bounty targets: a Next.js/React/Vue
  bundle IS source you can read (minified, but still parseable). Treat each
  JS chunk as a "source file" in the harness and look for the same
  dangerous-pattern classes: `eval`/`new Function`, hardcoded API keys/secrets
  (see `auth_secret` findings — this is exactly the kind of thing a per-file
  pass over JS bundles would have surfaced faster), `postMessage` handlers
  without origin checks, prototype pollution patterns, debug/test code left
  in production bundles, client-trusted flags (`withVip`-style booleans).

## How to run this harness in this lab

No local model (Qwen/Ollama/llama.cpp) is installed in this environment —
that's not the point. The **harness pattern** is what to reuse, and this
session's own tooling (the `Agent`/`Workflow` mechanism) already implements
it structurally:

1. Pull the target material: JS bundle files (`curl` each `_next/static/chunks/*.js`),
   or a cloned repo if source is in scope.
2. Split into per-file (or per-chunk) units small enough for one review pass.
3. For each unit: one review pass, fixed output structure (finding / file /
   line / why-it-matters / confidence) — same shape as this project's own
   `ReportFindings` schema.
4. Collect every report, don't stop at the first hit — full coverage is the
   entire point, matching the article's "every run found it" result versus
   the agentic approach's "sometimes found it."
5. Use `Workflow` with `pipeline()` over the file list for this: one
   `agent()` call per file/chunk, schema-constrained output, then merge —
   this is a direct match for the winning harness, just using cloud models
   instead of a local Qwen rig. (Only invoke `Workflow` if the user asks
   for multi-agent orchestration explicitly — see this repo's own tool
   rules.)

## Known limitations (carry these over, don't oversell the method)

- **High token consumption** — file-by-file coverage on a large bundle set
  is expensive. Scale the file count to what the engagement budget allows.
- **False positives** — every finding from this pass is a *candidate*,
  not a confirmed bug. Still needs the same manual verification discipline
  used elsewhere in this lab (see `docs/hackerone-workflow.md` — no
  reporting without a working PoC).
- **Weak on Broken Access Control / multi-step logic bugs** — a single file
  in isolation can't see cross-request state (auth flows, IDOR across
  endpoints, race conditions). Those still need the manual,
  cross-referencing review this lab already does by hand — this harness is
  a complement for *code-visible* bug classes (injection, hardcoded
  secrets, dangerous sinks), not a replacement for business-logic testing.

## Reference CVEs from the source article

| CVE | Software | Bug |
|---|---|---|
| CVE-2026-12194 | PHPIPAM | Authenticated LFI — unsanitized controller param concatenated into `require_once()` |
| CVE-2026-12195 | myVesta | Authenticated RCE — FTP username-deletion function passes username param straight to `exec()` |
