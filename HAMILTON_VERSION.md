# Hamilton Comparator version

Base upstream repository: https://github.com/qinz1yang/differential-geometry
Base upstream revision: `4fbccdfc73f986ce59d7bb66e8bb078f8007ffe2` (September 17, 2026).

This copy starts from the same upstream revision and upgrades to Mathlib `769b0a5ad45c8d886c754c0be19835b908f98dcb`, Lean 4.34.0-rc2, which includes the upstream Levi-Civita construction from PR #36845. The shorter statement uses this connection, and the solution transfers the original Hamilton theorem through a comparison of the geometric definitions.

**Status: official Comparator pass verified.**

[CI run 35475666721](https://github.com/Deicyde/differential-geometry/actions/runs/35475666721)
checked commit `c282651d95a6c07d7c531c68e6835e9f2128a4b1` and completed
on September 20, 2026 at 00:02:59 UTC. Comparator exited with code zero and
reported both solution acceptance and acceptance by Lean's default kernel.
All 3,944 recorded Lean source/configuration inputs remained unchanged during
the run and matched the local files when the result was verified. Compilation
and kernel verification cover the Hamilton challenge/solution pair and its
imported proof dependencies. No heartbeat overrides were introduced.

See the [verified pass summary](ComparatorSupport/comparator-pass.json) and its
linked metadata, full log, and source-hash verification.

The updated solution imports the original Hamilton library theorem and transfers
it through `HamiltonBridge.lean`. The challenge remains self-contained over
Mathlib. The complete bridge has passed its normal build, live Lean check, and axiom
audits. The final solution passed Comparator's statement comparison, transitive
axiom audit, and kernel replay with only `propext`, `Quot.sound`, and
`Classical.choice` permitted and no definition exemptions.

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
- `Solution.lean`: the original Hamilton proof and its dependency closure built on
  the upgraded dependencies, and the complete pair passed official Comparator.
- Compatibility repairs adapt imports and proofs to the new Mathlib APIs while
  preserving the original mathematical statements and assumptions. Their details
  are recorded in `ComparatorSupport/UPGRADE_PORT_STATUS.md`.

See `ComparatorSupport/README.md` for the actual pair configuration and reproducible
Comparator command. The final result and its exact tested inputs are recorded in
`ComparatorSupport/comparator-pass.json`.
