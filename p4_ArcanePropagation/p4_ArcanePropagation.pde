// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage img;
float[] xmg;

int matrixsize = 3;

void setup(){
	size(800, 800, P3D);
	
	pg = createGraphics(800, 800, P2D);
	pg.noSmooth();
	
	img = loadImage("./imgs/buff_skate.JPG");
	// img = loadImage("./imgs/face.png");
	if(img.width > img.height){
			img.resize(width,0);
	} else {
		img.resize(0,height);
	}
	
	xmg = loadxm(img);
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", float(pg.width), float(pg.height));
	blueline.set("tex0", img);
	blueline.set("aspect", float(img.width)/float(img.height));
}

void draw(){
	// blueline.set("time", millis()/1000.);

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
			// float gs = ((rgs+ggs+bgs)/3.)/255.;
			// float txm = map(gs,0,1,-1,1);
			float gs = ((rgs+ggs+bgs))/255.;
			float txm = map(gs,0,3,-1,1);
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
	// float total = 0.0;
	float rtotal = 0.0;
	float gtotal = 0.0;
	float btotal = 0.0;
	int offset = matrixsize / 2;
	for (int i = 0; i < matrixsize; i++){
		for (int j= 0; j < matrixsize; j++){
			// What pixel are we testing
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			// Make sure we haven't walked off our image, we could do better here
			loc = constrain(loc,0,img.pixels.length-1);
			
			// Large divisor means less time!
			// float r = random(1.);
			// float leak = (ximg[loc]+r);
			// float leak = (ximg[loc] * 10.);
			float leak = (ximg[loc]);
			
			rtotal +=   red(img.pixels[loc]) * leak;
			gtotal += green(img.pixels[loc]) * leak;
			btotal +=  blue(img.pixels[loc]) * leak;

		}
	}
	
	// constrain(rtotal, 0, 255);
	// constrain(gtotal, 0, 255);
	// constrain(btotal, 0, 255);
	return color(rtotal, gtotal, btotal);
}
