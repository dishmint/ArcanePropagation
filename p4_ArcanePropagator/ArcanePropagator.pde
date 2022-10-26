class ArcanePropagator{
	Consumer<ArcanePropagator> updater;
	/* VARS */
	int kernelwidth;
	float scalefactor;
	float xfactor;
	/* IMAGE */
	PImage source;
	float[][][] ximage;
	float displayScale;
	ArcaneFilter af;
	/* RENDER */
	ArcaneRender ar;
	Movie arcfilm;

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
		
		return (
				0.2989 * rpx +
				0.5870 * gpx +
				0.1140 * bpx
				) / 255.0;
		// return (
		// 		rpx +
		// 		gpx +
		// 		bpx
		// 		) / 255.0;
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

						// kernel[k][l] = gs;
						// kernel[k][l] = gs * -2.0;
						kernel[k][l] = map(gs, 0, 1, -1.,1.);
						// kernel[k][l] = map(gs, 0, 1, -0.5,0.5);
						// kernel[k][l] = map(gs, 0, 1, -1.,1.)*scalefactor;
						// kernel[k][l] = map(gs, 0, 1, -1.,1.)/scalefactor;
						// kernel[k][l] = map(gs, 0, 1, -1.,1.)*kernelwidth;
						// kernel[k][l] = (map(gs, 0, 1, -1.,1.)*kernelwidth)/kernelwidth;
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * ((k*l)/pow(kernelwidth, 2.0));


						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * k;
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * l;
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * (k + l);

						// kernel[k][l] = map(gs, 0, 1, -1.,1.) - (k * l);
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) - (k + l);
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * (offset - k); /* moves to the left */
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * (offset - l); /* moves to the top */
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) - ((k*l)/(kernelwidth*2.0)); /* blown out */
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * ((abs(k-offset) * abs(l-offset))/kernelwidth); /* static */
						// kernel[k][l] = map(gs, 0, 1, -1.,1.) * ((abs(k-offset) * abs(l-offset))/pow(kernelwidth,2.0)); /* dynamic */
						}
					}
				xms[index] = kernel;
			}
		}
		img.updatePixels();
		return xms;
	}

	/* CNSR */
	ArcanePropagator(PImage img, String filtermode, String rendermode, int kw, float sf, float xf, float ds){
		/* SETUP VARS */
		kernelwidth = kw;
		scalefactor = sf;
		xfactor = xf;
		displayScale = ds;
		/* SETUP IMAGE */
		source = resize(img);		
		ximage = loadxm(source);
		/* SETUP FILTER */
		af = new ArcaneFilter(filtermode, kernelwidth, xfactor);
		/* SETUP RENDERER */
		ar = new ArcaneRender(source, rendermode, "blueline.glsl", displayScale);

		updater = (ap) -> {
			ap.update();
		};
	}

	ArcanePropagator(Movie m, String filtermode, String rendermode, int kw, float sf, float xf, float ds){
		/* SETUP VARS */
		kernelwidth = kw;
		scalefactor = sf;
		xfactor = xf;
		displayScale = ds;
		/* SETUP MOVIE */
		arcfilm = m;
		arcfilm.read();
		source = resize(arcfilm);
		ximage = loadxm(source);
		/* SETUP FILTER */
		af = new ArcaneFilter(filtermode, kernelwidth, xfactor);
		/* SETUP RENDERER */
		ar = new ArcaneRender(source, rendermode, "blueline.glsl", displayScale);

		updater = (ap) -> {
			if(arcfilm.available()){
				arcfilm.read();
			}
			ap.source = resize(arcfilm);
			ap.update();
		};
	}

	void update(){
		af.kernelmap(this);
	}
	
	void show(){
		ar.show(this); /* should just display an image (what about point orbit though w/ geo?)*/
	}

	void draw(){
		updater.accept(this);
		ar.show(this);
	}
}