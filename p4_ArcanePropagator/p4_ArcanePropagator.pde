// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PImage simg;
ArcaneGenerator arcgen;

int kernelWidth;
ArcanePropagator parc;
float kernelScale,xsmnfactor,displayscale;

ArcaneGenerator ag;

void setup(){
	/* WINDOW SETUP */
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);

	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);
	
	/* IMAGE SETUP */
	simg = loadImage("./imgs/mwrTn-pixelmaze.gif");


	/* ---------------------------- image generators ---------------------------- */
	// int noisew =  width/16; /* 2|16|32 */
	// int noiseh = height/16; /* 2|16|32 */
	// int noisew = int(0.0625 * width);
	// int noiseh = int(0.0625 * height);
	// Random Noise
	// ag = new ArcaneGenerator("random", noisew, noiseh);
	
	// Kufic Noise
	// ag = new ArcaneGenerator("kufic", noisew, noiseh);
	
	// Maze Noise
	// ag = new ArcaneGenerator("maze", noisew, noiseh);
	// PImage mimg = loadImage("./imgs/universe.jpg");
	// ag.setMazeSource(mimg);

	// Noise
	// ag = new ArcaneGenerator("noise", noisew, noiseh);
	// ag.setLod(3); ag.setFalloff(0.6f);
		
	/* -------------------------------- get image ------------------------------- */
	// simg = ag.getImage(); 

	/* scales the values of the kernel (-1.0~1.0) * kernelScale  */
	// kernelScale = 1.0f;
	kernelScale = 1.0f / 255.0f; /* default */
	// kernelScale = 1.0f / 0.098f;
	
	/* 
		kernelWidth is the kernelsize

		as kw ⬆️ more pixels involved in convolution
		as kw ⬇️ less pixels involved in convolution
	 */
	// kernelWidth = 1~n; 5 is best for rdf; 4 is best for rdfx
	// kernelWidth = 1; /* 3 - default */
	// kernelWidth = 2; /* 3 - default */
	// kernelWidth = 3; /* 3 - default */
	// kernelWidth = 4; /* 4 - default */
	kernelWidth = 5; /* 5 - default */
	// kernelWidth = 6; /* 6 - default */
	// kernelWidth = 7; /* 7 - default */

	/* Divisor: kernelsum / xsmnfactor */
	// xsmnfactor = 1.0f / pow(kernelWidth, 2.0f); /* default */
	// xsmnfactor = 1.0f / (pow(kernelWidth, 2.0f) - 1.0f);
	// xsmnfactor = 1.0f / kernelWidth;
	// xsmnfactor = kernelWidth;
	xsmnfactor = kernelScale;

	displayscale = 1.0;
	float colordivisor = 1.0f/255.0f;
	// float colordivisor = 255.0f;

	/* afilter = transmit|transmitMBL|amble|convolve|collatz|rdf|rdft|rdfm|rdfr|rdfx|blur|dilate */
	parc = new ArcanePropagator(simg, "rdfx", "shader", kernelWidth, kernelScale, xsmnfactor, displayscale, colordivisor);

	// frameRate(1);
	// frameRate(5);
	// frameRate(12);
}

void draw(){
	parc.draw();
}