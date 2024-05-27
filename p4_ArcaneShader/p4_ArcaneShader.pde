// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PShader blueline;
PGraphics pg;

PImage simg,dimg;
float[][][] xmg;

/* ------------------------------ KERNELWIDTHS ------------------------------ */
int[] kwOptions = {1, 2, 3, 4, 5, 6, 7, 8};
final int kw = kwOptions[2];
final int kwsq = (int)(pow(kw, 2));

int drawswitch = 0;
float chance;

boolean hav;

ArcaneFilter af;
ArcaneGenerator ag;

/* ------------------------------ KERNELSCALES ------------------------------ */
//                           0      1      2      3      4       5       6         7         8           9
final float[] ksOptions = {1.00f, 0.75f, 0.50f, 0.33f, 0.25f, 0.125f, 0.0625f, 0.03125f, 0.015625f, 0.0078125f};
final float kernelScale = ksOptions[4];
// final float kernelScale = 5.0;

/* ------------------------------- DOWNSAMPLES ------------------------------ */
/* higher dsfloat -> higher framerate | 1.0~N | 2.25 Default */
//                                   0       1      2      3      4      5      6
final float[] downsampleOptions = {1.00f, 1.125f, 1.25f, 1.50f, 2.25f, 3.00f, 6.00f};
final float downsample = downsampleOptions[0];
final boolean dispersed = true;
final int[] modfacs = {1, 2, 3, 4, 5, 6, 7, 8};
final int modfac = modfacs[2];

final int mfd = 4;
final float	dmfd = modfac/mfd;
final float	fmfd = 1.0/modfac;

/* ------------------------------ IMAGE SOURCE ------------------------------ */
final String[] sourcepathOptions = {
	/* 0 */"imgs/nasa.jpg", 
	/* 1 */"imgs/face.png", 
	/* 2 */"imgs/buildings.jpg", 
	/* 3 */"imgs/mwrTn-pixelmaze.gif", 
	/* 4 */"imgs/ryoji-iwata-n31JPLu8_Pw-unsplash.jpg",
	/* 5 */"imgs/buff_skate.JPG",
	/* 6 */"imgs/universe.jpg",
	/* 7 */"imgs/enrapture-captivating-media-8_oFcxtXUSU-unsplash.jpg",
	/* 8 */"imgs/planetsAbstract.jpg",
	/* 9 */"imgs/enter.jpg",
   /* 10 */"imgs/sign1.jpg",
   /* 11 */"imgs/p5sketch1.jpg",
   /* 12 */"imgs/mountains_1.jpg",
   /* 13 */"imgs/clouds.jpg",
   /* 14 */"imgs/sora-sagano-7LWIGWh-YKM-unsplash.jpg",
   /* 15 */"imgs/fruit.jpg"
};
final String sourcepath = sourcepathOptions[12];
final String mazesource = sourcepath;

// convolution — still | convolve | collatz | transmit | transmitMBL | amble | smear | smearTotal | switch | switchTotal | blur | weightedblur | gol | chladni | rdf(t|x|r|m)
/* --------------------------------- THEMES --------------------------------- */
// THEMES
final int RED = 1;
final int BLUE = 2;
final int GREEN = 3;
final int YELLOW = 4;
final int RBLUE = 5;
final int YELLOWBRICK = 6;
final int GRED = 7;
final int STARRYNIGHT = 8;
final int EMBER = 9;
final int BLOODRED = 10;
final int GUNDAM = 11;
final int MOONLIGHT = 12;

// ALPHAS
final int ALPHA1 = 1;
final int ALPHAC = 2;
final int ALPHAY = 3;

// GRADERS
final int GRADE   = 1;
final int NOGRADE = 2;
final int SOURCE  = 3;

//                     0     1     2       3      4         5         6        7         8       9        10       11
final int[] themes = {RED, BLUE, GREEN, YELLOW, RBLUE, YELLOWBRICK, GRED, STARRYNIGHT, EMBER, BLOODRED, GUNDAM, MOONLIGHT};
final int theme = themes[11];

/* --------------------------------- ALPHAS --------------------------------- */
final int[] alphas = {ALPHA1, ALPHAC, ALPHAY};
final int alpha = alphas[0];

/* --------------------------------- GRADES --------------------------------- */
final int[] grades = {GRADE, NOGRADE, SOURCE};
final int grade = grades[2];

/* --------------------------------- FILTERS -------------------------------- */
//                                 0          1            2             3         4         5          6            7         8       9        10         11         12        13       14
final String[] filterOptions = {"still", "transmit", "transmitMBL", "convolve", "amble", "collatz", "xcollatz", "xtcollatz", "rdf", "rdft", "arcblur", "xdilate", "xsdilate", "blur", "dilate"};
final String filter = filterOptions[3];

/* -------------------------------- SET VARS -------------------------------- */
//                                0                 1      2       3        4
final float[] xfacs = {1.0f/pow(float(kw), 2.0), 1.0f/kw, kw, kernelScale, 1.0};
final float xfac = xfacs[0];

final float[] colordivOptions = {1.0f/255.0f, 1.0f/ 765.0f, 255.0f, 9.0f, 85.0f, 3.0f };
final float colordiv = colordivOptions[0];

final float D4 = 0.25;
//                               0    1   2   3   4   5   6   7  8  9
final int[] framerateOptions = {120, 90, 75, 60, 48, 30, 24, 12, 6, 1};
final int framerate = framerateOptions[0];

final float displayscale = 1.0;
final float resolutionScale = 1000.00f;

void setup(){
	size(1422,800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);

	/* -------------------------------------------------------------------------- */
	/*                                 Load Image                                 */
	/* -------------------------------------------------------------------------- */
	
	simg = loadImage(sourcepath); 
	// simg = genImage(generator); 
	// simg.filter(GRAY);

	/* -------------------------------------------------------------------------- */
	/*                             Remaining Settings                             */
	/* -------------------------------------------------------------------------- */
		
	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	final float sw = (float)simg.width;
	final float sh = (float)simg.height;
	final float scale = min(width/sw, height/sh);
	
	final int nw = Math.round(sw*scale/downsample);
	final int nh = Math.round(sh*scale/downsample);
	simg.resize(nw, nh);

	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/
	hav = true;
	xmg = loadxm(simg, kw);
	
	// max width and height is 16384 for the Apple M1 graphics card (according to Processing debug message)
	pg = createGraphics(2*simg.width,2*simg.height, P2D);
	pg.noSmooth();
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", resolutionScale*float(pg.width), resolutionScale*float(pg.height));
	
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
	blueline.set("rfac", 0.0);
	// blueline.set("rfac", 0.50);
	// blueline.set("rfac", 1.0);

	blueline.set("theme", theme);
	blueline.set("alpha", alpha);
	blueline.set("grader", grade);
	
	if(dispersed){
		useDispersed(modfac);
	} else {
		useOriginal();
	}

	background(0);

	af = new ArcaneFilter(filter, kw, xfac);
}

void draw(){
	af.kernelmap( simg, xmg );
	background(0);
	pgDraw();
	shaderDraw();
	showFrameRate();
}

void showFrameRate(){
	pushMatrix();
	final String fr = "fps: " + str(frameRate);
	stroke(255);
	text(fr, 25,25);
	popMatrix();
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
	
	final float sw = (float)dimg.width;
	final float sh = (float)dimg.height;
	final float scale = min(width/sw, height/sh);
	
	final int nw = Math.round(sw*scale);
	final int nh = Math.round(sh*scale);
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
	final float rpx = px >> 16 & 0xFF;
	final float gpx = px >> 8 & 0xFF;
	final float bpx = px & 0xFF;
	
	float gs = 1.;
	if(hav){
		// human grayscale
		gs = (
			0.2989 * rpx +
			0.5870 * gpx +
			0.1140 * bpx
			) * colordiv;
	} else {
		// channel average
		gs = (rpx + gpx + bpx) * colordiv;
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

PImage genImage(String generator){
	int noisew = int(0.0625 *  width);
	int noiseh = int(0.0625 * height);
	switch (generator) {
		case "random":
			ag = new ArcaneGenerator("random", noisew, noiseh);
			break;
		case "kufic":
			ag = new ArcaneGenerator("kufic", noisew, noiseh);
			break;
		case "maze":
			final PImage mimg = loadImage(mazesource);
			ag = new ArcaneGenerator("maze", noisew, noiseh);
			ag.setMazeSource(mimg);
			break;
		case "noise":
			ag = new ArcaneGenerator("noise", noisew, noiseh);
			ag.setLod(3); ag.setFalloff(0.6f);
			break;
		default:
			ag = new ArcaneGenerator("random", noisew, noiseh);
			break;
	}
	return ag.getImage(); 
}