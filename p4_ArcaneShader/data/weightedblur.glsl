#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float kernelScale;      // Kernel scaling factor
uniform int kernelWidth;        // Kernel width
uniform float blurStrength;     // Blur intensity

varying vec4 vertTexCoord;

float computeGS(vec3 color) {
    return dot(color, vec3(0.2989, 0.5870, 0.1140));
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;
    
    vec3 result = vec3(0.0);
    float totalWeight = 0.0;
    
    int offset = kernelWidth / 2;
    
    for(int k = 0; k < 8; k++) {
        if(k >= kernelWidth) break;
        for(int l = 0; l < 8; l++) {
            if(l >= kernelWidth) break;
            
            vec2 sampleOffset = vec2(float(k - offset), float(l - offset));
            vec2 sampleUV = uv + sampleOffset * texelSize;
            sampleUV = clamp(sampleUV, vec2(0.0), vec2(1.0));
            
            vec4 sampleColor = texture2D(tex0, sampleUV);
            float gs = computeGS(sampleColor.rgb);
            
            // Use grayscale as weight
            float weight = gs * kernelScale;
            
            result += sampleColor.rgb * weight;
            totalWeight += weight;
        }
    }
    
    if(totalWeight > 0.0) {
        result /= totalWeight;
    }
    
    vec4 original = texture2D(tex0, uv);
    result = mix(original.rgb, result, blurStrength);
    
    gl_FragColor = vec4(result, original.a);
}