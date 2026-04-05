# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ArcanePropagation is a Processing 4 creative coding project exploring pixel diffusion algorithms. Pixel values are filtered (diffused) across images, then rendered as points/lines rotating around pixel origins at angles determined by pixel energy values. The output feeds back as input, creating evolving visual patterns.

Core algorithm loop: Load Image → Filter → Render (point orbit) → Feed back → Repeat

## Running

Processing sketches are run via the Processing IDE or CLI:
```
processing-java --sketch=/path/to/p4_ArcaneShader --run
```

No external build system (no Maven/Gradle). GLSL shaders live in each sketch's `data/` directory.

## Sketch Variants

- **p4_ArcaneShader** — Latest and most advanced. GPU-accelerated via GLSL shaders. Active development on `dev/refactor/dishmint/ArcaneGPU`.
- **p4_ArcanePropagator** — Most complete CPU-based implementation. Reference version.
- **p4_ArcanePropagatorGUI** — Interactive GUI version with controls.
- **p4_ArcanePropagation_PointOrbit** — Point orbit visualization variant.
- **p4_ArcanePropagation_Shader** — Earlier shader experiment.
- **max8_ArcaneViewer** — Max/MSP integration for audio-visual use.

## Architecture (p4_ArcaneShader — primary sketch)

Each `.pde` file in a Processing sketch shares one namespace. The main entry point is always `[SketchName].pde` (contains `setup()` and `draw()`).

Key classes:
- **ArcaneSettings** — Centralized config: kernel width/scale, downsample factor, filter selection (22 filters), theme (14 themes), generator mode, framerate. All params are index-based with setter methods that call `updateComputedValues()`.
- **ArcaneGPUFilter** — Manages GLSL shader loading and application. Uses HashMap to map filter names to PShader objects. Maintains working/temp/previous frame buffers.
- **ArcaneFilter** — CPU-based filter implementations using `@FunctionalInterface` lambdas (`ArcaneProcess`). Fallback when GPU filters aren't available.
- **ArcaneGenerator** — Image source generation (modes: random, noise, kufic, maze) or loads from `data/imgs/`.

Functional interfaces used throughout:
- `ArcaneProcess` — `void filter(int x, int y, PImage img, float[][][] xmg)`
- `ArcaneImager` — `PImage generator()`
- `ArcaneHue` — `color archue(float thetafactor)`

## Architecture (p4_ArcanePropagator — CPU reference)

- **ArcanePropagator** — Main orchestrator combining filter + render + generator via Consumer/Supplier patterns.
- **ArcaneRender** — Manages PGraphics buffers, applies `blueline.glsl` shader for point orbit rendering.
- **ArcaneFilter** / **ArcaneGenerator** — Same role as in ArcaneShader.

## Filters and Shaders

22 filters available, each with a matching `.glsl` file in `data/`:
- Diffusion: `transmit`, `transmitMBL`, `convolve`, `blur`, `weightedblur`
- Reaction-diffusion: `rdf`, `rdft`, `rdfx`, `rdfr`, `rdfm`
- Cellular: `conway`, `collatz`, `xcollatz`, `xtcollatz`
- Morphological: `dilate`, `xdilate`, `xsdilate`
- Other: `amble`, `smear`, `smearTotal`, `chladni`, `still` (passthrough)

The render shader `blueline.glsl` handles the point orbit visualization.

## Key Patterns

- All configurable parameters in ArcaneSettings use parallel arrays: an options array and an index into it. Change settings via `setX(index)` methods — never set fields directly.
- Kernel maps are 3D float arrays (`float[][][]`) representing per-pixel convolution neighborhoods.
- The `data/imgs/` directory (gitignored) holds source images referenced by index in ArcaneSettings.
