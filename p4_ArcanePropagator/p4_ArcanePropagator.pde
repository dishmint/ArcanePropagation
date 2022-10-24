// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PImage simg;
int kernelWidth;
ArcanePropagator parc;
float scalefac,xsmnfactor,displayscale;

boolean dispersed;

void setup(){
	// size(100, 100, P3D);
	// size(700, 350, P3D);
	// size(900, 900, P3D);
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(1);
	hint(ENABLE_STROKE_PURE);

	simg = loadImage("./imgs/nasa.jpg");
	// arcfilm = new Movie(this, "./videos/20220808-200543.mov");
	// arcfilm.loop();

	// simg.filter(GRAY);
	/*
		sf: Divisor which determines the pixel's x-strength

		To slow down transmission of transmit* functions increase sf
		To slow down transmission of convolve* functions decrease sf

	*/
	float sf = 0000.25;   /* 010.20 */
	// float sf = 0756.00;   /* 000.33 */
	scalefac = 255./sf;
	kernelWidth = 3;
	// Determine the leak-rate (transmission factor) of each pixel
	// xsmnfactor = pow(kernelWidth, 3.);
	// xsmnfactor = pow(kernelWidth, 2.); /* default */
	// xsmnfactor = kernelWidth;
	// xsmnfactor = pow(kernelWidth, 0.5);
	// xsmnfactor = pow(kernelWidth, 0.25);
	// xsmnfactor = pow(kernelWidth, 0.125);
	// xsmnfactor = 255.; 
	xsmnfactor = scalefac;
	
	// dispersed = true;
	displayscale = 1.0; /* float value to scale the displayed results (1.0 -> fits screen; 0.5 -> half-size) */

	String afilter = "convolve"; /* transmit|transmitMBL|convolve|test|blur|dilate */
	parc = new ArcanePropagator(simg, afilter, "shader", kernelWidth, scalefac, xsmnfactor, displayscale);

	background(0);
}

void draw(){
	parc.draw();
}