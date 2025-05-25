#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float frequency1;       // First frequency component
uniform float frequency2;       // Second frequency component
uniform float amplitude;        // Wave amplitude
uniform float time;             // Time for animation
uniform vec2 nodeOffset;        // Offset for node positions

varying vec4 vertTexCoord;

// Generate Chladni pattern based on standing wave interference
float chladniPattern(vec2 pos, float freq1, float freq2, float t) {
    float x = pos.x * 2.0 - 1.0;  // Normalize to [-1, 1]
    float y = pos.y * 2.0 - 1.0;
    
    // Standing wave equations for Chladni patterns
    float wave1 = sin(freq1 * x + t) * sin(freq1 * y + t);
    float wave2 = sin(freq2 * x + t * 0.7) * sin(freq2 * y + t * 0.7);
    
    // Combine waves with different phases
    float pattern = wave1 + wave2 * 0.8;
    
    // Create nodes (zero points) where particles would accumulate
    return abs(pattern);
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec4 currentPixel = texture2D(tex0, uv);
    
    // Generate Chladni pattern
    vec2 adjustedUV = uv + nodeOffset;
    float pattern = chladniPattern(adjustedUV, frequency1, frequency2, time);
    
    // Create sharp node lines
    float nodeStrength = 1.0 - smoothstep(0.0, 0.1, pattern);
    
    // Apply pattern to image
    vec3 chladniColor = vec3(nodeStrength);
    vec3 result = mix(currentPixel.rgb, chladniColor, amplitude);
    
    // Add some interference based on original image brightness
    float brightness = dot(currentPixel.rgb, vec3(0.299, 0.587, 0.114));
    result += vec3(brightness * nodeStrength * 0.2);
    
    gl_FragColor = vec4(result, currentPixel.a);
}