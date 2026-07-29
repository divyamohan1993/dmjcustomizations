# Quantum-Durable Crypto

Parameters, construction, and migration order. Confirm every algorithm and parameter against the current FIPS text at invocation: this file is a starting point with a known publication date, not a live source.

Status at time of writing: FIPS 203 (ML-KEM), 204 (ML-DSA), 205 (SLH-DSA) final since August 2024. FN-DSA (Falcon) and HQC selected but still in standardization, so not primaries. NIST deprecates and removes quantum-vulnerable algorithms from its standards by 2035.

## Three profiles, chosen by data lifetime

Maximum parameters everywhere is the wrong rule, for one reason that has nothing to do with cost: **the strongest primitive is usually the least deployed**, and a mandate to use it where no audited implementation exists produces a hand-rolled one. A hand-written AEGIS-256 is far worse than a platform AES-256-GCM. So the profile is chosen by how long the data must stay secret, and the availability rule below overrides all three.

### MAX: data at rest, long confidentiality life

Archives, PII, medical, legal, financial records, backups, anything harvested today that still matters in 2040.

| Use | Choice |
|---|---|
| AEAD | **AEGIS-256**, 256-bit tag, 256-bit **random** nonce. Fall back to AES-256-GCM where unavailable |
| Key exchange | **X25519 + ML-KEM-1024** hybrid (Category 5) |
| Signatures | **ML-DSA-87** (Category 5) |
| Signing roots, 10-year life | **SLH-DSA-SHA2-256s** (hash-based, different math family) |
| KDF | HKDF-SHA-512 |
| Hash | SHA-512, or SHA-384 where output size matters |
| Passwords | Argon2id, memory cost tuned to the deployment hardware |

### TRANSPORT: TLS, where you do not control the peer

Use the strongest group the stack and the peer will both negotiate. Today that is **X25519MLKEM768**, because that is what browsers ship. You cannot mandate ML-KEM-1024 here: writing a rule the peer cannot satisfy produces either a broken connection or a silent downgrade nobody notices. Verify the negotiated group on a live connection rather than trusting configuration.

### SESSION: ephemeral, minutes to hours

Session tokens, short-lived caches, request signing. AES-256-GCM and X25519+ML-KEM-768 are sufficient, because harvest-now-decrypt-later does not threaten data whose value expires before the decryption does. Spending complexity budget here buys nothing.

## Two rules that override the profiles

**1. Never hand-roll to reach a tier.** If the MAX profile's primitive has no audited implementation on your platform, drop to the next choice that does and record the drop in `qgate.config.sh` with a reason. An audited AES-256-GCM beats an unaudited AEGIS-256 by a wide margin, and the failure is silent in exactly the way crypto failures always are.

**2. AEGIS nonces are random, never counters, never reused.** AEGIS is **not** nonce-misuse resistant. The specification is explicit: reuse under one key lets an attacker recover the internal state, which is a worse failure than the forgery you get from GCM nonce reuse. The 256-bit nonce is what makes this safe, because random 256-bit nonces will not collide at any realistic message volume. A counter-based or truncated nonce throws that away. Use a 256-bit tag as well: at 128 bits, committing security is only 64 bits.

## Why AEGIS-256 over AES-256-GCM

Both are AES-round based, so both are fast on hardware with AES-NI, and both retain roughly 128-bit strength against Grover.

- **Nonce space.** GCM's 96-bit nonce forces careful counter management, and random 96-bit nonces become risky in the billions of messages. AEGIS-256's 256-bit nonce makes random generation safe at any volume, which removes an entire class of operational bug.
- **Throughput.** AEGIS is designed for vector AES instructions and outperforms AES-GCM substantially on modern cores.
- **Committing security.** With a 256-bit tag, AEGIS gives a meaningful commitment property. AES-GCM gives none, which matters wherever a ciphertext might decrypt under more than one key.

**Status, and the reason to keep the fallback.** AEGIS came out of the CAESAR competition and is being standardized through the IRTF CFRG. As of this writing draft-18 has been sent to the RFC Editor for Informational publication; it is not yet an RFC. libsodium ships it (1.0.19 onward). Confirm the current status and your library's support at invocation rather than assuming either.

**Why two signature families.** ML-DSA and SLH-DSA rest on different mathematics. If lattice assumptions fall, a hash-based root can still sign the emergency rotation. A system whose every signature depends on one family has a single point of cryptographic failure, which is the thing defence in depth exists to prevent.

## Hybrid construction

Hybrid means an attacker must break **both** primitives, so do not let the combination be weaker than either part.

- Run both key exchanges. You now hold a classical shared secret and a post-quantum shared secret.
- Feed **both, plus a transcript binding**, into a single KDF (HKDF-SHA256 or better). The output is the session key.
- Do **not** XOR the two secrets, and do not use one to encrypt the other. Concatenate into the KDF input so the result is at least as strong as the stronger input.
- Bind the transcript, meaning both public keys and the negotiated parameters, into the KDF so neither half can be swapped by an attacker in the middle.

For TLS, do not build this yourself. Enable the hybrid group in the TLS stack and verify the negotiated group is `X25519MLKEM768` on a live connection. Hand-rolled hybrids are how a hybrid becomes weaker than its classical half.

## Ciphertext envelope

Every stored ciphertext carries its own recipe. This is what makes rotation possible later.

```
[version:u16][alg_id:u16][key_id:16][nonce:12][ciphertext][tag:16]
```

- **version** increments when the envelope layout changes.
- **alg_id** identifies the exact suite, so one dataset can hold records under several algorithms during migration.
- **key_id** names the wrapping key, so rotation does not require a flag day.
- Readers accept every supported `alg_id`. Writers emit only the current one. A background sweep re-encrypts on read and in batches.

A ciphertext with no version prefix is a migration you will one day do by hand, under time pressure, with the algorithm already broken.

## Key hierarchy

```
Root KEK          (HSM or KMS, never leaves, rotated yearly)
  -> Tenant KEK   (one per tenant, wrapped by root)
    -> Record DEK (one per record, wrapped by tenant KEK, never reused)
```

- A full database dump yields wrapped DEKs and nothing else.
- Compromise of one tenant KEK exposes one tenant.
- Deleting a record's DEK renders that record unrecoverable everywhere, including in immutable backups. That is crypto-shredding, and it is the only deletion that works against backups you cannot edit.
- Derive rather than store where you can: `DEK = KDF(tenant_KEK, record_id)` removes a storage lookup, at the cost of losing per-record shredding. Choose deliberately. If right-to-deletion matters, store the DEKs.

## Migration order

Do these in order. The ordering follows exposure, not effort.

1. **Anything crossing a network with a long confidentiality life.** Harvest-now-decrypt-later applies the moment the packet leaves. Enable hybrid TLS groups first because it is a configuration change with no data migration.
2. **Long-lived signing roots.** Code signing, firmware, certificate authorities. A root trusted for a decade must outlive the transition. Move to SLH-DSA or a dual-signature scheme.
3. **Data at rest with a long secrecy requirement.** Re-wrap under hybrid KEMs. Envelope versioning makes this incremental.
4. **Short-lived signatures and tokens.** Session JWTs verified within minutes are the least urgent. Move them last, and mostly for uniformity.

Anything already using AES-256-GCM for the data itself needs no change to the symmetric layer. Only the key exchange and the key wrapping move.

## Libraries

Verify availability and audit status at invocation; this landscape moves fast.

| Stack | Where to look |
|---|---|
| Any, via TLS | OpenSSL 3.5+ carries ML-KEM and ML-DSA natively. Check your version and the negotiated group rather than assuming |
| Node | `@noble/post-quantum` (audited, pure JS, covers ML-KEM, ML-DSA, SLH-DSA); check whether your Node release exposes them in `node:crypto` |
| Python | `liboqs-python`, `pqcrypto` |
| Rust | RustCrypto `ml-kem`, `pqcrypto` |
| Go | `cloudflare/circl` |
| JVM | Bouncy Castle |

Prefer the platform TLS stack over any application-level implementation. Prefer an audited library over a maintained one, and a maintained one over a clever one. Never implement a primitive.

## What not to do

- Pure post-quantum with no classical partner. SIKE was a NIST finalist and was broken on a single core in 2022. Hybrid costs a few hundred bytes.
- XOR-combining hybrid secrets, or otherwise inventing the combiner.
- One key for a whole table. It forecloses crypto-shredding permanently.
- An algorithm name at a call site. One module owns selection; grep for the name outside it and every hit is a future blocker.
- Rolling your own KEM, signature, or KDF. Not once, not for a demo.
- Treating "we are on TLS 1.3" as post-quantum. TLS 1.3 with classical-only groups is exactly the traffic being harvested.
