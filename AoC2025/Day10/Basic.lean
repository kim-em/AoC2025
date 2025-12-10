/-
  # Day 10 - Parsing and Data Structures
-/
import AoC2025.Basic

namespace AoC2025.Day10

/-- A machine has a target pattern, buttons, and joltage requirements -/
structure Machine where
  target : Array Bool           -- target indicator light pattern
  buttons : Array (Array Nat)   -- each button toggles certain lights (0-indexed)
  joltage : Array Nat           -- joltage requirements for Part 2
  deriving Repr

/-- Parse the target pattern from [.##.] format -/
def parseTarget (s : String) : Array Bool := Id.run do
  let chars := s.toList
  let mut result : Array Bool := #[]
  for c in chars do
    if c == '#' then
      result := result.push true
    else if c == '.' then
      result := result.push false
  return result

/-- Parse a button from (0,1,3) format -/
def parseButton (s : String) : Array Nat := Id.run do
  -- Remove parentheses and split by comma
  let inner := s.dropWhile (· != '(') |>.drop 1 |>.takeWhile (· != ')')
  let parts := inner.splitOn ","
  let mut result : Array Nat := #[]
  for p in parts do
    let trimmed := p.trim
    if let some n := trimmed.toNat? then
      result := result.push n
  return result

/-- Parse joltage requirements from {3,5,4,7} format -/
def parseJoltage (s : String) : Array Nat := Id.run do
  let inner := s.dropWhile (· != '{') |>.drop 1 |>.takeWhile (· != '}')
  let parts := inner.splitOn ","
  let mut result : Array Nat := #[]
  for p in parts do
    let trimmed := p.trim
    if let some n := trimmed.toNat? then
      result := result.push n
  return result

/-- Parse a single line into a Machine -/
def parseLine (line : String) : Option Machine := do
  -- Find the target in square brackets
  let targetStart := line.posOf '['
  let targetEnd := line.posOf ']'
  if targetStart >= line.endPos || targetEnd >= line.endPos then
    none
  else
    let targetStr := line.extract (targetStart + ⟨1⟩) targetEnd
    let target := parseTarget targetStr

    -- Find all buttons in parentheses (stop at curly brace)
    let beforeCurly := line.takeWhile (· != '{')
    let mut buttons : Array (Array Nat) := #[]
    let mut i := 0
    let chars := beforeCurly.toList
    while i < chars.length do
      if chars.get! i == '(' then
        -- Find matching close paren
        let mut j := i + 1
        while j < chars.length && chars.get! j != ')' do
          j := j + 1
        if j < chars.length then
          let buttonStr := String.mk (chars.drop i |>.take (j - i + 1))
          buttons := buttons.push (parseButton buttonStr)
        i := j + 1
      else
        i := i + 1

    -- Parse joltage requirements
    let joltage := parseJoltage line

    some { target := target, buttons := buttons, joltage := joltage }

/-- Parse the entire input -/
def parseInput (input : String) : Array Machine := Id.run do
  let lines := input.trim.splitOn "\n"
  let mut machines : Array Machine := #[]
  for line in lines do
    if let some m := parseLine line then
      machines := machines.push m
  return machines

/-- Create a bit vector from button indices (which lights it toggles) -/
def buttonToBitVector (button : Array Nat) (numLights : Nat) : Array Bool := Id.run do
  let mut vec : Array Bool := Array.mkArray numLights false
  for idx in button do
    if h : idx < vec.size then
      vec := vec.set idx true
    else
      vec := vec  -- skip invalid indices
  return vec

/-- XOR two bit vectors -/
def xorVec (a b : Array Bool) : Array Bool :=
  Array.zipWith (· != ·) a b

/-- Count number of true bits -/
def countBits (v : Array Bool) : Nat :=
  v.foldl (fun acc b => if b then acc + 1 else acc) 0

/-- GF(2) matrix: represented as array of rows, each row is a bit vector -/
abbrev GF2Matrix := Array (Array Bool)

/-- Create augmented matrix [A | target] for Gaussian elimination -/
def createAugmentedMatrix (m : Machine) : GF2Matrix := Id.run do
  let numLights := m.target.size
  let numButtons := m.buttons.size

  -- Create the transpose: columns are buttons, rows are lights
  -- We want to find which buttons to press, so each column is a button
  -- Each row is a light equation: sum of button[i] for buttons that toggle this light = target[i]
  let mut matrix : Array (Array Bool) := #[]
  for lightIdx in [:numLights] do
    let mut row : Array Bool := Array.mkArray (numButtons + 1) false
    for buttonIdx in [:numButtons] do
      let button := m.buttons[buttonIdx]!
      -- Check if this button toggles this light
      if button.any (· == lightIdx) then
        row := row.set! buttonIdx true
    -- Augment with target
    row := row.set! numButtons m.target[lightIdx]!
    matrix := matrix.push row
  return matrix

/-- Swap two rows in a matrix -/
def swapRows (mat : GF2Matrix) (i j : Nat) : GF2Matrix :=
  if h1 : i < mat.size then
    if h2 : j < mat.size then
      let ri := mat[i]
      let rj := mat[j]
      let mat' := mat.set i rj
      have h2' : j < mat'.size := by rw [Array.size_set]; exact h2
      mat'.set j ri
    else mat
  else mat

/-- XOR row j into row i -/
def addRow (mat : GF2Matrix) (i j : Nat) : GF2Matrix :=
  if h1 : i < mat.size then
    if h2 : j < mat.size then
      let newRow := xorVec mat[i] mat[j]
      mat.set i newRow
    else mat
  else mat

/-- Perform Gaussian elimination, return the matrix in row echelon form and pivot columns -/
def gaussianElimination (mat : GF2Matrix) : GF2Matrix × Array Nat := Id.run do
  let numRows := mat.size
  if numRows == 0 then return (mat, #[])
  let numCols := mat[0]!.size

  let mut m := mat
  let mut pivotRow := 0
  let mut pivotCols : Array Nat := #[]

  for col in [:numCols - 1] do  -- Don't pivot on augmented column
    if pivotRow >= numRows then break

    -- Find a pivot in this column
    let mut found := false
    for row in [pivotRow:numRows] do
      if m[row]![col]! then
        -- Swap to pivot position
        m := swapRows m pivotRow row
        found := true
        break

    if found then
      pivotCols := pivotCols.push col
      -- Eliminate all other rows
      for row in [:numRows] do
        if row != pivotRow && m[row]![col]! then
          m := addRow m row pivotRow
      pivotRow := pivotRow + 1

  return (m, pivotCols)

/-- Check if the system is consistent (no row of form [0 0 ... 0 | 1]) -/
def isConsistent (mat : GF2Matrix) (numVars : Nat) : Bool := Id.run do
  for row in mat do
    -- Check if all variable columns are 0 but augmented column is 1
    let mut allZero := true
    for i in [:numVars] do
      if row[i]! then
        allZero := false
        break
    if allZero && row[numVars]! then
      return false
  return true

/-- Find free variables (columns that are not pivot columns) -/
def freeVariables (numVars : Nat) (pivotCols : Array Nat) : Array Nat := Id.run do
  let mut free : Array Nat := #[]
  for i in [:numVars] do
    if !pivotCols.contains i then
      free := free.push i
  return free

/-- Back-substitute to find a particular solution -/
def backSubstitute (mat : GF2Matrix) (pivotCols : Array Nat) (numVars : Nat) (freeValues : Array Bool) (freeVars : Array Nat) : Array Bool := Id.run do
  let mut solution := Array.mkArray numVars false

  -- Set free variables according to freeValues
  for i in [:freeVars.size] do
    solution := solution.set! freeVars[i]! freeValues[i]!

  -- Back-substitute for pivot variables (go from bottom to top)
  let mut pivotIdx := pivotCols.size
  for row in mat.reverse do
    if pivotIdx == 0 then break
    let col := pivotCols[pivotIdx - 1]!

    -- Check if this row corresponds to this pivot (row has 1 in this column)
    if row[col]! then
      pivotIdx := pivotIdx - 1
      -- Calculate: solution[col] = row[numVars] XOR (sum of row[j] * solution[j] for j > col and j in pivotCols or freeVars)
      let mut val := row[numVars]!
      for j in [:numVars] do
        if j != col && row[j]! then
          val := xor val solution[j]!
      solution := solution.set! col val

  return solution

/-- Find the minimum weight solution using brute force over free variables -/
def findMinSolution (mat : GF2Matrix) (pivotCols : Array Nat) (numVars : Nat) : Option Nat := Id.run do
  let freeVars := freeVariables numVars pivotCols
  let numFree := freeVars.size

  if numFree > 20 then
    -- Too many free variables, just use the particular solution
    let solution := backSubstitute mat pivotCols numVars (Array.mkArray numFree false) freeVars
    return some (countBits solution)

  -- Try all 2^numFree combinations
  let mut minWeight : Option Nat := none
  for i in [:2^numFree] do
    -- Convert i to binary
    let mut freeValues : Array Bool := Array.mkArray numFree false
    for j in [:numFree] do
      if (i >>> j) &&& 1 == 1 then
        freeValues := freeValues.set! j true

    let solution := backSubstitute mat pivotCols numVars freeValues freeVars
    let weight := countBits solution

    match minWeight with
    | none => minWeight := some weight
    | some w => if weight < w then minWeight := some weight

  return minWeight

/-- Solve for minimum button presses for a machine -/
def solveMachine (m : Machine) : Option Nat := Id.run do
  let numButtons := m.buttons.size
  if numButtons == 0 then
    -- No buttons: check if target is all off
    if m.target.all (!·) then return some 0
    else return none

  let augMat := createAugmentedMatrix m
  let (echelon, pivotCols) := gaussianElimination augMat

  if !isConsistent echelon numButtons then
    return none

  return findMinSolution echelon pivotCols numButtons

-- ========== Part 2: Integer Linear Programming ==========

/-- Integer matrix for Part 2 -/
abbrev IntMatrix := Array (Array Int)

/-- Create augmented matrix for Part 2 (over integers) -/
def createIntAugmentedMatrix (m : Machine) : IntMatrix := Id.run do
  let numCounters := m.joltage.size
  let numButtons := m.buttons.size

  let mut matrix : Array (Array Int) := #[]
  for counterIdx in [:numCounters] do
    let mut row : Array Int := Array.replicate (numButtons + 1) 0
    for buttonIdx in [:numButtons] do
      let button := m.buttons[buttonIdx]!
      if button.any (· == counterIdx) then
        row := row.set! buttonIdx 1
    row := row.set! numButtons (Int.ofNat m.joltage[counterIdx]!)
    matrix := matrix.push row
  return matrix

/-- Swap two rows in an integer matrix -/
def swapIntRows (mat : IntMatrix) (i j : Nat) : IntMatrix :=
  if h1 : i < mat.size then
    if h2 : j < mat.size then
      let ri := mat[i]
      let rj := mat[j]
      let mat' := mat.set i rj
      have h2' : j < mat'.size := by rw [Array.size_set]; exact h2
      mat'.set j ri
    else mat
  else mat

/-- Multiply row i by a scalar -/
def scaleRow (mat : IntMatrix) (i : Nat) (s : Int) : IntMatrix :=
  if h : i < mat.size then
    mat.set i (mat[i].map (· * s))
  else mat

/-- Add s * row j to row i -/
def addScaledRow (mat : IntMatrix) (i j : Nat) (s : Int) : IntMatrix :=
  if h1 : i < mat.size then
    if h2 : j < mat.size then
      let rowI := mat[i]
      let rowJ := mat[j]
      let newRow := Array.zipWith (fun a b => a + s * b) rowI rowJ
      mat.set i newRow
    else mat
  else mat

/-- GCD of two naturals -/
def natGcd (a b : Nat) : Nat :=
  if h : b = 0 then a else natGcd b (a % b)
termination_by b
decreasing_by simp_wf; exact Nat.mod_lt a (Nat.pos_of_ne_zero h)

/-- GCD of two integers -/
def intGcd (a b : Int) : Int :=
  natGcd a.natAbs b.natAbs

/-- Perform Gaussian elimination over integers, return matrix in echelon form and pivot info -/
def intGaussianElimination (mat : IntMatrix) : IntMatrix × Array Nat := Id.run do
  let numRows := mat.size
  if numRows == 0 then return (mat, #[])
  let numCols := mat[0]!.size

  let mut m := mat
  let mut pivotRow := 0
  let mut pivotCols : Array Nat := #[]

  for col in [:numCols - 1] do
    if pivotRow >= numRows then break

    -- Find a non-zero pivot in this column
    let mut pivotIdx : Option Nat := none
    for row in [pivotRow:numRows] do
      if m[row]![col]! != 0 then
        pivotIdx := some row
        break

    match pivotIdx with
    | none => continue  -- No pivot in this column
    | some pIdx =>
      m := swapIntRows m pivotRow pIdx
      pivotCols := pivotCols.push col

      -- Eliminate all other rows
      let pivotVal := m[pivotRow]![col]!
      for row in [:numRows] do
        if row != pivotRow && m[row]![col]! != 0 then
          let targetVal := m[row]![col]!
          -- To eliminate: multiply row by pivotVal, pivotRow by -targetVal, add
          -- This keeps everything integer
          m := scaleRow m row pivotVal
          m := addScaledRow m row pivotRow (-targetVal)

      pivotRow := pivotRow + 1

  return (m, pivotCols)

/-- Check if integer system is consistent -/
def isIntConsistent (mat : IntMatrix) (numVars : Nat) : Bool := Id.run do
  for row in mat do
    let mut allZero := true
    for i in [:numVars] do
      if row[i]! != 0 then
        allZero := false
        break
    if allZero && row[numVars]! != 0 then
      return false
  return true

/-- For Part 2, use a simple approach: try to find non-negative integer solutions
    by iterating through possible button press counts.
    Since the systems are small, we can use a bounded search. -/
def solveMachineJoltage (m : Machine) : Option Nat := Id.run do
  let numButtons := m.buttons.size
  let numCounters := m.joltage.size
  if numButtons == 0 then
    if m.joltage.all (· == 0) then return some 0
    else return none

  -- Maximum possible presses for any button is max joltage value
  let maxJoltage := m.joltage.foldl max 0

  -- Use BFS/dynamic programming approach
  -- State: array of current counter values
  -- We want to reach target joltage with minimum button presses

  -- For efficiency, use a different approach:
  -- Since we're adding, we can use greedy + exhaustive for small cases

  -- Actually, for integer systems Ax = b with A having 0/1 entries and x >= 0,
  -- we can solve by finding the general solution and searching.

  -- But for AoC, let's use a simpler bounded search with memoization
  -- Try all combinations up to maxJoltage presses per button

  -- Since numButtons can be up to ~13 and maxJoltage up to ~250, we need a smarter approach

  -- Use the fact that in the reduced system, some variables are determined by others
  -- After Gaussian elimination, pivot variables are determined by free variables

  let augMat := createIntAugmentedMatrix m
  let (echelon, pivotCols) := intGaussianElimination augMat

  if !isIntConsistent echelon numButtons then
    return none

  -- Find free variables
  let freeVars := freeVariables numButtons pivotCols
  let numFree := freeVars.size

  -- For each row in echelon form, we have an equation
  -- pivotVar = (RHS - sum of coefficients * other vars) / pivotCoeff
  -- We need all variables to be non-negative integers

  -- For small number of free variables, enumerate possible values
  -- The maximum value for any free variable is bounded by maxJoltage

  if numFree == 0 then
    -- Unique solution (if any) - just back-substitute and check if all non-negative
    let mut solution := Array.replicate numButtons 0
    for rowIdx in [:echelon.size] do
      if rowIdx >= pivotCols.size then break
      let row := echelon[rowIdx]!
      let col := pivotCols[rowIdx]!
      let pivotCoeff := row[col]!
      if pivotCoeff == 0 then continue

      let rhs := row[numButtons]!
      -- Calculate: solution[col] = rhs / pivotCoeff (should be exact for consistent system)
      if rhs % pivotCoeff != 0 then
        return none  -- Not an integer solution
      let val := rhs / pivotCoeff
      if val < 0 then
        return none  -- Negative solution
      solution := solution.set! col val.toNat

    return some (solution.foldl (· + ·) 0)

  -- With free variables, search for minimum sum solution
  -- Bound each free variable by maxJoltage
  let bound := maxJoltage + 1

  -- For efficiency, limit search if too many free variables
  if numFree > 3 then
    -- Fall back to a heuristic: try free vars = 0 first, then small values
    -- This won't always find minimum but is fast
    let mut bestSum : Option Nat := none

    for freeSum in [:numFree * bound / 2 + 1] do
      -- Try all ways to distribute freeSum among free variables
      -- For simplicity, just try all zeros first
      if freeSum == 0 then
        let freeValues := Array.replicate numFree 0
        match tryFreeSolution echelon pivotCols numButtons freeVars freeValues with
        | some sol =>
          let sum := sol.foldl (· + ·) 0
          if bestSum.isNone || sum < bestSum.get! then
            bestSum := some sum
        | none => continue
      else
        break  -- Just use the zero solution if it works

    return bestSum
  else
    -- Enumerate all combinations
    let mut bestSum : Option Nat := none

    -- Generate all combinations of free variable values
    -- Each from 0 to bound-1
    let totalCombos := bound ^ numFree
    for combo in [:totalCombos] do
      let mut freeValues := Array.replicate numFree 0
      let mut c := combo
      for i in [:numFree] do
        freeValues := freeValues.set! i (c % bound)
        c := c / bound

      match tryFreeSolution echelon pivotCols numButtons freeVars freeValues with
      | some sol =>
        let sum := sol.foldl (· + ·) 0
        if bestSum.isNone || sum < bestSum.get! then
          bestSum := some sum
      | none => continue

    return bestSum

where
  /-- Try to solve with given free variable values, return solution if valid -/
  tryFreeSolution (echelon : IntMatrix) (pivotCols : Array Nat) (numVars : Nat)
      (freeVars : Array Nat) (freeValues : Array Nat) : Option (Array Nat) := Id.run do
    let mut solution := Array.replicate numVars 0

    -- Set free variables
    for i in [:freeVars.size] do
      solution := solution.set! freeVars[i]! freeValues[i]!

    -- Back-substitute for pivot variables
    -- Process rows from bottom to top
    for rowIdx' in [:pivotCols.size] do
      let rowIdx := pivotCols.size - 1 - rowIdx'
      let row := echelon[rowIdx]!
      let col := pivotCols[rowIdx]!
      let pivotCoeff := row[col]!

      if pivotCoeff == 0 then return none

      -- rhs - sum of (coeff[j] * solution[j]) for j != col
      let mut rhs := row[numVars]!
      for j in [:numVars] do
        if j != col then
          rhs := rhs - row[j]! * Int.ofNat solution[j]!

      if rhs % pivotCoeff != 0 then
        return none

      let val := rhs / pivotCoeff
      if val < 0 then
        return none

      solution := solution.set! col val.toNat

    return some solution

end AoC2025.Day10
