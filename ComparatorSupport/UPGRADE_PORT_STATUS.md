# Mathlib upgrade validation

Updated: 2026-09-19 17:17 UTC.

The repository uses Mathlib commit `769b0a5ad45c8d886c754c0be19835b908f98dcb` and Lean `v4.34.0-rc2`, based on upstream differential-geometry commit `4fbccdf`.

**The full Hamilton dependency build and Comparator validation are pending.** The current dependency build has completed 23 additional project modules without errors. An earlier interface build completed 27 modules; neither partial build establishes a successful port. Latest completed module: `DifferentialGeometry.Tensor.RSTensor.Components (41s)`.

The compatibility change currently applied to the existing library is the `LevelSetDecay.lean` import from `Mathlib.MeasureTheory.Measure.MeasureSpace` to `Mathlib.MeasureTheory.Measure.Basic`. No mathematical statements or assumptions have been changed for the upgrade.

A source-path check found that all 18,202 direct Mathlib/project imports across 3,931 project files resolve. This checks file availability only and does not replace Lean typechecking. Deprecation warnings for `if_neg` and `dif_pos` have appeared; they are not build failures.

To build the original Hamilton proof with bounded compiler concurrency:

```sh
LEAN_NUM_THREADS=2 lake build DifferentialGeometry.Geometry.Flow.RicciFlow.DimensionThree.PositiveRicci.Hamilton
```

The upstream base already includes PR #78 addressing the curvature-jet kernel cost. That proof should be preserved when resolving upgrade errors. All repairs must retain the original mathematical statements and assumptions, without proof holes, custom axioms, heartbeat overrides, or kernel-checking bypasses.
