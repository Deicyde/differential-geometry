# Mathlib upgrade validation

Updated: 2026-09-19.

The repository uses Mathlib commit `769b0a5ad45c8d886c754c0be19835b908f98dcb` and Lean `v4.34.0-rc2`, based on upstream differential-geometry commit `4fbccdf`.

**The full Hamilton dependency build and Comparator validation are in progress.**
The hosted `Hamilton Comparator` workflow runs the official checker against the
pair, saves build progress after failures, and retains its complete logs. Successful
individual module builds are not a substitute for a full Comparator pass.

The compatibility repairs applied to the original library are:

- The `LevelSetDecay.lean` import now uses `Mathlib.MeasureTheory.Measure.Basic`.
- `CLMNeumann.lean` explicitly imports continuous-linear-map invertibility.
- Completeness proofs use the renamed `γ` argument.
- The zero-distance proof uses the separation field of its chosen metric space,
  avoiding the changed implicit arguments of the global lemma.
- Derivative congruence proofs close the new tangent-space cast equalities by
  reflexivity. All 121 uses of `.mfderiv_eq` in the solution's project dependency
  chain were reviewed for this change.

These repairs preserve mathematical statements and assumptions. The concrete
Levi-Civita, Riemann, sectional-curvature, and Ricci comparison proofs passed a
complete live Lean check and their axiom audits contain only the three standard
axioms. See `concrete-bridge-validation.json` for the exact scope and evidence.

A source-path check found that all 18,202 direct Mathlib/project imports across 3,931 project files resolve. This checks file availability only and does not replace Lean typechecking. Deprecation warnings for `if_neg` and `dif_pos` have appeared; they are not build failures.

To build the original Hamilton proof with bounded compiler concurrency:

```sh
LEAN_NUM_THREADS=2 lake build DifferentialGeometry.Geometry.Flow.RicciFlow.DimensionThree.PositiveRicci.Hamilton
```

The upstream base already includes PR #78 addressing the curvature-jet kernel cost. That proof should be preserved when resolving upgrade errors. All repairs must retain the original mathematical statements and assumptions, without proof holes, custom axioms, heartbeat overrides, or kernel-checking bypasses.
