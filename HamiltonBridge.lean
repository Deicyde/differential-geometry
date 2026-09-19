/-
The shared challenge predicates agree with the original library predicates.
This module imports only the already established geometric interface; Hamilton's
theorem itself is imported by Solution.lean.
-/
import HamiltonDefinitions
import ComparatorSupport.LeviCivita
import DifferentialGeometry.Geometry.Metric.Sphere.SpaceForm
import DifferentialGeometry.Geometry.Curvature.Components.Basic
import DifferentialGeometry.Geometry.Curvature.MetricConditions

set_option autoImplicit false

namespace HamiltonPointwise

noncomputable section

open scoped Manifold ContDiff

universe uE uQ

variable {E : Type uE} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [FiniteDimensional ℝ E]
variable {n : ℕ} [Fact (Module.finrank ℝ E = n + 1)] [NeZero n]

def SectionWitness.ofOriginal
    {Q : Type uQ} [TopologicalSpace Q] [ChartedSpace (EuclideanSpace ℝ (Fin n)) Q]
    [IsManifold (𝓡 n) ∞ Q]
    {proj : Metric.sphere (0 : E) 1 → Q} {x : Q}
    (S : DifferentialGeometry.Geometry.SectionWitness E n Q proj x) :
    SectionWitness E n Q proj x where
  W := S.W
  V := S.V
  scW := S.scW
  t2W := S.t2W
  bW := S.bW
  m1W := S.m1W
  mtW := S.mtW
  scV := S.scV
  t2V := S.t2V
  bV := S.bV
  m1V := S.m1V
  mtV := S.mtV
  s := S.s
  mem := S.mem
  isSec := S.isSec

def RoundQuotientData.ofOriginal
    (D : DifferentialGeometry.Geometry.RoundQuotientData.{uE, uQ} E n) :
    RoundQuotientData.{uE, uQ} E n where
  Q := D.Q
  topos := D.topos
  charted := D.charted
  mfld := D.mfld
  mfld1 := D.mfld1
  mfldTop := D.mfldTop
  t2 := D.t2
  sigmaCompact := D.sigmaCompact
  boundaryless := D.boundaryless
  Γ := D.Γ
  grp := D.grp
  fin := D.fin
  ρ := D.ρ
  proj := D.proj
  proj_smooth := D.proj_smooth
  proj_smul := D.proj_smul
  proj_eq_imp := D.proj_eq_imp
  sectionAt x := SectionWitness.ofOriginal (D.sectionAt x)

def SectionWitness.toOriginal
    {Q : Type uQ} [TopologicalSpace Q] [ChartedSpace (EuclideanSpace ℝ (Fin n)) Q]
    [IsManifold (𝓡 n) ∞ Q]
    {proj : Metric.sphere (0 : E) 1 → Q} {x : Q}
    (S : SectionWitness E n Q proj x) :
    DifferentialGeometry.Geometry.SectionWitness E n Q proj x where
  W := S.W
  V := S.V
  scW := S.scW
  t2W := S.t2W
  bW := S.bW
  m1W := S.m1W
  mtW := S.mtW
  scV := S.scV
  t2V := S.t2V
  bV := S.bV
  m1V := S.m1V
  mtV := S.mtV
  s := S.s
  mem := S.mem
  isSec := S.isSec

def RoundQuotientData.toOriginal
    (D : RoundQuotientData.{uE, uQ} E n) :
    DifferentialGeometry.Geometry.RoundQuotientData.{uE, uQ} E n where
  Q := D.Q
  topos := D.topos
  charted := D.charted
  mfld := D.mfld
  mfld1 := D.mfld1
  mfldTop := D.mfldTop
  t2 := D.t2
  sigmaCompact := D.sigmaCompact
  boundaryless := D.boundaryless
  Γ := D.Γ
  grp := D.grp
  fin := D.fin
  ρ := D.ρ
  proj := D.proj
  proj_smooth := D.proj_smooth
  proj_smul := D.proj_smul
  proj_eq_imp := D.proj_eq_imp
  sectionAt x := SectionWitness.toOriginal (D.sectionAt x)

section SpaceForm

variable {H : Type*} [TopologicalSpace H]
variable {I : ModelWithCorners ℝ E H}
variable {M : Type uQ} [TopologicalSpace M] [ChartedSpace H M]

omit [FiniteDimensional ℝ E] in
theorem isSphericalSpaceForm_of_original
    (h : DifferentialGeometry.Geometry.isSphericalSpaceForm (I := I) (M := M)) :
    isSphericalSpaceForm (I := I) (M := M) := by
  obtain ⟨S⟩ := h
  exact ⟨⟨RoundQuotientData.ofOriginal S.data, S.equiv⟩⟩

omit [FiniteDimensional ℝ E] in
theorem isSphericalSpaceForm_iff_original :
    isSphericalSpaceForm (I := I) (M := M) ↔
      DifferentialGeometry.Geometry.isSphericalSpaceForm (I := I) (M := M) := by
  constructor
  · rintro ⟨S⟩
    exact ⟨⟨RoundQuotientData.toOriginal S.data, S.equiv⟩⟩
  · exact isSphericalSpaceForm_of_original

end SpaceForm

end

end HamiltonPointwise

namespace HamiltonPointwise
noncomputable section
open DifferentialGeometry.Geometry.Curvature
open DifferentialGeometry.Tensor0SBundle
open scoped Manifold ContDiff BigOperators

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [FiniteDimensional ℝ E] [CompleteSpace E]
variable {H : Type*} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
variable {M : Type*} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]

/-- The original connection and Mathlib's connection agree on differentiable fields. -/
theorem metricConnection_eq_original (g : SmoothRiemannianMetric I M)
    (Y : (p : M) → TangentSpace I p) (x : M)
    (hY : MDiffAt (T% Y) x) (v : TangentSpace I x) :
    metricConnection g Y x v = metricCov (I := I) g Y x v := by
  exact HamiltonLeviCivitaSupport.metricConnection_eq_of_compatible_torsionFree
    g (metricCov (I := I) g)
    (DifferentialGeometry.Geometry.Connection.leviCivitaConnectionOfMetric_isMetricCompatible
      (I := I) g)
    (DifferentialGeometry.Geometry.Connection.leviCivitaConnectionOfMetric_isTorsionFree
      (I := I) g) hY v

/-- The curvature formula is independent of the two constructions of Levi-Civita. -/
theorem riemannValue_eq_original (g : SmoothRiemannianMetric I M) (x : M)
    (X Y Z : TangentSpace I x) :
    riemannValue g x X Y Z =
      CovariantDerivative.riemannCurvatureAux (metricCov (I := I) g)
        (CovariantDerivative.tangentConstAt (I := I) x X)
        (CovariantDerivative.tangentConstAt (I := I) x Y)
        (CovariantDerivative.tangentConstAt (I := I) x Z) x := by
  exact HamiltonLeviCivitaSupport.riemannValue_eq_of_connection_agreement
    g (metricCov (I := I) g)
    (fun Y x hY v => metricConnection_eq_original g Y x hY v)
    (CovariantDerivative.cov_tangentConst_apply_mdiffAt_self
      (metricCov (I := I) g) (metricCov_smooth (I := I) g)) x X Y Z

theorem sectionalValue_eq (g : SmoothRiemannianMetric I M) (x : M)
    (X Y Z W : TangentSpace I x) :
    metricRm04StdAt (I := I) g x X Y Z W =
      g.inner x W (riemannValue (I := I) g x X Y Z) := by
  rw [riemannValue_eq_original]
  exact CovariantDerivative.riemannCurvature04At_apply_const
    g (metricCov (I := I) g) (metricCov_smooth (I := I) g) X Y Z W

theorem ricciValue_eq (g : SmoothRiemannianMetric I M) (x : M)
    (Y Z : TangentSpace I x) :
    metricRicciAt (I := I) g x (vec2 Y Z) = ricciValue (I := I) g x Y Z := by
  unfold metricRicciAt CovariantDerivative.ricciCurvatureAt
  rw [ricciFromRm13At_apply_basis_trace (Module.finBasis ℝ (TangentSpace I x))]
  unfold ricciValue
  apply Finset.sum_congr rfl
  intro i _
  rw [CovariantDerivative.riemannCurvatureAt_apply_const,
    cotangentToDual_dualToCotangent_gen, riemannValue_eq_original]

omit [CompleteSpace E] in
theorem positiveRicciMetric_iff (g : SmoothRiemannianMetric I M) :
    positiveRicciMetric (I := I) g ↔
      DifferentialGeometry.Geometry.Curvature.positiveRicciMetric (I := I) g := by
  simp only [positiveRicciMetric,
    DifferentialGeometry.Geometry.Curvature.positiveRicciMetric, ricciValue_eq]

omit [CompleteSpace E] in
theorem constantPositiveSectionalCurvatureMetric_iff (g : SmoothRiemannianMetric I M) :
    constantPositiveSectionalCurvatureMetric (I := I) g ↔
      DifferentialGeometry.Geometry.Curvature.constantPositiveSectionalCurvatureMetric
        (I := I) g := by
  simp only [constantPositiveSectionalCurvatureMetric,
    DifferentialGeometry.Geometry.Curvature.constantPositiveSectionalCurvatureMetric,
    sectionalValue_eq]

end

open scoped Manifold ContDiff

universe uE uH uM

/-- The original library theorem's full statement, used only as a bridge input. -/
def OriginalHamiltonStatement : Prop :=
  ∀ {E : Type uE} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    [FiniteDimensional ℝ E] [CompleteSpace E]
    {H : Type uH} [TopologicalSpace H] {I : ModelWithCorners ℝ E H}
    {M : Type uM} [TopologicalSpace M] [ChartedSpace H M] [IsManifold I ∞ M]
    [SigmaCompactSpace M] [T2Space M],
    DifferentialGeometry.Topology.ThreeManifold.isClosedThreeManifold (I := I) (M := M) →
    DifferentialGeometry.Geometry.Curvature.admitsPositiveRicci (I := I) (M := M) →
    DifferentialGeometry.Geometry.Curvature.admitsConstantPositiveSectionalCurvature
      (I := I) (M := M) ∧
      DifferentialGeometry.Geometry.isSphericalSpaceForm (I := I) (M := M)

/-- Transfer the original theorem to the shared statement without adding assumptions. -/
theorem hamiltonStatement_of_original
    (hamilton : OriginalHamiltonStatement.{uE, uH, uM}) :
    HamiltonStatement.{uE, uH, uM} := by
  intro E _ _ _ _ H _ I M _ _ _ _ _ hM hpos
  obtain ⟨g, hg⟩ := hpos
  obtain ⟨⟨g', hg'⟩, hspace⟩ :=
    hamilton (I := I) (M := M) hM
      ⟨g, (positiveRicciMetric_iff (I := I) g).mp hg⟩
  exact ⟨⟨g', (constantPositiveSectionalCurvatureMetric_iff (I := I) g').mpr hg'⟩,
    isSphericalSpaceForm_of_original hspace⟩

/-- The shorter statement is equivalent to the original statement, in both directions. -/
theorem hamiltonStatement_iff_original :
    HamiltonStatement.{uE, uH, uM} ↔ OriginalHamiltonStatement.{uE, uH, uM} := by
  constructor
  · intro hamilton E _ _ _ _ H _ I M _ _ _ _ _ hM hpos
    obtain ⟨g, hg⟩ := hpos
    obtain ⟨⟨g', hg'⟩, hspace⟩ :=
      hamilton (I := I) (M := M) hM
        ⟨g, (positiveRicciMetric_iff (I := I) g).mpr hg⟩
    exact ⟨⟨g', (constantPositiveSectionalCurvatureMetric_iff (I := I) g').mp hg'⟩,
      isSphericalSpaceForm_iff_original.mp hspace⟩
  · exact hamiltonStatement_of_original

end HamiltonPointwise
