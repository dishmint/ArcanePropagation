class ArcanePropagator{
	Consumer<ArcanePropagator> updater;
	/* VARS */
	int kernelwidth;
	float kernelScale;
	float xfactor;
	/* IMAGE */
	PImage source;
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
		
		return map((
				0.2989 * rpx +
				0.5870 * gpx +
				0.1140 * bpx
				) / 3.0, 0.0, 255.0, 0.0, 1.0);
		
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
	ArcanePropagator(PImage img, String filtermode, String rendermode, int kw, float ks, float xf, float ds){
		/* SETUP VARS */
		kernelwidth = kw;
		kernelScale = ks;
		xfactor = xf;
		displayScale = ds;
		/* SETUP IMAGE */
		source = resize(img);		
		ximage = loadxm(source);
		/* SETUP FILTER */
		af = new ArcaneFilter(filtermode, kernelwidth, xfactor);
		/* SETUP RENDERER */
		ar = new ArcaneRender(source, "blueline.glsl", displayScale);

		updater = (ap) -> {
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