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
