# Day 09 Upstream Candidates

## Computational Geometry Utilities

Day 09 implements several computational geometry algorithms:

### Point-in-Polygon (Ray Casting)

```lean
def isInsidePolygon (p : Point) (vertices : Array Point) : Bool
```

Standard ray casting algorithm to determine if a point is inside a polygon.

**Potential Value**: Useful for any geometric computations involving polygons.

**Current Limitations**:
- Uses integer arithmetic (avoids floating point issues)
- Assumes vertices form a simple polygon (no self-intersections)
- No correctness proof

### Axis-Aligned Segment Membership

```lean
def isOnSegment (p a b : Point) : Bool
```

Checks if a point lies on an axis-aligned segment between two endpoints (excluding endpoints).

**Proved Properties**:
- `isOnSegment_not_endpoint_left`: Result excludes left endpoint
- `isOnSegment_not_endpoint_right`: Result excludes right endpoint
- `isOnSegment_non_axis_aligned`: Returns false for non-axis-aligned segments

### Rectangle Area

```lean
def rectangleArea (p1 p2 : Point) : Nat
```

Calculates the area of a rectangle with opposite corners at two points.

**Proved Properties**:
- `rectangleArea_ge_one`: Area is always at least 1
- `rectangleArea_comm`: Area calculation is symmetric

## Significant Y-Coordinates Optimization

```lean
def getSignificantYs (vertices : Array Point) (minY maxY : Nat) : Array Nat
```

Collects y-coordinates where polygon validity changes (vertex y-coordinates plus boundaries).

This is an optimization technique for polygon validation - instead of checking all y-values, only check significant ones plus midpoints between them.

**Status**: Two theorems (`getSignificantYs_contains_minY`, `getSignificantYs_contains_maxY`) pending Aristotle proof.

## Recommendation

The computational geometry primitives (point-in-polygon, segment membership) could be useful in a general geometry library, but would need:
1. Generalization beyond `Nat` coordinates
2. More comprehensive correctness proofs
3. Handling of edge cases (degenerate polygons, etc.)

The current implementation is specialized for the AoC problem and not immediately suitable for upstream without significant work.
