// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

import com.krab.lazy.*;

PImage simg;
ArcaneGenerator arcgen;

int kernelWidth;
ArcanePropagator parc;
float kernelScale,xsmnfactor,displayscale;
String[] afilter = {"amble", "transmit", "transmitMBL", "convolve", "collatz", "rdf", "rdft", "rdfm", "rdfr", "rdfx", "blur", "dilate"};
String flt;

ArcaneGenerator ag;

LazyGui gui;

void setup(){
	/* WINDOW SETUP */
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	surface.setResizable(true);
  	// surface.setLocation(18, 0); offset for me because I use Stage Manager on MacOS

	gui = new LazyGui(this, new LazyGuiSettings()
		.setLoadLatestSaveOnStartup(false)
		// .setAutosaveOnExit(false)
		);
	
	gui.toggleSet("Run", false);
	gui.sliderInt("Steps", 1, 1, 120);

	imageMode(CENTER);

	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);
	
	/* IMAGE SETUP */
	simg = loadImage("./imgs/universe.jpg");

	/* scales kernel values (-1.0~1.0) * kernelScale  */
	gui.slider("ArcaneSettings/KernelScale", 1.0f/255.0f, 0.0f, 1.0f);
	
	/* TODO: kernelWidth guislider needs to wait for the filter to apply to all pixels before the kw changes, otherwise index out of bounds error  */
	// gui.sliderInt("ArcaneSettings/KernelWidth", 3, 1, 7);
	kernelWidth = 3;

	/* TODO:
		xsmnfactor : radio({1,2,3,4})
			1 -> 1/(kernelWidth^2),
			2 -> 1/(kernelWidth^2 - 1),,
			3 -> 1/kernelWidth,
			4 -> kernelWidth
			5 -> gui.slider("ArcaneSettings/KernelScale")
		 */
	/* Divisor: kernelsum / xsmnfactor */
	xsmnfactor = 1.0f / pow(kernelWidth, 2.0f); /* default */
	// xsmnfactor = 1.0f / (pow(kernelWidth, 2.0f) - 1.0f);
	// xsmnfactor = 1.0f / kernelWidth;
	// xsmnfactor = kernelWidth;
	// xsmnfactor = kernelScale;
	// xsmnfactor = gui.slider("ArcaneSettings/KernelScale");

	displayscale = 1.0;
	float colordivisor = 1.0f/255.0f;
	// float colordivisor = 255.0f;

	/* afilter = transmit|transmitMBL|amble|convolve|collatz|rdf|rdft|rdfm|rdfr|rdfx|blur|dilate */
	parc = new ArcanePropagator(
		simg,
		gui.radio("ArcaneSettings/Filter", afilter, "transmit"), 
		"shader", 
		// gui.sliderInt("ArcaneSettings/KernelWidth"), 
		kernelWidth, 
		gui.slider("ArcaneSettings/KernelScale"), 
		xsmnfactor, displayscale, colordivisor
		);
	parc.debug();
}

void draw(){
	parc.setFilter(gui.radio("ArcaneSettings/Filter", afilter));
	parc.setKernelScale(gui.slider("ArcaneSettings/KernelScale"));
	// parc.setKernelWidth(gui.sliderInt("ArcaneSettings/KernelWidth"));
	if (frameCount % gui.sliderInt("Steps") == 0){
		parc.run();
	}
}