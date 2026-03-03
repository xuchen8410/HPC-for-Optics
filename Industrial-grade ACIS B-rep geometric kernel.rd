# Stray Light Analysis 
## Tools, Limitations, and Expansion Strategy

### 1. Why Stray Light Is Critical

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


### 2. A space-grade stray platform must include:

1. BVH acceleration (cache-optimized)
2. Advanced BRDF (wavelength dependent)
3. Radiometric integration (Planck + QE)
4. Monte Carlo importance sampling
5. STOP deformation coupling
6. Multi-bounce scatter control

Stray must be:

Structural → Thermal → Optical → Radiometric coupled
