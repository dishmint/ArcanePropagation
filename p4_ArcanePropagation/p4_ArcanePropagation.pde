// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage img,dimg;
float[] xmg;

float maxsum;
int matrixsize;
int modfac = 2;

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
	dimg = createImage(img.width * 2, img.height*2, ARGB);
	
	// img.filter(GRAY);
	img.resize(width/4,0);
	dimg.resize(width/4,0);
	
	loadDispersedImage(img, dimg);
	// maxsum = 255. * 3.;
	// xmg = loadxm(img);
	xmg = loadxm(dimg);
	
	matrixsize = 3;
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", float(pg.width), float(pg.height));
	// blueline.set("tex0", img);
	blueline.set("tex0", dimg);
	blueline.set("aspect", float(img.width)/float(img.height));

	// frameRate(1.);
}

void draw(){
	
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	// kernelp(img,xmg);
	kernelp2(img, dimg, xmg);
	
	// blueline.set("tex0", img);
	blueline.set("tex0", dimg);
	
	image(pg, 0, 0, width, height);
}

float[] loadxm(PImage image) {
	float[] xms = new float[image.width * image.height];

	image.loadPixels();
	for (int i = 0; i < image.width; i++){
		for (int j = 0; j < image.height; j++){
			int index = (i + j * image.width);

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
			float leak = ximg[loc];

			rtotal +=   red(img.pixels[loc]) * leak;
			gtotal += green(img.pixels[loc]) * leak;
			btotal +=  blue(img.pixels[loc]) * leak;
		}
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
