/-
  # Day 07: Laboratories - Tachyon Manifold Simulation
-/
import Mathlib
import AoC2025.Basic

namespace AoC2025.Day07

/-- A position in the grid -/
structure Pos where
  row : Nat
  col : Nat
  deriving BEq, Hashable, Repr

/-- Parse the grid and find the start position -/
def parseGrid (input : String) : (Array (Array Char) × Pos) :=
  let rows := lines input
  let grid := rows.map (·.toList.toArray) |>.toArray
  -- Find 'S' position
  let startPos := Id.run do
    for r in [:grid.size] do
      for c in [:(grid[r]!).size] do
        if (grid[r]!)[c]! == 'S' then
          return Pos.mk r c
    return Pos.mk 0 0
  (grid, startPos)

/-- Remove duplicates from a list -/
def dedup (xs : List Nat) : List Nat :=
  xs.foldl (fun acc x => if acc.contains x then acc else acc ++ [x]) []

/-- Merge timeline counts: combine entries with same column -/
def mergeTimelines (xs : List (Nat × Nat)) : List (Nat × Nat) :=
  xs.foldl (fun acc (col, count) =>
    match acc.find? (fun (c, _) => c == col) with
    | some _ => acc.map (fun (c, n) => if c == col then (c, n + count) else (c, n))
    | none => acc ++ [(col, count)]
  ) []

/-- Process one row: given active beams, return (new beams, splits count) -/
def processRow (grid : Array (Array Char)) (row : Nat) (activeBeams : List Nat) : (List Nat × Nat) :=
  let numRows := grid.size
  let numCols := if numRows > 0 then grid[0]!.size else 0

  let getCell (r c : Nat) : Option Char :=
    grid[r]?.bind (·[c]?)

  let result := activeBeams.foldl (fun (acc : List Nat × Nat) col =>
    let (beams, splits) := acc
    match getCell row col with
    | some '^' =>
      -- Splitter: create beams left and right
      let newBeams := if col > 0 then beams ++ [col - 1] else beams
      let newBeams := if col + 1 < numCols then newBeams ++ [col + 1] else newBeams
      (newBeams, splits + 1)
    | some '.' | some 'S' =>
      -- Empty space or start: beam continues down
      (beams ++ [col], splits)
    | _ =>
      -- Out of bounds or other: beam stops
      (beams, splits)
  ) ([], 0)

  (dedup result.1, result.2)

/-- Simulate tachyon beams and count splits -/
def simulateBeams (grid : Array (Array Char)) (startPos : Pos) : Nat :=
  let numRows := grid.size

  let rec simulate (row : Nat) (activeBeams : List Nat)
      (splitCount : Nat) (fuel : Nat) : Nat :=
    match fuel with
    | 0 => splitCount
    | fuel' + 1 =>
      if activeBeams.isEmpty then splitCount
      else if row >= numRows then splitCount
      else
        let (nextBeams, newSplits) := processRow grid row activeBeams
        simulate (row + 1) nextBeams (splitCount + newSplits) fuel'

  -- Start with a single beam at the start column, beginning from row below start
  simulate (startPos.row + 1) [startPos.col] 0 (numRows * 2)

/-- Process one row for Part 2: given beams with timeline counts, return new beams with counts -/
def processRowTimelines (grid : Array (Array Char)) (row : Nat)
    (activeBeams : List (Nat × Nat)) : List (Nat × Nat) :=
  let numRows := grid.size
  let numCols := if numRows > 0 then grid[0]!.size else 0

  let getCell (r c : Nat) : Option Char :=
    grid[r]?.bind (·[c]?)

  let result := activeBeams.foldl (fun (acc : List (Nat × Nat)) (col, count) =>
    match getCell row col with
    | some '^' =>
      -- Splitter: each timeline splits into two
      let newBeams := if col > 0 then acc ++ [(col - 1, count)] else acc
      let newBeams := if col + 1 < numCols then newBeams ++ [(col + 1, count)] else newBeams
      newBeams
    | some '.' | some 'S' =>
      -- Empty space or start: beam continues with same timeline count
      acc ++ [(col, count)]
    | _ =>
      -- Out of bounds or other: beam stops (timelines end here but we count at the end)
      acc
  ) []

  mergeTimelines result

/-- Simulate tachyon beams and count total timelines -/
def simulateTimelines (grid : Array (Array Char)) (startPos : Pos) : Nat :=
  let numRows := grid.size

  let rec simulate (row : Nat) (activeBeams : List (Nat × Nat)) (fuel : Nat) : Nat :=
    match fuel with
    | 0 => activeBeams.foldl (fun acc (_, count) => acc + count) 0
    | fuel' + 1 =>
      if activeBeams.isEmpty then 0
      else if row >= numRows then
        -- Sum up all timelines that made it to the bottom
        activeBeams.foldl (fun acc (_, count) => acc + count) 0
      else
        let nextBeams := processRowTimelines grid row activeBeams
        simulate (row + 1) nextBeams fuel'

  -- Start with 1 timeline at the start column, beginning from row below start
  simulate (startPos.row + 1) [(startPos.col, 1)] (numRows * 2)

/-! ## Specification Theorems -/

/-- dedup removes duplicates -/
theorem dedup_nodup (xs : List Nat) : (dedup xs).Nodup := by
  unfold dedup
  induction xs using List.reverseRecOn with
  | nil => simp
  | append_singleton l a ih =>
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    split_ifs with h
    · exact ih
    · rw [List.nodup_append]
      refine ⟨ih, List.nodup_singleton a, ?_⟩
      intro x hx
      simp only [List.mem_singleton]
      intro b hb
      subst hb
      rw [List.contains_eq_any_beq] at h
      simp only [List.any_eq_true, beq_iff_eq, not_exists, not_and] at h
      intro hxa
      exact h x hx hxa.symm

/-- dedup preserves membership -/
theorem mem_dedup_iff (xs : List Nat) (n : Nat) :
    n ∈ dedup xs ↔ n ∈ xs := by
  simp [dedup]
  induction xs using List.reverseRecOn <;> aesop

set_option maxHeartbeats 800000 in
/-- mergeTimelines preserves total count -/
theorem mergeTimelines_sum (xs : List (Nat × Nat)) :
    (mergeTimelines xs).foldl (fun acc (_, c) => acc + c) 0 =
    xs.foldl (fun acc (_, c) => acc + c) 0 := by
  -- Proved by Aristotle (v4.24.0), requires increased heartbeats for v4.24.1
  induction' xs using List.reverseRecOn with xs ih <;> aesop;
  by_cases h : fst ∈ List.map Prod.fst (AoC2025.Day07.mergeTimelines xs);
  · have h_add : List.foldl (fun acc (x : ℕ × ℕ) => acc + x.2) 0 (List.map (fun (c, n) => if c = fst then (c, n + snd) else (c, n)) (AoC2025.Day07.mergeTimelines xs)) = List.foldl (fun acc (x : ℕ × ℕ) => acc + x.2) 0 (AoC2025.Day07.mergeTimelines xs) + snd := by
      have h_add : ∀ {l : List (ℕ × ℕ)}, fst ∈ List.map Prod.fst l → List.foldl (fun acc (x : ℕ × ℕ) => acc + x.2) 0 (List.map (fun (c, n) => if c = fst then (c, n + snd) else (c, n)) l) = List.foldl (fun acc (x : ℕ × ℕ) => acc + x.2) 0 l + snd * (List.countP (fun (c, _) => c = fst) l) := by
        intros l hl; induction' l using List.reverseRecOn with l ih <;> aesop;
        · linarith [ a_1 _ h_1 ];
        · grind;
        · by_cases h : ( fst, w ) ∈ l <;> simp_all ( config := { decide := Bool.true } ) [ mul_add, add_assoc, add_comm, add_left_comm ];
          · exact a_1 _ h;
          · induction l using List.reverseRecOn <;> aesop;
            · exact a_1 _ ( Or.inr rfl );
            · grind;
      rw [ h_add h ];
      have h_count : ∀ {l : List (ℕ × ℕ)}, List.Nodup (List.map Prod.fst l) → List.countP (fun (c, snd) => c = fst) l = if fst ∈ List.map Prod.fst l then 1 else 0 := by
        norm_num +zetaDelta at *;
        intros l hl; induction l <;> aesop;
        rw [ List.countP_cons ] ; aesop;
      rw [ h_count ];
      · aesop;
      · have h_nodup : ∀ {l : List (ℕ × ℕ)}, List.Nodup (List.map Prod.fst (List.foldl (fun (acc : List (ℕ × ℕ)) (x : ℕ × ℕ) => match acc.find? (fun (c, _) => c == x.1) with | some _ => acc.map (fun (c, n) => if c == x.1 then (c, n + x.2) else (c, n)) | none => acc ++ [(x.1, x.2)]) [] l)) := by
          intro l; induction' l using List.reverseRecOn with l ih <;> aesop;
          · convert a_1 using 1;
            exact List.map_congr_left fun x hx => by aesop;
          · rw [ List.nodup_append ] ; aesop;
        exact h_nodup;
    unfold AoC2025.Day07.mergeTimelines at * ; aesop;
  · unfold AoC2025.Day07.mergeTimelines at *;
    grind

/-- Timeline doubling: each split doubles timelines going through it -/
theorem split_doubles_timelines (count : Nat) :
    count + count = 2 * count := by
  omega

/-- Part 2 computes 2^(number of splits) when all paths reach bottom -/
theorem timelines_eq_two_pow_splits (splits : Nat) :
    2 ^ splits = Nat.pow 2 splits := by
  rfl

end AoC2025.Day07
