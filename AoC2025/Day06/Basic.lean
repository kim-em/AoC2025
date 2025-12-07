/-
  # Day 06: Trash Compactor - Parsing and helper functions
-/
import AoC2025.Basic

namespace AoC2025.Day06

/-- A problem: list of numbers and an operation -/
structure Problem where
  nums : List Nat
  op : Char  -- '*' or '+'
  deriving Repr

/-- Evaluate a problem -/
def Problem.eval (p : Problem) : Nat :=
  match p.op with
  | '*' => p.nums.foldl (· * ·) 1
  | '+' => p.nums.foldl (· + ·) 0
  | _ => 0

/-- Parse the grid-based input into problems.
    Each problem is a vertical column separated by space columns. -/
def parseProblems (input : String) : List Problem :=
  let rows := lines input
  if rows.isEmpty then []
  else
    -- Pad all rows to same length
    let maxLen := rows.foldl (fun m r => max m r.length) 0
    let paddedRows := rows.map (fun r => r ++ String.mk (List.replicate (maxLen - r.length) ' '))

    -- Convert to array of arrays for easier column access
    let grid := paddedRows.map (·.toList) |>.toArray

    -- Find column ranges for each problem (separated by space columns)
    let numRows := grid.size
    let numCols := if h : 0 < numRows then grid[0].length else 0

    -- Find columns that are all spaces (problem separators)
    let isSpaceCol (col : Nat) : Bool :=
      (List.range numRows).all fun row =>
        match grid[row]?.bind (·[col]?) with
        | some ' ' => true
        | _ => false

    -- Group consecutive non-space columns into problems
    let rec findProblems (col : Nat) (currentNums : List (List Char))
        (acc : List Problem) (fuel : Nat) : List Problem :=
      match fuel with
      | 0 => acc.reverse
      | fuel' + 1 =>
        if col >= numCols then
          -- Finish any current problem
          if currentNums.isEmpty then acc.reverse
          else
            let p := finishProblem grid currentNums numRows
            (p :: acc).reverse
        else if isSpaceCol col then
          -- End current problem if any
          if currentNums.isEmpty then
            findProblems (col + 1) [] acc fuel'
          else
            let p := finishProblem grid currentNums numRows
            findProblems (col + 1) [] (p :: acc) fuel'
        else
          -- Add this column to current problem
          let colChars := (List.range numRows).map fun row =>
            match grid[row]?.bind (·[col]?) with
            | some c => c
            | none => ' '
          findProblems (col + 1) (currentNums ++ [colChars]) acc fuel'

    findProblems 0 [] [] (numCols + 2)

where
  finishProblem (grid : Array (List Char)) (cols : List (List Char)) (numRows : Nat) : Problem :=
    -- Last row is the operator
    let op := cols.foldl (fun o colChars =>
      match colChars[numRows - 1]? with
      | some c => if c = '*' || c = '+' then c else o
      | none => o) '+'

    -- Other rows are numbers (concatenate digits in each row to form numbers)
    let nums := (List.range (numRows - 1)).filterMap fun row =>
      let rowChars := cols.filterMap (·[row]?)
      let numStr := String.mk (rowChars.filter (·.isDigit))
      numStr.toNat?

    ⟨nums, op⟩

/-- Parse problems reading right-to-left, where each column forms a number (top=MSB) -/
def parseProblemsPart2 (input : String) : List Problem :=
  let rows := lines input
  if rows.isEmpty then []
  else
    -- Pad all rows to same length
    let maxLen := rows.foldl (fun m r => max m r.length) 0
    let paddedRows := rows.map (fun r => r ++ String.mk (List.replicate (maxLen - r.length) ' '))

    -- Convert to array of arrays for easier column access
    let grid := paddedRows.map (·.toList) |>.toArray

    let numRows := grid.size
    let numCols := if h : 0 < numRows then grid[0].length else 0

    -- Get character at (row, col)
    let getChar (row col : Nat) : Char :=
      match grid[row]?.bind (·[col]?) with
      | some c => c
      | none => ' '

    -- Find columns that are all spaces (problem separators)
    let isSpaceCol (col : Nat) : Bool :=
      (List.range numRows).all fun row => getChar row col == ' '

    -- Process columns right-to-left
    let rec findProblems (col : Int) (currentCols : List Nat)
        (acc : List Problem) (fuel : Nat) : List Problem :=
      match fuel with
      | 0 => acc
      | fuel' + 1 =>
        if col < 0 then
          -- Finish any current problem
          if currentCols.isEmpty then acc
          else
            let p := finishProblemP2 grid currentCols numRows
            p :: acc
        else
          let colNat := col.toNat
          if isSpaceCol colNat then
            -- End current problem if any
            if currentCols.isEmpty then
              findProblems (col - 1) [] acc fuel'
            else
              let p := finishProblemP2 grid currentCols numRows
              findProblems (col - 1) [] (p :: acc) fuel'
          else
            -- Add this column to current problem (prepend since we're going right-to-left)
            findProblems (col - 1) (colNat :: currentCols) acc fuel'

    findProblems (numCols - 1) [] [] (numCols + 2)

where
  finishProblemP2 (grid : Array (List Char)) (colIndices : List Nat) (numRows : Nat) : Problem :=
    let getChar (row col : Nat) : Char :=
      match grid[row]?.bind (·[col]?) with
      | some c => c
      | none => ' '

    -- Last row is the operator
    let op := colIndices.foldl (fun o col =>
      let c := getChar (numRows - 1) col
      if c == '*' || c == '+' then c else o) '+'

    -- Each column forms a number (digits from rows 0 to numRows-2)
    -- Top digit is most significant
    let nums := colIndices.filterMap fun col =>
      let digitChars := (List.range (numRows - 1)).filterMap fun row =>
        let c := getChar row col
        if c.isDigit then some c else none
      if digitChars.isEmpty then none
      else (String.mk digitChars).toNat?

    ⟨nums, op⟩

/-! ## Specification Theorems -/

/-- Problem.eval for multiplication is the product of all numbers -/
theorem Problem.eval_mul (nums : List Nat) :
    Problem.eval ⟨nums, '*'⟩ = nums.foldl (· * ·) 1 := by
  rfl

/-- Problem.eval for addition is the sum of all numbers -/
theorem Problem.eval_add (nums : List Nat) :
    Problem.eval ⟨nums, '+'⟩ = nums.foldl (· + ·) 0 := by
  rfl

/-- Empty problem has neutral element result -/
theorem Problem.eval_empty_mul : Problem.eval ⟨[], '*'⟩ = 1 := by rfl

theorem Problem.eval_empty_add : Problem.eval ⟨[], '+'⟩ = 0 := by rfl

/-- Single-element multiplication is the element itself -/
theorem Problem.eval_singleton_mul (n : Nat) :
    Problem.eval ⟨[n], '*'⟩ = n := by
  simp [Problem.eval]

/-- Single-element addition is the element itself -/
theorem Problem.eval_singleton_add (n : Nat) :
    Problem.eval ⟨[n], '+'⟩ = n := by
  simp [Problem.eval]

end AoC2025.Day06
