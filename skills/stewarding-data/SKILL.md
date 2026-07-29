---
name: stewarding-data
description: Use when creating or changing a schema, writing or running a migration, handling backups or restores, bulk-editing production data, storing PII, or setting retention and deletion policy. Symptoms: ALTER or DROP on a live table, "just run this SQL on prod", a backup never restored.
---

# Stewarding Data

Data outlives code. Every change to it reversible, every copy restorable, every byte accounted for. Code bugs get fixed; data loss is forever.

## Gate 0: restorable before touchable

Before any schema change or bulk edit on real data: a backup exists AND its restore has been DRILLED (restore into a scratch environment, verify row counts and checksums, record the evidence per dmj:verification-before-completion). Existence is not restorability: the drill is the backup, an unrestored one is a hope. Drills repeat on a schedule, not once.

## Migrations

- **Expand, migrate, contract.** Add the new shape first; backfill in bounded, resumable batches (watch locks and load: dmj:enforcing-performance-budgets); dual-read or dual-write through the window; remove the old shape only in a LATER release, after nothing reads it.
- **Every migration ships its down-path** and the down-path is tested. Genuinely irreversible (a DROP, a lossy cast)? It waits for explicit user confirmation, named as irreversible.
- **Pipeline only.** Migrations run by the deploy process (dmj:shipping-to-production), versioned in the repo. Hand-run SQL on production is an incident, not a workflow.

## Data model floors

| Floor | Rule |
|---|---|
| Lifecycle columns | Every table: id, created_at, updated_at, deleted_at. Soft delete first; hard delete is a policy decision |
| PII | Field-level encrypted with current quantum-safe primitives (dmj:defending-in-depth); never plaintext, never in logs |
| Retention | A written policy per data type at DESIGN time; expiry enforced by code, not memory |
| Deletion rights | Right-to-deletion executable end to end (GDPR, DPDPA): one command finds and purges a subject's data, backups included in the plan |

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "Staging ran the migration fine" | Staging has no locks, no load, no irreplaceable rows. Expand-migrate-contract anyway |
| "The column is unused, just drop it" | Unused is a claim; a reader you missed makes the drop an outage. Contract in a later release |
| "Add retention later" | Later is a compliance letter. Policy at design time |

## Red flags (stop)

- A migration with no tested down-path, or DDL and data-destruction in one step.
- A restore that has never been performed, or performed only at launch.
- SQL typed into a production console.
- A PII column added plaintext, or an unbounded single-transaction backfill.
- A deletion request that requires an engineer to improvise.

**Headless:** drill restores in scratch autonomously; PARK irreversible drops, retention policy numbers, and anything touching live PII beyond the design.

Next: dmj:shipping-to-production runs the migration; dmj:defending-in-depth owns the crypto; dmj:verification-before-completion holds the drill evidence.
