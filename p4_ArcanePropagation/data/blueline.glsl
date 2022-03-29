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

#define points 1
#define lines  2

void pushgeo(int selector, vec2 uv){
	switch(selector)
	{
		case points:
			pxos = _pointorbit(uv, uv);
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

#define red   1
#define blue  2
#define green 3
#define rblue 4

vec3 makebase(int selector){
	vec3 b;
	switch(selector)
	{
		case red:
			b = vec3(1.0,0.0,0.0)*(angle/(2.*PI));
			break;
		case blue:
			b = vec3(0.0980392, 0.0980392, 0.439216)*(angle/(2.*PI));
			break;
		case green:
			b = vec3(0.101961, 0.145098, 0.117647)*(angle/(2.*PI));
			break;
		case rblue:
			b = vec3((angle/(2.*PI))*(215./255.), 1.-abs(mix(-1.,1.,energy)), 1.-(abs(mix(-1.,1.,energy))*(200./255.)));
			break;
		default:
			b = vec3((angle/(2.*PI))*(215./255.), 1.-abs(mix(-1.,1.,energy)), 1.-(abs(mix(-1.,1.,energy))*(200./255.)));
			break;
	}
	return b;
}


vec4 makeGrade(int selector, int selector2){
	vec3 base = makebase(selector);
	
	vec4 mgrade;
	
	switch(selector2)
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

void pushgrade(int selector, int selector2, int selector3){
	
	switch(selector)
	{
		case normal:
			grade =      makeGrade(selector2, selector3);
			break;
		case inverse:
			grade = 1. - makeGrade(selector2, selector3);
			break;
		default:
			grade =      makeGrade(selector2, selector3);
			break;
	}
}

#define GEO   1
#define NOGEO 2

#define GRADE   1
#define NOGRADE 2
#define SOURCE  3

vec4 pushfrag(int geoQ, int gradeQ, vec2 uv){
	if (uv.y > 1. || uv.y < 0.0){
			clip = 0.0;
		} else {
			clip = 1.0;
		}
	
	vec4 geo = vec4(0.);
	vec4 thm = vec4(0.);
	
	switch(geoQ)
	{
		case GEO:
			geo = vec4(pxos);
			break;
		case NOGEO:
		geo = vec4(1.0);
			break;
		default:
			geo = vec4(pxos);
			break;
	}

	switch(gradeQ)
	{
		case GRADE:
			thm = grade;
			break;
		case NOGRADE:
			thm = vec4(1.0);
			break;
		case SOURCE:
			thm = color;
			break;
		default:
			thm = grade;
			break;
	}
	
	vec4 c = geo * thm * clip;
	
	return c;
}

void main( void ) {
	
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	pixel = 1./resolution;
	position.y*=aspect;
	position.y += (1.0 - aspect) / 2.0;
	
	color = texture2D(tex0, vec2(position.x, 1.0 - position.y));
	
	//| C4Z | E =>           Mean[ color.rgba ]  |  A => mix(0,2 PI, E)          |
	//| C3M | E => mix(-1,1, Mean[ color.rgb  ]) |  A => map(E, -1, 1, 0, 2 PI)  |
	//| C3Z | E => mix( 0,1, Mean[ color.rgb  ]) |  A => mix(0,2 PI, E)          |
	pushEnergyAngle(C4Z);
	
	thickness = pixel;
	radius    = (rfac*thickness);
	
	//| points   | _pointorbit       |
	pushgeo(points, position);
	
	//|              ARG1            |
	//| normal   | grade             |
	//| inverse  | 1 - grade         |
	//|              ARG2            |
	//| red | green | blue |  rblue  |
	//|              ARG3            |
	//| alpha1   | alpha => 1.0      |
	//| alphaE   | alpha => ec       |
	//| alphaC   | alpha => color.a  |
	//| alphaY   | alpha => energy   |
	pushgrade(normal, green, alphaY);
	
	//| GEO   / NOGEO            | shape or 1.0           |
	//| GRADE / NOGRADE / SOURCE | grade or 1.0 or source  |
	gl_FragColor = pushfrag(GEO, GRADE, position);
	}
