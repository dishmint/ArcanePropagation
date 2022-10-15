class ArcaneRender {
	BiConsumer<PImage, Float> renderer;
	String shaderPath;
	PShader blueline;
	PGraphics buffer;
	float displayScale;
	boolean dispersed;

	// private void shaderDraw(PImage simg, float dscale){
		
	// }
	private void geoDraw(PImage simg, float dscale){
		/* 
		
		for each pixel draw shape.

		 */
	}

	ArcaneRender(PImage source, String rendermode, String sPath, float dscale){
		shaderPath = sPath;
		displayScale = dscale;
		
		buffer = createGraphics(2*source.width,2*source.height, P2D);
		buffer.noSmooth();
		
		switch(rendermode){
			case "shader":
				blueline = loadShader(shaderPath);
				blueline.set("aspect", float(source.width)/float(source.height));
				blueline.set("tex0", source);

				blueline.set("resolution", 100.*float(buffer.width), 100.*float(buffer.height));
	
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

				renderer = (simg, ds) -> {
					blueline.set("tex0", simg);

					image(buffer, width/2, height/2, simg.width*ds, simg.height*ds);
				};
				break;
			case "geo":
				// renderer = ArcaneRender::geoDraw;
				break;
			default:
				blueline = loadShader(shaderPath);
				blueline.set("aspect", float(source.width)/float(source.height));
				blueline.set("tex0", source);

				blueline.set("resolution", 100.*float(buffer.width), 100.*float(buffer.height));
	
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
				renderer = (simg, ds) -> {
					blueline.set("tex0", simg);

					image(buffer, width/2, height/2, simg.width*ds, simg.height*ds);
				};
				break;
		}
	}
	
	void show(ArcanePropagator aprop){
		background(0);
		buffer.beginDraw();
		buffer.background(0);
		buffer.shader(blueline);
		buffer.rect(0, 0, buffer.width, buffer.height);
		buffer.endDraw();

		renderer.accept(aprop.source, displayScale);
	}
}