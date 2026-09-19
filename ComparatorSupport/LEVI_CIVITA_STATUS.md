# Upgraded Hamilton challenge: Levi-Civita checkpoint

## Initial checkpoint: statement and generic helpers

- `Challenge.lean` (245 lines) imports only Mathlib. It now uses Mathlib's actual `CovariantDerivative.leviCivitaConnection` with the explicitly supplied smooth metric. Full live Lean check completed successfully (`partial=false`); its sole diagnostic is the intended final target `sorry` at line 242.
- `HamiltonDefinitions.lean` (230 lines) contains the identical import and definition block, byte for byte. Its dedicated live Lean check was pending at the initial checkpoint, with no diagnostics or failed dependencies. The same complete block passed within `Challenge.lean`, and the resumed work below subsequently built `HamiltonDefinitions.olean` successfully.
- `ComparatorSupport/LeviCivita.lean` (168 lines) imports only Mathlib and contains proved generic comparison lemmas. Its full live Lean check completed successfully (`partial=false`) with **zero diagnostics**, no failed dependencies, and no proof holes. The file is tracked by the existing `/ComparatorSupport/` whitelist in `.gitignore`.
- Machine-readable evidence and SHA-256 hashes: `validation.json`.

The repository pin is Mathlib `769b0a5ad45c8d886c754c0be19835b908f98dcb`, the Levi-Civita PR merge, on Lean `v4.34.0-rc2`. No heartbeat overrides were introduced.

## What is preserved

The closed-manifold definition, quotient data and all quotient fields, spherical-space-form definition, and complete `HamiltonStatement` quantifiers/hypotheses were copied unchanged from the previous standalone statement. A byte comparison of that whole suffix succeeded. Only the connection construction was replaced, eliminating the custom flat/sharp and Koszul basis machinery.

The statement still quantifies over an explicit smooth metric. The wrapper installs that metric's `RiemannianBundle` locally and obtains its metric regularity from Mathlib's existing instance. There is no new hypothesis assuming that a Levi-Civita connection exists, is smooth, or proves Hamilton's conclusion. No norm/topology instance conflict arose in the complete checks.

## Checked support lemmas

`HamiltonLeviCivitaSupport` contains:

1. `metricConnection_isLeviCivita`: the explicit metric wrapper is Mathlib Levi-Civita.
2. `metricConnection_eq_of_compatible_torsionFree`: any connection satisfying the original raw compatibility equation and zero torsion agrees with the Mathlib connection on differentiable fields.
3. `covariantDerivative_iterate_eq`: this equality transports nested derivatives when the inner derivative for the old connection is differentiable.
4. `tangentConstAt_eventuallyEq_extend` and `eventually_mdiff_tangentConstAt`: the original local extension agrees with Mathlib's extension near the base point and is differentiable on a neighborhood.
5. `riemannValue_eq_of_connection_agreement`: pointwise Riemann formulas agree under connection agreement and the old local differentiability result.

The support module deliberately uses its own namespace and includes its own small metric/curvature wrappers. It does **not** yet instantiate these generic lemmas for the original repository connection, and importing it does not prove the challenge.

A relevant upgrade change was caught and handled: `Trivialization.symm` now uses `Classical.arbitrary` outside its chart, while `symmL` still uses zero. Their global equality is false in general. The proved bridge uses only equality on a neighborhood, which is all curvature needs.

## Concrete bridge implementation awaiting validation

The resumed `HamiltonBridge.lean` candidate instantiates the generic connection lemma with:

- `DifferentialGeometry.Geometry.Connection.leviCivitaConnectionOfMetric`;
- `leviCivitaConnectionOfMetric_isMetricCompatible`;
- `leviCivitaConnectionOfMetric_isTorsionFree`.

These original compatibility and torsion predicates have exactly the raw equations accepted by the checked generic lemma. The compatibility conversion uses `CovariantDerivative.isMetricCompatible_iff`; the torsion conversion is function extensionality.

For the iterated derivative hypothesis, the candidate uses the original:

- `DifferentialGeometry.Geometry.Curvature.CovariantDerivative.cov_tangentConst_apply_mdiffAt_self`;
- `DifferentialGeometry.Geometry.Connection.leviCivitaConnectionOfMetric_contMDiffCovariantDerivativeLocally`.

The candidate transfers the Riemann and Ricci values and their positivity/constant-curvature predicates, adapting the previous `HamiltonBridge.lean` proof. Its local regularity comes from the old proved smooth connection; it does not assume a new Mathlib LC smoothness result. These concrete instantiations still require validation after the original interfaces finish building.

The upgraded original-library build is incomplete. See `UPGRADE_PORT_STATUS.md` for the current build state. The resumed request authorizes a solution importing the original Hamilton theorem. The saved bridge and solution contain no proof holes, but their full check and the Comparator verdict remain pending.


## Resumed solution work

The user has requested a passing upgraded Solution. `HamiltonBridge.lean` now has a complete proof candidate for the original connection and curvature comparison, including a two-way equivalence of the full statements. `Solution.lean` (19 lines) imports the original Hamilton theorem and applies that bridge. Neither file contains a proof hole; they are **not yet claimed checked** because the upgraded original interfaces and Hamilton dependency graph are still compiling in the single port build.

`ComparatorSupport/DefinitionAgreement.lean` passed a complete live Lean check with zero diagnostics. It proves by reflexivity that the challenge's connection, tangent extension, and Riemann formula coincide with the generic support definitions. The LSP setup also successfully built `HamiltonDefinitions.olean` and `ComparatorSupport/LeviCivita.olean`.

No challenge statement, hypothesis, or shared definition was changed in this resumed work. The final Comparator verdict remains pending. See the refreshed `validation.json` for per-file evidence.
