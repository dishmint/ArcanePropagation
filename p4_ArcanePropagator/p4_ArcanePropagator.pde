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

	// simg = loadImage("./imgs/p5sketch1.jpg");
	// simg = loadImage("./imgs/buff_skate.JPG");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// simg = loadImage("./imgs/mwrTn-pixelmaze_copy.png");
	// simg = loadImage("./imgs/enrapture-captivating-media-8_oFcxtXUSU-unsplash.jpg");
	// simg = loadImage("./imgs/sora-sagano-7LWIGWh-YKM-unsplash.jpg");
	// simg = loadImage("./imgs/nestedsquare.png");
	simg = loadImage("./imgs/universe.jpg");

	// sf ~~ rate of decay
	// float sf = 0005.00;   /* 010.20 */
	// float sf = 0025.00;   /* 010.20 */
	// float sf = 0125.00;   /* 002.04 */
	float sf = 0756.00;   /* 000.33 */
	scalefac = 255./sf;
	kernelWidth = 3;
	// Determine the leak-rate (transmission factor) of each pixel
	xsmnfactor = pow(kernelWidth, 2.); /* default */
	// xsmnfactor = pow(kernelWidth, 3.);
	// xsmnfactor = pow(kernelWidth, 0.5);
	// xsmnfactor = 255.; 
	// xsmnfactor = scalefac;
	
	// dispersed = true;
	displayscale = 1.0;
	// displayscale = 0.5;
	
	// parc = new ArcanePropagator(simg, "transmit", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	// parc = new ArcanePropagator(simg, "transmitMBL", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	parc = new ArcanePropagator(simg, "convolve", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	/* 
		NOTE:
		Something makes me think that the values for convolve are somehow to big.. that's why everything goes to zero in the second frame.
	 */
	/* 
		NOTE: NO values are zero-ed out here, why does the screen go black? Is it the shader theme?

	 */
	// parc = new ArcanePropagator(simg, "blur", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	// parc = new ArcanePropagator(simg, "dilate", "shader", kernelWidth, scalefac, xsmnfactor, displayscale);
	
	// parc = new ArcanePropagator(simg, "transmit", "geo", kernelWidth, scalefac, xsmnfactor, displayscale);

	background(0);
}

void draw(){
	parc.show();
	parc.update();
}