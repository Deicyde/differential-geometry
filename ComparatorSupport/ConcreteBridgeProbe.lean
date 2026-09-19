import HamiltonDefinitions
import ComparatorSupport.LeviCivita
import DifferentialGeometry.Geometry.Connection.LeviCivita.Torsion
import DifferentialGeometry.Geometry.Connection.LeviCivita.Smooth.Connection
import DifferentialGeometry.Geometry.Curvature.Components.Basic

set_option autoImplicit false

namespace HamiltonConnectionProbe

open HamiltonPointwise
open DifferentialGeometry.Geometry.Connection
open DifferentialGeometry.Geometry.Curvature
open DifferentialGeometry.Tensor0SBundle
open scoped Manifold ContDiff

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [FiniteDimensional ℝ E] [CompleteSpace E]
variable {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]

theorem metricConnection_eq_original (g : HamiltonPointwise.SmoothRiemannianMetric I M)
    (Y : (p : M) → TangentSpace I p) (x : M)
    (hY : MDiffAt (T% Y) x) (v : TangentSpace I x) :
    metricConnection g Y x v = leviCivitaConnectionOfMetric (I := I) g Y x v := by
  exact HamiltonLeviCivitaSupport.metricConnection_eq_of_compatible_torsionFree
    g (leviCivitaConnectionOfMetric (I := I) g)
    (leviCivitaConnectionOfMetric_isMetricCompatible (I := I) g)
    (leviCivitaConnectionOfMetric_isTorsionFree (I := I) g) hY v

theorem riemannValue_eq_original (g : HamiltonPointwise.SmoothRiemannianMetric I M) (x : M)
    (X Y Z : TangentSpace I x) :
    riemannValue g x X Y Z =
      CovariantDerivative.riemannCurvatureAux (leviCivitaConnectionOfMetric (I := I) g)
        (CovariantDerivative.tangentConstAt (I := I) x X)
        (CovariantDerivative.tangentConstAt (I := I) x Y)
        (CovariantDerivative.tangentConstAt (I := I) x Z) x := by
  exact HamiltonLeviCivitaSupport.riemannValue_eq_of_connection_agreement
    g (leviCivitaConnectionOfMetric (I := I) g)
    (fun Y x hY v => metricConnection_eq_original g Y x hY v)
    (CovariantDerivative.cov_tangentConst_apply_mdiffAt_self
      (leviCivitaConnectionOfMetric (I := I) g)
      (leviCivitaConnectionOfMetric_contMDiffCovariantDerivativeLocally (I := I) g)) x X Y Z

theorem sectionalValue_eq (g : HamiltonPointwise.SmoothRiemannianMetric I M) (x : M)
    (X Y Z W : TangentSpace I x) :
    CovariantDerivative.riemannCurvature04At g
      (leviCivitaConnectionOfMetric (I := I) g)
      (leviCivitaConnectionOfMetric_contMDiffCovariantDerivativeLocally (I := I) g)
      x (vec4 X Y Z W) = g.inner x W (riemannValue g x X Y Z) := by
  rw [riemannValue_eq_original]
  exact CovariantDerivative.riemannCurvature04At_apply_const
    g (leviCivitaConnectionOfMetric (I := I) g)
    (leviCivitaConnectionOfMetric_contMDiffCovariantDerivativeLocally (I := I) g) X Y Z W

theorem ricciValue_eq (g : HamiltonPointwise.SmoothRiemannianMetric I M) (x : M)
    (Y Z : TangentSpace I x) :
    CovariantDerivative.ricciCurvatureAt
      (leviCivitaConnectionOfMetric (I := I) g)
      (leviCivitaConnectionOfMetric_contMDiffCovariantDerivativeLocally (I := I) g)
      x (vec2 Y Z) = ricciValue g x Y Z := by
  unfold CovariantDerivative.ricciCurvatureAt
  rw [ricciFromRm13At_apply_basis_trace (Module.finBasis ℝ (TangentSpace I x))]
  unfold ricciValue
  apply Finset.sum_congr rfl
  intro i _
  rw [CovariantDerivative.riemannCurvatureAt_apply_const,
    cotangentToDual_dualToCotangent_gen, riemannValue_eq_original]

end HamiltonConnectionProbe
