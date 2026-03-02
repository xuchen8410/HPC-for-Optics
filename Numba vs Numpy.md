## 两者差别 Numba vs NumPy: Execution & Memory Model in HPC
- NumPy temp arrays： RAM ←→ CPU ←→ RAM ←→ CPU
- Numba：RAM → cache → 连续算 → RAM

The real difference is: Memory traffic + loop fusion + native compilation

### 1. Execution Model Difference
- NumPy (Vectorized Style) Numpy 的执行方式
NumPy = Memory bound
CPU 等内存: c = a * b + d * e
Under the hood this becomes:
temp1 = a * b
temp2 = d * e
c = temp1 + temp2
 What Happens when Multiple full-array passes -- Temporary arrays allocated -- Repeated memory reads/writes -- Execution becomes memory-bound
Even though it looks “vectorized”, it still performs separate passes over memory.

- Numba (JIT Compiled Loop Fusion)
  from numba import njit

 @njit
def kernel(a, b, d, e, c):
    for i in range(len(a)):
        c[i] = a[i] * b[i] + d[i] * e[i]
What LLVM Sees

A single fused loop:
load a[i]
load b[i]
load d[i]
load e[i]
compute
store c[i]

1. 完全不允许 Python 解释器参与:  from numba import njit ------ Entire loop compiled to native machine code, Python interpreter completely bypassed
2. 并行计算: 没有 temp array！：直接 Loop Fusion（循环融合）=compute boud, CPU is continuing computationcache-friendly memory access ---Often compute-bound instead of memory-bound
自动：多核 CPU； OpenMP-like 分块； SIMD vectorization -- Monte Carlo / FDTD / ray loop 巨快。
from numba import prange
@njit(parallel=True)
def f(N):
    for i in prange(N):

### 2. Parallel Execution (Multi-Core + SIMD)
from numba import njit, prange

@njit(parallel=True)
def f(N):
    for i in prange(N):
        ...
What Happens Internally

Multi-core CPU parallelization

OpenMP-style chunk partitioning

Automatic thread scheduling

SIMD vectorization (AVX2 / AVX-512 when available)

No GIL limitation

Ideal Workloads

Monte Carlo simulations

STOP tolerance analysis

FDTD time stepping

Ray tracing loops

Parameter sweeps

### 3. Memory Model: The Real Bottleneck

Modern CPUs:

Compute throughput  >>  Memory bandwidth

Meaning:

CPU often waits on RAM rather than computing.

NumPy = Memory-Bound Pattern

For:

c = a * b + d * e

Memory flow:

Pass 1: read a, b → write temp1
Pass 2: read d, e → write temp2
Pass 3: read temp1, temp2 → write c

Multiple full-array scans.

Memory dominates runtime.

Numba = Single-Pass Pattern
RAM → L1 cache → continuous compute → write once

Only one memory traversal.

Minimal memory traffic.

### 4. Hardware-Level Explanation
Component	Approx Latency
L1 Cache	~1 ns
L2 Cache	~4 ns
L3 Cache	~10–20 ns
RAM	~80–120 ns

RAM access is roughly 100× slower than L1 cache.

NumPy with Temporary Arrays
RAM ↔ CPU ↔ RAM ↔ CPU ↔ RAM

Constant memory movement.

Numba Fused Loop
RAM → Cache → Continuous compute → RAM

Maximizes cache reuse.

Minimizes memory latency penalties.

### 5. Example: STOP Monte Carlo Kernel

Typical STOP inner loop:

for sample in range(N):
    thermal_expansion()
    tilt_solve()
    wavefront_update()
Characteristics

Small arithmetic per iteration

Large number of iterations

Heavy repetition

Memory-sensitive

NumPy Style
vector op
vector op
vector op

Each step scans the full array.

Memory-bound.

Numba Style
for sample:
    thermal expansion
    tilt solve
    wavefront update

Single fused loop:

One memory pass

Cache reuse

No temporaries

Dramatic speed improvement

### 6. Why This Matters in Optical HPC

In optical-mechanical simulations:

Tolerance Monte Carlo

Structural deformation propagation

Wavefront accumulation

Stray light ray tracing

STOP system modeling

Workloads are:

Arithmetic-light

Loop-heavy

Memory-sensitive

Performance depends more on:

Memory locality

Cache behavior

Loop fusion

than on raw floating-point count.

### 7.  Summary Comparison


| Aspect        | NumPy                    | Numba                    |
| ------------- | ------------------------ | ------------------------ |
| Execution     | Interpreter + vector ops | Native LLVM machine code |
| Temp Arrays   | Yes                      | No                       |
| Memory Passes | Multiple                 | Single                   |
| Loop Fusion   | No                       | Yes                      |
| Parallelism   | Limited                  | Multi-core + SIMD        |
| Typical Bound | Memory-bound             | Often compute-bound      |
| Best Use Case | Linear algebra           | Custom HPC kernels       |

### 8. example
Numba：一次扫描完成全部计算
从硬件层解释（真正核心）
CPU：
L1 cache  ~1ns
RAM       ~100ns
差 100×
 Numba accelerates optical HPC kernels because it:
-Eliminates temporary arrays
-Fuses loops
-Maximizes cache locality
-Enables SIMD
-Scales across cores
This is why Monte Carlo, STOP, FDTD, and ray loops can become dramatically faster.Current CPU：算力 >> 内存带宽
 少访问内存 = 巨大加速
