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

- 1. Industrial-grade ACIS B-rep geometric kernel
- 2. BVH acceleration (cache-optimized)
- 3. Advanced BRDF (wavelength dependent)
- 4. Radiometric integration (Planck + QE)
- 5. Monte Carlo importance sampling
- 6. STOP deformation coupling
- 7. Multi-bounce scatter control

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



# P.S.
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
### 军工级要求
- 1. 必须支持的能力
✔ 大规模几何 - 1e6 – 1e7 三角面； 大型挡光罩； 复杂支撑结构； 多层 baffle； 太阳挡板
✔ 多次散射路径； 不仅是 1 次反射。
- 2. 空间系统常见：3–8 次 bounce； 微弱路径贡献 1e-6 量级 -仍必须统计
- 3. BVH traversal 必须支持深递归且不爆栈
- 4. 高动态范围： 太阳入射 10^6–10^9 动态范围； BVH + Monte Carlo 必须避免：数值 underflow； 精度丢失； 路径剪枝错误
- 5. 精确控制 traversal 次序： 军工系统中，需要 deterministic seed，可重复 ray path，可 debug 单路径
- 6. 可与变形几何动态更新： STOP 后，镜面变形，baffle 位置变化，探测器偏移
BVH 需要：局部 refit，或快速 rebuild， 而不是完全重建
### 辐射度积分系统
#### 架构形态：
#### 4.1 Geometry Layer
CAD → 三角网格； BVH 构建-Linear BVH（LBVH）或 SAH 构建；AABB hierarchy； Cache 对齐；内存布局必须：struct-of-arrays，而非 pointer tree
#### 4.2 Monte Carlo Layer
- 每条 ray 携带：能量权重，波长， 偏振（可选）， bounce 计数， 路径更新：
- W_new = W_old × BRDF × cosθ × reflectivity
- 不是简单 hit 统计。
#### 4.3 Radiometric Integration
- 在 detector 面积分：
 L = ∑ (W_i × QE(λ_i))
- 单位必须一致：
W / sr / m²
或 W/m²
- 军工系统必须：从光线 → 辐射单位闭环。
#### 4.4 与 STOP 深度耦合
- 商业软件真正弱的地方。
- STOP 耦合需要：
##### 4.4.1 几何动态变形
- FEA 节点位移，Zernike surface map，热梯度变形必须更新 mesh 或 analytic surface。
- BVH 需要：快速 refit或 GPU rebuild
- 变形引起 stray path 改变 -例子：镜面 10 µrad tilt，可能打开太阳直通路径，这不是线性误差问题，Monte Carlo 必须重新统计路径分布。
- 抖动与时间平均： Jitter 模型 - 小角随机，时间积分
- BVH traversal 需支持大量重复批次。
### GPU 规模并行的现实意义
- CPU：内存带宽瓶颈，分支发散严重
- GPU：Massive parallel traversal，高 ray throughput，批量 Monte Carlo
- 关键：BVH 必须无递归；栈less traversal；Warp-friendly，否则 GPU 效率崩溃。

### Diagram

```text
┌────────────────────────────┐
│       Scenario     │
│   Sun, Earth, Background   │
└──────────────┬─────────────┘
               │
               ▼
┌────────────────────────────────────────────────────────────┐
│                    Monte Carlo Engine                      │
│  Importance Sampling | Multi-Bounce | Russian Roulette     │
│  Deterministic Seeds | Confidence Estimation               │
└───────────────┬───────────────────────────────┬────────────┘
                │                               │
                ▼                               ▼
        ┌──────────────────┐            ┌────────────────────┐
        │   BVH Traversal  │            │  Radiometric Engine │
        │   (GPU / CPU)    │            │  Spectral + Planck  │
        │   Stackless      │            │  Detector QE        │
        └─────────┬────────┘            └──────────┬─────────┘
                  │                                  │
                  ▼                                  ▼
        ┌────────────────────┐            ┌────────────────────┐
        │   Geometry Layer   │            │   Detector Model   │
        │   Mesh + BVH Build │            │   Pixel Integration│
        │   Refit / Rebuild  │            │   SNR Estimation   │
        └─────────┬──────────┘            └──────────┬─────────┘
                  │
                  ▼
        ┌────────────────────┐
        │    STOP Coupling   │
        │    FEA Deformation │
        │    Thermal Gradient│
        │    Jitter Model    │
        └────────────────────┘
```  ···


··· 

