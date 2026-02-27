# Power FEA Migration Status

_Updated: 2026-02-23 (handoff refresh)_

## Executive state

- **Operational mode now:** FEA-only path is enforced for shadow-controlled powernets (rollback to legacy write mode is blocked by lock).
- **Shadow/ops tooling:** dashboard + live refresh + delta visualization + auto-repair are in place and usable.
- **Quality gates:** guard, acceptance, telemetry, export/report, and backend A/B controls are active.
- **Build health:** latest DreamMaker build is green (`0 errors, 0 warnings`).

## Current coverage (estimated)

- **Overall migration readiness:** **~91-93%**
- **Shadow analysis + observability:** **~95%**
- **Write/control path operations:** **~90%** (includes FEA-only lock + guard + fallback + repair controls)
- **Physical FEA fidelity:** **~30-35%** (still approximation, not full nodal/resistance electrical solve)

## Implemented in this branch (actual)

### 1) Legacy power stabilization
- Fixed known legacy issues that were destabilizing power behavior (APC ENVIRON behavior, sensor divide-by-zero path, cable accumulation handling, terminal direction checks, SMES demand double counting).

### 2) Shadow solver architecture
- Two backends are available and runtime-switchable:
  - `shadow_fea`
  - `strict_capacity_flow`
- Per-powernet shadow telemetry includes:
  - current load/avail deltas,
  - unserved power,
  - mismatch status and thresholds,
  - rolling statistics and acceptance evaluation inputs.

### 3) Write-path and safety model
- Write modes implemented:
  - `legacy`
  - `pilot_smes_input`
  - `pilot_apc_advisory`
  - `pilot_apc_enforced`
  - `fea_only`
- Guard behavior implemented:
  - mismatch streak trip threshold,
  - cooldown window,
  - rollback/fallback behavior,
  - threshold override independent from global mismatch threshold.
- FEA-only lock behavior implemented:
  - powernets marked as force-locked cannot be switched back to legacy mode via debug flow.

### 4) Observability and operator UX
- Added admin-facing tools:
  - `Power Shadow Dashboard` (static/live refresh, sorting, top-N, problem-only filter)
  - `Visualize Powernets (Shadow Delta)` overlay
  - `Auto Repair Powernets` action flow
  - report export, threshold/mode/backend/guard controls
- Dashboard stability fixes completed:
  - fixed runtime `type mismatch` by explicit numeric coercion in row sorting/rendering paths.
- Admin verb discoverability fix completed:
  - new `power_shadow_*` verbs are registered in debug verb list and should be visible for admins with `R_DEBUG` after admin verbs refresh/relogin.

### 5) Auto-repair core refactor
- Auto-repair logic moved out of UI proc into testable subsystem procs:
  - `power_shadow_collect_anomalies(...)`
  - `power_shadow_apply_auto_repair(...)`
- Behavior now supports:
  - retune,
  - backend fallback,
  - optional rebuild branch.

### 6) Test coverage added
- Unit tests added for:
  - FEA lock enforcement,
  - cache reuse behavior,
  - acceptance thresholds/reasons,
  - guard rollback logic,
  - SMES shadow input calculations,
  - auto-repair collect/apply flows.

## Key files for continuation

- `code/modules/admin/verbs/debug.dm`
  - dashboard/live loop/render,
  - visualization,
  - auto-repair admin action,
  - runtime type-coercion fixes.
- `code/modules/admin/admin_verbs.dm`
  - debug verb registry updated to include new `power_shadow_*` procs.
- `code/controllers/subsystems/machines.dm`
  - extracted subsystem-level auto-repair/collect procs.
- `code/unit_tests/power_tests.dm`
  - power shadow and auto-repair unit tests.

## Known limits / still missing for “true FEA”

- No full nodal voltage/current solver yet.
- No proper per-edge physical model (resistance/impedance/loss) feeding a field-equation solve.
- Rebuild-path testing is not yet fully represented by integration-style long-run scenarios.
- Acceptance under prolonged stress rounds still needs broader automated coverage.

## Recommended next steps (priority)

1. Add integration test for `power_shadow_apply_auto_repair(..., do_rebuild = TRUE)` against realistic `SSmachines.powernets` state.
2. Extend dashboard with concise auto-fix action trace (what got retuned/fallback-switched) for auditability.
3. Start physical-model scaffolding (edge resistance placeholders + solver input normalization) as first concrete step toward actual FEA.

## Quick operator notes

- If new debug verbs are not visible:
  - verify admin has `R_DEBUG`,
  - refresh admin verbs / relog to reload verb table.
- For dashboard live mode issues:
  - use `Stop Power Shadow Live` to terminate refresh loop before reopening with new interval.
- Current expected baseline for stability:
  - dashboard opens without runtime errors,
  - sorting by Delta works,
  - build remains clean.
