/-
Self-contained Mathlib-only challenge using Mathlib's Levi-Civita connection.
All geometric definitions are included below. Only the final theorem has a proof hole.
The shared definition block is identical to HamiltonDefinitions.lean.
-/
import Mathlib.Geometry.Manifold.VectorBundle.CovariantDerivative.LeviCivita
import Mathlib.Geometry.Manifold.Instances.Sphere
import Mathlib.Geometry.Manifold.Diffeomorph
import Mathlib.Geometry.Manifold.ContMDiff.NormedSpace
import Mathlib.Geometry.Manifold.MFDeriv.FDeriv
import Mathlib.Tactic.NormNum

set_option autoImplicit false

namespace HamiltonPointwise

noncomputable section

open Bundle
open scoped Manifold ContDiff BigOperators

section Metric

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
variable {H : Type*} [TopologicalSpace H]

abbrev SmoothRiemannianMetric
    (I : ModelWithCorners ℝ E H) (M : Type*)
    [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M] : Type _ :=
  Bundle.ContMDiffRiemannianMetric I ∞ E (TangentSpace I : M → Type _)

variable [FiniteDimensional ℝ E]
variable {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]

/-- Mathlib's Levi-Civita connection for the given smooth Riemannian metric. -/
def metricConnection (g : SmoothRiemannianMetric I M) :
    CovariantDerivative I E (TangentSpace I : M → Type _) := by
  letI : RiemannianBundle (TangentSpace I : M → Type _) := ⟨g.toRiemannianMetric⟩
  exact CovariantDerivative.leviCivitaConnection I M

def tangentConstAt (x : M) (v : TangentSpace I x) (p : M) : TangentSpace I p :=
  (trivializationAt E (TangentSpace I) x).symmL ℝ p
    ((trivializationAt E (TangentSpace I) x).continuousLinearMapAt ℝ x v)

end Metric

section Curvature

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [FiniteDimensional ℝ E] [CompleteSpace E]
variable {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]

local instance curvatureTangentSpace_finiteDimensional (x : M) :
    FiniteDimensional ℝ (TangentSpace I x) :=
  inferInstanceAs (FiniteDimensional ℝ E)

def riemannValue (g : SmoothRiemannianMetric I M) (x : M)
    (X Y Z : TangentSpace I x) : TangentSpace I x :=
  let cov := metricConnection g
  let X' := tangentConstAt x X
  let Y' := tangentConstAt x Y
  let Z' := tangentConstAt x Z
  (cov (fun p => (cov Z' p) (Y' p)) x) (X' x) -
    (cov (fun p => (cov Z' p) (X' p)) x) (Y' x) -
      (cov Z' x) (VectorField.mlieBracket I X' Y' x)

def ricciValue (g : SmoothRiemannianMetric I M) (x : M)
    (Y Z : TangentSpace I x) : ℝ :=
  let b := Module.finBasis ℝ (TangentSpace I x)
  ∑ i, b.coord i (riemannValue g x (b i) Y Z)

def positiveRicciMetric (g : SmoothRiemannianMetric I M) : Prop :=
  ∀ x : M, ∀ v : TangentSpace I x, v ≠ 0 → 0 < ricciValue g x v v

def constantPositiveSectionalCurvatureMetric (g : SmoothRiemannianMetric I M) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ x : M, ∀ X Y : TangentSpace I x,
    g.inner x X (riemannValue g x X Y Y) =
      c * (g.inner x X X * g.inner x Y Y - g.inner x X Y * g.inner x X Y)

end Curvature

section Closed

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
variable {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M]

def isClosedThreeManifold : Prop :=
  CompactSpace M ∧ ConnectedSpace M ∧ I.Boundaryless ∧ Module.finrank ℝ E = 3

end Closed

section SphereAction

open Manifold Set Metric Module
open scoped Topology RealInnerProductSpace

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [FiniteDimensional ℝ E]
variable {n : ℕ} [Fact (finrank ℝ E = n + 1)]

def sphereMap (e : E ≃ₗᵢ[ℝ] E) : sphere (0 : E) 1 → sphere (0 : E) 1 :=
  Set.codRestrict (fun x : sphere (0 : E) 1 => (e (x : E) : E)) (sphere (0 : E) 1)
    (fun x => by
      rw [mem_sphere_zero_iff_norm, e.norm_map]
      exact mem_sphere_zero_iff_norm.mp x.2)

omit [FiniteDimensional ℝ E] in
@[simp] theorem sphereMap_coe (e : E ≃ₗᵢ[ℝ] E) (x : sphere (0 : E) 1) :
    (sphereMap e x : E) = e (x : E) := rfl

theorem sphereMap_contMDiff (e : E ≃ₗᵢ[ℝ] E) :
    ContMDiff (𝓡 n) (𝓡 n) ∞ (sphereMap e) :=
  ContMDiff.codRestrict_sphere
    (e.toContinuousLinearMap.contMDiff.comp contMDiff_coe_sphere) _

def sphereDiffeo (e : E ≃ₗᵢ[ℝ] E) :
    sphere (0 : E) 1 ≃ₘ⟮𝓡 n, 𝓡 n⟯ sphere (0 : E) 1 where
  toFun := sphereMap e
  invFun := sphereMap e.symm
  left_inv x := Subtype.ext (by simp)
  right_inv x := Subtype.ext (by simp)
  contMDiff_toFun := sphereMap_contMDiff (n := n) e
  contMDiff_invFun := sphereMap_contMDiff (n := n) e.symm

end SphereAction

section Quotient

open Manifold Set Metric Module
open scoped Topology RealInnerProductSpace

universe uE uQ

structure SectionWitness (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] (n : ℕ) [Fact (finrank ℝ E = n + 1)] [NeZero n]
    (Q : Type*) [TopologicalSpace Q] [ChartedSpace (EuclideanSpace ℝ (Fin n)) Q]
    [IsManifold (𝓡 n) ∞ Q]
    (proj : sphere (0 : E) 1 → Q) (x : Q) where
  W : TopologicalSpace.Opens Q
  V : TopologicalSpace.Opens (sphere (0 : E) 1)
  [scW : SigmaCompactSpace W]
  [t2W : T2Space W]
  [bW : BoundarylessManifold (𝓡 n) W]
  [m1W : IsManifold (𝓡 n) 1 W]
  [mtW : IsManifold (𝓡 n) ((∞ : WithTop ℕ∞) + 1) W]
  [scV : SigmaCompactSpace V]
  [t2V : T2Space V]
  [bV : BoundarylessManifold (𝓡 n) V]
  [m1V : IsManifold (𝓡 n) 1 V]
  [mtV : IsManifold (𝓡 n) ((∞ : WithTop ℕ∞) + 1) V]
  s : W ≃ₘ⟮𝓡 n, 𝓡 n⟯ V
  mem : x ∈ W
  isSec : ∀ r : W, proj ((s r : V) : sphere (0 : E) 1) = (r : Q)

structure RoundQuotientData (E : Type uE) [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] (n : ℕ) [Fact (finrank ℝ E = n + 1)] [NeZero n] where
  Q : Type uQ
  [topos : TopologicalSpace Q]
  [charted : ChartedSpace (EuclideanSpace ℝ (Fin n)) Q]
  [mfld : IsManifold (𝓡 n) ∞ Q]
  [mfld1 : IsManifold (𝓡 n) 1 Q]
  [mfldTop : IsManifold (𝓡 n) ((∞ : WithTop ℕ∞) + 1) Q]
  [t2 : T2Space Q]
  [sigmaCompact : SigmaCompactSpace Q]
  [boundaryless : BoundarylessManifold (𝓡 n) Q]
  Γ : Type uQ
  [grp : Group Γ]
  [fin : Fintype Γ]
  ρ : Γ →* (E ≃ₗᵢ[ℝ] E)
  proj : sphere (0 : E) 1 → Q
  proj_smooth : ContMDiff (𝓡 n) (𝓡 n) ∞ proj
  proj_smul : ∀ (γ : Γ) (q : sphere (0 : E) 1),
    proj (sphereDiffeo (n := n) (ρ γ) q) = proj q
  proj_eq_imp : ∀ q₁ q₂ : sphere (0 : E) 1,
    proj q₁ = proj q₂ → ∃ γ : Γ, sphereDiffeo (n := n) (ρ γ) q₁ = q₂
  sectionAt : ∀ x : Q, SectionWitness E n Q proj x

attribute [instance] RoundQuotientData.topos RoundQuotientData.charted RoundQuotientData.mfld
  RoundQuotientData.mfld1 RoundQuotientData.mfldTop RoundQuotientData.t2
  RoundQuotientData.sigmaCompact RoundQuotientData.boundaryless RoundQuotientData.grp
  RoundQuotientData.fin
  SectionWitness.scW SectionWitness.t2W SectionWitness.bW SectionWitness.m1W
  SectionWitness.mtW SectionWitness.scV SectionWitness.t2V SectionWitness.bV
  SectionWitness.m1V SectionWitness.mtV

end Quotient

section SpaceForm

universe u

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable {H : Type*} [TopologicalSpace H]

local instance euclideanFour_finrank :
    Fact (Module.finrank ℝ (EuclideanSpace ℝ (Fin 4)) = 3 + 1) :=
  ⟨by norm_num [finrank_euclideanSpace_fin]⟩

structure SphericalSpaceFormQuotientModel
    (I : ModelWithCorners ℝ E H) (N : Type u)
    [TopologicalSpace N] [ChartedSpace H N] : Type _ where
  data : RoundQuotientData.{0, u} (EuclideanSpace ℝ (Fin 4)) 3
  equiv : N ≃ₘ⟮I, 𝓡 3⟯ data.Q

def isSphericalSpaceFormQuotient
    (I : ModelWithCorners ℝ E H) (N : Type u)
    [TopologicalSpace N] [ChartedSpace H N] : Prop :=
  Nonempty (SphericalSpaceFormQuotientModel I N)

variable {I : ModelWithCorners ℝ E H}
variable {M : Type u} [TopologicalSpace M] [ChartedSpace H M]

def isSphericalSpaceForm : Prop := isSphericalSpaceFormQuotient I M

end SpaceForm

universe uE uH uM

def HamiltonStatement : Prop :=
  ∀ {E : Type uE} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [CompleteSpace E]
    {H : Type uH} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
    {M : Type uM} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]
    [SigmaCompactSpace M] [T2Space M],
    isClosedThreeManifold (I := I) (M := M) →
    (∃ g : SmoothRiemannianMetric I M, positiveRicciMetric g) →
    (∃ g : SmoothRiemannianMetric I M, constantPositiveSectionalCurvatureMetric g) ∧
      isSphericalSpaceForm (I := I) (M := M)

end

end HamiltonPointwise

namespace HamiltonPointwise

universe uE uH uM

/-- Hamilton's theorem: a closed connected three-manifold admitting positive Ricci
curvature admits constant positive sectional curvature and is a spherical space form. -/
theorem hamilton_positive_ricci : HamiltonStatement.{uE, uH, uM} := by
  sorry

end HamiltonPointwise
