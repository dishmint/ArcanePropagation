class ArcaneRender {
	BiConsumer<PImage, Float> renderer;
	String shaderPath;
	PShader blueline;
	PGraphics buffer;
	float displayScale;
	boolean dispersed;

	void setShader(PImage source){
			blueline = loadShader(shaderPath);

			println("SET_SHADER | source dimentions: " + source.pixelWidth + " x " + source.pixelHeight);
			if (source.pixelWidth != source.pixelHeight) {
				if (source.pixelWidth > source.pixelHeight){
					blueline.set("aspect", float(source.pixelWidth)/float(source.pixelHeight));
				} else if (source.pixelWidth < source.pixelHeight){
					// blueline.set("aspect", (float(source.height)/float(source.width)));
					blueline.set("aspect", 1.0);
				}
			} else {
				blueline.set("aspect", 1.0);
			}
			
			blueline.set("tex0", source);
			blueline.set("densityscale", 1.0/displayDensity());

			blueline.set("resolution", 1000.*float(buffer.pixelWidth), 1000.*float(buffer.pixelHeight));
	
			/* unitsize => size of pixel */
			blueline.set("unitsize", 1.00);
			/* (unitsize/resolution)/tfac => scales size of pixel */
			blueline.set("tfac", 1.0);

			/* (unitsize/resolution) * rfac => scales orbit radius */
			blueline.set("rfac", 1.0); /* default */

			renderer = (simg, ds) -> {
				blueline.set("tex0", simg);

				float sw = (float)simg.pixelWidth;
				float sh = (float)simg.pixelHeight;
				float scale = min(width/sw, height/sh);
				// float wh = sw/sh;
				float wh = 1.0;

				if (simg.pixelWidth > simg.pixelHeight){
						wh = sw/sh;
						image(buffer, width*0.5, height*0.5, simg.pixelWidth*ds, wh*simg.pixelHeight*ds);
					} else {
						image(buffer, width*0.5, height*0.5, simg.pixelWidth*ds, simg.pixelHeight*ds);
					}
			};
		};

	ArcaneRender(PImage source, String sPath, float dscale){
		shaderPath = sPath;
		displayScale = dscale;
		
		buffer = createGraphics(2*source.pixelWidth,2*source.pixelHeight, P2D);
		buffer.noSmooth();
		
		setShader(source);
	}

	void bufferDraw(){
		buffer.beginDraw();
		buffer.background(0);
		buffer.shader(blueline);
		buffer.rect(0, 0, buffer.pixelWidth, buffer.pixelHeight);
		buffer.endDraw();
	}
	
	void show(ArcanePropagator aprop){
		background(0);
		bufferDraw();
		renderer.accept(aprop.source, displayScale);
	}
}
