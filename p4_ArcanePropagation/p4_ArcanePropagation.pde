// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage img;
float[] xmg;

int matrixsize = 4;

void setup(){
	size(400,400, P3D);
	pixelDensity(1);
	pg = createGraphics(400,400, P2D);
	pg.noSmooth();
	
	
	// img = loadImage("./imgs/buff_skate.JPG");
	// img = loadImage("./imgs/face.png");
	img = loadImage("./imgs/p5sketch1.jpg");
	
	surface.setTitle("Arcane Propagations");
	// surface.setResizable(true);
	
	img.filter(GRAY);
	
	xmg = loadxm(img);
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", float(pg.width), float(pg.height));
	blueline.set("tex0", img);
	blueline.set("aspect", float(img.width)/float(img.height));

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


void resizeImage(PGraphics pg, PImage img){
	if (img.height > img.width) {
		float hRatio = pg.height / img.height;
		int h = int(img.height * hRatio);
		int w = int(img.width * hRatio);
		img.resize(w, h);
	// Horizontal
	} else if (img.width > img.height) {
		float wRatio = pg.width / img.width;
		int w = int(img.width * wRatio);
		int h = int(img.height * wRatio);
		img.resize(w, h);
 // 1:1
	} else {
		img.resize(width, height);
	}
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

			float gs = ((rgs+ggs+bgs))/255.;
			// float txm = map(gs,0,3,-.5,.125);
			// float txm = map(gs,0,3,.00009,1.);
			// float txm = map(gs,0,3,0.0,1.0);
			float txm = map(gs,0,3,0.0,.25);
			// float txm = map(gs,0,1,0.0,.25);
			// float txm = map(gs,0,1,-0.05,.05);
			// float txm = lerp(-.5,.5,gs);
			// float txm = lerp(-1.,1.,gs);
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
			// What pixel are we testing
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			// Make sure we haven't walked off our image, we could do better here
			loc = constrain(loc,0,img.pixels.length-1);
			// loc = (loc < 0) ? (img.pixels.length -1)+loc : (loc > img.pixels.length - 1) ? 0 : loc;
			
			float leak = ximg[loc];
			
			rtotal +=   red(img.pixels[loc]) * leak;
			gtotal += green(img.pixels[loc]) * leak;
			btotal +=  blue(img.pixels[loc]) * leak;

		}
	}
	
	return color(rtotal, gtotal, btotal);
}
