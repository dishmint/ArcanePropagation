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
uniform float densityscale;

uniform int theme;
uniform int grader;
uniform int alpha;

float energy, angle = 0;
float pxos,clip,ec;

vec2 radius, thickness, pixel;

vec4 color,grade,theta;

#define D4 0.250000000000000
#define D9 0.111111111111111

#define TAU			6.283185307179586
#define HTAU		TAU * 0.5
#define QTAU		TAU * D4
#define DTAU 0.159155

// https://gist.github.com/companje/29408948f1e8be54dd5733a74ca49bb9
float map(float value, float min1, float max1, float min2, float max2) {
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

// ———————

#define C4Z 1
#define C4B 2
#define C4C 4
#define C3M 5
#define C3Z 6

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
			// energy = mix(-1.,1.,(color.r+color.g+color.b+color.a));
			theta = mix(vec4(-QTAU), vec4(QTAU), energy); /* default */
			// vec4 theta = mix(vec4(-TAU), vec4(TAU), energy);
			
			angle = theta.x+theta.y+theta.z+theta.w;
			break;
		case C4C:
			// vec4 plasma = mix(vec4(0.0), vec4(0.25), color);
			// vec4 plasma = mix(vec4(-0.25), vec4(0.25), color);
			vec4 plasma = mix(vec4(0.0), vec4(0.25), vec4(color.rgb, 1.0));
			energy = (plasma.x+plasma.y+plasma.z+plasma.w);

			theta = mix(vec4(-QTAU), vec4(QTAU), energy); /* default */
			
			angle = theta.x+theta.y+theta.z+theta.w;
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

#define white 1
#define red 2
#define blue 3
#define green 4
#define yellow 5
#define rblue 6
#define yellowbrick 7
#define gred 8
#define reen 9
#define starrynight 10
#define ember 11
#define bloodred 12
#define gundam 13
#define moonlight 14

#define GRADE   1
#define NOGRADE 2
#define SOURCE  3

vec3 makebase(int selector){
	vec3 b;
	switch(selector)
	{
		case white:
			b = vec3(1.0) * (angle * DTAU);
			break;
		case red:
			b = vec3(1.0,0.0,0.0)*(angle * DTAU);
			break;
		case blue:
			// b = vec3(0.0980392, 0.0980392, 0.439216)*(angle * DTAU);
			b = vec3(0.0, 0.0, 1.0)*(angle * DTAU);
			break;
		case green:
			b = vec3(0.101961, 0.145098, 0.117647)*(angle * DTAU);
			break;
		case yellow:
			b = vec3(1., 1., 0.0)*(angle * DTAU);
			break;
		case yellowbrick:
			b = mix(vec3(.22, .06, 0.), vec3(1., .84, 0.), (angle * DTAU));
			break;
		case rblue:
			b = vec3((angle * DTAU)*(215./255.), 1.-abs(mix(-1.,1.,energy)), 1.-(abs(mix(-1.,1.,energy))*(200./255.)));
			break;
		case gred:
			b = mix(vec3(1., .16, 0.22), vec3(0.07, .42, 0.1), (angle * DTAU));
			break;
		case reen:
			b = mix(vec3(0.07, .42, 0.10), vec3(1.0, .16, 0.22), (angle * DTAU));
			break;
		case starrynight:
			b = mix(vec3(0.2, 0.4, 0.54), vec3(0.96, .68, 0.18), (angle * DTAU));
			break;
		case ember:
			b = mix(vec3(0.18, 0.28, 0.35), vec3(0.95, .39, 0.1), (angle * DTAU));
			break;
		case bloodred:
			b = mix(vec3(0.34, 0.0, 0.0), vec3(0.99, 1.0, 1.0), (angle * DTAU));
			break;
		case gundam:
			b = mix(vec3(0.12, 0.2, 0.19), vec3(0.86, 0.3, 0.25), (angle * DTAU));
			break;
		case moonlight:
			b = mix(vec3(0.10588235, 0.10588235, 0.11764706), vec3(1.0, 0.6627451, 0.08627451), (angle * DTAU));
			break;
		default:
			b = mix(vec3(0.0), vec3(1.0), angle * DTAU);
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
/* — emap   : C4Z|C4B|C3M|C3Z                               — */
/* — state  : normal|inverse                                — */
/* — theme  : red|green|blue|yellow|yellowbrick|rblue|gred  — */
/* — alpha  : alpha1|alphaC|alphaY                          — */
/* — shape  : GEO|NOGEO                                     — */
/* — grader : GRADE|NOGRADE|SOURCE                          — */

struct settings
{
	int emap;  /* Select energy and gangle mapping function */
	int state; /* Use original image or color negated image */
	int theme; /* Specify color theme */
	int alpha; /* Select alpha interpretation */
	int shape; /* Specify wheter to rotate pixel or not */
	int grader; /* Specify whether to use the theme or not */
};

settings setting = settings(
	C4B, 
	normal, 
	theme, 
	alpha, 
	GEO, 
	grader
	);

void main( void ) {
	vec2 position = ( gl_FragCoord.xy / resolution.xy ) * densityscale;
	pixel = unitsize/resolution;

	position.y*=aspect;
	position.y += (1.0 - aspect) / 2.0;
	
	color = texture2D(tex0, vec2(position.x, 1.0 - position.y));
	
	pushEnergyAngle(setting.emap);
	
	thickness = pixel;
	radius    = (rfac*thickness);
	
	pushgeo(points, position);
	pushgrade(setting.state, setting.theme, setting.alpha);
	
	gl_FragColor = pushfrag(setting.shape, setting.grader, position);
}
