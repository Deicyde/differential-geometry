# Hamilton Comparator version

Base upstream repository: https://github.com/qinz1yang/differential-geometry
Base upstream revision: `4fbccdfc73f986ce59d7bb66e8bb078f8007ffe2` (September 17, 2026).

This copy starts from the same upstream revision and upgrades to Mathlib `769b0a5ad45c8d886c754c0be19835b908f98dcb`, Lean 4.34.0-rc2, which includes the upstream Levi-Civita construction from PR #36845. The shorter statement and original-proof bridge are being prepared.

Status: work in progress. No Comparator pass is claimed. No heartbeat overrides are permitted.

The final solution import scope is awaiting clarification: the latest request says a
Mathlib-only challenge/solution pair, while the earlier solution imported the original
Hamilton library theorem. A solution restricted to Mathlib imports must inline its
actual proof dependencies; a short import-based solution has a different dependency
contract. No placeholder is being presented as a completed solution.

## Verified work

- `Challenge.lean`: 245-line self-contained statement importing the upstream Mathlib
  Levi-Civita implementation; live Lean validation completed with only the intended
  Hamilton target `sorry` warning.
- `HamiltonDefinitions.lean`: matching shared definition block for a possible
  import-based solution.
- `ComparatorSupport/LeviCivita.lean`: the explicit-metric Levi-Civita wrapper and
  generic uniqueness/curvature transport proofs passed full live Lean validation
  with zero diagnostics and no proof holes. See
  `ComparatorSupport/LEVI_CIVITA_STATUS.md` for the concrete bridge still required.
- Canonical Mathlib dependency cache fetched successfully. A targeted two-interface build
  compiled 27 project modules without recorded errors before stopping; the final
  build result is unavailable. Full Hamilton and Comparator checks are incomplete.
- `Analysis/Integration/Measure/LevelSetDecay.lean` changes only an import path from
  the removed Mathlib `MeasureSpace` module to its replacement `Basic` module.

See `ComparatorSupport/UPGRADE_PORT_STATUS.md` for the recorded interface build
state. `ComparatorSupport/comparator.draft.json` is a prepared configuration, not
a runnable pair: `Solution.lean` and the concrete original-proof bridge are not
yet delivered. Missing solution/bridge modules are not registered as Lake targets.
