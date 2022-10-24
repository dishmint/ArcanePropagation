// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PImage simg;
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
	pixelDensity(1);
	hint(ENABLE_STROKE_PURE);
	background(0);
	
	/* IMAGE SETUP */
	simg = loadImage("./imgs/buildings.jpg");

	// simg.filter(GRAY);
	/*
		sf: Divisor which affects the pixel's x-strength

		It's not clear yet when this value has more effect, as transmission can also be affected by kernelWidth and xsmnfactor

	*/
	float sf = 0000.0625;   /* 010.20 */
	// float sf = 0000.125;   /* 010.20 */
	// float sf = 0000.25;   /* 010.20 */
	// float sf = 0756.00;   /* 000.33 */
	scalefac = 255./sf;
	kernelWidth = 3;

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
	displayscale = 0.75; /* float value to scale the displayed results (1.0 -> fits screen; 0.5 -> half-size) */

	String afilter = "convolve"; /* transmit|transmitMBL|convolve|test|blur|dilate */
	parc = new ArcanePropagator(simg, afilter, "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
}

void draw(){
	parc.draw();
}