# GPU-Accelerated Filter System

This system provides GPU-accelerated versions of the ArcaneShader filters using OpenGL fragment shaders for massive performance improvements.

## Overview

The GPU filter system uses ping-pong framebuffers to process images in real-time on the graphics card, providing significant performance boosts over CPU-based processing.

## Usage

### Basic Setup
```java
// Toggle GPU filtering (default: enabled)
boolean useGPUFilter = true;
```

### Keyboard Controls
- `G` - Toggle between GPU and CPU filtering modes
- `S` - Show available shaders

### Available GPU Filters

#### Fully Implemented
- **transmit** - Core transmission algorithm with kernel-based processing
- **rdf/rdft/rdfx/rdfr/rdfm** - Reaction-diffusion systems (Gray-Scott equations)
- **weightedblur** - Kernel-weighted blur effects
- **blur** - Gaussian blur
- **dilate/xdilate/xsdilate** - Morphological dilation operations
- **amble** - Noise-based displacement effects

#### Experimental/Stubs
- **collatz/xcollatz/xtcollatz** - Collatz conjecture-based transformations
- **smear/smearTotal** - Temporal smearing effects (requires previous frame)
- **chladni** - Standing wave interference patterns
- **conway** - Conway's Game of Life cellular automaton

#### Passthrough
- **still** - No processing (identity)
- **convolve** - Basic convolution (currently passthrough)
- **transmitMBL** - Alternative transmission mode

## Technical Details

### Architecture
- **ArcaneGPUFilter.pde** - Main GPU filter class
- **data/*.glsl** - Fragment shader implementations
- Ping-pong rendering between two PGraphics buffers
- Automatic fallback to CPU processing for unsupported filters

### Shader Uniforms
Common uniforms passed to all shaders:
- `tex0` - Source texture
- `resolution` - Texture dimensions
- `time` - Animation time

Filter-specific uniforms are set based on ArcaneSettings configuration.

### Performance Benefits
- **Parallel Processing** - GPU processes many pixels simultaneously
- **Memory Efficiency** - No CPU-GPU memory transfers per frame
- **Optimized Operations** - Hardware-accelerated texture sampling and math

### Fallback System
If a GPU shader is not available:
1. Attempts to use passthrough shader
2. Falls back to original CPU processing
3. Logs warnings for missing shaders

## Shader Development

### Creating New Shaders
1. Create `.glsl` file in `data/` folder
2. Add shader name to `loadShaders()` array in ArcaneGPUFilter
3. Add uniform setup in `setFilterSpecificUniforms()`

### Shader Template
```glsl
#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;
uniform vec2 resolution;
// Add filter-specific uniforms

varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.st;
    vec4 currentPixel = texture2D(tex0, uv);
    
    // Filter processing here
    
    gl_FragColor = vec4(result, currentPixel.a);
}
```

## Future Improvements

1. **Multi-pass Effects** - Complex filters requiring multiple rendering passes
2. **Compute Shaders** - For more advanced parallel algorithms (Processing 4+ only)
3. **Texture Arrays** - For storing kernel data as textures
4. **Dynamic Shader Compilation** - Runtime shader generation based on settings
5. **Performance Profiling** - GPU timing and optimization metrics

## Troubleshooting

### Common Issues
- **Shader Compilation Errors** - Check console for GLSL syntax errors
- **Performance Drops** - Some filters may be computationally intensive
- **Visual Artifacts** - Ensure proper texture clamping and bounds checking

### Debug Information
Enable debug output to see:
- Which shaders loaded successfully
- Fallback usage notifications
- Performance mode switching