#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform vec2 resolution;
uniform sampler2D ppixels;

uniform sampler2D tex0;
uniform float aspect;
uniform float rfac;

float energy, angle = 0;
float pxos,clip,ec;
#define lineweight .000000000001

vec2 radius, thickness, pixel;

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


float lineSegment(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a, ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return smoothstep(0.0, 1.0 / pixel.x, length(pa - ba*h));
}


// ———————

#define C4Z 1
#define C3M 2
#define C3Z 3

void pushEnergyAngle(int selector){
	switch(selector)
	{
		case C4Z:
			energy = (color.r+color.g+color.b+color.a/4.0);
			angle = mix(0.0, 2.*PI, energy);
			break;
		case C3M:
			energy = mix(-1.,1.,(color.r+color.g+color.b)/3.0);
			angle = map(energy, -1., 1., 0., 2.*PI);
			break;
		case C3Z:
			energy = mix(0.,1.,(color.r+color.g+color.b)/3.0);
			angle = mix(0., 2.*PI, energy);
			break;
		default:
			energy = (color.r+color.g+color.b+color.a/4.0);
			angle = mix(0.0, 2.*PI, energy);
			break;
	}
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
	// return 1.0-drawLine(uv, center, o);
	// return 1.0-drawLine(uv, center, vec2(.5));
	return lineSegment(uv, center, o);
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
			pxos = _lineorbit(uv, uv+.5);
			break;
		default:
			pxos = _pointorbit(uv, uv);
			break;
	}
}

#define alpha1 1
#define alphaE 2
#define alphaC 3
#define alphaY 4

vec4 makeGrade(int selector){
	float ac4 = (angle/(2.*PI))*(215./255.);
	float ec = mix(-1.,1.,energy);
	vec3 base = vec3(ac4, 1.-abs(ec), 1.-(abs(ec)*(200./255.)));
	
	vec4 mgrade;
	
	switch(selector)
	{
		case alpha1:
			mgrade = vec4(base,1.0);
			break;
		case alphaE:
			mgrade = vec4(base,ec);
			break;
		case alphaC:
			mgrade = vec4(base,color.a);
			break;
		case alphaY:
			mgrade = vec4(base,energy);
			break;
		default:
			mgrade = vec4(base,1.0);
			break;
	}
	return mgrade;
}

#define normal  1
#define inverse 2

void pushgrade(int selector, int selector2){
	
	switch(selector)
	{
		case normal:
			grade = makeGrade(selector2);
			break;
		case inverse:
			// vec4 c = makeGrade();
			// grade = vec4(1.-c.rgb, c.a);
			grade = 1. - makeGrade(selector2);
			break;
		default:
			grade = makeGrade(selector2);
			break;
	}
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
			c = ((vec4(pxos)+color)/2.)*clip;
			// c = (1.0-(vec4(pxos)))*clip;
			break;
		default:
			c = color*clip;
			break;
	}
	return c;
}

void main( void ) {
	
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	pixel = 1./resolution;
	position.y*=aspect;
	position.y += (1.0 - aspect) / 2.0;
	
	color = texture2D(tex0, vec2(position.x, 1.0 - position.y));
	// color  = (texture2D(tex0, vec2(position.x, 1.0 - position.y))+1.)/2.;
	
	//| C4Z | E =>           Mean[ color.rgba ]  |  A => mix(0,2 PI, E)          |
	//| C3M | E => mix(-1,1, Mean[ color.rgb  ]) |  A => map(E, -1, 1, 0, 2 PI)  |
	//| C3Z | E => mix( 0,1, Mean[ color.rgb  ]) |  A => mix(0,2 PI, E)          |
	pushEnergyAngle(C4Z);
	
	thickness = pixel;
	radius    = (rfac*thickness);
	
	//| points   | _pointorbit       |
	//| lines    | _lineorbit        |
	pushgeo(lines, position);
	
	//|              ARG1            |
	//| normal   | grade             |
	//| inverse  | 1 - grade         |
	//|              ARG2            |
	//| alpha1   | alpha => 1.0      |
	//| alphaE   | alpha => ec       |
	//| alphaC   | alpha => color.a  |
	//| alphaY   | alpha => energy   |
	pushgrade(normal, alphaY);
	
	//| pointgrade | point * grade * clip |
	//| graderlock | grade * clip         |
	//| colorclipr | color * clip         |
	//| pointclipr | point * color * clip |
	//| lineclipr  | line  * color * clip |
	gl_FragColor = pushfrag(pointgrade, position);
	}
