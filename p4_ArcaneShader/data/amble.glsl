#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float ambleStrength;    // Strength of amble effect
uniform float time;             // Time for animation
uniform vec2 ambleDirection;    // Direction of amble movement
uniform float noiseScale;       // Scale of noise pattern

varying vec4 vertTexCoord;

// Simple noise function
float noise(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// 2D noise
float noise2D(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
    vec2 uv = vertTexCoord.st;
    
    // Generate noise-based displacement
    vec2 noisePos = uv * noiseScale + time * 0.1;
    float noiseX = noise2D(noisePos) - 0.5;
    float noiseY = noise2D(noisePos + vec2(100.0, 100.0)) - 0.5;
    
    // Create ambling movement
    vec2 displacement = vec2(noiseX, noiseY) * ambleStrength;
    displacement += ambleDirection * sin(time + uv.x * 10.0) * 0.01;
    
    // Sample from displaced position
    vec2 sampleUV = uv + displacement / resolution;
    sampleUV = clamp(sampleUV, vec2(0.0), vec2(1.0));
    
    vec4 displaced = texture2D(tex0, sampleUV);
    vec4 original = texture2D(tex0, uv);
    
    // Mix original and displaced for smooth ambling effect
    vec3 result = mix(original.rgb, displaced.rgb, 0.7);
    
    // Add subtle color shifting based on displacement
    result.r += noiseX * 0.05;
    result.g += noiseY * 0.05;
    result.b += (noiseX + noiseY) * 0.025;
    
    gl_FragColor = vec4(result, original.a);
}