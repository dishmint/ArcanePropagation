class ArcaneRender {
	BiConsumer<PImage, Float> renderer;
	String shaderPath;
	PShader blueline;
	PGraphics buffer;
	float displayScale;
	boolean dispersed;

	void setShader(PImage source){
			blueline = loadShader(shaderPath);
			blueline.set("aspect", float(source.width)/float(source.height));
			blueline.set("tex0", source);

			blueline.set("resolution", 100.*float(buffer.width), 100.*float(buffer.height));
	
			/* the unitsize determines the dimensions of pixels for the shader */
			blueline.set("unitsize", 1.00);
			/* the thickness used to determine a points position is determined by thickness/tfac */
			blueline.set("tfac", 1.0);
			blueline.set("rfac", 1.0625);

			renderer = (simg, ds) -> {
				blueline.set("tex0", simg);
				image(buffer, width/2, height/2, simg.width*ds, simg.height*ds);
			};
		};

	ArcaneRender(PImage source, String rendermode, String sPath, float dscale){
		shaderPath = sPath;
		displayScale = dscale;
		
		buffer = createGraphics(2*source.width,2*source.height, P2D);
		buffer.noSmooth();
		
		switch(rendermode){
			case "shader":
				setShader(source);
				break;
			case "geo":
				// renderer = ArcaneRender::geoDraw;
				break;
			default:
				setShader(source);
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