class ArcaneRender {
	BiConsumer<PImage, Float> renderer;
	String shaderPath;
	String rendermode;
	PShader blueline;
	PGraphics buffer;
	float displayScale;
	boolean dispersed;

	void setShader(PImage source){
			blueline = loadShader(shaderPath);
			blueline.set("aspect", float(source.pixelWidth)/float(source.pixelHeight));
			blueline.set("tex0", source);
			blueline.set("densityscale", 1.0/displayDensity());

			// blueline.set("resolution", float(buffer.pixelWidth), float(buffer.pixelHeight));
			// blueline.set("resolution", 100.*float(buffer.pixelWidth), 100.*float(buffer.pixelHeight)); /* default */
			blueline.set("resolution", 1000.*float(buffer.pixelWidth), 1000.*float(buffer.pixelHeight));
	
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
			blueline.set("rfac", 1.00000); /* default */
			// blueline.set("rfac", 1.015625); 
			// blueline.set("rfac", 1.03125); 
			// blueline.set("rfac", 1.0625); 
			// blueline.set("rfac", 1.25);
			// blueline.set("rfac", 1.300000);
			// blueline.set("rfac", 2.00);

			renderer = (simg, ds) -> {
				blueline.set("tex0", simg);
				image(buffer, width/2, height/2, simg.pixelWidth*ds, simg.pixelHeight*ds);
			};
		};

	//void setGeo(PImage source){
	//		renderer = (simg, ds) -> {
	//			geoRenderer(simg);
	//		};
	//	};
	
	float computeGS(color px){
		float rpx = px >> 16 & 0xFF;
		float gpx = px >> 8 & 0xFF;
		float bpx = px & 0xFF;
		
		return (
			0.2989 * rpx +
			0.5870 * gpx +
			0.1140 * bpx
			) / 255.0;
		};

	float energyAngle(float ec) {
		float ecc = (ec + 1.) / 2.;
		float a = lerp(0., 360., ecc);
		return a;
	};

	color energyDegree(float energy) {
		float ne = (energy+1.)/2.;
		return lerpColor(color(0, 255, 255, 255), color(215, 0, 55, 255), ne);
	};

	void geoRenderer(PImage simg){
			simg.loadPixels();
			for(int x = 0; x < simg.pixelWidth;x++){
				for(int y = 0; y < simg.pixelHeight; y++){
					int index = (x + (y * simg.pixelWidth));
					index = constrain(index, 0, simg.pixels.length - 1);
					color cpx = simg.pixels[index];
					float gs = computeGS(cpx);
					pushMatrix();
						/* Show As Point */
						float enc = lerp(-1., 1., gs);
						stroke(energyDegree(gs));
						float ang = radians(energyAngle(enc));
						float px = x + (1./(/* modfac */ 1) * cos(ang));
						float py = y + (1./(/* modfac */ 1) * sin(ang));
						
						pushMatrix();
							translate((width/2)-(simg.pixelWidth/2),(height/2)-(simg.pixelHeight/2));
							point(
								(px),
								(py)
								);
						popMatrix();
					popMatrix();
				}
			}
			simg.updatePixels();
	}

	ArcaneRender(PImage source, String rmode, String sPath, float dscale){
		rendermode = rmode;
		shaderPath = sPath;
		displayScale = dscale;
		
		buffer = createGraphics(2*source.pixelWidth,2*source.pixelHeight, P2D);
		buffer.noSmooth();
		
		switch(rendermode){
			case "shader":
				setShader(source);
				break;
			case "geo":
				//setGeo(source); /* TODO: implement setGeo */
				break;
			default:
				setShader(source);
				break;
		}
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
		switch(rendermode){
			case "shader":
				bufferDraw();
				break;
			case "geo":
				break;
			default:
				bufferDraw();
				break;
		}

		renderer.accept(aprop.source, displayScale);
	}
}
