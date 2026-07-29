# Quantum-Durable Crypto

Depth behind dmj:defending-in-depth, which owns the profile table, the two override rules, and the red flags. This file is standards status, construction, format, and migration order. Confirm every algorithm and parameter against the current FIPS text at invocation: a written file carries a publication date and is not a live source.

## Standards status

FIPS 203 (ML-KEM), 204 (ML-DSA), and 205 (SLH-DSA) are final. FN-DSA (Falcon) and HQC are selected but still in standardization, so neither is a primary. NIST removes quantum-vulnerable algorithms from its standards by 2035. AEGIS came out of the CAESAR competition and is standardizing through the IRTF CFRG: draft-18 has gone to the RFC Editor for Informational publication, so it is not yet an RFC, and libsodium ships it from 1.0.19 onward. Re-check every claim in this paragraph at invocation rather than assuming.

## Why AEGIS-256 over AES-256-GCM

Both are AES-round based, both fast on AES-NI hardware, both roughly 128-bit against Grover. AEGIS wins on three axes:

- **Nonce space.** GCM's 96-bit nonce forces careful counter management, and random 96-bit nonces get risky in the billions of messages. A random 256-bit nonce is safe at any realistic volume, which removes an entire class of operational bug.
- **Throughput.** Designed for vector AES instructions, substantially faster than AES-GCM on modern cores.
- **Committing security.** At a 256-bit tag AEGIS commits meaningfully; AES-GCM does not, which matters wherever a ciphertext might decrypt under more than one key.

**Two signature families, deliberately.** ML-DSA and SLH-DSA rest on different mathematics, so a hash-based root can still sign the emergency rotation if lattice assumptions fall. A system whose every signature depends on one family has a single point of cryptographic failure.

## Hybrid construction

Hybrid means an attacker must break **both** primitives, so never let the combination end up weaker than either part.

- Run both key exchanges. You now hold a classical shared secret and a post-quantum shared secret.
- Feed **both, plus a transcript binding** (both public keys and the negotiated parameters), into a single KDF, HKDF-SHA256 or better. The output is the session key. Binding the transcript is what stops an attacker in the middle swapping one half.
- Concatenate into the KDF input so the result is at least as strong as the stronger input. Never XOR the secrets, never use one to encrypt the other, never invent the combiner.

For TLS, do not build this yourself: enable the hybrid group in the TLS stack and verify the negotiated group on a live connection. Hand-rolled hybrids are how a hybrid becomes weaker than its classical half.

## Ciphertext envelope

Every stored ciphertext carries its own recipe. This is what makes rotation possible later.

```
[version:u16][alg_id:u16][key_id:16][nonce:per_alg][ciphertext][tag:per_alg]
```

- **version** increments when the envelope layout changes.
- **alg_id** identifies the exact suite, so one dataset can hold records under several algorithms during migration.
- **Nonce and tag lengths follow `alg_id`**: 32 and 32 bytes for AEGIS-256 at the mandated 256-bit tag, 12 and 16 for AES-256-GCM. A layout that hardcodes 12 and 16 cannot store the MAX profile at all.
- **key_id** names the wrapping key, so rotation does not require a flag day.
- Readers accept every supported `alg_id`. Writers emit only the current one. A background sweep re-encrypts on read and in batches.

A ciphertext with no version prefix is a migration you will one day do by hand, under time pressure, with the algorithm already broken.

## Key hierarchy

```
Root KEK          (HSM or KMS, never leaves, rotated yearly)
  -> Tenant KEK   (one per tenant, wrapped by root)
    -> Record DEK (one per record, wrapped by tenant KEK, never reused)
```

A full database dump yields wrapped DEKs and nothing else; one compromised tenant KEK exposes one tenant. Deleting a record's DEK renders that record unrecoverable everywhere, immutable backups included, which is why crypto-shredding is the only deletion that works against backups you cannot edit.

Deriving instead of storing, `DEK = KDF(tenant_KEK, record_id)`, removes a storage lookup and costs you per-record shredding. Choose deliberately: where right-to-deletion matters (dmj:stewarding-data), store the DEKs.

## Migration order

Ordered by exposure, not effort.

1. **Anything crossing a network with a long confidentiality life.** Harvest-now-decrypt-later applies the moment the packet leaves, and enabling hybrid TLS groups is a configuration change with no data migration.
2. **Long-lived signing roots.** Code signing, firmware, certificate authorities: a root trusted for a decade must outlive the transition. Move to SLH-DSA or a dual-signature scheme.
3. **Data at rest with a long secrecy requirement.** Re-wrap under hybrid KEMs; envelope versioning makes this incremental.
4. **Short-lived signatures and tokens.** Session JWTs verified within minutes are least urgent. Move them last, and mostly for uniformity.

Data already under AES-256-GCM needs no change to the symmetric layer. Only the key exchange and the key wrapping move.

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

Prefer the platform TLS stack over any application-level implementation, an audited library over a merely maintained one, a maintained one over a clever one. Never implement a primitive.
