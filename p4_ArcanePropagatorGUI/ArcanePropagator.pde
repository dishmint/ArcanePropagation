class ArcanePropagator{
	/* VARS */
	int kernelwidth;
	float kernelScale;
	float xfactor;
	float colordiv;
	/* IMAGE */
	PImage source;
	PImage og;
	PImage overlay;
	float[][][] ximage;
	float displayScale;
	ArcaneFilter af;
	/* RENDER */
	ArcaneRender ar;

	PImage resize(PImage img){
		// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
		float sw = (float)img.pixelWidth;
		float sh = (float)img.pixelHeight;
		float scale = min(width/sw, height/sh);
		int nw = Math.round(sw*scale);
		int nh = Math.round(sh*scale);
		img.resize(nw, nh);
		return img;
	}


	float computeGS(color px){
		float rpx = px >> 16 & 0xFF;
		float gpx = px >> 8 & 0xFF;
		float bpx = px & 0xFF;
				
		return (
				0.2989 * rpx +
				0.5870 * gpx +
				0.1140 * bpx
				) * colordiv;
	}
	
	float[][][] loadxm(PImage img) {
		float[][][] xms = new float[int(img.pixelWidth * img.pixelHeight)][kernelwidth][kernelwidth];
		float[][] kernel = new float[kernelwidth][kernelwidth];
		int offset = kernelwidth / 2;
		img.loadPixels();
		for (int i = 0; i < img.pixelWidth; i++){
			for (int j = 0; j < img.pixelHeight; j++){
				int index = (i + j * img.pixelWidth);
				index = constrain(index,0,img.pixels.length-1);

				for (int k = 0; k < kernelwidth; k++){
					for (int l= 0; l < kernelwidth; l++){

						int xloc = i+k-offset;
						int yloc = j+l-offset;
						int loc = xloc + img.pixelWidth*yloc;

						loc = constrain(loc,0,img.pixels.length-1);

						color cpx = img.pixels[loc];

						float gs = computeGS(cpx);

						// kernel[k][l] = map(gs, 0, 1, -1.,1.) /* * kernelScale */;
						kernel[k][l] = map(gs, 0, 1, -1.,1.) * kernelScale;

						}
					}
				xms[index] = kernel;
			}
		}
		img.updatePixels();
		return xms;
	}

	/* CNSR */
	ArcanePropagator(PImage img, String filtermode, int kw, float ks, float xf, float ds, float gsd){
		/* SETUP VARS */
		kernelwidth = kw;
		kernelScale = ks;
		xfactor = xf;
		displayScale = ds;
		colordiv = gsd;
		/* SETUP IMAGE */
		og = resize(img);
		source = og.copy();	
		overlay = og.copy();	
		ximage = loadxm(source);
		/* SETUP FILTER */
		af = new ArcaneFilter(filtermode, kernelwidth, xfactor);
		/* SETUP RENDERER */
		ar = new ArcaneRender(source, "blueline.glsl", displayScale);
	}

	void setFilter(String flt){
		af.setFilterMode(flt);
	}

	void setImage(PImage nimg){
		og = resize(nimg);
		source = og.copy();
		overlay = og.copy();
		ximage = loadxm(source);
		ar.setShader(source);
	}


	void setTransmissionFactor(String nxf){
		switch (nxf) {
			case "1 div kw^2":
				xfactor = 1.0f / pow(kernelwidth, 2.0f);
				af.transmissionfactor = xfactor;
				break;
			case "1 div (kw^2 - 1)":
				xfactor = 1.0f / (pow(kernelwidth, 2.0f) - 1.0f);
				af.transmissionfactor = xfactor;
				break;
			case "1 div kw":
				xfactor = 1.0f / kernelwidth;
				af.transmissionfactor = xfactor;
				break;
			case "kernel width":
				xfactor = kernelwidth;
				af.transmissionfactor = xfactor;
				break;
			case "kernel scale":
				xfactor = gui.slider("ArcaneSettings/Kernel/KernelScale");
				af.transmissionfactor = xfactor;
				break;
			default:
				xfactor = 1.0f / pow(kernelwidth, 2.0f);
				af.transmissionfactor = xfactor;
		    	break;
		}
	}

	void setDisplayScale(float nds){
		displayScale = nds;
		ar.displayScale = nds;
	}

	void reset(){
		source = og.copy();
	}

	void save(String filename){
		String file = "data/captures/" + filename + ".png";
		saveFrame(file);
	}

	void run(){
		if (gui.toggle("Run")){
			af.kernelmap(this);
			ar.show(this);
		} else {
			ar.show(this);
		}

		if(gui.toggle("Overlay")){
			tint(255, 127);
			image(overlay, width*0.5, height*0.5, overlay.pixelWidth*displayScale, overlay.pixelHeight*displayScale);
			tint(255, 255);
		}

		/* if the current kw is different than the last then rerun loadxm */
		int currentkw = gui.sliderInt("ArcaneSettings/Kernel/KernelWidth");
		if(kernelwidth != currentkw){
			kernelwidth = currentkw;
			ximage = loadxm(source);
			/* ^^ should this use og instead of source? source is the current state of the image, where og is the original image */
			af.kernelwidth = kernelwidth;
		}
		float currentks = gui.slider("ArcaneSettings/Kernel/KernelScale");
		if(kernelScale != currentks){
			kernelScale = currentks;
			ximage = loadxm(source);
		}
		float currentcd = gui.slider("ArcaneSettings/Kernel/ColorFactor");
		if(colordiv != currentcd){
			colordiv = currentcd;
			ximage = loadxm(source);
		}
		
	}

	void debug(){
		println("kernelwidth: " + kernelwidth);
		println("kernelScale: " + kernelScale);
		println("xfactor: " + xfactor);
		println("colordiv: " + colordiv);
		println("displayScale: " + displayScale);
	}
}