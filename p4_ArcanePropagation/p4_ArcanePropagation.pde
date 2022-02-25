// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage img;
float[] xmg;

float maxsum;
int matrixsize;

void setup(){
	size(800,800, P3D);
	surface.setTitle("Arcane Propagations");
	pixelDensity(1);
	pg = createGraphics(800,800, P2D);
	pg.noSmooth();
	
	
	// img = loadImage("./imgs/buff_skate.JPG");
	// img = loadImage("./imgs/face.png");
	// img = loadImage("./imgs/p5sketch1.jpg");
	// img = loadImage("./imgs/fezHassan.JPG");
	// img = loadImage("./imgs/buildings.jpg");
	// img = loadImage("./imgs/clouds.jpg");
	img = loadImage("./imgs/nasa.jpg");
	
	
	// img.filter(GRAY);
	img.resize(width,0);
	
	maxsum = 255. * 3.;
	xmg = loadxm(img);
	
	matrixsize = 3;
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", float(pg.width), float(pg.height));
	blueline.set("tex0", img);
	blueline.set("aspect", float(img.width)/float(img.height));

	// frameRate(1.);
}

void draw(){
	
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	kernelp(img,xmg);
	
	blueline.set("tex0", img);
	
	image(pg, 0, 0, width, height);
}

float[] loadxm(PImage image) {
	float[] xms = new float[image.width * image.height];

	image.loadPixels();
	for (int i = 0; i < image.width; i++){
		for (int j = 0; j < image.height; j++){
			int index = (i + j * image.width);

			float rgs = (red(image.pixels[index]));
			float ggs = (green(image.pixels[index]));
			float bgs = (blue(image.pixels[index]));

			// float gs = (rgs+ggs+bgs);
			// float txm = map(gs,0,maxsum,0.0,.25 * maxsum);
			
			float gs = ((rgs+ggs+bgs)/3.)/255.;
			// float txm = map(gs,0,3,0.0,.25 );
			float txm = map(gs,0,3,0,.5);

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
			float leak = ximg[loc];

			rtotal +=   red(img.pixels[loc]) * leak;
			gtotal += green(img.pixels[loc]) * leak;
			btotal +=  blue(img.pixels[loc]) * leak;
		}
	}
	
	return color(rtotal, gtotal, btotal);
}
