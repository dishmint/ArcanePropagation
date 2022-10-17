class ArcanePropagator{
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

	PImage resize(PImage img){
		// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
		float sw = (float)img.width;
		float sh = (float)img.height;
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
	}
	
	float[][][] loadxm(PImage img) {
		float[][][] xms = new float[int(img.width * img.height)][kernelwidth][kernelwidth];
		float[][] kernel = new float[kernelwidth][kernelwidth];
		int offset = kernelwidth / 2;
		img.loadPixels();
		for (int i = 0; i < img.width; i++){
			for (int j = 0; j < img.height; j++){
				int index = (i + j * img.width);
				index = constrain(index,0,img.pixels.length-1);

				for (int k = 0; k < kernelwidth; k++){
					for (int l= 0; l < kernelwidth; l++){

						int xloc = i+k-offset;
						int yloc = j+l-offset;
						int loc = xloc + img.width*yloc;

						loc = constrain(loc,0,img.pixels.length-1);

						color cpx = img.pixels[loc];

						float gs = computeGS(cpx);

						// kernel[k][l] = gs;
						// kernel[k][l] = gs * -2.0;
						kernel[k][l] = map(gs, 0, 1, -1.,1.);
						// kernel[k][l] = map(gs, 0, 1, -0.5,0.5);
						// kernel[k][l] = map(gs, 0, 1, -1.*scalefactor,1.*scalefactor);
						// kernel[k][l] = map(gs, 0, 1, -1.*(1./scalefactor),(1./scalefactor));
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
	}

	void update(){
		af.kernelmap(this);
	}
	
	void show(){
		ar.show(this); /* should just display an image (what about point orbit though w/ geo?)*/
	}
}
/* 

// the use functions set the image, so should be run when creating source.
	if(dispersed){
		useDispersed(modfac);
	} else {
		useOriginal();
	}

void useDispersed(int factor){
	dimg = createImage((simg.width*factor), (simg.height*factor), ARGB);
	
	float sw = (float)dimg.width;
	float sh = (float)dimg.height;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	dimg.resize(nw, nh);
	
	setDispersedImage(simg, dimg);
	blueline.set("aspect", float(dimg.width)/float(dimg.height));
	blueline.set("tex0", dimg);
}

void useOriginal(){
	blueline.set("aspect", float(simg.width)/float(simg.height));
	blueline.set("tex0", simg);
}

// The draw functions should go in the renderer?
void drawDispersed(){
	setDispersedImage(simg,dimg);
	blueline.set("tex0", dimg);
}

void drawOriginal(){
	blueline.set("tex0", simg);
}

void setDispersedImage(PImage source, PImage di) {
	source.loadPixels();
	di.loadPixels();
	for (int i = 0; i < di.width; i++){
		for (int j = 0; j < di.height; j++){
			int dindex = (i + j * di.width);
			if(i % modfac == 0 && j % modfac == 0){
				int x = i - 1;
				int y = j - 1;
				x = constrain(x, 0, source.width - 1);
				y = constrain(y, 0, source.height - 1);
				int sindex = (x + (y *source.width));
				if (sindex < source.pixels.length){
					di.pixels[dindex] = source.pixels[sindex];
				}
			} else {
				di.pixels[dindex] = color(0);
				}
			}
		}
	source.updatePixels();
	di.updatePixels();
}












*/