#ifdef GL_ES
precision highp float;
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
        // Match CPU perceptual grayscale calculation
        return dot(color, vec3(0.2989, 0.5870, 0.1140)) * (colordiv * 255.0);
    } else {
        // Channel average
        return (color.r + color.g + color.b) * (colordiv * 255.0);
    }
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec4 currentPixel = texture2D(tex0, uv);

    vec3 result = currentPixel.rgb * 255.0;
    vec2 texelSize = 1.0 / resolution;
    int offset = kernelWidth / 2;

    for(int i = 0; i < 8; i++) {
        if(i >= kernelWidth) break;
        for(int j = 0; j < 8; j++) {
            if(j >= kernelWidth) break;

            vec2 sampleOffset = vec2(float(i - offset), float(j - offset));
            vec2 sampleUV = clamp(uv + sampleOffset * texelSize, vec2(0.0), vec2(1.0));

            vec4 sampleColor = texture2D(tex0, sampleUV);
            vec3 sampleRGB = sampleColor.rgb * 255.0;
            float gs = computeGS(sampleColor.rgb);

            float kernelWeight = mix(-kernelScale, kernelScale, gs);
            float xmsn = kernelWeight * transmissionfactor;
            vec3 contribution = sampleRGB * xmsn;

            if(i == offset && j == offset) {
                result -= contribution;
            } else {
                result += contribution;
            }
        }
    }

    result = clamp(result, 0.0, 255.0);
    gl_FragColor = vec4(result / 255.0, currentPixel.a);
}
