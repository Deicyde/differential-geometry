# Mathlib upgrade status

Snapshot: 2026-09-19 17:02 UTC.

- Upstream base: `4fbccdfc73f986ce59d7bb66e8bb078f8007ffe2`.
- Mathlib: `769b0a5ad45c8d886c754c0be19835b908f98dcb`.
- Lean: `leanprover/lean4:v4.34.0-rc2`.

## Validation recorded so far

A targeted build of the following interfaces compiled 27 project modules with no
recorded errors before this snapshot:

- `DifferentialGeometry.Geometry.Curvature.MetricConditions`
- `DifferentialGeometry.Geometry.Metric.Sphere.SpaceForm`

These targets reach 481 project modules. Their build is **incomplete**. The last
recorded success is `DifferentialGeometry.Tensor.RSTensor.CoordinateBasis`.
The previous build process is no longer present, and no final exit status was
available. This is not a successful port or full-build result.

The only existing library source change is an import in
`Analysis/Integration/Measure/LevelSetDecay.lean`, replacing Mathlib's removed
`MeasureSpace` module with `Basic`.

Challenge and generic connection-bridge validation are documented separately in
`LEVI_CIVITA_STATUS.md` and `validation.json`. The final Hamilton bridge, Solution,
and Comparator pass are still outstanding.

## Resume the port

From the repository root, after checking that no equivalent build is running:

```sh
env LEAN_NUM_THREADS=2 lake build DifferentialGeometry.Geometry.Curvature.MetricConditions DifferentialGeometry.Geometry.Metric.Sphere.SpaceForm
```

Diagnose actual upgrade errors with the Lean language server and narrow source
edits. Preserve theorem statements and mathematical assumptions. Do not add proof
holes, custom axioms, heartbeat overrides, or unchecked declarations to proofs.

Once the original connection, Riemann, metric-condition, and space-form interfaces
are available, instantiate the generic lemmas in `LeviCivita.lean` as described in
`LEVI_CIVITA_STATUS.md`. Then complete the Hamilton solution and run Comparator.
The prepared configuration is `comparator.draft.json`; it is not runnable until
`Solution.lean` exists and the pair is complete.
