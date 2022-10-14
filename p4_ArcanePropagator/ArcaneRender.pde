class ArcaneRender {
	Function<T,R> renderer;
	String shaderPath;
	PShader blueline;
	PGraphics buffer;
	float displayScale;
	boolean dispersed;

	private void shaderDraw(PImage simg, float dscale){
		blueline.set("tex0", simg);

		image(buffer, width/2, height/2, simg.width*dscale, simg.height*dscale);
	}
	private void geoDraw(PImage simg, float dscale){
		/* 
		
		for each pixel draw shape.

		 */
	}

	ArcaneRender(ArcanePropagator aprop, String rendermode, String sPath, float dscale){
		shaderPath = sPath;
		displayScale = dscale;
		switch(rendermode){
			case "shader":
				blueline = loadShader(shaderPath);
				blueline.set("aspect", float(aprop.source.width)/float(aprop.source.height));
				blueline.set("tex0", aprop.source);

				float resu = 100.;
				blueline.set("resolution", resu*float(pg.width), resu*float(pg.height));
	
				// the unitsize determines the dimensions of a pixels for the shader
				blueline.set("unitsize", 1.00);
				// the thickness used to determine a points position is determined by thickness/tfac
				blueline.set("tfac", 1.0);
	
	
				// - The radius of a point orbit is determined by rfac * thickness
				// - when 1.0000 < rfac < 1.0009 values begin to display as black pixels, kind of like a mask.
				// - rfac >= 1.5 == black screen
				// - rfac == 0.0 == 1:1
	
	
				// TODO: add rfac slider
				// blueline.set("rfac", 0.0);
				// blueline.set("rfac", 1.00000);
				blueline.set("rfac", 1.0625);
				// blueline.set("rfac", 1.25);
				// blueline.set("rfac", 1.300000);

				renderer = ArcaneRender::shaderDraw;
				break;
			case "geo":
				renderer = ArcaneRender::geoDraw;
				break;
			default:
				renderer = ArcaneRender::shaderDraw;
				break;
		}
	}
	
	void setup(ArcanePropagator aprop){
		/* initialize buffer */
		// max width and height is 16384 for the Apple M1 graphics card (according to Processing debug message)
		buffer = createGraphics(2*aprop.source.width,2*aprop.source.height, P2D);
		buffer.noSmooth();
	}
	
	void show(ArcanePropagator aprop){
		background(0);
		buffer.beginDraw();
		buffer.background(0);
		buffer.shader(blueline);
		buffer.rect(0, 0, buffer.width, buffer.height);
		buffer.endDraw();

		renderer(aprop.source, displayScale);
	}
}