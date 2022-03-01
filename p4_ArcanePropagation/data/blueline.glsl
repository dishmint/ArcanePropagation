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
float pxos,clip,ec;
#define lineweight .003

vec2 radius, thickness;

vec4 color,grade;

#define PI 3.1415926538

// https://gist.github.com/companje/29408948f1e8be54dd5733a74ca49bb9
float map(float value, float min1, float max1, float min2, float max2) {
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

// https://stackoverflow.com/questions/15276454/is-it-possible-to-draw-line-thickness-in-a-fragment-shader

float drawLine(vec2 uv, vec2 p1, vec2 p2) {
	
	float a = abs(distance(p1, uv));
	float b = abs(distance(p2, uv));
	float c = abs(distance(p1, p2));
	
	if ( a >= c || b >=  c ) return 0.0;
	
	float p = (a + b + c) * 0.5;
	
	// median to (p1, p2) vector
	float h = 2. / c * sqrt( p * ( p - a) * ( p - b) * ( p - c));
	
	return mix(1.0, 0.0, smoothstep(0.5 * lineweight, 1.5 * lineweight, h));
}

// ———————

void energyAngle1(){
	energy = (color.r+color.g+color.b+color.a/4.0);
	angle = mix(0.0, 2.*PI, energy);
}

void energyAngle2(){
	energy = mix(-1.,1.,(color.r+color.g+color.b)/3.0);
	angle = map(energy, -1., 1., 0., 2.*PI);
}

void energyAngle3(){
	energy = mix(0.,1.,(color.r+color.g+color.b)/3.0);
	angle = mix(0., 2.*PI, energy);
}

void energyAngle4(){
	energy = mix(0.,1.,(color.r+color.g+color.b)/3.0);
	angle = mix(0.,(2.*PI), energy);
}

float _point(in vec2 uv, vec2 o){
	float s1 = step(o.x - thickness.x, uv.x) - step(o.x + thickness.x, uv.x);
	float s2 = step(o.y - thickness.y, uv.y) - step(o.y + thickness.y, uv.y);
	return s1*s2;
}

float _pointorbit(in vec2 uv, vec2 center){
	vec2 trig = vec2(cos(angle),sin(angle));
	vec2 o = center + (radius * trig);
	return _point(uv, o);
}

float _lineorbit(in vec2 uv, vec2 center){
	vec2 trig = vec2(cos(angle),sin(angle));
	vec2 o = center + (radius * trig);
	return drawLine(uv, center, o);
}

#define points 1
#define lines  2

void pushgeo(int selector, vec2 uv){
	switch(selector)
	{
		case points:
			pxos = _pointorbit(uv, uv);
			break;
		case lines:
			pxos = _lineorbit(uv, uv+radius);
			break;
		default:
			pxos = _point(uv,uv);
			break;
	}
}

vec4 makeGrade(){
	float ac4 = (angle/(2.*PI))*(215./255.);
	float ec = mix(-1.,1.,energy);
	// return vec4(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)),color.a);
	// return vec4(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)),ec);
	// return vec4(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)),energy);
	return vec4(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)),1.0);
	// return vec4(angle,vec2(0.),color.a);
}

void pushgrade(){
	grade = makeGrade();
}

void pushgradeI(){
	vec4 c = makeGrade();
	grade = vec4(1.-c.rgb, c.a);
}

#define pointgrade 1
#define graderlock 2
#define colorclipr 3
#define pointclipr 4
#define lineclipr 5

vec4 pushfrag(int selector, vec2 uv){
	if (uv.y > 1. || uv.y < 0.0){
			clip = 0.0;
		} else {
			clip = 1.0;
		}
	
	vec4 c = vec4(0.0);
	switch(selector)
	{
		case pointgrade:
			c = (1.-vec4(pxos))*grade*clip;
			break;
		case graderlock:
			c = clip*grade;
			break;
		case colorclipr:
			c = color*clip;
			break;
		case pointclipr:
			c = (1.-vec4(pxos))*color*clip;
			break;
		case lineclipr:
			c = vec4(1.0-vec3(pxos), energy)*clip;
			break;
		default:
			c = color*clip;
			break;
	}
	return c;
}

void main( void ) {
	
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	vec2 pixel = 1./resolution;
	position.y*=aspect;
	position.y += (1.0 - aspect) / 2.0;
	
	color = texture2D(tex0, vec2(position.x, 1.0 - position.y));
	// color  = (texture2D(tex0, vec2(position.x, 1.0 - position.y))+1.)/2.;
		
		// energyAngle1();
		// energyAngle2();
		// energyAngle3();
	energyAngle4();
		
	thickness = pixel;
	radius    = (2.*thickness);
	
	pushgeo(lines, position);
	
	pushgrade();
	// pushgradeI();
		
		gl_FragColor = pushfrag(lineclipr, position);
	}
