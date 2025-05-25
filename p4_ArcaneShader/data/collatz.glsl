#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float time;             // Time for animation
uniform int iterations;         // Number of Collatz iterations

varying vec4 vertTexCoord;

// Collatz conjecture function
int collatzStep(int n) {
    if(n % 2 == 0) {
        return n / 2;
    } else {
        return 3 * n + 1;
    }
}

// Convert color to seed value for Collatz
int colorToSeed(vec3 color) {
    return int(color.r * 255.0) + int(color.g * 255.0) + int(color.b * 255.0) + 1;
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec4 currentPixel = texture2D(tex0, uv);
    
    // Get seed from current pixel
    int seed = colorToSeed(currentPixel.rgb);
    
    // Apply Collatz iterations
    int value = seed;
    for(int i = 0; i < 100; i++) {
        if(i >= iterations) break;
        value = collatzStep(value);
        if(value == 1) break;
    }
    
    // Convert result back to color
    float intensity = float(value) / 255.0;
    vec3 result = vec3(intensity, intensity * 0.8, intensity * 0.6);
    
    // Mix with original for smoother transition
    result = mix(currentPixel.rgb, result, 0.1);
    
    gl_FragColor = vec4(result, currentPixel.a);
}