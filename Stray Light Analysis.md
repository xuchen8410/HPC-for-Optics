# Stray Light Analysis 
## Tools, Limitations, and Expansion Strategy

## 1. Why Stray Light Is Critical

In  reflective systems (TMA, Korsch, IR payloads),  
stray light often limits radiometric performance more than nominal wavefront error.

Primary drivers:

- Solar intrusion
- Earth limb scatter
- Internal baffle multiple reflections
- Surface microroughness (BRDF)
- Thermal emission (MWIR/LWIR)
- Ghost reflections

Stray light = Radiometric stability problem  
Not just ray tracing.

## 2. A space-grade stray platform must include:

1. BVH acceleration (cache-optimized)
2. Advanced BRDF (wavelength dependent)
3. Radiometric integration (Planck + QE)
4. Monte Carlo importance sampling
5. STOP deformation coupling
6. Multi-bounce scatter control

### Stray must be: Structural → Thermal → Optical → Radiometric coupled

## 3. 总结 Industrial-grade ACIS B-rep geometric kernel

杂散光分析离不开几何内核（Geometry Kernel）。

主流几何内核：

### 3.1 OpenCASCADE (OCCT)
- 开源
- 广泛用于CAD系统
- B-Rep支持
- R-tree空间索引
- 适合工程几何处理

优点：
- 可控
- 可二次开发
- 易集成自动流程

缺点：
- 曲面细分质量依赖网格策略
- 非专为高速光线追迹设计

### 3.2 Parasolid（Siemens）
- 商业内核
- SolidWorks / NX使用
- 工业成熟度高

优点：
- 几何稳定性强
- CAD质量高

缺点：
- 授权昂贵
- 不直接面向光学追迹

### 3.3 ACIS
- 商业内核
- 广泛用于工程CAD

特点与Parasolid类似。


### 3.4  Ray Engine 自有几何内核

GPU引擎通常：

- 使用三角网格
- BVH加速
- 不直接使用CAD B-Rep

优点：
- 高速
- 易并行
- 可极端扩展

缺点：
- 几何精度依赖网格
- 与CAD存在转换误差



P.S.:  
### 从工程架构角度，一个杂散光平台应包含五个核心层级：
- 第一，几何层。
需要从 CAD 内核（如 OpenCASCADE、Parasolid）导入 B-Rep 模型，并进行高质量网格化，然后构建 BVH 加速结构。
BVH 是目前工业界最现实的选择，因为它对大规模三角面片最友好，也最适合 GPU 扩展。
- 第二，散射物理层。
支持 ABg 模型、实测 BSDF 表、光谱反射率，并允许多次反射路径传播。
- 第三，辐射度层。
不仅统计 ray 数，而是进行光谱积分，结合 Planck 热辐射模型以及探测器 QE，输出真实辐射单位。
- 第四，Monte Carlo 引擎。
含重要性采样、Russian roulette、多 bounce 控制，以及置信区间统计。这是保证工程可信度的关键。
- 第五，STOP 耦合层。
结构变形、热梯度、刚体偏心、抖动必须参与杂散路径计算。
真正的空间系统不能只分析 nominal geometry。

### 性能上，杂散光是一个内存受限问题，不是算力受限问题。

关键在于：BVH 的线性布局; cache 局部性; SIMD 向量化; GPU traversal; 分支发散控制; 现代 CPU 算力远大于内存带宽，因此数据布局比算法复杂度更关键
