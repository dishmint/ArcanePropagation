#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float kernelScale;      // Kernel scaling factor
uniform int kernelWidth;        // Kernel width
uniform float colordiv;         // Color division factor
uniform bool hav;               // Human vs average grayscale

varying vec4 vertTexCoord;

#define D3 1.0/3.0

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
    vec3 result = currentPixel.rgb * 255.0;

    // Compute xmn from center kernel value (ximg[cloc][1][1])
    float gs = computeGS(currentPixel.rgb);
    float xmn = mix(-kernelScale, kernelScale, gs);

    // Count alive neighbors using channel-average brightness
    int count = 0;
    int offset = kernelWidth / 2;

    for(int i = -4; i <= 4; i++) {
        if(i < -offset || i > offset) continue;
        for(int j = -4; j <= 4; j++) {
            if(j < -offset || j > offset) continue;
            if(i == 0 && j == 0) continue; // Skip center

            vec2 sampleUV = uv + vec2(float(i), float(j)) * texelSize;
            // Skip out-of-bounds (matching CPU boundary check)
            if(sampleUV.x < 0.0 || sampleUV.x > 1.0 || sampleUV.y < 0.0 || sampleUV.y > 1.0) continue;

            vec4 neighbor = texture2D(tex0, sampleUV);
            // CPU uses channel average: (R+G+B) * D3 where values are [0,255]
            float avg = (neighbor.r + neighbor.g + neighbor.b) * 255.0 * D3;
            if(avg > 0.5) {
                count++;
            }
        }
    }

    float countd = 1.0 / (float(count) + 0.001);

    if(count < 2 || count > 3) {
        // Death: subtract xmn * countd
        result -= vec3(xmn * countd);
    } else if(count == 3) {
        // Birth/sustain: add xmn * countd
        result += vec3(xmn * countd);
    } else {
        // count == 2: set to white
        result = vec3(255.0);
    }

    result = clamp(result / 255.0, 0.0, 1.0);
    gl_FragColor = vec4(result, currentPixel.a);
}
