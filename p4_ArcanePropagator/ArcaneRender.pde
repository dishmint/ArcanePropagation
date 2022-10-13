class ArcaneRender {
	String rendermode;
	ArcaneInterface ai;
	PGraphics buffer;
	
	ArcaneRenderer(String renderer){
		rendermode = renderer;
		ArcaneInterface ai = switch(rendermode){
			case "shader":
				getArcShader();
				break;
			case "geo":
				getArcGeo();
				break;
			default:
				getArcShader();
				break;
		}
	}
	
	void setup(){
		switch(rendermode){
			case "shader":
				// SHADER SETUP
				// uniforms other params etc.
				break;
			case "geo":
				// GEO SETUP
				break;
			default:
				// SHADER SETUP
				break;
		}
	}
	
	void show(ArcanePropagator aprop){

		/* 
			background(0);
			pgDraw();
			shaderDraw();
		 */

		switch(rendermode){
			case "shader":
				// SHADER Draw
				pgDraw();
				shaderDraw();
				break;
			case "geo":
				// GEO Draw
				pointDraw();
				break;
			default:
				// SHADER SETUP
				break;
		}
	}
}


/* 
PShader blueline;
PGraphics pg;

void shaderDraw(){
	if(dispersed){
		drawDispersed();
	} else {
		drawOriginal();
	}
	image(pg, width/2, height/2, simg.width*displayscale, simg.height*displayscale);
}

void pgDraw(){
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
}

	// max width and height is 16384 for the Apple M1 graphics card (according to Processing debug message)
	// pg = createGraphics(5000,5000, P2D);
	pg = createGraphics(2*simg.width,2*simg.height, P2D);
	// pg = createGraphics(10000,10000, P2D);
	pg.noSmooth();
	
	blueline = loadShader("blueline.glsl");
	float resu = 100.;
	blueline.set("resolution", resu*float(pg.width), resu*float(pg.height));
	
	// the unitsize determines the dimensions of a pixels for the shader
	blueline.set("unitsize", 1.00);
	// the thickness used to determine a points position is determined by thickness/tfac
	blueline.set("tfac", 1.0);
	
	/*
	- The radius of a point orbit is determined by rfac * thickness
	- when 1.0000 < rfac < 1.0009 values begin to display as black pixels, kind of like a mask.
	- rfac >= 1.5 == black screen
	- rfac == 0.0 == 1:1
	*/
	
	// TODO: add rfac slider
	// blueline.set("rfac", 0.0);
	// blueline.set("rfac", 1.00000);
	blueline.set("rfac", 1.0625);
	// blueline.set("rfac", 1.25);
	// blueline.set("rfac", 1.300000);

 */