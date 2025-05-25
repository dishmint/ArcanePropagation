#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
uniform vec2 resolution;        // Image resolution
uniform float threshold;        // Brightness threshold for life/death
uniform float lifeStrength;     // Strength of life effect
uniform float deathStrength;    // Strength of death effect
uniform bool useOriginalRules;  // Use classic Conway rules vs modified

varying vec4 vertTexCoord;

// Count living neighbors around a cell
int countNeighbors(sampler2D tex, vec2 uv, vec2 texelSize, float thresh) {
    int count = 0;
    
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue; // Skip center cell
            
            vec2 neighborUV = uv + vec2(float(x), float(y)) * texelSize;
            neighborUV = clamp(neighborUV, vec2(0.0), vec2(1.0));
            
            vec4 neighbor = texture2D(tex, neighborUV);
            float brightness = dot(neighbor.rgb, vec3(0.299, 0.587, 0.114));
            
            if(brightness > thresh) {
                count++;
            }
        }
    }
    
    return count;
}

void main() {
    vec2 uv = vertTexCoord.st;
    vec2 texelSize = 1.0 / resolution;
    
    vec4 currentPixel = texture2D(tex0, uv);
    float currentBrightness = dot(currentPixel.rgb, vec3(0.299, 0.587, 0.114));
    
    bool isAlive = currentBrightness > threshold;
    int neighbors = countNeighbors(tex0, uv, texelSize, threshold);
    
    bool newState = false;
    
    if(useOriginalRules) {
        // Classic Conway's Game of Life rules
        if(isAlive) {
            newState = (neighbors == 2 || neighbors == 3);
        } else {
            newState = (neighbors == 3);
        }
    } else {
        // Modified rules for more interesting visual effects
        if(isAlive) {
            newState = (neighbors >= 2 && neighbors <= 4);
        } else {
            newState = (neighbors >= 3 && neighbors <= 5);
        }
    }
    
    vec3 result;
    if(newState) {
        // Cell lives - brighten
        result = currentPixel.rgb + vec3(lifeStrength);
    } else {
        // Cell dies - darken
        result = currentPixel.rgb * (1.0 - deathStrength);
    }
    
    // Clamp to valid range
    result = clamp(result, vec3(0.0), vec3(1.0));
    
    gl_FragColor = vec4(result, currentPixel.a);
}