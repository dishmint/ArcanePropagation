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

#define PI 3.14159265359

float computeGS(vec3 color) {
    if(hav) {
        return dot(color, vec3(0.2989, 0.5870, 0.1140)) * (colordiv * 255.0);
    } else {
        return (color.r + color.g + color.b) * (colordiv * 255.0);
    }
}

// chladnifunction(x, y, n, m) = sin(n/255*PI*x)*sin(m*PI*y) - sin(m*PI*x)*sin(n/255*PI*y)
float chladniFunction(float x, float y, float n, float m) {
    float fn = n / 255.0;
    float c1 = sin(fn * PI * x) * sin(m * PI * y);
    float c2 = sin(m * PI * x) * sin(fn * PI * y);
    return c1 - c2;
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;

    vec3 rtotal = vec3(0.0);

    int offset = kernelWidth / 2;

    for(int i = -4; i <= 4; i++) {
        if(i < -offset || i > offset) continue;
        for(int j = -4; j <= 4; j++) {
            if(j < -offset || j > offset) continue;

            vec2 sampleUV = uv + vec2(float(i), float(j)) * texelSize;
            // Skip out-of-bounds (matching CPU boundary check)
            if(sampleUV.x < 0.0 || sampleUV.x > 1.0 || sampleUV.y < 0.0 || sampleUV.y > 1.0) continue;

            vec4 sampleColor = texture2D(tex0, sampleUV);

            // Compute xmsn from xmg equivalent
            float gs = computeGS(sampleColor.rgb);
            float kernelWeight = mix(-kernelScale, kernelScale, gs);
            float xmsn = kernelWeight * transmissionfactor;

            vec3 sampleRGB = sampleColor.rgb * 255.0;

            // Pixel coordinates for chladni function
            // CPU uses absolute pixel coordinates (xloc, yloc)
            float xloc = (uv.x + float(i) * texelSize.x) * resolution.x;
            float yloc = (uv.y + float(j) * texelSize.y) * resolution.y;

            // Per-channel: chladnifunction(xloc, yloc, channel_value, xmsn)
            rtotal.r += chladniFunction(xloc, yloc, sampleRGB.r, xmsn);
            rtotal.g += chladniFunction(xloc, yloc, sampleRGB.g, xmsn);
            rtotal.b += chladniFunction(xloc, yloc, sampleRGB.b, xmsn);
        }
    }

    vec3 result = clamp(rtotal / 255.0, 0.0, 1.0);
    gl_FragColor = vec4(result, 1.0);
}
