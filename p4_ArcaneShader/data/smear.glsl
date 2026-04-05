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
uniform int selector;           // Operation mode selector

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

    // CPU smear initializes rpx/gpx/bpx to 0, then overwrites each iteration
    vec3 rpx = vec3(0.0);

    int offset = kernelWidth / 2;

    for(int i = 0; i < 8; i++) {
        if(i >= kernelWidth) break;
        for(int j = 0; j < 8; j++) {
            if(j >= kernelWidth) break;

            vec2 sampleOffset = vec2(float(i - offset), float(j - offset));
            vec2 sampleUV = clamp(uv + sampleOffset * texelSize, vec2(0.0), vec2(1.0));

            vec4 sampleColor = texture2D(tex0, sampleUV);
            float gs = computeGS(sampleColor.rgb);

            float kernelWeight = mix(-kernelScale, kernelScale, gs);
            float xmsn = kernelWeight * transmissionfactor;

            // CPU reads neighbor pixel fresh each iteration, overwriting rpx
            rpx = sampleColor.rgb * 255.0;

            bool isCenter = (i == offset && j == offset);

            // Selector mode 1 (default): center subtract, neighbor add
            if(selector == 2) {
                if(isCenter) {
                    rpx -= vec3(xmsn);
                } else {
                    rpx *= vec3(xmsn);
                }
            } else if(selector == 3) {
                if(isCenter) {
                    rpx += vec3(xmsn);
                } else {
                    rpx *= vec3(xmsn);
                }
            } else if(selector == 4) {
                if(isCenter) {
                    rpx = vec3(xmsn);
                }
            } else {
                // selector == 1 or default
                if(isCenter) {
                    rpx -= vec3(xmsn);
                } else {
                    rpx += vec3(xmsn);
                }
            }
        }
    }

    vec3 result = clamp(rpx / 255.0, 0.0, 1.0);
    gl_FragColor = vec4(result, 1.0);
}
