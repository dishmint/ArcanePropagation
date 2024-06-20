// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
import com.wolfram.jlink.*;

KernelLink ml = null;
Expr imgclusters;


PShader blueline;
PGraphics pg;

ArcaneGenerator ag;

PImage simg,dimg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
int drawswitch = 0;
float scalefac,xsmnfactor,chance,displayscale,sw,sh,scale,gsd;

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
   /* 15 */"imgs/fruit.jpg",
   /* 16 */"imgs/abstract_1.PNG",
   /* 17 */"imgs/abstract_2.PNG",
   /* 18 */"imgs/fruit.jpg",
   /* 19 */"imgs/abstract_3.PNG",
   /* 20 */"imgs/abstract_4.JPG",
   /* 21 */"imgs/andrea-leopardi-5qhwt_Lula4-unsplash.jpg",
   /* 22 */"imgs/fzn_dishmint.JPG",
   /* 23 */"imgs/fezHassan.JPG",
   /* 24 */"imgs/roc_flour.jpg",
   /* 25 */"imgs/shio-yang-b6i9pe16pAg-unsplash.jpg",
   /* 26 */"imgs/binarized_moon.png",
   /* 27 */"imgs/binarized_moon_inverted.png",
   /* 28 */"imgs/nestedsquare.png",
   /* 29 */"imgs/ArcaneTest/block-6.png",
   /* 30 */"imgs/ArcaneTest/patchwork-51.png",
   /* 31 */"imgs/ArcaneTest/patchwork-51-image.png",
   /* 32 */"imgs/ArcaneTest/patchwork-1080-image.png",
   /* 33 */"imgs/ArcaneTest/center-50.png",
   /* 34 */"imgs/ArcaneTest/center-1080.png"
};

final String sourcepath = sourcepathOptions[29];
final String mazesource = sourcepath;
// final String mazesource = sourcepathOptions[8];

final String[] generatorOptions = {"random", "kufic", "maze", "noise"};
final String generator = generatorOptions[2];


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

// GEOQ
final int GEO   = 1;
final int NOGEO = 2;

//                     0     1     2       3      4         5         6        7         8       9        10       11
final int[] themes = {RED, BLUE, GREEN, YELLOW, RBLUE, YELLOWBRICK, GRED, STARRYNIGHT, EMBER, BLOODRED, GUNDAM, MOONLIGHT};
final int theme = themes[4];

/* --------------------------------- ALPHAS --------------------------------- */
final int[] alphas = {ALPHA1, ALPHAC, ALPHAY};
final int alpha = alphas[2];

/* --------------------------------- GRADES --------------------------------- */
final int[] grades = {GRADE, NOGRADE, SOURCE};
final int grade = grades[0];
final int[] geos = {GEO, NOGEO};
final int geoq = geos[0];

final boolean dispersed = false;
boolean hav, klinkQ;

//                               0    1   2   3   4   5   6   7  8  9 10
final int[] framerateOptions = {120, 90, 75, 60, 48, 30, 24, 12, 6, 3, 1};
final int framerate = framerateOptions[0];

// CellularAutomaton variables
int rule, k, r1, r2;

void setup(){
	// size(25,25, P3D);
	// size(100,100, P3D);
	// size(200,200, P3D);
	// size(300,300, P3D);
	// size(355,200, P3D);
	// size(711,400, P3D);
	// size(500,500, P3D);
	size(1422,800, P3D);
	// size(1600,900, P3D);
	// size(2560,1440, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);
	frameRate(framerate);

	simg = loadImage(sourcepath);
	// simg = genImage(generator);
	
	// simg.filter(GRAY);
	// simg.filter(POSTERIZE, 4);
	// simg.filter(BLUR, 2);
	// simg.filter(DILATE);
	// simg.filter(ERODE);
	// simg.filter(INVERT);
	// simg.filter(THRESHOLD, .8);
	
	dmfac = 1;
	downsample = modfac = dmfac;
	// downsample = 1;
	// modfac = 5;
	
	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	float sw = (float)simg.pixelWidth;
	float sh = (float)simg.pixelHeight;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	simg.resize(nw, nh);
	
	// sf ~~ rate of decay
	// convolve: As sf increases decay-rate increases
	// transmit: As sf increases decay-rate decreases
	// smear: As sf increases      smear decreases
	// float sf = 0000.50;   /* 510.00 */
	// float sf = 0001.00;   /* 255.00 */
	// float sf = 0002.00;   /* 127.50 */
	// float sf = 0003.00;   /* 085.00 */
	// float sf = 0004.00;   /* 063.75 */
	// float sf = 0005.00;   /* 051.00 */
	// float sf = 0006.00;   /* 042.50 */
	// float sf = 0010.00;   /* 025.50 */
	// float sf = 0012.00;   /* 021.25 */
	// float sf = 0015.00;   /* 017.00 */
	// float sf = 0017.00;   /* 015.00 */
	// float sf = 0020.00;   /* 012.75 */
	float sf = 0025.00;   /* 010.20 */
	// float sf = 0027.00;   /* ————— */
	// float sf = 0030.00;   /* 008.50 */
	// float sf = 0034.00;   /* 007.50 */
	// float sf = 0050.00;   /* 005.10 */
	// float sf = 0051.00;   /* 005.00 */
	// float sf = 0060.00;   /* 004.25 */
	// float sf = 0068.00;   /* 003.75 */
	// float sf = 0075.00;   /* 003.40 */
	// float sf = 0085.00;   /* 003.00 */
	// float sf = 0100.00;   /* 002.55 */
	// float sf = 0102.00;   /* 002.50 */
	// float sf = 0125.00;   /* 002.04 */
	// float sf = 0150.00;   /* 001.70 */
	// float sf = 0170.00;   /* 001.50 */
	// float sf = 0204.00;   /* 001.25 */
	// float sf = 0250.00;   /* 001.02 */
	// float sf = 0255.00;   /* 001.00 */
	// float sf = 0382.50;   /* 000.66 */
	// float sf = 0510.00;   /* 000.50 */
	// float sf = 0637.50;   /* 000.40 */
	// float sf = 0765.00;   /* 000.33 */ /* works well with transmit */
	// float sf = 1020.00;   /* 000.25 */
	// float sf = 2040.00;   /* 000.125 */
	// float sf = 3750.00;   /* 000.068 */
	// float sf = 4080.00;   /* 000.0625 */
	scalefac = 255./sf;
	
	// Determine the leak-rate (transmission factor) of each pixel
	// xsmnfactor = 1.;
	// xsmnfactor = pow(kwidth,0.5);
	// xsmnfactor = pow(kwidth,1.5);
	// xsmnfactor = pow(kwidth - 1,3.); /* default */
	xsmnfactor = pow(kwidth, 2.); /* default */
	// xsmnfactor = pow(kwidth,3.);
	// xsmnfactor = pow(kwidth,4.);
	// xsmnfactor = pow(kwidth,6.);
	// xsmnfactor = scalefac; /* makes transmission some value between 0 and 1*/
	
	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/
	gsd = 255.; /* 255 | 3 */
	hav = true;
	xmg = loadxm(simg, kwidth);
	
	displayscale = 1.0 /* * 0.5 */;

	
	// max width and height is 16384 for the Apple M1 graphics card (according to Processing debug message)
	// pg = createGraphics(5000,5000, P2D);
	pg = createGraphics(2*simg.pixelWidth,2*simg.pixelHeight, P2D);
	// pg = createGraphics(10000,10000, P2D);
	pg.noSmooth();
	
	blueline = loadShader("blueline.glsl");
	float resu = 1000.;
	blueline.set("resolution", resu*float(pg.pixelWidth), resu*float(pg.pixelHeight));
	blueline.set("displayscale", (1.0/displayDensity()));
	
	// the unitsize determines the dimensions of a pixels for the shader
	blueline.set("unitsize", 1.00);
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
	blueline.set("rfac", 0.5);
	// blueline.set("rfac", 1.00000);
	// blueline.set("rfac", 1.015625); /* default */
	// blueline.set("rfac", 1.0625);
	// blueline.set("rfac", 1.25);
	// blueline.set("rfac", 1.300000);
	
	blueline.set("geoq", geoq);
	blueline.set("theme", theme);
	blueline.set("alpha", alpha);
	blueline.set("grader", grade);

	if(dispersed){
		useDispersed(modfac);
	} else {
		useOriginal();
	}
	
	klinkQ = false;
	if(klinkQ){
		String mlargs = "-linkmode launch -linkname '\"/Applications/Mathematica.app/Contents/MacOS/MathKernel\" -mathlink'";
		
		try {
			ml = MathLinkFactory.createKernelLink(mlargs);
			ml.discardAnswer();
			} catch (MathLinkException e) {
				System.out.println("MathLinkFactory::Fatal error opening link: " + e.getMessage());
				return;
			}
			
			// Define CellularAutomaton parameters
			rule = 30; /* 30 */
			k = 2;
			r1 = r2 = 1;
		
		// Create 2D image array
		// int[][] iarray = new int[simg.pixelWidth][simg.pixelHeight];
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

void draw(){
	selectDraw("convolve");
	// selectDraw("transmit");
	// selectDraw("transmitMBL");
	// selectDraw("switch");
	// selectDraw("switchTotal");
	// selectDraw("CA");
	// selectDraw("blur");
	// selectDraw("dilate");

	showFrameRate();
}

void showFrameRate(){
	pushMatrix();
	final String fr = "fps: " + str(frameRate);
	stroke(255);
	text(fr, 25,25);
	popMatrix();
}

void selectDraw(String selector){
	switch(selector){
		case "transmit":
			transmit(simg, xmg);
			break;
		case "convolve":
			convolve(simg, xmg);
			break;
		case "smear":
			smear(simg, xmg, 1);
			break;
		case "smearTotal":
			smearTotal(simg, xmg, 1);
			break;
		case "transmitMBL":
			transmitMBL(simg, xmg);
			break;
		case "CA":
			cellularAutomaton(simg);
			break;
		case "blur":
			simg.filter(BLUR);
			break;
		case "dilate":
			simg.filter(DILATE);
			break;
		case "switch":
			// switchdraw((frameCount % 20)+1, 1);
			switchdraw((frameCount % 60)+1, 1);
			// switchdraw(20, 1);
			// switchdraw(20, 2);
			// switchdraw(20, 3);
			// switchdraw(20, 4);
			
			// switchdraw(60, 1);
			// switchdraw(60, 2);
			// switchdraw(60, 3);
			// switchdraw(60, 4);
			break;
		case "switchTotal":
			// switchdrawTotal(60, 1);
			// switchdrawTotal(60, 2);
			// switchdrawTotal(60, 3);
			// switchdrawTotal(100, 1);
			// switchdrawTotal(100, 2);
			// switchdrawTotal(100, 3);
			// switchdrawTotal(100, 4);
			break;
		default:
			transmit(simg, xmg);
			break;
	}
	
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
	image(pg, width/2, height/2, simg.pixelWidth*displayscale, simg.pixelHeight*displayscale);
}

void pgDraw(){
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.pixelWidth, pg.pixelHeight);
	pg.endDraw();
}

void switchdraw(int mod, int smearSelector){
	if(frameCount % mod == 0){
		drawswitch = 1 - drawswitch;
	}
	
	if(drawswitch == 0){
		transmit(simg, xmg);
	} else {
		smear(simg, xmg, smearSelector);
	}
}

void switchdrawTotal(int mod, int smearSelector){
	if(frameCount % mod == 0){
		drawswitch = 1 - drawswitch;
	}
	
	if(drawswitch == 0){
		transmit(simg, xmg);
	} else {
		smearTotal(simg, xmg, smearSelector);
	}
}

void useDispersed(int factor){
	dimg = createImage((simg.pixelWidth*factor), (simg.pixelHeight*factor), ARGB);
	
	float sw = (float)dimg.pixelWidth;
	float sh = (float)dimg.pixelHeight;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	dimg.resize(nw, nh);
	
	setDispersedImage(simg, dimg);
	blueline.set("aspect", float(dimg.pixelWidth)/float(dimg.pixelHeight));
	blueline.set("tex0", dimg);
}

void useOriginal(){
	blueline.set("aspect", float(simg.pixelWidth)/float(simg.pixelHeight));
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
			) / gsd;
	} else {
		// channel average
		gs = (rpx + gpx + bpx) / gsd;
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
			int loc = xloc + img.pixelWidth*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			// TODO: should gs be computed with a different divisor. 3? or should I just take the natural mean values instead of the graded grayscale?
			
			color cpx = img.pixels[loc];
			
			float gs = computeGS(cpx);
			
			// the closer values are to 0 the more negative the transmission is, that's why a large value of scalefac produces fast fades.
			kern[i][j] = map(gs, 0, 1, -1.*scalefac,1.*scalefac);
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
			int loc = xloc + img.pixelWidth*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			
			color cpx = img.pixels[loc];
			
			float rpx = cpx >> 16 & 0xFF;
			float gpx = cpx >> 8 & 0xFF;
			float bpx = cpx & 0xFF;
			
			rpx += edge[i][j]/9;
			gpx += edge[i][j]/9;
			bpx += edge[i][j]/9;
			
			float gs = computeGS(cpx);
			
			kern[i][j] = map(gs, 0, 1, -1.*scalefac,1.*scalefac);
			}
		}
		img.updatePixels();
		return kern;
	}

float[][][] loadxm(PImage img, int kwidth) {
	float[][][] xms = new float[int(img.pixelWidth * img.pixelHeight)][kwidth][kwidth];
	float[][] kernel = new float[kwidth][kwidth];
	img.loadPixels();
	for (int i = 0; i < img.pixelWidth; i++){
		for (int j = 0; j < img.pixelHeight; j++){
			kernel = loadkernel(i,j, kwidth, img);
			// kernel = loadEdgeWeight(i,j, kwidth, img);
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

void convolve(PImage img, float[][][] ximage) {
	img.loadPixels();
	for (int i = 0; i < img.pixelWidth; i++){
		for (int j = 0; j < img.pixelHeight; j++){
			color c =  convolution(i,j, kwidth, img, ximage);
			int index = (i + j * img.pixelWidth);
			img.pixels[index] = c;
		}
	}
	img.updatePixels();
}

// https://processing.org/examples/convolution.html
// Adjusted slightly for the purposes of this sketch
color convolution(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		float rtotal = 0.0;
		float gtotal = 0.0;
		float btotal = 0.0;

		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] / xsmnfactor);
				
				color cpx = img.pixels[loc];
				
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;
				
				if(xloc == x && yloc == y){
					rtotal -= (rpx * xmsn);
					gtotal -= (gpx * xmsn);
					btotal -= (bpx * xmsn);
				} else {
					rtotal += (rpx * xmsn);
					gtotal += (gpx * xmsn);
					btotal += (bpx * xmsn);
				}
			}
		}
		
		return color(rtotal, gtotal, btotal);
	}

void smear(PImage img, float[][][] ximage, int selector) {
	img.loadPixels();
	for (int i = 0; i < img.pixelWidth; i++){
		for (int j = 0; j < img.pixelHeight; j++){
			color c =  smearing(i,j, kwidth, img, ximage, selector);
			int index = (i + j * img.pixelWidth);
			img.pixels[index] = c;
		}
	}
	img.updatePixels();
	}

color smearing(int x, int y, int kwidth, PImage img, float[][][] ximg, int sel)
	{
		
		float rpx = 0.0;
		float gpx = 0.0;
		float bpx = 0.0;
		
		
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] / xsmnfactor);
				
				color cpx = img.pixels[loc];
				rpx = cpx >> 16 & 0xFF;
				gpx = cpx >> 8 & 0xFF;
				bpx = cpx & 0xFF;

				switch(sel){
					case 1:
						if(xloc == x && yloc == y){
							rpx -= (xmsn);
							gpx -= (xmsn);
							bpx -= (xmsn);
							} else {
								rpx += (xmsn);
								gpx += (xmsn);
								bpx += (xmsn);
							}
						break;
					case 2:
						if(xloc == x && yloc == y){
							rpx -= (xmsn);
							gpx -= (xmsn);
							bpx -= (xmsn);
							} else {
								rpx *= (xmsn);
								gpx *= (xmsn);
								bpx *= (xmsn);
							}
						break;
					case 3:
						if(xloc == x && yloc == y){
							rpx += (xmsn);
							gpx += (xmsn);
							bpx += (xmsn);
							} else {
								rpx *= (xmsn);
								gpx *= (xmsn);
								bpx *= (xmsn);
							}
						break;
					case 4:
						if(xloc == x && yloc == y){
							rpx = (xmsn);
							gpx = (xmsn);
							bpx = (xmsn);
						}
						break;
					default:
						if(xloc == x && yloc == y){
							rpx -= (xmsn);
							gpx -= (xmsn);
							bpx -= (xmsn);
							} else {
								rpx += (xmsn);
								gpx += (xmsn);
								bpx += (xmsn);
							}
						break;
				}
			}
		}
		return color(rpx, gpx, bpx);
	}

	
void smearTotal(PImage img, float[][][] ximage, int selector) {
	img.loadPixels();
	for (int i = 0; i < img.pixelWidth; i++){
		for (int j = 0; j < img.pixelHeight; j++){
			color c =  smearingTotal(i,j, kwidth, img, ximage, selector);
			int index = (i + j * img.pixelWidth);
			img.pixels[index] = c;
		}
	}
	img.updatePixels();
	}

color smearingTotal(int x, int y, int kwidth, PImage img, float[][][] ximg, int sel)
	{
		
		float rtotal = 0.0;
		float gtotal = 0.0;
		float btotal = 0.0;
		
		
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] / xsmnfactor);
				
				color cpx = img.pixels[loc];
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;

				switch(sel){
					case 1:
						if(xloc == x && yloc == y){
							rtotal -= rpx * (xmsn);
							gtotal -= gpx * (xmsn);
							btotal -= bpx * (xmsn);
							} else {
								rtotal += rpx * (xmsn);
								gtotal += gpx * (xmsn);
								btotal += bpx * (xmsn);
							}
						break;
					case 2:
						if(xloc == x && yloc == y){
							rtotal -= rpx * (xmsn);
							gtotal -= gpx * (xmsn);
							btotal -= bpx * (xmsn);
							} else {
								rtotal *= rpx * (xmsn);
								gtotal *= gpx * (xmsn);
								btotal *= bpx * (xmsn);
							}
						break;
					case 3:
						if(xloc == x && yloc == y){
							rtotal += rpx * (xmsn);
							gtotal += gpx * (xmsn);
							btotal += bpx * (xmsn);
							} else {
								rtotal *= rpx * (xmsn);
								gtotal *= gpx * (xmsn);
								btotal *= bpx * (xmsn);
							}
						break;
					case 4:
						if(xloc == x && yloc == y){
							rtotal = rpx * (xmsn);
							gtotal = gpx * (xmsn);
							btotal = bpx * (xmsn);
						}
						break;
					default:
						if(xloc == x && yloc == y){
							rtotal -= rpx * (xmsn);
							gtotal -= gpx * (xmsn);
							btotal -= bpx * (xmsn);
							} else {
								rtotal += rpx * (xmsn);
								gtotal += gpx * (xmsn);
								btotal += bpx * (xmsn);
							}
						break;
				}
			}
		}
		return color(rtotal, gtotal, btotal);
	}

void transmit(PImage img, float[][][] ximage)
	{
		img.loadPixels();
		for (int i = 0; i < img.pixelWidth; i++){
			for (int j = 0; j < img.pixelHeight; j++){
				transmission(i,j, kwidth, img, ximage);
			}
		}
		img.updatePixels();
	}

void transmission(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		color cpx = img.pixels[x+y*img.pixelWidth];
		
		float rpx = cpx >> 16 & 0xFF;
		float gpx = cpx >> 8 & 0xFF;
		float bpx = cpx & 0xFF;
		
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				float xmsn = (ximg[loc][i][j] / xsmnfactor);
				
				if(xloc == x && yloc == y){
					rpx -= xmsn;
					gpx -= xmsn;
					bpx -= xmsn;
				} else {
					rpx += xmsn;
					gpx += xmsn;
					bpx += xmsn;
				}
			}
		}
		img.pixels[x+y*img.pixelWidth] = color(rpx,gpx,bpx);
	}

void transmitMBL(PImage img, float[][][] ximage)
	{
		img.loadPixels();
		for (int i = 0; i < img.pixelWidth; i++){
			for (int j = 0; j < img.pixelHeight; j++){
				transmissionMBL(i,j, kwidth, img, ximage);
			}
		}
		img.updatePixels();
	}

void transmissionMBL(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		int sloc = x+y*img.pixelWidth;
		
		color spx = img.pixels[sloc];
		float gs = computeGS(spx);
		
		float xmsn = map(gs, 0., 1., -.5, .5) / xsmnfactor;
		// float xmsn = map(gs, 0., 1., -1.*scalefac, 1.*scalefac) / xsmnfactor;
		// float xmsn = ximg[sloc][i][j] / xsmnfactor;
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				color cpx = img.pixels[loc];
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;
				
				if(xloc == x && yloc == y){
					continue;
				} else {
					// float xmsn = ximg[sloc][i][j] / xsmnfactor;
					rpx += xmsn;
					gpx += xmsn;
					bpx += xmsn;
				}
				img.pixels[loc] = color(rpx,gpx,bpx);
			}
		}
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

int[][] cellularAutomatize(int rnum, int colors, int range1, int range2, int[][] clusters){
	try {
		ml.putFunction("CellularAutomaton",3);
			ml.putFunction("List",3);
				ml.put(rule);
				ml.put(k); /* Non Totalistic */
				// ml.putFunction("List",2); /* Totalistic */
					// ml.put(k);
					// ml.put(1);
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

PImage randomImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.pixelWidth; i++){
			for (int j = 0; j < rimg.pixelHeight; j++){
				color c = color(random(255.));
				int index = (i + j * rimg.pixelWidth);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}

PImage noiseImage(int w, int h, int lod, float falloff){
	  noiseDetail(lod, falloff);
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.pixelWidth; i++){
			for (int j = 0; j < rimg.pixelHeight; j++){
				color c = color(lerp(0,1,noise(i*cos(i),j*sin(j), (i+j)/2))*255);
				int index = (i + j * rimg.pixelWidth);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}

PImage kuficImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.pixelWidth; i++){
			for (int j = 0; j < rimg.pixelHeight; j++){
				chance = ((i % 2) + (j % 2));
				
				float wallornot = random(2.);
				int index = (i + j * rimg.pixelWidth);
				if(wallornot <= chance){
						color c = color(0);
						rimg.pixels[index] = c;
					} else {
						color c = color(255-(255*(wallornot/2.)));
						rimg.pixels[index] = c;
					}
				}
			}
		rimg.updatePixels();
		return rimg;
	}


void mazeImage(PImage source){
		source.loadPixels();
		for (int i = 0; i < source.pixelWidth; i++){
			for (int j = 0; j < source.pixelHeight; j++){
				
				int loc = (i + j * source.pixelWidth);
				
				color cpx = source.pixels[loc];
				
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;
				float apx = alpha(cpx);
				
				float avgF = ((rpx+gpx+bpx+apx)/4.)/255.;
				
				float r = round(avgF);
				color c = color(r*255);
				source.pixels[loc] = c;
				}
			}
		source.updatePixels();
	}

void stop() {
		ml.close();
	}
