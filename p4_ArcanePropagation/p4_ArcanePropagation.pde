// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage simg;
float[][][] xmg;

float maxsum;
int kwidth;

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
	
	
	// simg.filter(GRAY);
	simg.resize(width,0);
	
	kwidth = 3;
	xmg = loadxm(simg, kwidth);
	
	
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", float(pg.width), float(pg.height));
	blueline.set("tex0", simg);
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
	
	blueline.set("tex0", simg);
	
	image(pg, 0, 0, width, height);
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
