---
name: defending-in-depth
description: Use when designing or implementing anything touching user input, auth, sessions, secrets, PII, network calls, uploads, crypto, or deploy config, when adding an endpoint or dependency, or when reviewing for security. Symptoms: "is this safe", handling tokens, storing passwords, encrypting data.
---

# Defending In Depth

Security is a design property from line 1, not a final pass. Any conflict with speed, scope, or elegance: security wins, no exceptions.

## Three laws

1. **Assume the breach already happened.** The attacker has root, a database dump, your source, and a valid session token. Design for what they do *next*; a control that only works against outsiders is not a control.
2. **Minimize blast radius by construction.** "If one thing leaks, it decrypts one record": structural, not procedural.
3. **Stay cryptographically agile.** NIST removes quantum-vulnerable algorithms by 2035; anything you cannot rotate without a rewrite is already a liability.

**Dev freedom never relaxes the artifact.** Dev machine runs full-permission; shipped code still assumes hostile prod. Every deployed change carries negligible blast radius: reversible migrations, one-step rollback, staged exposure for risky paths, kill switch on new surface. Nothing deploys without the gate green on the deploy artifact (dmj:enforcing-quality-gates).

## Gate 0: Threat model before code

Write four lists first:
- **Assets**: PII, secrets, money, trust.
- **Entry points**: every input, route, header, file, queue, env var.
- **Trust boundaries**: where data crosses less-trusted to more-trusted.
- **Abuse cases**: how a hostile user attacks each entry point.

Then the one people skip: **post-compromise cases.** Per asset, what does an attacker with root and a DB dump get? "The data" means the design is not finished.

Gate against the **current OWASP Top 10** (WebFetch the live edition; categories change) and target **ASVS L2** as the verifiable bar. Each item: mitigated, or not-applicable with a reason.

## Blast radius by construction

| Design choice | Radius when breached |
|---|---|
| One key encrypts the whole table | everything |
| One key per tenant | one tenant |
| **Per-record DEK wrapped by a tenant KEK** | **one record** |
| Long-lived service credential | everything that credential reaches, forever |
| **Short-TTL credential, per-workload identity** | **one workload, for minutes** |
| Field-level encryption | the encrypted fields survive a full DB dump |
| Data never collected | nothing. The cheapest control there is |

**Crypto-shredding is deletion.** Destroy the record's key and the ciphertext is unrecoverable, including in backups you cannot selectively edit. This is how right-to-deletion (GDPR/DPDPA) works against immutable backups, and it only works if keys are per-record from day one. Retrofitting it means re-encrypting everything.

## Quantum durability

The threat is **harvest now, decrypt later**: ciphertext recorded today is decrypted once a cryptographically relevant quantum computer exists, so confidentiality that must outlast roughly 2035 is already exposed under classical-only exchange. **Symmetric is fine** (Grover only halves: AES-256 keeps ~128-bit strength; SHA-384 and Argon2id stay); the exposure is asymmetric exchange and signatures. **Hybrid, never pure**: combine classical and post-quantum so the result holds if either survives; SIKE reached the NIST finalist round and fell on a laptop in 2022. **Profile follows data lifetime, not preference**: mandating the strongest primitive where no audited implementation exists produces a hand-rolled one.

| | MAX (at rest, long life) | TRANSPORT (TLS) | SESSION (minutes) |
|---|---|---|---|
| AEAD | **AEGIS-256**, 256-bit tag, 256-bit random nonce | negotiated | AES-256-GCM |
| Key exchange | **X25519 + ML-KEM-1024** | strongest the peer will negotiate, today X25519MLKEM768 | X25519 + ML-KEM-768 |
| Signatures | **ML-DSA-87** | n/a | ML-DSA-65 |
| Roots (10-year) | **SLH-DSA-SHA2-256s** | n/a | n/a |
| KDF / hash | HKDF-SHA-512 | negotiated | HKDF-SHA-256 |

Passwords are always Argon2id at high memory cost, never bcrypt, scrypt, or custom.

**Two rules override the table.** Never hand-roll a primitive to reach a tier: an audited AES-256-GCM beats an unaudited AEGIS-256, so drop to the next audited choice and record why. AEGIS nonces are random 256-bit values, never counters, never reused (not nonce-misuse resistant; reuse recovers internal state). Tag pinned at 256 bits; at 128, committing security is only 64.

TLS is the peer's choice, not yours: take the strongest negotiated group and verify it on a live connection. AEGIS is not yet an RFC (CFRG draft-18, shipped in libsodium); Falcon and HQC are unfinalized. Confirm all of it at invocation.

Encryption is urgent now (harvested ciphertext cannot be un-harvested); signature urgency scales with key lifetime, a decade-lived signing root long before a five-minute session token. Parameters, hybrid construction, envelope format, key hierarchy, migration order: `quantum-durable-crypto.md`.

## Crypto agility is the actual five-year answer

Picking the right algorithm is a bet. Being able to change it is a design.

- **Version every ciphertext and signature**: a leading algorithm identifier; read any supported version, write only the current.
- **One module owns algorithm selection.** A primitive named outside it is a future migration blocker; grep for hits.
- **Rotation is a tested path**: re-encrypt-on-read plus a background sweep, exercised before needed. A rotation that has never run does not exist.
- **Write the migration before you need it**, while the system is small.

## Assume-breach controls

The attacker is already inside. These are what still work.

| Control | What it denies the attacker |
|---|---|
| **Hash-chained append-only audit** | rewriting their tracks. Each entry commits to the previous hash, so any edit breaks the chain. Ship the chain head off-host |
| **Egress allowlist** | exfiltration. Breach without egress is contained. Most systems control ingress carefully and let anything out |
| **Short-TTL credentials, no standing privilege** | persistence. A stolen token that expires in minutes needs continuous re-theft |
| **Per-workload identity** | lateral movement. One compromised service reaches only what it needs |
| **Canary records and tokens** | silence. A read of a record no legitimate query touches is an unambiguous breach signal |
| **Volume and shape anomaly detection** | bulk theft. Nobody legitimately reads every row |
| **Tested restore, tested key rotation** | permanence. An untested backup is a hope |

Under law 1 detection outranks prevention: prevention already failed in the scenario you are designing for.

## Non-negotiable controls

| Layer | Floor |
|---|---|
| Input | All input hostile. Server-side validation, parameterized queries only, output-encode on render. No dynamic code execution. |
| Authz | Zero trust, verify every layer, never trust internal. Least privilege, deny-by-default. |
| Crypto | Hybrid post-quantum per the table above. One module owns selection. Versioned ciphertexts. Confirm current FIPS parameters at invocation. |
| Keys | Per-record DEK, per-tenant KEK, rotation tested. Keys never share a blast radius with the data they protect. |
| Transport | TLS 1.3 floor with hybrid key exchange. HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy on every response. Nonce-based CSP. CORS explicit origins, never `*`. |
| Secrets | Never in source or logs. Short TTL, injected at runtime, rotated on every deploy. |
| Audit | Hash-chained, append-only, head replicated off-host. |
| Abuse | Static early-reject (small fixed response) before any DB/CPU/memory work. Brute-force backoff, rate limits day one. |
| Blast radius | Smallest reversible diff, sandbox first, every credential scoped tightly and short-lived. |

## Fuzz what decides, not what sounds security-shaped

Anything that makes an allow or deny decision, or parses input it did not create, gets a fuzz harness (dmj:enforcing-quality-gates, `fuzzing.md`): encoding, structure, lexical, boundary. A fail-open control that has never been fuzzed is bypassable until proven otherwise; a behavior suite covers only the cases someone imagined.

## Machine-checkable gates (CI)

SAST, dependency audit failing on high or critical, secret scanning, security headers, and the **crypto lane**: banned primitives (MD5, SHA-1, bcrypt, scrypt, RSA or ECDH key exchange without a hybrid PQC partner), hardcoded algorithm strings outside the crypto module, and unversioned ciphertext writes. Human review catches what these miss; it never replaces them.

## Parallel pattern

Before implementation, spawn an **adversarial attacker-mindset teammate** to attack the design (one `Agent` with a `name`; it `SendMessage`s midway progress). Give it law 1 explicitly: it starts with root and a DB dump. Every review panel runs a dedicated **fresh-context security reviewer**, never same-context self-review.

## Rationalization table

| Excuse | Reality |
|---|---|
| "Internal service, it is trusted" | Zero trust. Internal is the next breach's lateral move. |
| "Add auth/validation later" | Later never comes before the exploit. |
| "It is just an MVP/demo" | Breached demos leak real data and the user's reputation. |
| "Client validates it already" | Client validation is UX; the server is the only authority. |
| "bcrypt/scrypt is fine" | Mandate is Argon2id. No substitutions. |
| "Quantum is decades away" | Harvest now, decrypt later. The ciphertext leaving today is the one decrypted then. |
| "We used ML-KEM, we are post-quantum" | Pure PQC drops classical assurance. Hybrid or it is a downgrade in one dimension. |
| "One key is simpler" | One key means one breach equals total loss, and makes crypto-shredding impossible forever. |
| "We will rotate keys if something happens" | An untested rotation path is not a path. Exercise it before you need it. |

## Red flags: STOP, fix the layer, continue

- String-concatenated SQL or shell.
- Secret in code, config, or a log line.
- New endpoint with no authz check or rate limit.
- `eval`, `dangerouslySetInnerHTML`, unsanitized template.
- `CORS: *`, missing security headers, TLS below 1.3.
- A single key protecting more than one tenant's data.
- An algorithm name hardcoded outside the crypto module.
- A ciphertext with no version prefix.
- Pure post-quantum key exchange with no classical hybrid partner.
- A backup that has never been restored, or a key rotation that has never run.
- A design review that never asked what an attacker with root already has.

Handoff: threat model into dmj:writing-plans; security lens required in dmj:requesting-code-review; gate lanes in dmj:enforcing-quality-gates.
