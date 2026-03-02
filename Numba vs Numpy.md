## Numba 的执行方式
Numba 编译整个 loop：
@njit
for i:
    c[i] = a[i]*b[i] + d[i]*e[i]
LLVM 看到的是：
single fused kernel
生成：
load a[i]
load b[i]
load d[i]
load e[i]
compute
store c[i]
 
没有 temp array！：直接 Loop Fusion（循环融合）=compute boud, CPU is continuing computation
1. 完全不允许 Python 解释器参与:  from numba import njit
2. 并行计算
自动：多核 CPU； OpenMP-like 分块； SIMD vectorization -- Monte Carlo / FDTD / ray loop 巨快。
from numba import prange
@njit(parallel=True)
def f(N):
    for i in prange(N):
        ...

## Numpy 的执行方式
NumPy = Memory bound
CPU 等内存。

# 两者差别
NumPy temp arrays： RAM ←→ CPU ←→ RAM ←→ CPU
Numba：RAM → cache → 连续算 → RAM

Numba：一次扫描完成全部计算
从硬件层解释（真正核心）
CPU：
L1 cache  ~1ns
RAM       ~100ns
差 100×

Current CPU：算力 >> 内存带宽
 少访问内存 = 巨大加速
 Numba accelerates optical HPC kernels because it:
-Eliminates temporary arrays
-Fuses loops
-Maximizes cache locality
-Enables SIMD
-Scales across cores
This is why Monte Carlo, STOP, FDTD, and ray loops can become dramatically faster.

 ----
Example: STOP kernel：
for sample:
    thermal expansion
    tilt solve
    wavefront update
特点：
每步计算量小
数据量巨大
重复 N 次

NumPy方式：
vector op
vector op
vector op
= 多次扫数组

