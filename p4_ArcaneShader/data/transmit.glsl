#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float kernelScale;      // Kernel scaling factor
uniform float transmissionfactor; // Transmission factor
uniform int kernelWidth;        // Kernel width (3, 5, 7, etc.)
uniform float colordiv;         // Color division factor
uniform bool hav;               // Human vs average grayscale

varying vec4 vertTexCoord;

float computeGS(vec3 color) {
    // Convert to 0-255 range like CPU version
    vec3 colorBytes = color * 255.0;
    
    if(hav) {
        // Human grayscale - exact match to CPU
        return (0.2989 * colorBytes.r + 0.5870 * colorBytes.g + 0.1140 * colorBytes.b) * colordiv;
    } else {
        // Channel average - exact match to CPU
        return (colorBytes.r + colorBytes.g + colorBytes.b) * colordiv;
    }
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec4 currentPixel = texture2D(tex0, uv);
    
    // Start with current pixel values in 0-255 range like CPU
    float rpx = currentPixel.r * 255.0;
    float gpx = currentPixel.g * 255.0;
    float bpx = currentPixel.b * 255.0;
    
    vec2 texelSize = 1.0 / resolution;
    int offset = kernelWidth / 2;
    
    for(int k = 0; k < 8; k++) {
        if(k >= kernelWidth) break;
        for(int l = 0; l < 8; l++) {
            if(l >= kernelWidth) break;
            
            // Calculate sample offset in texel space
            vec2 sampleOffset = vec2(float(k - offset), float(l - offset));
            vec2 sampleUV = uv + sampleOffset * texelSize;
            
            // Clamp to texture bounds
            sampleUV = clamp(sampleUV, vec2(0.0), vec2(1.0));
            
            // Sample the neighbor pixel
            vec4 sampleColor = texture2D(tex0, sampleUV);
            float gs = computeGS(sampleColor.rgb);
            
            // Compute kernel weight exactly like CPU loadkernel
            float kernelWeight = mix(-1.0 * kernelScale, 1.0 * kernelScale, gs);
            float xmsn = kernelWeight * transmissionfactor;
            
            // Apply exact CPU transmit logic
            if(k == offset && l == offset) {
                // Center pixel case - subtract (xmsn * l)
                rpx -= xmsn * float(l);
                gpx -= xmsn * float(l);
                bpx -= xmsn * float(l);
            } else {
                // Non-center pixel case - add (xmsn * l)
                rpx += xmsn * float(l);
                gpx += xmsn * float(l);
                bpx += xmsn * float(l);
            }
        }
    }
    
    // Convert back to 0-1 range for output
    gl_FragColor = vec4(rpx / 255.0, gpx / 255.0, bpx / 255.0, currentPixel.a);
}