#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float kernelScale;      // Kernel scaling factor
uniform float transmissionfactor; // Transmission factor
uniform int kernelWidth;        // Kernel width
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
    vec2 texelSize = 1.0 / resolution;

    vec4 currentPixel = texture2D(tex0, uv);
    // Start with current pixel value (matching CPU: rpx = cpx channels)
    vec3 result = currentPixel.rgb;

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

            float kernelWeight = mix(-kernelScale, kernelScale, gs);
            float xmsn = kernelWeight * transmissionfactor;

            // Accumulate: rpx += nrpx * xmsn
            result += sampleColor.rgb * xmsn;
        }
    }

    result = clamp(result, 0.0, 1.0);
    gl_FragColor = vec4(result, currentPixel.a);
}
