#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float dilateRadius;     // Dilation radius
uniform float threshold;        // Brightness threshold for dilation
uniform int kernelSize;         // Size of dilation kernel

varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;
    
    vec4 currentPixel = texture2D(tex0, uv);
    vec3 maxColor = currentPixel.rgb;
    
    int radius = int(dilateRadius);
    radius = min(radius, kernelSize / 2);
    
    // Find maximum value in neighborhood (morphological dilation)
    for(int x = -radius; x <= radius; x++) {
        for(int y = -radius; y <= radius; y++) {
            vec2 sampleUV = uv + vec2(float(x), float(y)) * texelSize;
            sampleUV = clamp(sampleUV, vec2(0.0), vec2(1.0));
            
            vec4 sample = texture2D(tex0, sampleUV);
            
            // Check if sample is brighter than threshold
            float brightness = dot(sample.rgb, vec3(0.299, 0.587, 0.114));
            if(brightness > threshold) {
                maxColor = max(maxColor, sample.rgb);
            }
        }
    }
    
    // Apply dilation effect
    vec3 result = mix(currentPixel.rgb, maxColor, 0.8);
    
    gl_FragColor = vec4(result, currentPixel.a);
}