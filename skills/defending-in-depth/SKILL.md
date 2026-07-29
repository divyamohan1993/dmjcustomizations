---
name: defending-in-depth
description: Use when designing or implementing anything touching user input, auth, sessions, secrets, PII, network calls, uploads, crypto, or deploy config, when adding an endpoint or dependency, or when reviewing for security. Symptoms: "is this safe", handling tokens, storing passwords, encrypting data.
---

# Defending In Depth

Security = design property from line 1, not a final pass. Conflict with speed/scope/elegance: security wins, no exceptions.

## Three laws

1. **Assume the breach already happened.** Attacker holds root + DB dump + your source + a valid session token. Design for what they do *next*. A control stopping only outsiders: not a control.
2. **Minimize blast radius by construction.** "One leak decrypts one record": structural, not procedural.
3. **Stay cryptographically agile.** NIST removes quantum-vulnerable algorithms by 2035. Anything unrotatable without a rewrite: already a liability.

**Dev freedom never relaxes the artifact.** Dev machine full-permission; shipped code still assumes hostile prod. Every deployed change carries negligible blast radius: reversible migrations, one-step rollback, staged exposure on risky paths, kill switch on new surface. Nothing deploys without gate green on the deploy artifact (dmj:enforcing-quality-gates).

## Gate 0: Threat model before code

Four lists first:
- **Assets**: PII, secrets, money, trust.
- **Entry points**: every input, route, header, file, queue, env var.
- **Trust boundaries**: less-trusted -> more-trusted crossings.
- **Abuse cases**: hostile user per entry point, business logic included: quota gaming (referral exploits, trial resets, free-tier abuse), unintended use (text field storing files, account sharing), social engineering of users/support.

Then **post-compromise cases**: per asset, what does an attacker with root + a DB dump get? "The data" = design not finished.

Gate against **current OWASP Top 10** (WebFetch the live edition; categories change). Target **ASVS L2** as the verifiable bar. Each item: mitigated, or not-applicable with a reason.

## Blast radius by construction

| Design choice | Radius when breached |
|---|---|
| One key encrypts the whole table | everything |
| One key per tenant | one tenant |
| **Per-record DEK wrapped by a tenant KEK** | **one record** |
| Long-lived service credential | everything that credential reaches, forever |
| **Short-TTL credential, per-workload identity** | **one workload, minutes** |
| Field-level encryption | encrypted fields survive a full DB dump |
| Data never collected | nothing. Cheapest control there is |

**Crypto-shredding = deletion.** Destroy the record's key -> ciphertext unrecoverable, backups you cannot selectively edit included. How right-to-deletion (GDPR/DPDPA) beats immutable backups; works only if keys are per-record from day one. Retrofit = re-encrypt everything.

## Quantum durability

**Harvest now, decrypt later**: today's ciphertext gets decrypted later. Confidentiality outlasting roughly 2035: already exposed under classical-only exchange. **Symmetric is fine** (Grover only halves: AES-256 keeps ~128-bit strength; SHA-384 + Argon2id stay). Exposure = asymmetric exchange + signatures. **Hybrid, never pure**: SIKE reached the NIST finalist round, fell on a laptop in 2022. Only a combination holding if either primitive survives is safe. **Profile follows data lifetime, not preference**: mandating the strongest primitive where no audited implementation exists produces a hand-rolled one.

| | MAX (at rest, long life) | TRANSPORT (TLS) | SESSION (minutes) |
|---|---|---|---|
| AEAD | **AEGIS-256**, 256-bit tag, 256-bit random nonce | negotiated | AES-256-GCM |
| Key exchange | **X25519 + ML-KEM-1024** (Category 5) | strongest the peer will negotiate, today X25519MLKEM768 | X25519 + ML-KEM-768 |
| Signatures | **ML-DSA-87** (Category 5) | n/a | ML-DSA-65 |
| Roots (10-year) | **SLH-DSA-SHA2-256s** | n/a | n/a |
| KDF / hash | HKDF-SHA-512; SHA-512, or SHA-384 where output size matters | negotiated | HKDF-SHA-256 |

Passwords always Argon2id, memory cost tuned high for the deployment hardware. Never bcrypt, scrypt, custom.

**Two rules override the table.** Never hand-roll a primitive to reach a tier: audited AES-256-GCM beats unaudited AEGIS-256. Drop to the next audited choice (AES-256-GCM wherever AEGIS is unavailable), record the drop + its reason in `qgate.config.sh`. AEGIS nonces = random 256-bit values, never counters, never reused (not nonce-misuse resistant; reuse recovers internal state). Tag pinned at 256 bits; at 128, committing security is only 64.

TLS = the peer's choice, not yours: take the strongest negotiated group, verify it on a live connection. Encryption urgent now, harvested ciphertext cannot be un-harvested; signature urgency scales with key lifetime, a decade-lived signing root long before a five-minute session token.

Construction, envelope format, key hierarchy, migration order, libraries, standards status: `quantum-durable-crypto.md`.

## Crypto agility is the actual five-year answer

- **Version every ciphertext and signature**: leading algorithm identifier. Read any supported version, write only the current.
- **One module owns algorithm selection.** A primitive named outside it = future migration blocker; grep for hits.
- **Rotation is a tested path**: re-encrypt-on-read + background sweep, exercised before needed. Rotation never run: does not exist.
- **Write the migration before you need it**, while the system is small.

## Assume-breach controls

Attacker already inside. These still work.

| Control | What it denies the attacker |
|---|---|
| **Hash-chained append-only audit** | rewriting tracks. Each entry commits to the previous hash -> any edit breaks the chain. Ship the chain head off-host |
| **Egress allowlist** | exfiltration. Breach without egress: contained. Most systems guard ingress carefully, let anything out |
| **Short-TTL credentials, no standing privilege** | persistence. Stolen token expiring in minutes needs continuous re-theft |
| **Per-workload identity** | lateral movement. One compromised service reaches only what it needs |
| **Canary records and tokens** | silence. A read of a record no legitimate query touches = unambiguous breach signal |
| **Volume and shape anomaly detection** | bulk theft. Nobody legitimately reads every row |
| **Tested restore, tested key rotation** | permanence. Untested backup: a hope |

Under law 1 detection outranks prevention: prevention already failed in the scenario you are designing for.

## Non-negotiable controls

| Layer | Floor |
|---|---|
| Input | All input hostile. Server-side validation. Parameterized queries only. Output-encode on render. No dynamic code execution. |
| Authz | Zero trust, verify every layer, never trust internal. Least privilege, deny-by-default. |
| Session and auth | Short-expiry tokens + refresh rotation. Every session invalidated on credential change. MFA on admin surfaces. Failed-auth attempts alerted + backed off (see Abuse). |
| Crypto | Hybrid post-quantum per the table above. One module owns selection. Versioned ciphertexts. Confirm current FIPS parameters at invocation. |
| Keys | Per-record DEK, per-tenant KEK, rotation tested. Keys never share a blast radius with the data they protect. |
| Transport | TLS 1.3 floor + hybrid key exchange. HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy on every response. Nonce-based CSP. CORS explicit origins, never `*`. |
| Secrets | Never in source or logs. Short TTL, injected at runtime, rotated every deploy. |
| Audit | Hash-chained, append-only, head replicated off-host. |
| Abuse | Static early-reject (small fixed response) before any DB/CPU/memory work. Brute-force backoff, rate limits day one. |
| Privacy and residency | DPDP Act 2023 + GDPR always. India users' data stays in India. Consent explicit, granular, revocable, no dark patterns. Deletion real: DB, backups (crypto-shred), logs, caches, analytics. Collect the minimum. PII never in logs, errors, URLs. |
| Blast radius | Smallest reversible diff, sandbox first, every credential scoped tightly + short-lived. |

## Fuzz what decides, not what sounds security-shaped

Anything making an allow/deny decision, or parsing input it did not create, gets a fuzz harness across encoding, structure, lexical, boundary classes (dmj:enforcing-quality-gates, `fuzzing.md`). Fail-open control never fuzzed: bypassable until proven otherwise.

## Machine-checkable gates (CI)

SAST, dependency audit failing on high or critical, secret scanning, security headers, plus the **crypto lane** grepping three things: banned primitives (MD5, SHA-1, bcrypt, scrypt, RC4, 3DES, ECB), algorithm names outside the crypto module, non-crypto randomness in security-relevant files. What a grep cannot decide stays on the security review lens: key exchange missing its hybrid PQC partner, ciphertext with no version prefix. Human review catches what the lanes miss; it never replaces them.

## Parallel pattern

Before implementation, an **adversarial attacker-mindset teammate** attacks the design (dmj:dispatching-parallel-teams), briefed with law 1 explicitly: it starts with root and a DB dump. Every review panel runs a dedicated **fresh-context security reviewer**, never same-context self-review.

## Rationalization table

| Excuse | Reality |
|---|---|
| "Internal service, it is trusted" | Zero trust. Internal = next breach's lateral move. |
| "Add auth/validation later" | Later never comes before the exploit. |
| "It is just an MVP/demo" | Breached demos leak real data + the user's reputation. |
| "Client validates it already" | Client validation = UX. Server = only authority. |
| "bcrypt/scrypt is fine" | Mandate = Argon2id. No substitutions. |
| "Quantum is decades away" | Harvest now, decrypt later. Today's ciphertext = the one decrypted then. |
| "We used ML-KEM, we are post-quantum" | Pure PQC drops classical assurance. Hybrid, or a downgrade in one dimension. |
| "We are on TLS 1.3, so the data is covered" | TLS 1.3 with classical-only groups = exactly the harvested traffic. Transport protects nothing at rest. |
| "One key is simpler" | One key = one breach equals total loss, crypto-shredding impossible forever. |
| "We will rotate keys if something happens" | Untested rotation path: not a path. Exercise it before you need it. |

## Red flags: STOP, fix the layer, continue

- String-concatenated SQL or shell.
- Secret in code, config, or a log line.
- New endpoint with no authz check or rate limit.
- `eval`, `dangerouslySetInnerHTML`, unsanitized template.
- `CORS: *`, missing security headers, TLS below 1.3.
- Single key protecting more than one tenant's data.
- Algorithm name hardcoded outside the crypto module, or ciphertext with no version prefix.
- Pure post-quantum key exchange, no classical hybrid partner.
- Backup never restored, or key rotation never run.
- Design review that never asked what an attacker with root already has.

Handoff: threat model -> dmj:writing-plans; security lens required in dmj:requesting-code-review; gate lanes in dmj:enforcing-quality-gates.
