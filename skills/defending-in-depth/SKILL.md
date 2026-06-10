---
name: defending-in-depth
description: Use when designing or implementing anything that touches user input, authentication, sessions, secrets, PII, network calls, file uploads, or deployment config, when adding an endpoint or a dependency, or when reviewing code for security. Symptoms: "is this safe", "validate this", handling tokens, building auth, storing passwords, accepting uploads, exposing an API.
---

# Defending In Depth

Security is a design property from line 1, not a final pass. Any conflict with speed, scope, or elegance: security wins, no exceptions.

**Assume host compromised, DB exfiltrated, attacker holds your source.** Each layer protects data independently; one failing exposes nothing.

**Dev freedom never relaxes the artifact.** Dev machine runs full-permission; shipped code still assumes hostile prod. Every deployed change = negligible blast radius: reversible migrations, one-step rollback, staged/flagged exposure for risky paths, kill switch on new surface. Nothing deploys, ever, without the full test suite green on the deploy artifact.

## Gate 0: Threat model before code

Write four lists first:
- **Assets**: PII, secrets, money, trust.
- **Entry points**: every input, route, header, file, queue, env var.
- **Trust boundaries**: where data crosses less-trusted to more-trusted.
- **Abuse cases**: how a hostile user attacks each entry point.

Then gate against the **current OWASP Top 10** (WebFetch the live edition; categories change). Each: mitigated, or not-applicable with reason.

## Non-negotiable controls

| Layer | Floor |
|-------|-------|
| Input | All input hostile. Server-side validation, parameterized queries only, output-encode on render. No dynamic code execution. |
| Authz | Zero trust, verify every layer, never trust internal. Least privilege, deny-by-default. |
| Crypto | Quantum-safe defaults: AES-256-GCM, ML-KEM, ML-DSA, Argon2id for passwords. Never bcrypt, scrypt, custom crypto. Confirm current FIPS/RFC parameters at invocation. |
| Transport | TLS 1.3 floor. HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy every response. Nonce-based CSP. CORS explicit origins (never `*`). |
| Secrets | Never in source or logs. Encrypted at rest, injected at runtime. |
| Audit | Tamper-evident, append-only trail on every privileged operation. |
| Abuse | Static early-reject (small fixed response) before any DB/CPU/memory work. Brute-force backoff, rate limits day one. |
| Blast radius | Smallest reversible diff, sandbox first, scope every credential tightly. |

## Machine-checkable gates (CI)

SAST (CodeQL or semgrep), dependency audit failing on high/critical, secret scanning, security-header check. Human lens catches what these miss, never replaces.

## Parallel pattern

Before implementation, spawn an **adversarial attacker-mindset teammate** to attack the design (TeamCreate + Agent with team_name + name; SendMessage midway progress; TeamCreate unavailable: native parallel Agent call). Every review panel runs a dedicated **fresh-context security reviewer**, never same-context self-review.

## Rationalization table

| Excuse | Reality |
|--------|---------|
| "Internal service, it is trusted" | Zero trust. Internal is the next breach's lateral move. |
| "Add auth/validation later" | Later never comes before the exploit. Build it now. |
| "It is just an MVP/demo" | Breached demos leak real data and the user's reputation. |
| "Client validates it already" | Client validation is UX; the server is the only authority. |
| "bcrypt/scrypt is fine" | Mandate is Argon2id, quantum-safe defaults. No substitutions. |

## Red flags: STOP, fix the layer, continue

- String-concatenated SQL or shell
- Secret in code, config, or a log line
- New endpoint, no authz check or rate limit
- `eval`, `dangerouslySetInnerHTML`, unsanitized template
- `CORS: *`, missing security headers, TLS below 1.3

Handoff: threat model into dmj:writing-plans; require the security lens in dmj:requesting-code-review.
