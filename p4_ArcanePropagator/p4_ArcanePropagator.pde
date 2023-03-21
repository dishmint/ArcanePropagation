// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PImage simg;
ArcaneGenerator arcgen;

int kernelWidth;
ArcanePropagator parc;
float kernelScale,xsmnfactor,displayscale;

void setup(){
	/* WINDOW SETUP */
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);

	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);
	
	/* IMAGE SETUP */
	simg = loadImage("./imgs/universe.jpg");
	// arcgen = new ArcaneGenerator("random", int(width * 0.95), height);
	// simg = arcgen.getImage();

	/* scales the values of the kernel (-1.0~1.0) * kernelScale  */
	// kernelScale = 1.0f / 255.0f;
	kernelScale = 1.0f / 1.0f;
	// kernelScale = 1.0f / 0.098f;
	
	/* 
		kernelWidth is the kernelsize

		as kw ⬆️ more pixels involved in convolution
		as kw ⬇️ less pixels involved in convolution
	 */
	// kernelWidth = 1~n; 5 is best for rdf; 4 is best for rdfx
	kernelWidth = 3; /* 3 - default */

	/* Divisor: kernelsum / xsmnfactor */
	xsmnfactor = 1.0f / pow(kernelWidth, 2.0f); /* default */
	// xsmnfactor = 1.0f / kernelWidth;
	// xsmnfactor = kernelWidth;
	// xsmnfactor = kernelScale;

	displayscale = 1.0;

	/* afilter = transmit|transmitMBL|amble|convolve|collatz|rdf|rdft|rdfm|rdfr|rdfx|blur|dilate */
	parc = new ArcanePropagator(simg, "transmit", "shader", kernelWidth, kernelScale, xsmnfactor, displayscale);;
}

void draw(){
	parc.draw();
}