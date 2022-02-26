// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage simg,dimg;
float[][][] xmg;
int kwidth;
int modfac = 2;

void setup(){
	size(400,400, P3D);
	surface.setTitle("Arcane Propagations");
	pixelDensity(1);
	pg = createGraphics(400,400, P2D);
	pg.noSmooth();
	
	
	// simg = loadImage("./imgs/buff_skate.JPG");
	// simg = loadImage("./imgs/face.png");
	// simg = loadImage("./imgs/p5sketch1.jpg");
	// simg = loadImage("./imgs/fezHassan.JPG");
	// simg = loadImage("./imgs/buildings.jpg");
	simg = loadImage("./imgs/clouds.jpg");
	// simg = loadImage("./imgs/nasa.jpg");
	// simg = randomImage(width,height);
	dimg = createImage(simg.width * 2, simg.height*2, ARGB);
	
	// simg.filter(GRAY);
	simg.resize(width/4,0);
	dimg.resize(width/4,0);
	
	kwidth = 3;
	xmg = loadxm(simg, kwidth);
	
	loadDispersedImage(simg, dimg);

	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", float(pg.width), float(pg.height));
	// blueline.set("tex0", simg);
	blueline.set("tex0", dimg);
	blueline.set("aspect", float(simg.width)/float(simg.height));
	
	// frameRate(1.);
}

void draw(){
	
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	kernelp(simg,xmg);
	
	// blueline.set("tex0", simg);
	// kernelp(img,xmg);
	kernelp2(simg, dimg, xmg);
	
	// blueline.set("tex0", img);
	blueline.set("tex0", dimg);
	
	image(pg, 0, 0, width, height);
}


float[][] loadkernel(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	img.loadPixels();
	int offset = dim / 2;
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			float rxm = (red(image.pixels[index]));
			float gxm = (green(image.pixels[index]));
			float bxm = (blue(image.pixels[index]));

			// float gs = (rgs+ggs+bgs);
			// float txm = map(gs,0,maxsum,0.0,.25 * maxsum);
			
			float gs = ((rxm+gxm+bxm)/3.)/255.;
			// float gs = ((rxm+gxm+bxm)/255.);
			float txm = map(gs,0,3,0.0,.25 );
			// float txm = map(gs,0,3,0.1,.5 );

			xms[index] = txm;
		}
	}
	image.updatePixels();
	return xms;
}

void kernelp(PImage image, float[] ximage) {
	image.loadPixels();
	for (int i = 0; i < image.width; i++){
		for (int j = 0; j < image.height; j++){
			color c = convolution(i,j, matrixsize, image, ximage);
			int index = (i + j * image.width);
			image.pixels[index] = c;
		}
	}
	image.updatePixels();
}

void kernelp2(PImage source, PImage di, float[] ximage) {
	source.loadPixels();
	di.loadPixels();
	for (int i = 0; i < di.width; i++){
		for (int j = 0; j < di.height; j++){
			int dindex = (i + j * di.width);
			if(i % modfac == 0 && j % modfac == 0){
				// println("kernelp2:mod");
				int x = i - 1;
				int y = j - 1;
				x = constrain(x, 0, source.width - 1);
				y = constrain(y, 0, source.height - 1);
				int sindex = (x + (y *source.width));
				if (sindex < source.pixels.length){
					// println("kernelp2:mod:sindex");
					color c = convolution(x,y, matrixsize, source, ximage);
					// println("kernelp2:color: ", c);
					source.pixels[sindex] = c;
					di.pixels[dindex] = c;
					// println("kernelp2:mod:convolution");
				}
			} else {
				// println("kernelp2:empty");
				di.pixels[dindex] = color(0);
				}
			}
		}
		di.updatePixels();
		source.updatePixels();
}

// https://processing.org/examples/convolution.html
// Adjusted slightly for the purposes of this sketch
color convolution(int x, int y, int matrixsize, PImage img, float[] ximg)
{
	
	float rtotal = 0.0;
	float gtotal = 0.0;
	float btotal = 0.0;
	int offset = matrixsize / 2;
	for (int i = 0; i < matrixsize; i++){
		for (int j= 0; j < matrixsize; j++){

			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			float gs = (
				0.2989 *   red(img.pixels[loc]) +
				0.5870 * green(img.pixels[loc]) +
				0.1140 *  blue(img.pixels[loc])
				) / 255;
				
				// Large Output Scales generally will slow down the dispersion
				// kern[i][j] = gs*255.;
				// kern[i][j] = map(gs, 0, 1, -1.,1.);
				// kern[i][j] = map(gs, 0, 1, -10.,10.);
				// kern[i][j] = map(gs, 0, 1, -100.,100.);
				kern[i][j] = map(gs, 0, 1, -1000.,1000.);
			}
		}
		img.updatePixels();
		return kern;
	}
	
	float[][][] loadxm(PImage img, int kwidth) {
		float[][][] xms = new float[int(img.width * img.height)][kwidth][kwidth];
		float[][] kernel = new float[kwidth][kwidth];
		img.loadPixels();
		for (int i = 0; i < img.width; i++){
			for (int j = 0; j < img.height; j++){
				kernel = loadkernel(i,j, kwidth, img);
				int index = (i + j * img.width);
				xms[index] = kernel;
			}
		}
		img.updatePixels();
		return xms;
	}
	
	void kernelp(PImage img, float[][][] ximage) {
		img.loadPixels();
		for (int i = 0; i < img.width; i++){
			for (int j = 0; j < img.height; j++){
				color c = convolution(i,j, kwidth, img, ximage);
				int index = (i + j * img.width);
				img.pixels[index] = c;
			}
		}
		img.updatePixels();
	}
	
	
	// https://processing.org/examples/convolution.html
	// Adjusted slightly for the purposes of this sketch
	color convolution(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		float rtotal = 0.0;
		float gtotal = 0.0;
		float btotal = 0.0;
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				// float xmsn = (ximg[loc][i][j] / kwidth);
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 2));
				float xmsn = (ximg[loc][i][j] / pow(kwidth, 3));
				if(xloc == x && yloc == y){
					rtotal -= (  red(img.pixels[loc]) * xmsn);
					gtotal -= (green(img.pixels[loc]) * xmsn);
					btotal -= ( blue(img.pixels[loc]) * xmsn);
				} else {
					rtotal += (  red(img.pixels[loc]) * xmsn);
					gtotal += (green(img.pixels[loc]) * xmsn);
					btotal += ( blue(img.pixels[loc]) * xmsn);
				}
			}
		}
		
		return color(rtotal, gtotal, btotal);
	}
	
	PImage randomImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				color c = color(random(255.));
				int index = (i + j * rimg.width);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}
	return color(rtotal, gtotal, btotal);
}

void loadDispersedImage(PImage source, PImage di) {
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
