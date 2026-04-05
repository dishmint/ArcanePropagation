# Convolve Flame Effect — Findings

## The Effect

The convolve filter in p4_ArcanePropagation_Shader produces a flickering, almost physical flame-like behavior. The same algorithm in later projects (p4_ArcaneShader) produces stable, boring output that quickly fades to black.

## Root Cause: Static vs Dynamic Kernel Weights

The flame effect depends on three factors working together:

### 1. Static kernel map (most important)

In p4_ArcanePropagation_Shader, `xmg` is computed **once in setup()** from the original image and never updated:

```java
// setup()
xmg = loadxm(simg, kwidth);
```

Each frame, the same frozen kernel weights are applied to an evolving image. This means the kernel retains memory of the original image's structure — bright regions always push energy outward, dark regions always pull inward, regardless of what the current frame looks like. This sustained asymmetry drives the oscillation.

In the GPU shader (convolve.glsl), kernel weights are **recomputed every frame** from the current pixel values via `computeGS(sampleColor.rgb)`. As the image darkens, the kernel weights shrink toward zero, creating a positive feedback loop toward black: darker image → weaker kernel → less energy transfer → darker → black.

### 2. Zero-initialized totals

The old convolve initializes accumulators at zero:

```java
float rtotal = 0.0;  // old project
```

The newer ArcaneFilter convolve seeds them with the current pixel value:

```java
float rtotal = rspx;  // newer project
```

Starting from zero makes the output a pure differential signal (neighbors minus center). With the static kernel driving sustained energy, this oscillates above and below zero on alternating frames — producing flicker. Seeding with the current pixel value anchors the output and dampens oscillation.

### 3. Large kernel scale

The old project uses `scalefac = 255/25 = 10.2`, mapping grayscale to the range [-10.2, +10.2] in `loadkernel()`. The newer project defaults to `kernelScale = 1.0`, mapping to [-1.0, +1.0]. The ~10x amplification is needed to make the oscillation visible.

## Why increasing kernelScale alone doesn't reproduce the effect

Cranking up `kernelScale` in the GPU shader amplifies the differential signal but also amplifies the feedback-toward-black problem. Without a static kernel anchoring the energy flow to the original image structure, the stronger signal just accelerates the fade to black.

## How to reproduce the flame effect on GPU

The GPU shader would need access to the original image as a separate texture for computing kernel weights, while still reading/writing the evolving frame for the convolution itself. This decouples the kernel computation from the feedback loop, matching the old project's static kernel behavior.
