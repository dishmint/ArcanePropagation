// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PImage simg;
ArcaneGenerator arcgen;

int kernelWidth;
ArcanePropagator parc;
float scalefac,xsmnfactor,displayscale;

boolean dispersed;

void setup(){
	/* WINDOW SETUP */
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);

	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);
	// TODO: GUI: Set Framerate : frameRate(1);
	
	/* IMAGE SETUP */
	simg = loadImage("./imgs/universe.jpg");
	// arcgen = new ArcaneGenerator("random", width, height);
	// simg = arcgen.getImage();

	float sfdivisor = 1.0f / 16;
	scalefac = 255.0f * sfdivisor;
	/* 
		kernelWidth is the kernelsize

		as kw ⬆️ more pixels involved in convolution
		as kw ⬇️ less pixels involved in convolution
	 */
	// kernelWidth = 1~n; 5 is best for rdf
	kernelWidth = 5; /* 3 - default */

	/* Divisor: kernelsum / xsmnfactor */
	xsmnfactor = pow(kernelWidth, 2.); /* default */

	displayscale = 1.0;

	/* afilter = transmit|transmitMBL|amble|convolve|collatz|rdf|rdfr|rdft|rdfx|blur|dilate */
	parc = new ArcanePropagator(simg, "rdf", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
}

void draw(){
	parc.draw();
}