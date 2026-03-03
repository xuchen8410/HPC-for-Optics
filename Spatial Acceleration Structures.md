

空间索引结构：快速找到可能相交的几何体
- KD-tree (points)
- BVH (ray tracing)
- R-tree (boxes)



# Spatial Acceleration Structures  
## KD-Tree vs BVH vs R-Tree  
### Engineering-Level Understanding for Optical / Ray / CAD Systems

---

# 1. Why Spatial Indexing Exists

Naive intersection:

for ray in rays:
    for object in objects:
        intersect(ray, object)

Time complexity:

O(N_ray × N_object)

Example:
- 1e6 rays
- 1e4 triangles

→ 1e10 intersection tests (impractical)

Spatial acceleration reduces complexity to:

O(N_ray log N_object)

Core idea:

> Eliminate 90–99% of impossible intersection tests before geometry testing.

---

# 2. KD-Tree (k-dimensional tree)

## Best For
- Point clouds
- kNN search
- Photon mapping
- Monte Carlo sampling
- Nearest-neighbor queries

---

## 2.1 Core Concept

Binary Space Partitioning (BSP).

At each level:
- Choose axis (x/y/z)
- Split at median
- Recursively divide space

---

## 2.2 Data Structure

struct KDNode {
    point
    axis
    left
    right
}

Binary tree.
Space is partitioned, not objects.

---

## 2.3 Query (Nearest Neighbor)

1. Traverse down likely branch.
2. Track best distance.
3. Backtrack if necessary.

Average complexity:
O(log N)

Worst case:
O(N)

---

## 2.4 Optical Applications

- Photon mapping
- Monte Carlo phase-space sampling
- Wavefront grid neighbor search
- Scattered ray statistics

---

# 3. BVH (Bounding Volume Hierarchy)

## Best For
- Ray tracing
- Stray light analysis
- Triangle meshes
- Reflective optical systems (TMA, mirrors)

Modern ray tracers use BVH (Embree, OptiX, Unreal Engine).

---

## 3.1 Core Concept

Wrap geometry in bounding boxes.
Then wrap boxes in larger boxes.

Hierarchy of bounding volumes.

---

## 3.2 Data Structure

struct BVHNode {
    bounding_box
    left
    right
    object (leaf only)
}

Binary tree.
Objects remain intact.
Only bounding volumes are hierarchical.

---

## 3.3 Construction Methods

Common strategies:

- Median split
- Surface Area Heuristic (SAH)

SAH cost model:

C = C_trav + P(left)C(left) + P(right)C(right)

Industrial ray tracers use SAH.

---

## 3.4 Ray Traversal

Pseudo-logic:

if not intersect(ray, node.box):
    return

if leaf:
    test geometry
else:
    traverse children

Most rays terminate high in tree.

---

## 3.5 Why BVH > KD-Tree for Ray Tracing?

| KD-tree            | BVH                     |
|--------------------|-------------------------|
| Splits space       | Wraps geometry          |
| Ray crosses splits | Ray tests AABB only     |
| Hard for dynamic   | Easier to update        |
| Memory scattered   | More cache-friendly     |

BVH is GPU-standard.

---

# 4. R-Tree

## Best For
- GIS systems
- CAD systems
- Spatial databases
- OpenCASCADE
- Collision detection

---

## 4.1 Core Concept

B-tree for spatial data.

Nodes store multiple bounding boxes.
Multi-branch tree.

---

## 4.2 Data Structure

Node:
    MBR (Minimum Bounding Rectangle)
    children[]

Not binary.
Multi-way branching.

---

## 4.3 Insertion Strategy

When inserting:

1. Choose child requiring smallest area expansion.
2. Insert box.
3. Split if overflow.
4. Update parent MBR.

---

## 4.4 Characteristics

| Feature        | R-tree |
|---------------|--------|
| Multi-branch  | Yes    |
| Dynamic insert| Strong |
| Database use  | Yes    |
| Ray tracing   | No     |

---

# 5. Core Structural Differences

| Feature | KD-tree | BVH | R-tree |
|---------|---------|-----|--------|
| Tree Type | Binary | Binary | Multi-branch |
| Split Method | Space partition | Object grouping | Object grouping |
| Best For | Points | Mesh / Rays | Bounding boxes |
| Dynamic Scene | Weak | Moderate | Strong |
| GPU | Rare | Standard | Rare |
| Optical Usage | Photon | Ray tracing | CAD indexing |

---

# 6. Engineering Perspective (HPC View)

Performance depends on:

- Memory locality
- Cache alignment
- Branch prediction
- SIMD friendliness
- Linear memory layout

Example optimized BVH layout:

struct BVHNode {
    float bounds[6];
    int left_first;
    int count;
}

Stored as flat array (not pointer tree).

Cache-optimal.
Traversal-friendly.
GPU-friendly.

---

# 7. Choosing Structure for Optical Systems

Monte Carlo tolerance
→ KD-tree (point search)

Stray light ray tracing
→ BVH

CAD collision / OCCT modeling
→ R-tree

---

# 8. One-Line Summary

KD-tree  = Split Space  
BVH      = Wrap Objects  
R-tree   = Spatial Database Index  

---

# 9. Complexity Summary

Naive:
O(N_ray × N_obj)

With Acceleration:
O(N_ray log N_obj)

True performance bottleneck:
Memory bandwidth > Floating point cost

---

# 10. Practical Insight

Modern CPUs:

Compute throughput >> Memory bandwidth

Thus:

Cache behavior and memory layout dominate performance.

Not raw FLOPS.

---

# End
