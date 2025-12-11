/-
  # Day 11 - Parsing and Data Structures
-/
import AoC2025.Basic
import Std.Data.HashMap

namespace AoC2025.Day11

open Std (HashMap)

abbrev Graph := HashMap String (Array String)

/-- Parse a single line "node: child1 child2 ..." -/
def parseLine (line : String) : Option (String × Array String) :=
  match line.splitOn ": " with
  | [name, rest] => some (name, rest.splitOn " " |>.toArray)
  | _ => none

/-- Parse the entire input into a graph -/
def parseGraph (input : String) : Graph :=
  input.trim.splitOn "\n"
  |>.filterMap parseLine
  |>.foldl (fun m (name, children) => m.insert name children) (HashMap.emptyWithCapacity 1000)

/-- Count paths from a node to target using memoization.
    Returns the updated memo table and the count. -/
partial def countPathsTo (graph : Graph) (node : String) (target : String)
    (memo : HashMap String Nat) : HashMap String Nat × Nat :=
  if node == target then
    (memo, 1)
  else
    let key := s!"{node}→{target}"
    match memo[key]? with
    | some count => (memo, count)
    | none =>
      let children := graph[node]?.getD #[]
      let (memo', total) := children.foldl
        (fun (m, acc) child =>
          let (m', c) := countPathsTo graph child target m
          (m', acc + c))
        (memo, 0)
      (memo'.insert key total, total)

/-- Count paths from start to target that pass through both waypoints (in any order) -/
def countPathsViaBoth (graph : Graph) (start wp1 wp2 target : String)
    (memo : HashMap String Nat) : HashMap String Nat × Nat :=
  -- Path: start → wp1 → wp2 → target
  let (memo', toWp1) := countPathsTo graph start wp1 memo
  let (memo'', wp1ToWp2) := countPathsTo graph wp1 wp2 memo'
  let (memo''', wp2ToTarget) := countPathsTo graph wp2 target memo''
  let count1 := toWp1 * wp1ToWp2 * wp2ToTarget
  -- Path: start → wp2 → wp1 → target
  let (memo4, toWp2) := countPathsTo graph start wp2 memo'''
  let (memo5, wp2ToWp1) := countPathsTo graph wp2 wp1 memo4
  let (memo6, wp1ToTarget) := countPathsTo graph wp1 target memo5
  let count2 := toWp2 * wp2ToWp1 * wp1ToTarget
  (memo6, count1 + count2)

-- Specification theorems

/-- Example: parsing "foo: bar baz" gives expected result -/
example : parseLine "foo: bar baz" = some ("foo", #["bar", "baz"]) := by native_decide

/-- Example: parsing without ": " fails -/
example : parseLine "foo bar" = none := by native_decide

/-- Example: parsing with single child -/
example : parseLine "node: out" = some ("node", #["out"]) := by native_decide

end AoC2025.Day11
