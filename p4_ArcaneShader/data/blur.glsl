#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float blurRadius;       // Blur radius
uniform int blurSamples;        // Number of blur samples

varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;
    
    vec3 result = vec3(0.0);
    float totalWeight = 0.0;
    
    int radius = int(blurRadius);
    radius = min(radius, 4); // Limit for performance
    
    // Gaussian-style blur
    for(int x = -radius; x <= radius; x++) {
        for(int y = -radius; y <= radius; y++) {
            vec2 sampleUV = uv + vec2(float(x), float(y)) * texelSize;
            sampleUV = clamp(sampleUV, vec2(0.0), vec2(1.0));
            
            vec4 sample = texture2D(tex0, sampleUV);
            
            // Gaussian weight based on distance from center
            float distance = length(vec2(float(x), float(y)));
            float weight = exp(-distance * distance / (2.0 * blurRadius * blurRadius));
            
            result += sample.rgb * weight;
            totalWeight += weight;
        }
    }
    
    if(totalWeight > 0.0) {
        result /= totalWeight;
    }
    
    gl_FragColor = vec4(result, texture2D(tex0, uv).a);
}