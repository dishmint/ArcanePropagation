// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PImage simg;
int kernelWidth;
ArcanePropagator parc;
float scalefac,xsmnfactor,displayscale;

boolean dispersed;

void setup(){
	// size(100, 100, P3D);
	size(700, 350, P3D);
	// size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(1);
	hint(ENABLE_STROKE_PURE);
	
	simg = loadImage("./imgs/p5sketch1.jpg");
	
	// sf ~~ rate of decay
	float sf = 0025.00;   /* 010.20 */
	scalefac = 255./sf;
	kernelWidth = 3;
	// Determine the leak-rate (transmission factor) of each pixel
	xsmnfactor = pow(kernelWidth, 2.); /* default */
	
	dispersed = true;
	displayscale = 1.0;
		
	parc = new ArcanePropagator(simg, "transmit", "shader", kernelWidth, scalefac, xsmnfactor);

	background(0);
}

void draw(){
	parc.show();
}