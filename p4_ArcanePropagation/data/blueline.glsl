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

float energy, angle = 0;
float clip;

vec4 color;
#define angleF 360.

// https://gist.github.com/companje/29408948f1e8be54dd5733a74ca49bb9
float map(float value, float min1, float max1, float min2, float max2) {
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

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

void energyAngle1(){
	energy = (color.r+color.g+color.b+color.a/4.0);
	angle = energy * angleF;
}

void energyAngle2(){
	float er = 0.2989 * color.r;
	float eg = 0.5870 * color.g;
	float eb = 0.1140 * color.b;

	energy = mix(-1.,1.,(color.r+color.g+color.b)/3.0);
	angle = map(energy, -1., 1., 0., 1.);
	angle = clamp(angle, 0., 1.0);
}

void main( void ) {
	
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	
	position.y*=aspect;
	position.y += (1.0 - aspect) / 2.0;
	// vec2 pixel = 1./resolution;
	
	// image pixels
	
	color  = texture2D(tex0, vec2(position.x, 1.0 - position.y));
	// color  = (texture2D(tex0, vec2(position.x, 1.0 - position.y))+1.)/2.0;
	
	if (position.y > 1. || position.y < 0.0){
		clip = 0.0;
		} else {
			clip = 1.0;
		}
		
		energyAngle1();

		
		// Not enough points
		// float radius    = .0000001;
		// float thickness = .0000001;
		
		// Bottom Left Corner is weird
		// float radius    = .00000001;
		// float thickness = .00000001;
		
		// Bottom Left Corner is weird and larger
		// float radius    = .00000002;
		// float thickness = .00000002;
		
		// Bottom Left Corner is weird but smaller
		// float radius    = .000000001;
		// float thickness = .000000001;
		
		// Bottom Left Corner is weird and really small
		// float radius    = .0000000001;
		// float thickness = .0000000001;
		
		// Perfect!
		// float radius    = .00000000001;
		// float thickness = .00000000001;
		
		// What happens if i change the radius?
		float radius    = .00000000001;
		float thickness = .00000000001;
		
		// pixel isn't small enough to capture enough details
		// float radius    = pixel.x;
		// float thickness = pixel.x;
		
		// blank screen
		// float radius    = pixel.x/pixel.y;
		// float thickness = pixel.x/pixel.y;
		
		// float pxos = _pointorbit(position, position, radius, angle+time/1., thickness);
		float pxos = _pointorbit(position, position, radius, angle, thickness);
		
		float ac4 = (angle/angleF)*(215./255.);
		float ec = mix(-1.,1.,energy);
		// vec4 grade = vec4(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)),1.0);;
		vec4 grade = vec4(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)),color.a);
		
		gl_FragColor = (1.-vec4(pxos))*grade*clip;
		// gl_FragColor = (1.-vec4(pxos))*clip;
		// gl_FragColor = clip*grade;
		// gl_FragColor = color*clip;
		// gl_FragColor = color;
	}
