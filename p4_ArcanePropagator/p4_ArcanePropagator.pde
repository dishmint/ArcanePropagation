// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
import processing.video.*;
PImage simg;
Movie mv;
int kernelWidth;
ArcanePropagator parc;
float scalefac,xsmnfactor,displayscale;

boolean dispersed;

void setup(){
	/* WINDOW SETUP */
	// size(100, 100, P3D);
	// size(700, 350, P3D);
	// size(900, 900, P3D);
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	// pixelDensity(1);
	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);
	// frameRate(1);
	
	/* IMAGE SETUP */
	simg = loadImage("./imgs/universe.jpg");
	// simg = loadImage("./imgs/nestedsquare.png");
	// simg = loadImage("./imgs/enter.jpg");
	// simg = loadImage("./imgs/nasa.jpg");
	// simg = loadImage("./imgs/buildings.jpg");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// int dimw = int(width * 0.5), dimh = int(height * 0.95);
	// simg = randomImage(dimw, dimh);
	// simg = noiseImage(dimw, dimh, 3, 0.6);
	// simg = kuficImage(dimw, dimh);

	// simg.filter(GRAY);
	// simg.filter(THRESHOLD);
	/*
		sf: Divisor which affects the pixel's x-strength

		It's not clear yet when this value has more effect, as transmission can also be affected by kernelWidth and xsmnfactor, or the image size it looks like.

	*/
	float sf = 0000.0625;   /* 010.20 */
	// float sf = 0000.125;   /* 010.20 */
	// float sf = 0000.25;   /* 010.20 */
	// float sf = 0756.00;   /* 000.33 */
	scalefac = 255./sf;
	/* 
		kw specifies the kernel area.

		on rdf, any kw above 9 appears static, kw of 5 is the most interesting.
	 */
	// kernelWidth = 1;
	// kernelWidth = 2;
	// kernelWidth = 3;
	// kernelWidth = 4;
	kernelWidth = 5; /* seems to be special for rdf */
	// kernelWidth = 9; 

	/* Determine the leak-rate (transmission factor) of each pixel */
	// xsmnfactor = pow(kernelWidth, 0.125);
	// xsmnfactor = pow(kernelWidth, 0.250);
	// xsmnfactor = pow(kernelWidth, 0.500);
	// xsmnfactor = kernelWidth;
	xsmnfactor = pow(kernelWidth, 2.); /* default */
	// xsmnfactor = pow(kernelWidth, 3.);
	// xsmnfactor = 255.; 
	// xsmnfactor = scalefac;
	
	// dispersed = true;
	/* TODO: ^^ dispersion needs to be setup  */
	displayscale = 1.0 /* * 0.5 */;

	/* afilter = transmit|transmitMBL|convolve|collatz|rdf|rdft|rdfx|blur|dilate */
	String afilter = "rdf"; 
	parc = new ArcanePropagator(simg, afilter, "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	
	// mv = new Movie(this, "./videos/20220808-200543.mov");
	// mv.loop();
	// parc = new ArcanePropagator(mv, afilter, "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
}

void draw(){
	parc.draw();
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
		float chance;
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