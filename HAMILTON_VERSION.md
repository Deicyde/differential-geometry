# Hamilton Comparator version

Base upstream repository: https://github.com/qinz1yang/differential-geometry
Base upstream revision: `4fbccdfc73f986ce59d7bb66e8bb078f8007ffe2` (September 17, 2026).

This copy starts from the same upstream revision and upgrades to Mathlib `769b0a5ad45c8d886c754c0be19835b908f98dcb`, Lean 4.34.0-rc2, which includes the upstream Levi-Civita construction from PR #36845. The shorter statement uses this connection, and the solution transfers the original Hamilton theorem through a comparison of the geometric definitions.

Status: work in progress. No Comparator pass is claimed. No heartbeat overrides are permitted.

The updated solution imports the original Hamilton library theorem and transfers
it through `HamiltonBridge.lean`. The challenge remains self-contained over
Mathlib. The complete bridge has passed its normal build, live Lean check, and axiom
audits. The solution is undergoing end-to-end validation and is not yet certified
by Comparator.

## Verified work

- `Challenge.lean`: 245-line self-contained statement importing the upstream Mathlib
  Levi-Civita implementation; live Lean validation completed with only the intended
  Hamilton target `sorry` warning.
- `HamiltonDefinitions.lean`: the shared definition block used by the solution.
  An official Comparator-based preflight matched all 37,653 constants reachable
  from the statement, without definition exemptions.
- `ComparatorSupport/LeviCivita.lean`: the explicit-metric Levi-Civita wrapper and
  generic uniqueness/curvature transport proofs passed full live Lean validation
  with zero diagnostics and no proof holes. See
  `ComparatorSupport/LEVI_CIVITA_STATUS.md` for the precise validation scope.
- The complete `HamiltonBridge.lean` passed its normal build and full live Lean
  validation with zero diagnostics. Its two statement-transfer theorems use only
  the three standard axioms and prove equivalence to the original statement in
  both directions. See `ComparatorSupport/full-bridge-validation.json`.
  The imported Hamilton proof and final Solution check remain under validation.
- Canonical Mathlib dependency cache fetched successfully. The original Hamilton
  proof is now being rebuilt on the upgraded dependencies. Full Hamilton and
  Comparator checks are incomplete.
- `Analysis/Integration/Measure/LevelSetDecay.lean` changes only an import path from
  the removed Mathlib `MeasureSpace` module to its replacement `Basic` module.
- The first hosted Comparator attempt exposed further Mathlib compatibility
  changes. The repairs add an explicit invertibility import, close derivative-cast
  equalities by reflexivity, and update a completeness lemma's named argument.
  They preserve the original theorem statements. That attempt was cancelled after
  compilation errors; its partial build cache is retained for the next run.

See `ComparatorSupport/README.md` for the actual pair configuration and reproducible
Comparator command. `ComparatorSupport/UPGRADE_PORT_STATUS.md` records the
compatibility repairs; it is not the final Hamilton-build result.
