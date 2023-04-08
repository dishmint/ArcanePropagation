// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PShader blueline;
PGraphics pg;

PImage simg,dimg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
int drawswitch = 0;
float kernelScale,xsmnfactor,chance,displayscale,sw,sh,scale,gsd;

boolean dispersed, hav;

ArcaneFilter af;
ArcaneGenerator ag;

void setup(){
	size(1422,800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);

	/* -------------------------------------------------------------------------- */
	/*                                 Load Image                                 */
	/* -------------------------------------------------------------------------- */
	
	/* ------------------------------- image files ------------------------------ */
	simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	
	/* ---------------------------- image generators ---------------------------- */
	// int noisew = int(0.0625 *  width);
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
		
	// simg.filter(GRAY);
	// simg.filter(POSTERIZE, 4);
	// simg.filter(BLUR, 2);
	// simg.filter(DILATE);
	// simg.filter(ERODE);
	// simg.filter(INVERT);
	// simg.filter(THRESHOLD, .8);


	/* -------------------------------------------------------------------------- */
	/*                             Remaining Settings                             */
	/* -------------------------------------------------------------------------- */
	
	
	dmfac = 1;
	downsample = modfac = dmfac;
	// downsample = 1;
	// modfac = 5;
	
	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	float sw = (float)simg.width;
	float sh = (float)simg.height;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	simg.resize(nw, nh);
	
	// sf ~~ rate of decay
	// float sf = 1.0f/255.0f; /* 25.0f */
	// kernelScale = 255. * sf;

	/* ^^ kernelScale is kernelScale  */
	/* scales the values of the kernel (-1.0~1.0) * kernelScale  */
	// kernelScale = 1.0f / 255.0f;
	kernelScale = 1.0f / 1.0f;
	// kernelScale = 0.098f / 1.0f;
	// kernelScale = 0.98f / 1.0f;
	// kernelScale = 0.50f / 1.0f;
	// kernelScale = 0.33f / 1.0f;
	
	// Determine the leak-rate (transmission factor) of each pixel
	// xsmnfactor = 1.;
	// xsmnfactor = pow(kwidth,0.5);
	// xsmnfactor = pow(kwidth,1.5);
	// xsmnfactor = pow(kwidth - 1,3.); /* default */
	xsmnfactor = 1.0f/pow(kwidth, 2.); /* default */
	// xsmnfactor = pow(kwidth,3.);
	// xsmnfactor = pow(kwidth,4.);
	// xsmnfactor = pow(kwidth,6.);
	// xsmnfactor = kernelScale; /* makes transmission some value between 0 and 1*/
	
	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/
	gsd = 1.0f/255.0f; /* 1.0f/ 765.0f | 255.0f | 9.0f | 85.0f | 3.0f */
	hav = true;
	xmg = loadxm(simg, kwidth);
	
	dispersed = false;
	displayscale = 1.0;
	// displayscale = 0.5;
	
	// max width and height is 16384 for the Apple M1 graphics card (according to Processing debug message)
	// pg = createGraphics(5000,5000, P2D);
	pg = createGraphics(2*simg.width,2*simg.height, P2D);
	// pg = createGraphics(10000,10000, P2D);
	pg.noSmooth();
	
	blueline = loadShader("blueline.glsl");
	float resu = 100.;
	blueline.set("resolution", resu*float(pg.width), resu*float(pg.height));
	
	// the unitsize determines the dimensions of a pixels for the shader
	blueline.set("unitsize", 1.00);
	blueline.set("densityscale", 1.00/displayDensity());
	// the thickness used to determine a points position is determined by thickness/tfac
	blueline.set("tfac", 1.0);
	
	/*
	- The radius of a point orbit is determined by rfac * thickness
	- when 1.0000 < rfac < 1.0009 values begin to display as black pixels, kind of like a mask.
	- rfac >= 1.5 == black screen
	- rfac == 0.0 == 1:1
	*/
	
	// TODO: add rfac slider
	// blueline.set("rfac", 0.0);
	blueline.set("rfac", 1.0);
	
	if(dispersed){
		useDispersed(modfac);
	} else {
		useOriginal();
	}

	background(0);
	/* 
		https://www.baeldung.com/java-8-lambda-expressions-tips
		^^ will help with functionalizing selectDraw so I can set the draw function in setup instead of in draw.
	 */
	// convolution — still | convolve | transmit | transmitMBL | switch | switchTotal | blur | weightedblur | gol | chladni
	af = new ArcaneFilter("chladni", kwidth, xsmnfactor);
}

void draw(){
	af.kernelmap( simg, xmg );
	background(0);
	pgDraw();
	shaderDraw();
}

void shaderDraw(){
	if(dispersed){
		drawDispersed();
	} else {
		drawOriginal();
	}
	image(pg, width/2, height/2, simg.width*displayscale, simg.height*displayscale);
}

void pgDraw(){
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
}

void switchdraw(int mod, int smearSelector){
	if(frameCount % mod == 0){
		drawswitch = 1 - drawswitch;
	}
	
	if(drawswitch == 0){
		af.setFilterMode("transmit");
	} else {
		af.setFilterMode("smear");
	}
}

void switchdrawTotal(int mod, int smearSelector){
	if(frameCount % mod == 0){
		drawswitch = 1 - drawswitch;
	}
	
	if(drawswitch == 0){
		af.setFilterMode("transmit");
	} else {
		af.setFilterMode("smearTotal");
	}
}

void useDispersed(int factor){
	dimg = createImage((simg.width*factor), (simg.height*factor), ARGB);
	
	float sw = (float)dimg.width;
	float sh = (float)dimg.height;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	dimg.resize(nw, nh);
	
	setDispersedImage(simg, dimg);
	blueline.set("aspect", float(dimg.width)/float(dimg.height));
	blueline.set("tex0", dimg);
}

void useOriginal(){
	blueline.set("aspect", float(simg.width)/float(simg.height));
	blueline.set("tex0", simg);
}

void drawDispersed(){
	setDispersedImage(simg,dimg);
	blueline.set("tex0", dimg);
}

void drawOriginal(){
	blueline.set("tex0", simg);
}

float computeGS(color px){
	float rpx = px >> 16 & 0xFF;
	float gpx = px >> 8 & 0xFF;
	float bpx = px & 0xFF;
	
	float gs = 1.;
	if(hav){
		// human grayscale
		gs = (
			0.2989 * rpx +
			0.5870 * gpx +
			0.1140 * bpx
			) * gsd;
	} else {
		// channel average
		gs = (rpx + gpx + bpx) * gsd;
	}
	return gs;
}

float[][] loadkernel(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	img.loadPixels();
	int offset = dim / 2;
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			
			color cpx = img.pixels[loc];
			
			float gs = computeGS(cpx);
			
			// the closer values are to 0 the more negative the transmission is, that's why a large value of kernelScale produces fast fades.
			kern[i][j] = map(gs, 0, 1, -1.*kernelScale,1.*kernelScale);
			}
		}
		img.updatePixels();
		return kern;
	}

int kerncenter(int dim){
	float kcenter = -0.5 + (0.5 *dim);
	return (int)kcenter;
}

int[][] makeEdgeKernel(int dim, int min, int max){
	int[][] ek = new int[dim][dim];
	int kc = kerncenter(dim);
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			if(i == kc && j == kc){
				ek[i][j] = max;
			} else {
				ek[i][j] = min;
			}
			}
		}
	return ek;
}
float[][] loadEdgeWeight(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	int[][] edge = makeEdgeKernel(dim, -1, 9);
	// {{-1,-1,-1},{-1,9,-1},{-1,-1,-1}}
	img.loadPixels();
	int offset = dim / 2;
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			
			color cpx = img.pixels[loc];
			
			float rpx = cpx >> 16 & 0xFF;
			float gpx = cpx >> 8 & 0xFF;
			float bpx = cpx & 0xFF;
			
			rpx += edge[i][j]/9;
			gpx += edge[i][j]/9;
			bpx += edge[i][j]/9;
			
			float gs = computeGS(cpx);
			
			kern[i][j] = map(gs, 0, 1, -1.*kernelScale,1.*kernelScale);
			}
		}
		img.updatePixels();
		return kern;
	}

float[][][] loadxm(PImage img, int kwidth) {
	float[][][] xms = new float[int(img.width * img.height)][kwidth][kwidth];
	float[][] kernel = new float[kwidth][kwidth];
	img.loadPixels();
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			kernel = loadkernel(i,j, kwidth, img);
			// kernel = loadEdgeWeight(i,j, kwidth, img);
			int index = (i + j * img.width);
			xms[index] = kernel;
		}
	}
	img.updatePixels();
	return xms;
}

void setDispersedImage(PImage source, PImage di) {
	source.loadPixels();
	di.loadPixels();
	for (int i = 0; i < di.width; i++){
		for (int j = 0; j < di.height; j++){
			int dindex = (i + j * di.width);
			if(i % modfac == 0 && j % modfac == 0){
				int x = i - 1;
				int y = j - 1;
				x = constrain(x, 0, source.width - 1);
				y = constrain(y, 0, source.height - 1);
				int sindex = (x + (y *source.width));
				if (sindex < source.pixels.length){
					di.pixels[dindex] = source.pixels[sindex];
				}
			} else {
				di.pixels[dindex] = color(0);
				}
			}
		}
	source.updatePixels();
	di.updatePixels();
}
