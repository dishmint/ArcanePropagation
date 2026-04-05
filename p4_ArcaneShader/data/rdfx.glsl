#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float dA;               // Diffusion rate A
uniform float dB;               // Diffusion rate B
uniform float fr;               // Feed rate
uniform float kr;               // Kill rate
uniform float transmissionfactor; // Transmission factor
uniform float kernelScale;      // Kernel scaling factor
uniform float colordiv;         // Color division factor
uniform bool hav;               // Human vs average grayscale
uniform int kernelWidth;        // Kernel width

varying vec4 vertTexCoord;

float computeGS(vec3 color) {
    if(hav) {
        return dot(color, vec3(0.2989, 0.5870, 0.1140)) * (colordiv * 255.0);
    } else {
        return (color.r + color.g + color.b) * (colordiv * 255.0);
    }
}

vec2 reactdiffuse(float a, float b, float la, float lb) {
    float newA = a + (dA * la) - (a * b * b) + (fr * (1.0 - a));
    float newB = b + (dB * lb) + (a * b * b) - ((kr + fr) * b);
    return vec2(newA, newB);
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;

    vec4 currentPixel = texture2D(tex0, uv);
    float srpx = currentPixel.r * 255.0;
    float sgpx = currentPixel.g * 255.0;
    float sbpx = currentPixel.b * 255.0;

    float rtotal = 0.0;
    float gtotal = 0.0;
    float btotal = 0.0;

    int offset = kernelWidth / 2;
    float center = float(offset);

    for(int i = 0; i < 8; i++) {
        if(i >= kernelWidth) break;
        for(int j = 0; j < 8; j++) {
            if(j >= kernelWidth) break;

            vec2 sampleOffset = vec2(float(i - offset), float(j - offset));
            vec2 sampleUV = clamp(uv + sampleOffset * texelSize, vec2(0.0), vec2(1.0));

            vec4 sampleColor = texture2D(tex0, sampleUV);
            float rpx = sampleColor.r * 255.0;
            float gpx = sampleColor.g * 255.0;
            float bpx = sampleColor.b * 255.0;

            // xmg kernel weight from grayscale
            float gs = computeGS(sampleColor.rgb);
            float xmgWeight = mix(-kernelScale, kernelScale, gs);

            // rdfkernel with range (-1.0, 0.5) for rdfx variant
            float d = distance(vec2(center), vec2(float(i), float(j)));
            // map(d, 0.0, center, -1.0, 0.5) = -1.0 + d/center * 1.5
            float rdfWeight = -1.0 + (d / max(center, 0.001)) * 1.5;

            // Combined: (xmg + rdfkernel) * transmissionfactor
            float xmsn = (xmgWeight + rdfWeight) * transmissionfactor;

            rtotal += rpx * xmsn;
            gtotal += gpx * xmsn;
            btotal += bpx * xmsn;
        }
    }

    vec2 sr = reactdiffuse(srpx, sgpx, rtotal, gtotal);
    vec2 sg = reactdiffuse(sr.y, sbpx, gtotal, btotal);
    vec2 sb = reactdiffuse(sg.y, sr.x, btotal, rtotal);

    float newr = sb.y;
    float newg = sg.x;
    float newb = sb.x;

    vec3 result = clamp(vec3(newr, newg, newb) / 255.0, 0.0, 1.0);
    gl_FragColor = vec4(result, 1.0);
}
