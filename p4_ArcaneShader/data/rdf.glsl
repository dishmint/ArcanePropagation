#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float dA;               // Diffusion rate A
uniform float dB;               // Diffusion rate B
uniform float fr;               // Feed rate
uniform float kr;               // Kill rate
uniform int kernelWidth;        // Kernel width

varying vec4 vertTexCoord;

// Reaction-diffusion step: matches CPU reactdiffuse(a, b, la, lb)
// a' = a + (dA * la) - (a * b * b) + (fr * (1 - a))
// b' = b + (dB * lb) + (a * b * b) - ((kr + fr) * b)
vec2 reactdiffuse(float a, float b, float la, float lb) {
    float newA = a + (dA * la) - (a * b * b) + (fr * (1.0 - a));
    float newB = b + (dB * lb) + (a * b * b) - ((kr + fr) * b);
    return vec2(newA, newB);
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;

    vec4 currentPixel = texture2D(tex0, uv);
    // Current pixel channels in [0,255] space
    float srpx = currentPixel.r * 255.0;
    float sgpx = currentPixel.g * 255.0;
    float sbpx = currentPixel.b * 255.0;

    float rtotal = 0.0;
    float gtotal = 0.0;
    float btotal = 0.0;

    int offset = kernelWidth / 2;
    float center = float(offset);

    // Distance-based rdfkernel: map(dist(center, i, j), 0, center, -1.0, 0.0)
    for(int i = 0; i < 8; i++) {
        if(i >= kernelWidth) break;
        for(int j = 0; j < 8; j++) {
            if(j >= kernelWidth) break;

            // Compute rdfkernel weight from distance
            float d = distance(vec2(center), vec2(float(i), float(j)));
            // map(d, 0.0, center, -1.0, 0.0) = -1.0 + d/center
            float xmsn = -1.0 + d / max(center, 0.001);

            vec2 sampleOffset = vec2(float(i - offset), float(j - offset));
            vec2 sampleUV = clamp(uv + sampleOffset * texelSize, vec2(0.0), vec2(1.0));

            vec4 sampleColor = texture2D(tex0, sampleUV);
            float rpx = sampleColor.r * 255.0;
            float gpx = sampleColor.g * 255.0;
            float bpx = sampleColor.b * 255.0;

            rtotal += rpx * xmsn;
            gtotal += gpx * xmsn;
            btotal += bpx * xmsn;
        }
    }

    // Chained cross-channel reaction-diffusion (matching CPU exactly):
    // sr = reactdiffuse(srpx, sgpx, rtotal, gtotal)
    vec2 sr = reactdiffuse(srpx, sgpx, rtotal, gtotal);
    // sg = reactdiffuse(sr[1], sbpx, gtotal, btotal)
    vec2 sg = reactdiffuse(sr.y, sbpx, gtotal, btotal);
    // sb = reactdiffuse(sg[1], sr[0], btotal, rtotal)
    vec2 sb = reactdiffuse(sg.y, sr.x, btotal, rtotal);

    // newr = sb[1]; newg = sg[0]; newb = sb[0]
    float newr = sb.y;
    float newg = sg.x;
    float newb = sb.x;

    vec3 result = clamp(vec3(newr, newg, newb) / 255.0, 0.0, 1.0);
    gl_FragColor = vec4(result, 1.0);
}
