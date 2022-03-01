// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg;

PImage simg,dimg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
float scalefac,minscalefac,maxscalefac,chance,displayscale;

boolean dispersed;

void setup(){
	size(800,800, P3D);
	surface.setTitle("Arcane Propagations");
	pixelDensity(1);
	
	simg = loadImage("./imgs/buff_skate.JPG");
	// simg = loadImage("./imgs/face.png");
	// simg = loadImage("./imgs/p5sketch1.jpg");
	// simg = loadImage("./imgs/fezHassan.JPG");
	// simg = loadImage("./imgs/buildings.jpg");
	// simg = loadImage("./imgs/clouds.jpg");
	// simg = loadImage("./imgs/nasa.jpg");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// simg = loadImage("./imgs/nestedsquare.png");
	// simg = randomImage(width/4, height/4);
	// simg = noiseImage(width/4, height/4, 3, .6);
	// simg = kuficImage(2*width, 2*height);

	
	// simg.filter(GRAY);
	// simg.filter(POSTERIZE, 4);
	// simg.filter(BLUR, 2);
	// simg.filter(DILATE);
	// simg.filter(ERODE);
	
	// max for height and with is 16384
	pg = createGraphics(4000,4000, P2D);
	// pg = createGraphics(constrain(dimg.width*4, 0, 16384),constrain(dimg.height*4, 0, 16384), P2D);
	pg.noSmooth();
	
	// dmfac = 1;
	// downsample = modfac = dmfac;
	downsample = 1;
	modfac = 3;
	simg.resize(width/downsample,0);
	
	// Smaller values tend to fade out fast, larger values tend to oscillate
	scalefac = 0001.50;
	
	// use minscalefac / maxscalefac to weight towards negative transmission / positive transmission
	// minscalefac = 0.;
	// maxscalefac = 1.;

	xmg = loadxm(simg, kwidth);
	
	blueline = loadShader("blueline.glsl");
	
	dispersed = true;
	if(dispersed){
		// useDispersed(dmfac);
		useDispersed(modfac);
	} else {
		useOriginal();
	}
	blueline.set("resolution", float(pg.width), float(pg.height));
	imageMode(CENTER);
	
	// displayscale = 1.0;
	displayscale = .98;
	
	// frameRate(6.);
}

void draw(){
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	kernelp(simg, xmg);
	
	if(dispersed){
		drawDispersed();
	} else {
		drawOriginal();
	}
	image(pg, width/2, height/2, width*displayscale, height*displayscale);
}


void useDispersed(int factor){
	// dimg = createImage((simg.width*factor), (simg.height*factor), ARGB);
	dimg = createImage((simg.width*modfac), (simg.height*modfac), ARGB);
	// dimg = createImage((simg.width), (simg.height), ARGB);
	// dimg = createImage((simg.width*4), (simg.height*4), ARGB);
	dimg.resize(width/downsample,0);
	setDispersedImage(simg, dimg);
	blueline.set("aspect", float(dimg.width)/float(dimg.height));
	blueline.set("tex0", dimg);
}

void useOriginal(){
	blueline.set("aspect", float(simg.width)/float(simg.height));
	blueline.set("tex0", simg);
}

void drawDispersed(){
	setDispersedImage(simg,dimg);
	blueline.set("tex0", dimg);
}

void drawOriginal(){
	blueline.set("tex0", simg);
}


float[][] loadkernel(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	img.loadPixels();
	int offset = dim / 2;
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			float gs = (
				0.2989 *   red(img.pixels[loc]) +
				0.5870 * green(img.pixels[loc]) +
				0.1140 *  blue(img.pixels[loc])
				) / 255;
				
				// kern[i][j] = map(gs, 0, 1, -1.*scalefac,1.*scalefac);
				kern[i][j] = map(gs, 0, 1, 1.*scalefac,-1.*scalefac);
				// kern[i][j] = map(gs, 0, 1, -1.*minscalefac,1.*maxscalefac);
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
				// float xmsn = (ximg[loc][i][j]);
				// float xmsn = (ximg[loc][i][j] / kwidth);
				float xmsn = (ximg[loc][i][j] / pow(kwidth, 1.5)); /* smooth fadeout */
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 2.0)); /* Fades out quickly */
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 1.25)); /* stuttery for some reason, the floating operation?*/
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 3));
				// float xmsn = (ximg[loc][i][j] * 4.);
				// float xmsn = (ximg[loc][i][j] * 2.);
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

PImage noiseImage(int w, int h, int lod, float falloff){
	  noiseDetail(lod, falloff);
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				color c = color(lerp(0,1,noise(i*cos(i),j*sin(j), (i+j)/2))*255);
				int index = (i + j * rimg.width);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}

PImage kuficImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				chance = ((i % 2) + (j % 2));
				
				float wallornot = random(2.);
				int index = (i + j * rimg.width);
				if(wallornot <= chance){
						color c = color(0);
						rimg.pixels[index] = c;
					} else {
						color c = color(255-(255*(wallornot/2.)));
						rimg.pixels[index] = c;
					}
				}
			}
		rimg.updatePixels();
		return rimg;
	}
