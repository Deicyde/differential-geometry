/-
Mathlib-only verified support for the upgraded Hamilton challenge.
These are generic geometric comparison lemmas, not a proof of Hamilton's theorem.
The concrete bridge to the original repository curvature is still required.
-/
import Mathlib.Geometry.Manifold.VectorBundle.CovariantDerivative.LeviCivita

set_option autoImplicit false

noncomputable section

namespace HamiltonLeviCivitaSupport

open Bundle
open scoped Manifold ContDiff Topology BigOperators

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
variable {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]

abbrev SmoothRiemannianMetric :=
  Bundle.ContMDiffRiemannianMetric I ∞ E (TangentSpace I : M → Type _)

variable [FiniteDimensional ℝ E]

/-- Mathlib's Levi-Civita connection for an explicit smooth metric. -/
def metricConnection (g : SmoothRiemannianMetric (I := I) (M := M)) :
    CovariantDerivative I E (TangentSpace I : M → Type _) := by
  let : RiemannianBundle (TangentSpace I : M → Type _) := ⟨g.toRiemannianMetric⟩
  exact CovariantDerivative.leviCivitaConnection I M

theorem metricConnection_isLeviCivita
    (g : SmoothRiemannianMetric (I := I) (M := M)) :
    letI : RiemannianBundle (TangentSpace I : M → Type _) := ⟨g.toRiemannianMetric⟩
    (metricConnection g).IsLeviCivitaConnection := by
  let : RiemannianBundle (TangentSpace I : M → Type _) := ⟨g.toRiemannianMetric⟩
  exact CovariantDerivative.isLeviCivitaConnection_leviCivitaConnection I

/-- Compatibility and torsion-freeness identify a previously constructed connection
with Mathlib's connection on differentiable sections. -/
theorem metricConnection_eq_of_compatible_torsionFree
    (g : SmoothRiemannianMetric (I := I) (M := M))
    (cov : CovariantDerivative I E (TangentSpace I : M → Type _))
    (hmetric : ∀ (x : M) (X Y Z : (p : M) → TangentSpace I p),
      MDiffAt (T% X) x → MDiffAt (T% Y) x → MDiffAt (T% Z) x →
      mvfderiv I (fun p => g.inner p (Y p) (Z p)) x (X x) =
        g.inner x (cov Y x (X x)) (Z x) + g.inner x (Y x) (cov Z x (X x)))
    (htorsion : ∀ x : M, cov.torsion x = 0)
    {Y : (p : M) → TangentSpace I p} {x : M}
    (hY : MDiffAt (T% Y) x) (v : TangentSpace I x) :
    metricConnection g Y x v = cov Y x v := by
  let : RiemannianBundle (TangentSpace I : M → Type _) := ⟨g.toRiemannianMetric⟩
  have hcov : cov.IsLeviCivitaConnection := by
    constructor
    · rw [CovariantDerivative.isMetricCompatible_iff]
      intro x X Y Z hX hY hZ
      exact hmetric x X Y Z hX hY hZ
    · exact funext htorsion
  exact (metricConnection_isLeviCivita g).uniqueness I hcov hY v

omit [FiniteDimensional ℝ E] in
/-- Equality of connections on differentiable fields also transports their iterates
when the original inner derivative is differentiable. -/
theorem covariantDerivative_iterate_eq
    (cov₁ cov₂ : CovariantDerivative I E (TangentSpace I : M → Type _))
    (heq : ∀ (Y : (p : M) → TangentSpace I p) (x : M),
      MDiffAt (T% Y) x → ∀ v, cov₁ Y x v = cov₂ Y x v)
    (Y Z : (p : M) → TangentSpace I p) (x : M)
    (hZ : ∀ᶠ p in 𝓝 x, MDiffAt (T% Z) p)
    (hinner : MDiffAt (T% (fun p => cov₂ Z p (Y p))) x)
    (v : TangentSpace I x) :
    cov₁ (fun p => cov₁ Z p (Y p)) x v =
      cov₂ (fun p => cov₂ Z p (Y p)) x v := by
  have hsec : (fun p => cov₁ Z p (Y p)) =ᶠ[𝓝 x] (fun p => cov₂ Z p (Y p)) := by
    filter_upwards [hZ] with p hp
    exact heq Z p hp (Y p)
  have htotal : (T% (fun p => cov₁ Z p (Y p))) =ᶠ[𝓝 x]
      (T% (fun p => cov₂ Z p (Y p))) := by
    filter_upwards [hsec] with p hp
    exact congrArg (TotalSpace.mk p) hp
  have hinner₁ := hinner.congr_of_eventuallyEq htotal
  have houter := cov₁.isCovariantDerivativeOn.congr_of_eventuallyEq
    hinner₁ hinner Filter.univ_mem hsec
  exact (congrArg (fun L => L v) houter).trans
    (heq (fun p => cov₂ Z p (Y p)) x hinner v)

/-- Local extension with the same formula as the original Hamilton development. -/
def tangentConstAt (x : M) (v : TangentSpace I x) (p : M) : TangentSpace I p :=
  (trivializationAt E (TangentSpace I) x).symmL ℝ p
    ((trivializationAt E (TangentSpace I) x).continuousLinearMapAt ℝ x v)

omit [FiniteDimensional ℝ E] in
theorem tangentConstAt_eventuallyEq_extend (x : M) (v : TangentSpace I x) :
    ∀ᶠ p in 𝓝 x, tangentConstAt x v p = FiberBundle.extend E v p := by
  let t := trivializationAt E (TangentSpace I) x
  have hx : x ∈ t.baseSet := FiberBundle.mem_baseSet_trivializationAt' x
  filter_upwards [t.open_baseSet.mem_nhds hx] with p hp
  change t.symmL ℝ p (t.continuousLinearMapAt ℝ x v) = t.symm p (t ⟨x, v⟩).2
  rw [Trivialization.continuousLinearMapAt_apply_of_mem ℝ t hx]
  exact t.symmL_apply hp _

omit [FiniteDimensional ℝ E] in
theorem eventually_mdiff_tangentConstAt (x : M) (v : TangentSpace I x) :
    ∀ᶠ p in 𝓝 x, MDiffAt (T% (tangentConstAt x v)) p := by
  have htotal : (T% (tangentConstAt x v)) =ᶠ[𝓝 x] (T% (FiberBundle.extend E v)) := by
    filter_upwards [tangentConstAt_eventuallyEq_extend x v] with p hp
    exact congrArg (TotalSpace.mk p) hp
  obtain ⟨s, hs, hsZ⟩ := FiberBundle.exists_mdifferentiableOn_extend I E v
  obtain ⟨u, hus, hu, hxu⟩ := mem_nhds_iff.mp hs
  filter_upwards [hu.mem_nhds hxu, htotal.eventuallyEq_nhds] with p hp heq
  exact ((hsZ p (hus hp)).mdifferentiableAt
    (Filter.mem_of_superset (hu.mem_nhds hp) hus)).congr_of_eventuallyEq heq

/-- Pointwise Riemann curvature from Mathlib's Levi-Civita connection. -/
def riemannValue (g : SmoothRiemannianMetric (I := I) (M := M)) (x : M)
    (X Y Z : TangentSpace I x) : TangentSpace I x :=
  let cov := metricConnection g
  let X' := tangentConstAt x X
  let Y' := tangentConstAt x Y
  let Z' := tangentConstAt x Z
  cov (fun p => cov Z' p (Y' p)) x (X' x) -
    cov (fun p => cov Z' p (X' p)) x (Y' x) -
      cov Z' x (VectorField.mlieBracket I X' Y' x)

theorem riemannValue_eq_of_connection_agreement
    (g : SmoothRiemannianMetric (I := I) (M := M))
    (cov : CovariantDerivative I E (TangentSpace I : M → Type _))
    (heq : ∀ (Y : (p : M) → TangentSpace I p) (x : M),
      MDiffAt (T% Y) x → ∀ v, metricConnection g Y x v = cov Y x v)
    (hsmooth : ∀ (x : M) (v w : TangentSpace I x),
      MDiffAt (T% (fun p => cov (tangentConstAt x v) p (tangentConstAt x w p))) x)
    (x : M) (X Y Z : TangentSpace I x) :
    riemannValue g x X Y Z =
      cov (fun p => cov (tangentConstAt x Z) p (tangentConstAt x Y p)) x
          (tangentConstAt x X x) -
        cov (fun p => cov (tangentConstAt x Z) p (tangentConstAt x X p)) x
          (tangentConstAt x Y x) -
        cov (tangentConstAt x Z) x
          (VectorField.mlieBracket I (tangentConstAt x X) (tangentConstAt x Y) x) := by
  have hZx : MDiffAt (T% (tangentConstAt x Z)) x :=
    (eventually_mdiff_tangentConstAt x Z).self_of_nhds
  exact congrArg₂ (fun a b => a - b)
    (congrArg₂ (fun a b => a - b)
      (covariantDerivative_iterate_eq (metricConnection g) cov heq _ _ x
        (eventually_mdiff_tangentConstAt x Z) (hsmooth x Z Y) _)
      (covariantDerivative_iterate_eq (metricConnection g) cov heq _ _ x
        (eventually_mdiff_tangentConstAt x Z) (hsmooth x Z X) _))
    (heq _ x hZx _)

local instance tangentSpace_finiteDimensional (x : M) :
    FiniteDimensional ℝ (TangentSpace I x) :=
  inferInstanceAs (FiniteDimensional ℝ E)

def ricciValue (g : SmoothRiemannianMetric (I := I) (M := M)) (x : M)
    (Y Z : TangentSpace I x) : ℝ :=
  let b := Module.finBasis ℝ (TangentSpace I x)
  ∑ i, b.coord i (riemannValue g x (b i) Y Z)

def positiveRicciMetric (g : SmoothRiemannianMetric (I := I) (M := M)) : Prop :=
  ∀ x : M, ∀ v : TangentSpace I x, v ≠ 0 → 0 < ricciValue g x v v

def constantPositiveSectionalCurvatureMetric
    (g : SmoothRiemannianMetric (I := I) (M := M)) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ x : M, ∀ X Y : TangentSpace I x,
    g.inner x X (riemannValue g x X Y Y) =
      c * (g.inner x X X * g.inner x Y Y - g.inner x X Y * g.inner x X Y)

end HamiltonLeviCivitaSupport
