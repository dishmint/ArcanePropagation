// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

import com.krab.lazy.*;

PImage simg;
ArcaneGenerator arcgen;

int kernelWidth;
ArcanePropagator parc;
float kernelScale,xsmnfactor,displayscale;

ArcaneGenerator ag;

LazyGui gui;

void setup(){
	/* WINDOW SETUP */
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	surface.setResizable(true);
  	// surface.setLocation(18, 0); offset for me because I use Stage Manager on MacOS

	gui = new LazyGui(this);
	gui.toggleSet("Animate", false);

	imageMode(CENTER);

	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);
	
	/* IMAGE SETUP */
	simg = loadImage("./imgs/universe.jpg");


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
	// kernelWidth = 1; /* 1 */
	// kernelWidth = 2; /* 2 */
	kernelWidth = 3; /* 3 - default */
	// kernelWidth = 4; /* 4 */
	// kernelWidth = 5; /* 5 */
	// kernelWidth = 6; /* 6 */
	// kernelWidth = 7; /* 7 */

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
	parc = new ArcanePropagator(simg, "amble", "shader", kernelWidth, kernelScale, xsmnfactor, displayscale, colordivisor);

	// frameRate(1);
	// frameRate(5);
	// frameRate(12);
}

void draw(){
	parc.run();
}