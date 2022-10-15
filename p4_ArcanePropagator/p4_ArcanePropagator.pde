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
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(1);
	hint(ENABLE_STROKE_PURE);
	
	// simg = loadImage("./imgs/p5sketch1.jpg");
	simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	
	// sf ~~ rate of decay
	// float sf = 0025.00;   /* 010.20 */
	float sf = 0756.00;   /* 010.20 */
	scalefac = 255./sf;
	kernelWidth = 3;
	// Determine the leak-rate (transmission factor) of each pixel
	xsmnfactor = pow(kernelWidth, 2.); /* default */
	
	dispersed = true;
	displayscale = 1.0;
	
	// parc = new ArcanePropagator(simg, "transmit", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	parc = new ArcanePropagator(simg, "convolve", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	// parc = new ArcanePropagator(simg, "transmitMBL", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	// parc = new ArcanePropagator(simg, "blur", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	// parc = new ArcanePropagator(simg, "dilate", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);

	background(0);
}

void draw(){
	parc.update();
	parc.show();
}