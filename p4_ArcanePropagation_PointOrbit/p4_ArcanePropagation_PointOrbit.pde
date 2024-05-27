// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

/* --------------------------------- IMPORTS -------------------------------- */
import java.util.function.*;
import java.util.Arrays;
import processing.javafx.*;

/* --------------------------- IMAGE DECLARATIONS --------------------------- */
PGraphics pg;
PImage simg, dximg;
float[][][] xmg;

ArcaneFilter af;
ArcaneGenerator ag;
ArcaneTheme at;
ArcaneOrbit ao;

/* -------------------------------------------------------------------------- */
/*                                  SETTINGS                                  */
/* -------------------------------------------------------------------------- */

/* ------------------------------ KERNELWIDTHS ------------------------------ */
int[] kwOptions = {1, 2, 3, 4, 5, 6, 7, 8};
final int kw = kwOptions[2];
final int kwsq = (int)(pow(kw, 2));

/* ------------------------------ KERNELSCALES ------------------------------ */
//                           0      1      2      3      4       5       6         7         8           9
final float[] ksOptions = {1.00f, 0.75f, 0.50f, 0.33f, 0.25f, 0.125f, 0.0625f, 0.03125f, 0.015625f, 0.0078125f};
final float kernelScale = ksOptions[4];
// final float kernelScale = 5.0;

/* ------------------------------- DOWNSAMPLES ------------------------------ */
/* higher dsfloat -> higher framerate | 1.0~N | 2.25 Default */
//                                   0       1      2      3      4      5      6
final float[] downsampleOptions = {1.00f, 1.125f, 1.25f, 1.50f, 2.25f, 3.00f, 6.00f};
final float downsample = downsampleOptions[6];
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
final String sourcepath = sourcepathOptions[15];
final String mazesource = sourcepath;
// final String mazesource = sourcepathOptions[8];

final String[] generatorOptions = {"random", "kufic", "maze", "noise"};
final String generator = generatorOptions[2];

// TODO: Implement shift to transition from one image to another
/* ---------------------------------- ORBIT --------------------------------- */
final String[] orbits = {"points", "lines"};
final String orbit = orbits[0];

/* --------------------------------- THEMES --------------------------------- */
//                         0        1       2        3        4        5           6          7        8          9          10         11         12          13
final String[] themes = {"truth", "red", "blue", "green", "yellow", "rblue", "yellowbrick", "gred", "reen", "starrynight", "ember", "bloodred", "gundam", "moonlight"};
final String theme = themes[0];

/* --------------------------------- FILTERS -------------------------------- */
//                                 0          1            2             3         4         5          6            7         8       9        10         11         12        13       14
final String[] filterOptions = {"still", "transmit", "transmitMBL", "convolve", "amble", "collatz", "xcollatz", "xtcollatz", "rdf", "rdft", "arcblur", "xdilate", "xsdilate", "blur", "dilate"};
final String filter = filterOptions[2];

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

void setup(){
	/* -------------------------------------------------------------------------- */
	/*                               Sketch Settings                              */
	/* -------------------------------------------------------------------------- */
	// size(1422, 800, P2D);
	// size(1422, 800, FX2D);
	fullScreen(FX2D);
	// fullScreen(P2D);

	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	imageMode(CENTER);
	background(0);
	frameRate(framerate);
	
	/* -------------------------------------------------------------------------- */
	/*                                 Load Image                                 */
	/* -------------------------------------------------------------------------- */
	
	simg = loadImage(sourcepath);
	// simg = genImage(generator);
	
	/* -------------------------------------------------------------------------- */
	/*                             Remaining Settings                             */
	/* -------------------------------------------------------------------------- */
	
	// APPLY BASE FILTER
	// simg.filter(GRAY|BLUR|DILATE|ERODE|INVERT);
	// simg.filter(POSTERIZE|BLUR|THRESHOLD, strength);

	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	final float sw = (float)simg.pixelWidth;
	final float sh = (float)simg.pixelHeight;
	final float scale = min(pixelWidth/sw, pixelHeight/sh);
	
	final int nw = Math.round(sw*scale/downsample);
	final int nh = Math.round(sh*scale/downsample);
	simg.resize(nw, nh);
		
	xmg = loadxm(simg, kw);
	dximg = createImage(simg.pixelWidth/modfac, simg.pixelHeight/modfac, ARGB);
		
	af = new ArcaneFilter(filter, kw, xfac);
	at = new ArcaneTheme(theme);
	ao = new ArcaneOrbit(orbit);

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

void printstamp(String msg, int end, int start) {
	println(msg + " (s): " + (end - start) * 0.001);
}

void draw(){
	int sdraw = millis();
	af.kernelmap(simg, xmg);

	background(0);
	if (dispersed) {
		loadDX();
		ao.show(dximg);
	} else {
		ao.show(simg);
	}

	stroke(255);
	text("fps: " + str(frameRate), 25,25);
	int edraw = millis();
	print("draw time (s) — ");
	print(((edraw - sdraw) * 0.001) + "\r");
}

void loadDX(){
	simg.loadPixels();
	dximg.loadPixels();
	for (int i = 0; i < dximg.pixelWidth; i++){
		for (int j = 0; j < dximg.pixelHeight; j++){
			int dindex = (i + j * dximg.pixelWidth);
			int x = i - 1;
			int y = j - 1;
			x = constrain(x, 0, dximg.pixelWidth - 1);
			y = constrain(y, 0, dximg.pixelHeight - 1);
			int sindex = ((x*modfac) + ((y*modfac) * (simg.pixelWidth)));
			if (sindex < simg.pixels.length){
				dximg.pixels[dindex] = simg.pixels[sindex];
				}
			}
		}
	simg.updatePixels();
	dximg.updatePixels();
}

float computeGS(color px){
		float rpx = px >> 16 & 0xFF;
		float gpx = px >> 8 & 0xFF;
		float bpx = px & 0xFF;
				
		return (
				0.2989 * rpx +
				0.5870 * gpx +
				0.1140 * bpx
		) * colordiv;
}

float[][] loadkernel(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	img.loadPixels();
	int offset = int(dim * 0.5);
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.pixelWidth*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			// TODO: should gs be computed with a different divisor. 3? or should I just take the natural mean values instead of the graded grayscale?
			
			color cpx = img.pixels[loc];
			float gs = computeGS(cpx);
			
			kern[i][j] = map(gs, 0.0f, 1.0f, -1.0f*kernelScale,1.0f*kernelScale);
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
	int offset = int(dim * 0.5);
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.pixelWidth*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			
			color cpx = img.pixels[loc];
			
			float rpx = cpx >> 16 & 0xFF;
			float gpx = cpx >> 8 & 0xFF;
			float bpx = cpx & 0xFF;
			
			rpx += edge[i][j]/9;
			gpx += edge[i][j]/9;
			bpx += edge[i][j]/9;
			
			float gs = computeGS(color(rpx,gpx,bpx));
			
			kern[i][j] = map(gs, 0, 1, -1.*kernelScale,1.*kernelScale);
			}
		}
		img.updatePixels();
		return kern;
	}

float[][][] loadxm(PImage img, int kw) {
	float[][][] xms = new float[int(img.pixelWidth * img.pixelHeight)][kw][kw];
	float[][] kernel = new float[kw][kw];
	img.loadPixels();
	for (int i = 0; i < img.pixelWidth; i++){
		for (int j = 0; j < img.pixelHeight; j++){
			kernel = loadkernel(i,j, kw, img);
			// kernel = loadEdgeWeight(i,j, kw, img);
			int index = (i + j * img.pixelWidth);
			xms[index] = kernel;
		}
	}
	img.updatePixels();
	return xms;
}

void setDispersedImage(PImage source, PImage di) {
	source.loadPixels();
	di.loadPixels();
	for (int i = 0; i < di.pixelWidth; i++){
		for (int j = 0; j < di.pixelHeight; j++){
			int dindex = (i + j * di.pixelWidth);
			if(i % modfac == 0 && j % modfac == 0){
				int x = i - 1;
				int y = j - 1;
				x = constrain(x, 0, source.pixelWidth - 1);
				y = constrain(y, 0, source.pixelHeight - 1);
				int sindex = (x + (y *source.pixelWidth));
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