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

end AoC2025.Day01
