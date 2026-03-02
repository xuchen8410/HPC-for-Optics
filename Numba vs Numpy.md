# Numba 的执行方式（关键差异）
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
----
NumPy = Memory bound
CPU 等内存。
----
Current CPU：算力 >> 内存带宽

 少访问内存 = 巨大加速
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
= 多次扫数组。

Numba：一次扫描完成全部计算



