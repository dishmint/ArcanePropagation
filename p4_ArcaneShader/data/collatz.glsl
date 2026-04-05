#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution

varying vec4 vertTexCoord;

// Per-channel Collatz step: even -> half, odd -> 3x+1
// Operates in [0,255] space to match CPU behavior
float collatzChannel(float val) {
    float v = val * 255.0;
    // GLSL ES lacks bitwise AND; use mod for even/odd test
    if(mod(floor(v), 2.0) < 1.0) {
        // even
        return (v * 0.5) / 255.0;
    } else {
        // odd
        return (3.0 * v + 1.0) / 255.0;
    }
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec4 currentPixel = texture2D(tex0, uv);

    vec3 result;
    result.r = collatzChannel(currentPixel.r);
    result.g = collatzChannel(currentPixel.g);
    result.b = collatzChannel(currentPixel.b);

    gl_FragColor = vec4(result, currentPixel.a);
}
