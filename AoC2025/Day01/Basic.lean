/-
  # Day 01 - Basic definitions and parsing
-/
namespace AoC2025.Day01

inductive Direction where
  | left
  | right
  deriving Repr

structure Rotation where
  dir : Direction
  dist : Nat
  deriving Repr

def parseRotation (s : String) : Option Rotation :=
  let s := s.trim
  if s.isEmpty then none
  else
    let dirChar := s.get ⟨0⟩
    let distStr := s.drop 1
    let dir := if dirChar == 'L' then Direction.left else Direction.right
    distStr.toNat?.map fun dist => ⟨dir, dist⟩

def parseInput (input : String) : List Rotation :=
  input.splitOn "\n" |>.filterMap parseRotation

def applyRotation (pos : Nat) (rot : Rotation) : Nat :=
  match rot.dir with
  | Direction.left  => (pos + 100 - rot.dist % 100) % 100
  | Direction.right => (pos + rot.dist) % 100

-- Count how many times the dial crosses 0 during a rotation (including final position)
def countZeroCrossings (pos : Nat) (rot : Rotation) : Nat :=
  match rot.dir with
  | Direction.right => (pos + rot.dist) / 100
  | Direction.left =>
    if pos == 0 then rot.dist / 100
    else if rot.dist >= pos then 1 + (rot.dist - pos) / 100
    else 0

/-! ## Specification Theorems -/

/-- applyRotation always returns a value in [0, 100) -/
theorem applyRotation_lt_100 (pos : Nat) (rot : Rotation) :
    applyRotation pos rot < 100 := by
  unfold applyRotation
  cases rot.dir <;> simp [Nat.mod_lt]

/-- applyRotation with 0 distance is identity (mod 100) -/
theorem applyRotation_zero_dist (pos : Nat) (dir : Direction) :
    applyRotation pos ⟨dir, 0⟩ = pos % 100 := by
  unfold applyRotation
  cases dir <;> simp

/-- Left rotation by 100 is identity for positions < 100 -/
theorem applyRotation_left_100 (pos : Nat) (hpos : pos < 100) :
    applyRotation pos ⟨Direction.left, 100⟩ = pos := by
  unfold applyRotation
  simp [Nat.mod_eq_of_lt hpos]

/-- Right rotation by 100 is identity for positions < 100 -/
theorem applyRotation_right_100 (pos : Nat) (hpos : pos < 100) :
    applyRotation pos ⟨Direction.right, 100⟩ = pos := by
  unfold applyRotation
  simp [Nat.mod_eq_of_lt hpos]

/-- countZeroCrossings for right rotation -/
theorem countZeroCrossings_right (pos : Nat) (dist : Nat) :
    countZeroCrossings pos ⟨Direction.right, dist⟩ = (pos + dist) / 100 := by
  rfl

/-- countZeroCrossings for left rotation when pos = 0 -/
theorem countZeroCrossings_left_pos0 (dist : Nat) :
    countZeroCrossings 0 ⟨Direction.left, dist⟩ = dist / 100 := by
  rfl

/-- countZeroCrossings for left rotation when dist < pos -/
theorem countZeroCrossings_left_small (pos : Nat) (dist : Nat) (hpos : pos ≠ 0) (hlt : dist < pos) :
    countZeroCrossings pos ⟨Direction.left, dist⟩ = 0 := by
  unfold countZeroCrossings
  simp [hpos, Nat.not_le.mpr hlt]

/-- countZeroCrossings for left rotation when dist ≥ pos -/
theorem countZeroCrossings_left_large (pos : Nat) (dist : Nat) (hpos : pos ≠ 0) (hge : dist ≥ pos) :
    countZeroCrossings pos ⟨Direction.left, dist⟩ = 1 + (dist - pos) / 100 := by
  unfold countZeroCrossings
  simp [hpos, hge]

end AoC2025.Day01
