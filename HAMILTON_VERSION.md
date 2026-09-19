# Hamilton Comparator version

Base upstream repository: https://github.com/qinz1yang/differential-geometry
Base upstream revision: `4fbccdfc73f986ce59d7bb66e8bb078f8007ffe2` (September 17, 2026).

This copy starts from the same upstream revision and upgrades to Mathlib `769b0a5ad45c8d886c754c0be19835b908f98dcb`, Lean 4.34.0-rc2, which includes the upstream Levi-Civita construction from PR #36845. The shorter statement and original-proof bridge are being prepared.

Status: work in progress. No Comparator pass is claimed. No heartbeat overrides are permitted.

The updated solution imports the original Hamilton library theorem and transfers
it through `HamiltonBridge.lean`. The challenge remains self-contained over
Mathlib. The solution and concrete bridge have been written and are undergoing
validation; they are not yet certified by Comparator.

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
- Canonical Mathlib dependency cache fetched successfully. The original Hamilton
  proof is now being rebuilt on the upgraded dependencies. Full Hamilton and
  Comparator checks are incomplete.
- `Analysis/Integration/Measure/LevelSetDecay.lean` changes only an import path from
  the removed Mathlib `MeasureSpace` module to its replacement `Basic` module.

See `ComparatorSupport/README.md` for the actual pair configuration and reproducible
Comparator command. `ComparatorSupport/UPGRADE_PORT_STATUS.md` records the earlier
interface-build checkpoint; it is not the final Hamilton-build result.
