---
name: stewarding-data
description: Use when creating or changing a schema, writing or running a migration, handling backups or restores, bulk-editing production data, storing PII, or setting retention and deletion policy. Symptoms: ALTER or DROP on a live table, "just run this SQL on prod", a backup never restored.
---

# Stewarding Data

Data outlives code. Every change reversible, every copy restorable, every byte accounted for. Code bugs get fixed; data loss is forever.

## Gate 0: restorable before touchable

Before any schema change or bulk edit on real data: backup exists AND its restore has been DRILLED (restore to scratch, verify row counts + checksums, record evidence per dmj:verification-before-completion). Existence is not restorability. Drill = the backup. Unrestored = a hope. Drills repeat on a schedule, not once.

## Migrations

- **Expand, migrate, contract.** New shape first; backfill in bounded, resumable batches (watch locks + load: dmj:enforcing-performance-budgets); dual-read/dual-write through the window; old shape removed only in a LATER release, after nothing reads it. Table size grants no exemption: "small table, ALTER inline" = how small tables take outages.
- **Every migration ships its down-path**, tested. Genuinely irreversible (a DROP, a lossy cast)? Waits for explicit user confirmation, named as irreversible.
- **Pipeline only.** Migrations run by the deploy process (dmj:shipping-to-production), versioned in repo. Hand-run SQL on production = incident, not workflow.

## Data model floors

| Floor | Rule |
|---|---|
| Lifecycle columns | Every table: id, created_at, updated_at, deleted_at. Soft delete first; hard delete = policy decision |
| PII | Field-level encrypted, current quantum-safe primitives (dmj:defending-in-depth). Never plaintext, never in logs |
| Retention | Written policy per data type at DESIGN time; expiry enforced by code, not memory |
| Deletion rights | Right-to-deletion executable end to end (GDPR, DPDPA): one command finds + purges a subject's data, backups included in the plan (mechanism surviving immutable backups = crypto-shredding: dmj:defending-in-depth) |

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "Staging ran the migration fine" | Staging has no locks, no load, no irreplaceable rows. Expand-migrate-contract anyway |
| "The column is unused, just drop it" | Unused = a claim; a reader you missed makes the drop an outage. Contract in a later release |
| "Add retention later" | Later = a compliance letter. Policy at design time |

## Red flags (stop)

- Migration with no tested down-path, or DDL + data-destruction in one step.
- Restore never performed, or performed only at launch.
- SQL typed into a production console.
- PII column added plaintext, or unbounded single-transaction backfill.
- Deletion request that requires an engineer to improvise.

**Headless:** drill restores in scratch autonomously; PARK irreversible drops, retention policy numbers, anything touching live PII beyond the design.

Next: dmj:shipping-to-production runs the migration; dmj:defending-in-depth owns the crypto; dmj:verification-before-completion holds the drill evidence.
