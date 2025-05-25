#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D tex0;         // Source image texture
varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.st;
    gl_FragColor = texture2D(tex0, uv);
}