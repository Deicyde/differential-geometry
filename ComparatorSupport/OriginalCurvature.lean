import HamiltonDefinitions
import ComparatorSupport.LeviCivita
import DifferentialGeometry.Geometry.Curvature.Riemann.Basic.Field

set_option autoImplicit false

namespace HamiltonPointwise

noncomputable section

open DifferentialGeometry.Geometry.Curvature
open scoped Manifold ContDiff

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [FiniteDimensional ℝ E]
variable {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]

/-- Agreement on differentiable fields with a smooth original connection identifies
the Mathlib-based curvature with the original pointwise curvature formula. -/
theorem riemannValue_eq_connection
    (g : SmoothRiemannianMetric I M)
    (cov : _root_.CovariantDerivative I E (TangentSpace I : M → Type _))
    (heq : ∀ (Y : (p : M) → TangentSpace I p) (x : M),
      MDiffAt (T% Y) x → ∀ v, metricConnection g Y x v = cov Y x v)
    (hcov : CovariantDerivative.ContMDiffCovariantDerivativeLocally cov ∞)
    (x : M) (X Y Z : TangentSpace I x) :
    riemannValue g x X Y Z =
      CovariantDerivative.riemannCurvatureAux cov
        (CovariantDerivative.tangentConstAt (I := I) x X)
        (CovariantDerivative.tangentConstAt (I := I) x Y)
        (CovariantDerivative.tangentConstAt (I := I) x Z) x := by
  exact HamiltonLeviCivitaSupport.riemannValue_eq_of_connection_agreement
    g cov heq (CovariantDerivative.cov_tangentConst_apply_mdiffAt_self cov hcov) x X Y Z

end

end HamiltonPointwise
