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
    if(hav) {
        return dot(color, vec3(0.2989, 0.5870, 0.1140)) * (colordiv * 255.0);
    } else {
        return (color.r + color.g + color.b) * (colordiv * 255.0);
    }
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec4 currentPixel = texture2D(tex0, uv);
    vec2 texelSize = 1.0 / resolution;

    vec3 result = currentPixel.rgb * 255.0;

    // Compute normalized average brightness in [0,1]
    float avg = (result.r + result.g + result.b) / 3.0 / 255.0;

    if(avg >= 0.5) {
        // Set pixel to white
        gl_FragColor = vec4(1.0, 1.0, 1.0, currentPixel.a);
        return;
    }

    // avg < 0.5: iterate kernel with conditional processing
    int offset = kernelWidth / 2;
    float kwSq = float(kernelWidth * kernelWidth);

    for(int k = 0; k < 8; k++) {
        if(k >= kernelWidth) break;
        for(int l = 0; l < 8; l++) {
            if(l >= kernelWidth) break;

            // Only process if avg < (k*l / kernelwidth^2)
            float threshold = float(k * l) / kwSq;
            if(avg >= threshold) continue;

            vec2 sampleOffset = vec2(float(k - offset), float(l - offset));
            vec2 sampleUV = clamp(uv + sampleOffset * texelSize, vec2(0.0), vec2(1.0));

            vec4 sampleColor = texture2D(tex0, sampleUV);
            float gs = computeGS(sampleColor.rgb);

            float kernelWeight = mix(-kernelScale, kernelScale, gs);
            float xmsn = kernelWeight * transmissionfactor;

            vec3 neighborRGB = sampleColor.rgb * 255.0;

            if(k == offset && l == offset) {
                // Center: multiplicative self-attenuation scaled by l
                // rpx -= (rpx * xmsn) * l
                result -= (result * xmsn) * float(l);
            } else {
                // Neighbor: additive with neighbor's pixel scaled by l
                // rpx += (irpx * xmsn) * l
                result += (neighborRGB * xmsn) * float(l);
            }
        }
    }

    result = clamp(result / 255.0, 0.0, 1.0);
    gl_FragColor = vec4(result, currentPixel.a);
}
