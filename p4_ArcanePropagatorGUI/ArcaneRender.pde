class ArcaneRender {
	BiConsumer<PImage, Float> renderer;
	String shaderPath;
	PShader blueline;
	PGraphics buffer;
	float displayScale;
	boolean dispersed;

	void setShader(PImage source){
			blueline = loadShader(shaderPath);
			blueline.set("aspect", float(source.pixelWidth)/float(source.pixelHeight));
			blueline.set("tex0", source);
			blueline.set("densityscale", 1.0/displayDensity());

			blueline.set("resolution", 1000.*float(buffer.pixelWidth), 1000.*float(buffer.pixelHeight));
			// blueline.set("resolution", 100.*float(buffer.pixelWidth), 100.*float(buffer.pixelHeight));
	
			/* the unitsize determines the dimensions of pixels for the shader */
			blueline.set("unitsize", 1.00);
			/* the thickness used to determine a points position is determined by thickness/tfac */
			blueline.set("tfac", 1.0);

			/*
			- The radius of a point orbit is determined by rfac * thickness
			- when 1.0000 < rfac < 1.0009 values begin to display as black pixels, kind of like a mask.
			- rfac >= 1.5 == black screen
			- rfac == 0.0 == 1:1
			*/
			// blueline.set("rfac", 0.0); 
			// blueline.set("rfac", 0.5);
			blueline.set("rfac", 1.0); /* default */

			renderer = (simg, ds) -> {
				blueline.set("tex0", simg);
				image(buffer, width/2, height/2, simg.pixelWidth*ds, simg.pixelHeight*ds);
			};
		};

	ArcaneRender(PImage source, String sPath, float dscale){
		shaderPath = sPath;
		displayScale = dscale;
		
		buffer = createGraphics(2*source.pixelWidth,2*source.pixelHeight, P2D);
		buffer.noSmooth();
		
		setShader(source);
	}

	void setShaderUnitSize(float nus){
		blueline.set("unitsize", nus);
	}

	void setShaderTFac(float ntf){
		blueline.set("tfac", ntf);
	}

	void setShaderRFac(float nrf){
		blueline.set("rfac", nrf);
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
