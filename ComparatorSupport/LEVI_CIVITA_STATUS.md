# Hamilton bridge validation

## Current result

The complete `HamiltonBridge.lean` passes both the normal Lean build and a full live Lean check. The normal build exited successfully with no errors; the live check returned `partial=false`, `success=true`, no diagnostics, and no failed dependencies. No bridge source changes were required.

Both full-statement transfer theorems, `HamiltonPointwise.hamiltonStatement_of_original` and `HamiltonPointwise.hamiltonStatement_iff_original`, depend on exactly `propext`, `Classical.choice`, and `Quot.sound`. The second theorem proves equivalence in both directions between the shortened statement and the original statement, including its complete quantifiers and hypotheses.

**`Solution.lean` and the final Comparator pass remain pending.** The solution imports the original Hamilton theorem, whose upgraded dependency build is separate from the now completed bridge validation. No final solution or Comparator success is claimed here.

Exact source and compiled-artifact hashes, build and live-check results, and the full axiom output are saved in `full-bridge-validation.json`. The normal build log is `.lake/upgrade-bridge-build-8.log`.

## Statement and metric construction

The repository uses Mathlib `769b0a5ad45c8d886c754c0be19835b908f98dcb`, the Levi-Civita PR merge, with Lean `v4.34.0-rc2`.

`Challenge.lean` has 245 lines and imports only Mathlib. Its complete live Lean check passed, with only the intended final target `sorry`. `HamiltonDefinitions.lean` contains the identical imports and definitions, byte for byte, and has built successfully. The solution and bridge contain no proof holes or added axioms, and no heartbeat overrides were introduced.

The statement quantifies over an explicit smooth metric. Its connection wrapper locally installs that metric's `RiemannianBundle` and uses Mathlib's actual `CovariantDerivative.leviCivitaConnection`. Metric regularity comes from the existing smooth-metric instance. The theorem does not assume additional existence, smoothness, or curvature facts about this connection.

The closed-manifold definition, all quotient fields, spherical-space-form definition, and complete main-statement quantifiers and hypotheses were preserved. The checked bridge proves agreement of the metric connections on differentiable fields, the pointwise Riemann and Ricci values, both curvature predicates, the quotient representations, and the full theorem statements.

## Local regularity and typeclasses

Mathlib's Levi-Civita connection is compared with the original connection only on differentiable fields. The original proved smoothness result supplies the regularity needed to transport nested derivatives. No equality on arbitrary nondifferentiable fields is asserted.

An upgrade detail matters here: `Trivialization.symm` now uses `Classical.arbitrary` outside its chart, while `symmL` uses zero. The tangent extensions are therefore compared only on a neighborhood of the base point. This is sufficient for curvature, and the complete bridge checks validate that local argument.

`ComparatorSupport/DefinitionAgreement.lean` proves by reflexivity that the challenge's connection, tangent extension, and Riemann formula are the generic helper definitions. Its full live Lean check passed with zero diagnostics. No additional norm/topology instance conflict occurred in the full checks.

## Supporting evidence

- `LeviCivita.lean`: checked Mathlib-only uniqueness, local extension, and curvature transport helpers.
- `DefinitionAgreement.lean`: checked definition agreement with the challenge.
- `ConcreteBridgeProbe.lean` and `concrete-bridge-validation.json`: concrete original connection and curvature checks, successful live Lean result, and four standard-three-axiom audits.
- `curvature-predicates-validation.json`: exact curvature section copied from the bridge, including actual metric aliases and both curvature predicate equivalences; all six theorem axiom audits passed.
- `quotient-bridge-validation.json`: exact quotient-data conversions checked in both directions.
- `full-bridge-validation.json`: authoritative complete bridge build, live-check, and full-statement axiom results.

The standalone probes are outside the `Solution.lean` import closure. They were checked using source-matched same-version compiled interfaces while the coordinated build progressed. The final full bridge result above uses the complete local build.
