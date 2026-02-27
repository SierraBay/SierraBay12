# Power Shadow Admin Guide

_Updated: 2026-02-25_

## Goal

This guide is for admins with `R_DEBUG` rights operating Power Shadow in live rounds.
Use it to decide what to change, when to change it, and what to avoid.

## Where to Start

Open `Debug -> Power Shadow Dashboard`.
Power Shadow verbs are now grouped into:
- `Power Shadow` (operational)
- `Power Shadow Advanced` (hidden by default, enable via `Power Shadow -> Toggle Advanced Verbs`)

Read these first:
- `Problem networks`
- `mismatch %`
- `avg |dLoad|` / `avg |dAvail|`
- `avg unserved P/D/T`
- `rollbacks`
- top rows by `Delta`

## Recommended Operating Modes

- Default backend: `Shadow FEA`
- Native mode: `ON` only if batch path shows real gain in benchmark
- Write mode during normal rounds: `FEA Only`

Avoid frequent backend/write-mode switching mid-round unless you are actively repairing an incident.

## What to Use and When

### 1) Dashboard
- Use `Live` mode for active incidents.
- Use `Static` mode for snapshots, postmortem, and reports.
- `Problematic only` is best for triage.

### 2) Benchmark
Use `Benchmark Power Shadow Solver` only:
- before rollout changes,
- after rust-g update,
- after major power code changes.

Interpretation:
- `E2E Native(batch) > E2E DM` means native is worth using.
- `E2E Native(single) < E2E DM` is acceptable; single-call path is fallback only.

### 3) Auto Repair
Use `Auto Repair Powernets` when:
- many networks stay problematic for sustained time,
- you see repeated mismatch/unserved spikes with no fast recovery.

`Retune` first.  
`Retune + Rebuild` only if retune does not stabilize.

### 4) Guard Settings
Adjust only when false positives or too-late rollback are obvious:
- lower trip threshold for faster rollback,
- increase cooldown to reduce thrashing.

If unsure, keep defaults.

## Safe Incident Flow

1. Open dashboard in `Problematic only` + `Live`.
2. Confirm issue is persistent (not one short spike).
3. Run `Auto Repair` with `Retune`.
4. If still unstable, run `Retune + Rebuild`.
5. If native batch underperforms or fails repeatedly, disable native.
6. Export report for follow-up.

## Do Not

- Do not tune thresholds every few minutes without evidence.
- Do not run repetitive benchmark loops during heavy round load.
- Do not keep switching backend and write-mode back and forth.

## Quick Recovery Defaults

If system behavior is unclear, return to:
- backend = `Shadow FEA`
- write mode = `FEA Only`
- native = `OFF` (temporarily, until benchmark confirms gain)
- guard settings = defaults
