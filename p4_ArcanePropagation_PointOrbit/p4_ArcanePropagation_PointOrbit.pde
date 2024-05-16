// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
import com.wolfram.jlink.*;
import java.util.function.*;
import java.util.Arrays;
import processing.javafx.*;

KernelLink ml = null;
Expr imgclusters;

// CellularAutomaton variables
int rule, k, r1, r2;

PGraphics pg;

PImage simg, dximg;
float[][][] xmg;

ArcaneFilter af;
ArcaneGenerator ag;
ArcaneTheme at;
ArcaneOrbit ao;

/* ------------------------------ KERNELWIDTHS ------------------------------ */
int[] kwOptions = {1, 2, 3, 4, 5, 6, 7, 8};
final int kw = kwOptions[2];
final int kwsq = (int)(pow(kw, 2));

/* ------------------------------ KERNELSCALES ------------------------------ */
//                           0      1      2      3      4       5       6         7         8
final float[] ksOptions = {1.00f, 0.75f, 0.50f, 0.33f, 0.25f, 0.125f, 0.0625f, 0.03125f, 0.015625f};
final float kernelScale = ksOptions[4];
// final float kernelScale = 5.0;

/* ------------------------------- DOWNSAMPLES ------------------------------ */
/* higher dsfloat -> higher framerate | 1.0~N | 2.25 Default */
final float[] downsampleOptions = {1.00f, 1.25f, 2.25f, 3.00f};
final float downsample = downsampleOptions[2];
final boolean dispersed = true;
final int[] modfacs = {1, 2, 3, 4, 5};
final int modfac = modfacs[1];

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
   /* 10 */"imgs/sign1.jpg"
};
final String sourcepath = sourcepathOptions[9];


/* ---------------------------------- ORBIT --------------------------------- */
final String[] orbits = {"points", "lines"};
final String orbit = orbits[0];

/* --------------------------------- THEMES --------------------------------- */
//                         0       1       2         3        4           5           6          7           8         9          10         11
final String[] themes = {"red", "blue", "green", "yellow", "rblue", "yellowbrick", "gred", "starrynight", "ember", "bloodred", "gundam", "moonlight"};
final String theme = themes[8];

/* --------------------------------- FILTERS -------------------------------- */
//                                 0          1            2             3         4         5        6      7         8          9          10        11       12
final String[] filterOptions = {"still", "transmit", "transmitMBL", "convolve", "amble", "collatz", "rdf", "rdft", "arcblur", "xdilate", "xsdilate", "blur", "dilate"};
final String filter = filterOptions[0];

/* -------------------------------- SET VARS -------------------------------- */
final float[] xfacs = {1.0f/(float(kw) * float(kw)), 1.0f/kw, kw, kernelScale, 1.0};
final float xfac = xfacs[0];

final float[] colordivOptions = {1.0f/255.0f, 1.0f/ 765.0f, 255.0f, 9.0f, 85.0f, 3.0f };
final float colordiv = colordivOptions[0];

final float D4 = 0.25;
final boolean klinkQ = false;

void setup(){
	/* -------------------------------------------------------------------------- */
	/*                               Sketch Settings                              */
	/* -------------------------------------------------------------------------- */
	// size(1422, 800, P2D);
	// size(1422, 800, FX2D);
	fullScreen(FX2D);
	// surface.setTitle("Arcane Propagations");
	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	imageMode(CENTER);
	background(0);
	// noCursor();
	
	/* -------------------------------------------------------------------------- */
	/*                                 Load Image                                 */
	/* -------------------------------------------------------------------------- */
	
	simg = loadImage(sourcepath);
	
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
	
	if(klinkQ){
		setupWLKernel();
	}
	
	af = new ArcaneFilter(filter, kw, xfac);
	
	at = new ArcaneTheme(theme);
	ao = new ArcaneOrbit(orbit);

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

void cellularAutomaton(PImage img)
		{
		img.loadPixels();
		int[][] newClusters;
		try{
			int[][] clusterMatrix = (int[][])imgclusters.asArray(Expr.INTEGER, 2);
			newClusters = cellularAutomatize(rule,k,r1,r2, clusterMatrix);
		} catch (ExprFormatException e) {
			System.out.println("ClusterExpr::ExprFormatException: " + e.getMessage());
			return;
		}
		
		for (int i = 0; i < img.pixelWidth; i++){
			for (int j = 0; j < img.pixelHeight; j++){
				
				int cloc = i+j*(img.pixelWidth);
				cloc = constrain(cloc,0,img.pixels.length-1);
				
				// Get cluster number and turn it into a color scale.
				int cl = newClusters[i][j];
				float clf = (float)cl;
				float ks = (float)(255 / (k - 1));
				
				// image disappears quickly
				// img.pixels[cloc] *= (newClusters[i][j] / (k - 1));
				
				img.pixels[cloc] = color(clf * ks);
				// img.pixels[cloc] = color(img.pixels[cloc] * (clf * ks));
			}
		}
		img.updatePixels();
		}

int[][] cellularAutomatize(int rnum, int colors, int range1, int range2, int[][] clusters)
	{
	try {
		ml.putFunction("CellularAutomaton",3);
			ml.putFunction("List",3);
				ml.put(rule);
				// ml.put(k); /* Non Totalistic */
				ml.putFunction("List",2); /* Totalistic */
					ml.put(k);
					ml.put(1);
				ml.putFunction("List",2);
					ml.put(range1);
					ml.put(range2);
			ml.put(clusters);
			ml.putFunction("List",1);
				ml.putFunction("List",1);
					ml.putFunction("List",1);
						ml.put(frameCount);
		ml.waitForAnswer();
		Expr res = ml.getExpr();
		
		try {
			int[][] nc = (int[][]) res.asArray(Expr.INTEGER, 2);
			return nc;
		} catch (ExprFormatException e){
			System.out.println("CellularAutomatatize::ExprFormatException: " + e.getMessage());
			return clusters;
		}
		
		} catch (MathLinkException e) {
			System.out.println("CellularAutomatatize::Fatal error opening link: " + e.getMessage());
			return clusters;
		}
	}

	void stop() {
		ml.close();
	}

void setupWLKernel(){
	String mlargs = "-linkmode launch -linkname '\"/Applications/Mathematica.app/Contents/MacOS/MathKernel\" -mathlink'";
		
	try {
		ml = MathLinkFactory.createKernelLink(mlargs);
		ml.discardAnswer();
		} catch (MathLinkException e) {
			System.out.println("MathLinkFactory::Fatal error opening link: " + e.getMessage());
			return;
		}
		
		// Define CellularAutomaton parameters
		rule = 30;
		k = 2;
		r1 = r2 = 1;
	
	// Create 2D image array
	int[][] iarray = new int[simg.pixelWidth][simg.pixelHeight];
	
	simg.loadPixels();
	int simglen = simg.pixelWidth * simg.pixelHeight;
	for(int i=0; i<simg.pixelWidth; i++){
		for(int j=0; j<simg.pixelHeight; j++){
		int lc = (i*simg.pixelWidth) + j;
		lc = constrain(lc,0,simglen-1);
		iarray[i][j] = simg.pixels[lc];
		}
	}
	simg.updatePixels();
	
	try {
		// Evaluate (ClusteringComponents[image, k] - 1)
		ml.putFunction("Subtract",2);
			ml.putFunction("ClusteringComponents",2);
				ml.put(iarray);
				ml.put(k);
			ml.put(1);
		ml.waitForAnswer();
		imgclusters = ml.getExpr();
		} catch (MathLinkException e) {
			System.out.println("LoadingArcaneUtilities::Fatal error opening link: " + e.getMessage());
			return;
		}
}