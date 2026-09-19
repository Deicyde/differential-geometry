import HamiltonDefinitions
import ComparatorSupport.LeviCivita

set_option autoImplicit false

open scoped Manifold ContDiff

namespace HamiltonPointwise

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [FiniteDimensional ℝ E]
variable {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]

theorem metricConnection_eq_support (g : SmoothRiemannianMetric I M) :
    metricConnection g = HamiltonLeviCivitaSupport.metricConnection g := rfl

omit [FiniteDimensional ℝ E] in
theorem tangentConstAt_eq_support (x : M) (v : TangentSpace I x) :
    tangentConstAt x v = HamiltonLeviCivitaSupport.tangentConstAt x v := rfl

theorem riemannValue_eq_support (g : SmoothRiemannianMetric I M) (x : M)
    (X Y Z : TangentSpace I x) :
    riemannValue g x X Y Z = HamiltonLeviCivitaSupport.riemannValue g x X Y Z := rfl

end HamiltonPointwise
