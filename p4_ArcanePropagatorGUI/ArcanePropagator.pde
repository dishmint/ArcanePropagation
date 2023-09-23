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
		return img; /* might not need to return this if img.resize is changing the original image */
	}

	float computeGS(color px){
		float rpx = px >> 16 & 0xFF;
		float gpx = px >> 8 & 0xFF;
		float bpx = px & 0xFF;
		
		// return map((
		// 		0.2989 * rpx +
		// 		0.5870 * gpx +
		// 		0.1140 * bpx
		// 		) / 3.0, 0.0, 255.0, 0.0, 1.0);
		
		return (
				0.2989 * rpx +
				0.5870 * gpx +
				0.1140 * bpx
				) * colordiv;
		
		// return map((
		// 		rpx +
		// 		gpx +
		// 		bpx
		// 		) / 3.0, 0.0, 255.0, 0.0, 1.0);
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
		/* NOTE: 
			^^ There may be cases where you want to preserve shader parameters even when you change images
			(they may be preserved though because the blueline.set functions don't affect the GUI) */
	}

	void setKernelScale(float nks){
		kernelScale = nks;
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
				xfactor = gui.slider("ArcaneSettings/KernelScale");
				af.transmissionfactor = xfactor;
				break;
			default:
				xfactor = 1.0f / pow(kernelwidth, 2.0f);
				af.transmissionfactor = xfactor;
		    	break;
		}
	}

	void setColorDiv(float ncd){
		colordiv = ncd;
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
			float osw = (float)overlay.pixelWidth;
			float osh = (float)overlay.pixelHeight;
			float oscale = min(width/((float)overlay.pixelWidth), height/((float)overlay.pixelHeight));
			int nw = Math.round(osw*oscale);
			int nh = Math.round(osh*oscale);
			// print("og — " + overlay.pixelWidth + " " + overlay.pixelHeight + " " + nw + " " + nh + "\n");
			overlay.resize(nw, nh);
			// print("rz — " + overlay.pixelWidth + " " + overlay.pixelHeight + " " + nw + " " + nh + "\n");
			// print("sz — " + source.pixelWidth + " " + source.pixelHeight + " " + nw + " " + nh + "\n");
			float szc = ((float)source.pixelHeight)/((float)source.pixelWidth);
			// println(szc);
			image(overlay, width*0.5, height*0.5, source.pixelWidth*displayScale, source.pixelHeight*displayScale*szc);
			tint(255, 255);
		}

		/* if the current kw is different than the last then rerun loadxm */
		int currentkw = gui.sliderInt("ArcaneSettings/KernelWidth");
		if(kernelwidth != currentkw){
			kernelwidth = currentkw;
			ximage = loadxm(source);
			af.kernelwidth = kernelwidth;
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