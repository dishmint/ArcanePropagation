#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D ppixels;

uniform sampler2D tex0;
uniform float aspect;

bool start = true;


float _point(in vec2 uv, vec2 o, in float t){
	float s1 = step(o.x - t, uv.x) - step(o.x + t, uv.x);
	float s2 = step(o.y - t, uv.y) - step(o.y + t, uv.y);
	return s1*s2;
}

float _pointorbit(in vec2 uv, vec2 center, in float radius, float angle, in float t){
	vec2 trig = vec2(cos(angle),sin(angle));
	vec2 o = center + (radius * trig);
	return _point(uv, o, t);
}

vec4 color;

#define angleF 2.

float clip;

void main( void ) {
	
	vec2 position = ( gl_FragCoord.xy / resolution.xy );

	position.y*=aspect;
	position.y += (1.0 - aspect) / 2.0;
	
	vec2 pixel = 1./resolution;
	
	// color of the image
	
	color  = texture2D(tex0, vec2(position.x, 1.0 - position.y));
	
	if (position.y > 1. || position.y < 0.0){
		clip = 0.0;
	} else {
		clip = 1.0;
	}
	
	float energy = (color.r+color.g+color.b+color.a/4.0);
	float angle = energy * angleF;
	
	float radius = 0.001;
	float thickness = 0.001;
	
	float pxos = _pointorbit(position, position, radius, angle+time/1., thickness);
	// float pxos = _pointorbit(position, position, radius, angle, thickness);

	float ac4 = (angle/angleF)*(215./255.);
	float ec = mix(-1.,1.,energy);
	vec4 grade = vec4(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)),1.0);
	
	gl_FragColor = (1.-vec4(pxos))*grade*clip;
	// gl_FragColor = (1.-vec4(pxos))*grade*clip*vec4(1.,1.,1., 1./8.);
}
