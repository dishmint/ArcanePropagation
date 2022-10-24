#ifdef GL_ES
precision highp float;
#endif

#define PROCESSING_COLOR_SHADER

uniform vec2 resolution;
uniform sampler2D ppixels;

uniform sampler2D tex0;
uniform float aspect;
uniform float rfac;
uniform float tfac;
uniform float unitsize;

float energy, angle = 0;
float pxos,clip,ec;

vec2 radius, thickness, pixel;

vec4 color,grade;

#define TAU 6.2831853071
#define QTAU TAU*.25

// https://gist.github.com/companje/29408948f1e8be54dd5733a74ca49bb9
float map(float value, float min1, float max1, float min2, float max2) {
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

// ———————

#define C4Z 1
#define C4B 2
#define C3M 3
#define C3Z 4

void pushEnergyAngle(int selector){
	switch(selector)
	{
		case C4Z:
			energy = (color.r+color.g+color.b+color.a/4.0);
			// angle = mix(0.0, TAU, energy);
			angle = mix(-TAU, TAU, energy);
			break;
		case C4B:
			energy = (color.r+color.g+color.b+color.a/4.0);
			// float rangle = mix(-TAU, TAU, color.r);
			// float gangle = mix(-TAU, TAU, color.g);
			// float bangle = mix(-TAU, TAU, color.b);
			// float aangle = mix(-TAU, TAU, color.a);

			// float rangle = mix(-QTAU, QTAU, color.r);
			// float gangle = mix(-QTAU, QTAU, color.g);
			// float bangle = mix(-QTAU, QTAU, color.b);
			// float aangle = mix(-QTAU, QTAU, color.a);

			float rangle = mix(0.0, QTAU, color.r);
			float gangle = mix(0.0, QTAU, color.g);
			float bangle = mix(0.0, QTAU, color.b);
			float aangle = mix(0.0, QTAU, color.a);
			
			angle = rangle+gangle+bangle+aangle;
			break;
		case C3M:
			energy = mix(-1.,1.,(color.r+color.g+color.b)/3.0);
			angle = map(energy, -1., 1., 0., TAU);
			// angle = ((energy + 1.0)/2.0) * TAU;
			break;
		case C3Z:
			energy = mix(0.,1.,(color.r+color.g+color.b)/3.0);
			angle = mix(0., TAU, energy);
			break;
		default:
			energy = map(color.r+color.g+color.b+color.a/4.0, 0.,1., .5,1.);
			angle = mix(0.5, TAU, energy);
			break;
	}
}

float _point(in vec2 uv, vec2 o){
	float s1 = step(o.x - (thickness.x/tfac), uv.x) - step(o.x + (thickness.x/tfac), uv.x);
	float s2 = step(o.y - (thickness.y/tfac), uv.y) - step(o.y + (thickness.y/tfac), uv.y);
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
#define alphaC 2
#define alphaY 3

#define red    1
#define blue   2
#define green  3
#define yellow 4
#define rblue  5
#define yellowbrick 6
#define gred 7

vec3 makebase(int selector){
	vec3 b;
	switch(selector)
	{
		case red:
			b = vec3(1.0,0.0,0.0)*(angle/(TAU));
			break;
		case blue:
			b = vec3(0.0980392, 0.0980392, 0.439216)*(angle/(TAU));
			break;
		case green:
			b = vec3(0.101961, 0.145098, 0.117647)*(angle/(TAU));
			break;
		case yellow:
			b = vec3(1., 1., 0.0)*(angle/(TAU));
			break;
		case yellowbrick:
		// b = mix(vec3(1., .84, 0.), vec3(.22, .06, 0.), (angle/(TAU)));
			b = mix(vec3(.22, .06, 0.), vec3(1., .84, 0.), (angle/(TAU)));
			break;
		case rblue:
			b = vec3((angle/(TAU))*(215./255.), 1.-abs(mix(-1.,1.,energy)), 1.-(abs(mix(-1.,1.,energy))*(200./255.)));
			break;
		case gred:
		// b = mix(vec3(0.07, .42, 0.1), vec3(1., .16, 0.22), (angle/(TAU)));
			b = mix(vec3(1., .16, 0.22), vec3(0.07, .42, 0.1), (angle/(TAU)));
			break;
		default:
			b = vec3((angle/(TAU))*(215./255.), 1.-abs(mix(-1.,1.,energy)), 1.-(abs(mix(-1.,1.,energy))*(200./255.)));
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

/* SETTINGS  */
/* — energy angle map — */
/* — C4Z|C4B|C3M|C3Z — */
int emap  = C4B;
/* — grade — */
/* — normal|inverse, red|green|blue|yellow|yellowbrick|rblue|gred, alpha1|alphaC|alphaY — */
int state = normal, theme = rblue, alpha = alphaY;
/* — frag — */
/* — GEO|NOGEO, GRADE|NOGRADE|SOURCE — */
int shape = GEO, grader = GRADE;

/* TODO: make some structs for these settings ^^ */

void main( void ) {
	
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	pixel = unitsize/resolution;

	position.y*=aspect;
	position.y += (1.0 - aspect) / 2.0;
	
	color = texture2D(tex0, vec2(position.x, 1.0 - position.y));
	
	pushEnergyAngle(emap);
	
	thickness = pixel;
	radius    = (rfac*thickness);
	
	pushgeo(points, position);
	pushgrade(state, theme, alpha);
	
	gl_FragColor = pushfrag(shape, grader, position);
	}
