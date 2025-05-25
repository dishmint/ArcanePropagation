#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform sampler2D prevFrame;    // Previous frame texture
uniform vec2 resolution;        // Image resolution
uniform float smearStrength;    // Smear intensity
uniform vec2 smearDirection;    // Direction of smear
uniform float time;             // Time for animation

varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;
    
    vec4 current = texture2D(tex0, uv);
    
    // Sample in smear direction
    vec2 smearUV = uv + smearDirection * texelSize * smearStrength;
    smearUV = clamp(smearUV, vec2(0.0), vec2(1.0));
    
    vec4 smeared = texture2D(tex0, smearUV);
    
    // Sample previous frame for temporal persistence
    vec4 previous = texture2D(prevFrame, uv);
    
    // Combine current, smeared, and previous
    vec3 result = mix(current.rgb, smeared.rgb, 0.3);
    result = mix(result, previous.rgb, 0.1);
    
    // Add some noise based on position for organic feel
    float noise = sin(uv.x * 100.0 + time) * sin(uv.y * 100.0 + time) * 0.01;
    result += vec3(noise);
    
    gl_FragColor = vec4(result, current.a);
}