#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float dA;               // Diffusion rate A
uniform float dB;               // Diffusion rate B
uniform float fr;               // Feed rate
uniform float kr;               // Kill rate
uniform float dt;               // Time step

varying vec4 vertTexCoord;

// Laplacian kernel for diffusion
vec3 laplacian(sampler2D tex, vec2 uv, vec2 texelSize) {
    vec3 center = texture2D(tex, uv).rgb;
    vec3 sum = vec3(0.0);
    
    // 3x3 Laplacian kernel
    sum += texture2D(tex, uv + vec2(-1.0, -1.0) * texelSize).rgb * 0.05;
    sum += texture2D(tex, uv + vec2( 0.0, -1.0) * texelSize).rgb * 0.2;
    sum += texture2D(tex, uv + vec2( 1.0, -1.0) * texelSize).rgb * 0.05;
    sum += texture2D(tex, uv + vec2(-1.0,  0.0) * texelSize).rgb * 0.2;
    sum += center * -1.0;
    sum += texture2D(tex, uv + vec2( 1.0,  0.0) * texelSize).rgb * 0.2;
    sum += texture2D(tex, uv + vec2(-1.0,  1.0) * texelSize).rgb * 0.05;
    sum += texture2D(tex, uv + vec2( 0.0,  1.0) * texelSize).rgb * 0.2;
    sum += texture2D(tex, uv + vec2( 1.0,  1.0) * texelSize).rgb * 0.05;
    
    return sum;
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;
    
    vec3 current = texture2D(tex0, uv).rgb;
    vec3 lap = laplacian(tex0, uv, texelSize);
    
    float a = current.r;
    float b = current.g;
    
    // Gray-Scott reaction-diffusion equations
    float newA = a + (dA * lap.r - a * b * b + fr * (1.0 - a)) * dt;
    float newB = b + (dB * lap.g + a * b * b - (kr + fr) * b) * dt;
    
    gl_FragColor = vec4(newA, newB, current.b, 1.0);
}