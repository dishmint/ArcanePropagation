// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
import com.wolfram.jlink.*;
import java.util.function.*;
import java.util.Arrays;

KernelLink ml = null;
Expr imgclusters;

// CellularAutomaton variables
int rule, k, r1, r2;

PGraphics pg;

PImage simg,dximg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3/* |5 */;
int kwidthsq = (int)(pow(kwidth, 2));
int drawswitch = 0;
float kernelScale,xsmnfactor,chance,displayscale,sw,sh,scale,gsd,downsampleFloat;

boolean dispersed, hav, klinkQ;

ArcaneFilter af;
ArcaneGenerator ag;

void setup(){
	/* -------------------------------------------------------------------------- */
	/*                               Sketch Settings                              */
	/* -------------------------------------------------------------------------- */
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	
	/* -------------------------------------------------------------------------- */
	/*                                 Load Image                                 */
	/* -------------------------------------------------------------------------- */
	
	/* ------------------------------- image files ------------------------------ */
	simg = loadImage("./imgs/universe.jpg");
	// simg = loadImage("/Users/faizonzaman/Documents/Assets/Images/ryoji-iwata-n31JPLu8_Pw-unsplash.jpg");
	
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
	// simg.filter(...);
	
	downsampleFloat = /* 1.0| */2.25/* |1.75|2.25|5.0 */;
	modfac = 3; /* 1|2|3|4|5|8 */
	
	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	float sw = (float)simg.pixelWidth;
	float sh = (float)simg.pixelHeight;
	float scale = min(pixelWidth/sw, pixelHeight/sh);
	
	int nw = Math.round(sw*scale/downsampleFloat);
	int nh = Math.round(sh*scale/downsampleFloat);
	simg.resize(nw, nh);
	
	/* scales the values of the kernel (-1.0~1.0) * kernelScale  */
	kernelScale = 1.0f;
	// kernelScale = 1.0f / 255.0f;
	// kernelScale = 0.098f / 1.0f;
	// kernelScale = 0.98f / 1.0f;
	// kernelScale = 0.50f / 1.0f;
	// kernelScale = 0.33f / 1.0f;
	
	// Determine the leak-rate (transmission factor) of each pixel
	xsmnfactor = 1.0f / pow(kwidth, 2.0f); /* default */
	// xsmnfactor = 1.0f / kwidth;
	// xsmnfactor = kwidth;
	// xsmnfactor = kernelScale;
	
	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/

	gsd = 1.0f/255.0f; /* 1.0f/ 765.0f | 255.0f | 9.0f | 85.0f | 3.0f */
	hav = false;
	xmg = loadxm(simg, kwidth);
	
	dispersed = true;
	dximg = createImage(simg.pixelWidth/modfac, simg.pixelHeight/modfac, ARGB);
	
	background(0);
	noCursor();
	
	klinkQ = false;
	if(klinkQ){
		setupWLKernel();
	}
	//convolution — still | convolve | transmit | transmitMBL | switch | switchTotal | blur | weighted blur
	/* TODO: add rdf filters */
	af = new ArcaneFilter("transmitMBL", kwidth, xsmnfactor);

}

void draw(){
	//style — point | line | xline | xliner | xliner2
	selectDraw("line");
}

void selectDraw(String style){

	af.kernelmap(simg, xmg);
	
	background(0);
	pointDraw(style);
}

void selectDraw(String selector, String style, int sparam){
	switch(selector){
		case "blur":
			simg.filter(BLUR, sparam);
			break;
		case "posterize":
			simg.filter(POSTERIZE, sparam);
			break;
		default:
			break;
		}
	
	background(0);
	pointDraw(style);
}

void pointDraw(String style){
	if(dispersed){
		loadDX();
		pointorbit(dximg, style);
	} else {
		pointorbit(simg, style);
	}
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
	float igs;
	float rpx = px >> 16 & 0xFF;
	float gpx = px >> 8 & 0xFF;
	float bpx = px & 0xFF;
	
	if(hav){
		// Human Visual Perception
		igs = (
			(0.2989 * rpx) +
			(0.5870 * gpx) +
			(0.1140 * bpx)
			) * gsd;
	} else if(!hav) {
		// channel average
		igs = (rpx + gpx + bpx) * gsd;
	} else {
		igs = 1.;
	}
	// return igs;
	// return map(igs, 0., 1., -.5*kernelScale, .5*kernelScale);
	return map(igs, 0., 1., -1.*kernelScale, 1.*kernelScale);
}


float computeGS(color px, boolean hu){
	float rpx = px >> 16 & 0xFF;
	float gpx = px >> 8 & 0xFF;
	float bpx = px & 0xFF;
	
	float igs = 1.;
	if(hu){
		// human grayscale
		igs = (
			0.2989 * rpx +
			0.5870 * gpx +
			0.1140 * bpx
			) * gsd;
	} else {
		// channel average
		igs = (rpx + gpx + bpx) * gsd;
	}
	return igs;
}

void pointorbit(PImage nimg, String selector){
	nimg.loadPixels();
	switch(selector){
		case "point":
			for(int x = 0; x < nimg.pixelWidth;x++){
				for(int y = 0; y < nimg.pixelHeight; y++){
					int index = (x + (y * nimg.pixelWidth));
					color cpx = nimg.pixels[index];
					float gs = computeGS(cpx);
					pushMatrix();
					showAsPoint(x,y,gs);
					popMatrix();
				}
			}
			break;
		case "line":
			for(int x = 0; x < nimg.pixelWidth;x++){
				for(int y = 0; y < nimg.pixelHeight; y++){
					int index = (x + (y * nimg.pixelWidth));
					color cpx = nimg.pixels[index];
					float gs = computeGS(cpx);
					pushMatrix();
					showAsLine(x,y,gs);
					popMatrix();
				}
			}
			break;
		case "xline":
			for(int x = 0; x < nimg.pixelWidth;x++){
				for(int y = 0; y < nimg.pixelHeight; y++){
					int index = (x + (y * nimg.pixelWidth));
					color cpx = nimg.pixels[index];
					float gs = computeGS(cpx);
					pushMatrix();
					showTLines(nimg,x,y,gs);
					popMatrix();
				}
			}
			break;
		case "xliner":
			for(int x = 0; x < nimg.pixelWidth;x++){
				for(int y = 0; y < nimg.pixelHeight; y++){
					int index = (x + (y * nimg.pixelWidth));
					color cpx = nimg.pixels[index];
					float gs = computeGS(cpx);
					pushMatrix();
					showTRotator(nimg,x,y,gs);
					popMatrix();
				}
			}
			break;
		case "xliner2":
			for(int x = 0; x < nimg.pixelWidth;x++){
				for(int y = 0; y < nimg.pixelHeight; y++){
					int index = (x + (y * nimg.pixelWidth));
					color cpx = nimg.pixels[index];
					float gs = computeGS(cpx);
					pushMatrix();
					showTRotator2(nimg,x,y,gs);
					popMatrix();
				}
			}
			break;
		default:
			for(int x = 0; x < nimg.pixelWidth;x++){
				for(int y = 0; y < nimg.pixelHeight; y++){
					int index = (x + (y * nimg.pixelWidth));
					color cpx = nimg.pixels[index];
					float gs = computeGS(cpx);
					pushMatrix();
					showAsPoint(x,y,gs);
					popMatrix();
				}
			}
			break;
	}
	nimg.updatePixels();
}


void showAsPoint(int x, int y, float energy) {
	float enc = lerp(-1., 1., energy);
	// float enc = lerp(-1., 1., energy/kernelScale);
	// float enc = lerp(-1., 1., (energy+1.)/2.);
	stroke(energyDegree(energy));
	float ang = radians(energyAngle(enc));
	
	// float px = x + (1./(modfac * 0.5) * cos(ang));
	// float py = y + (1./(modfac * 0.5) * sin(ang));
	
	float px = x + (1./(modfac) * cos(ang));
	float py = y + (1./(modfac) * sin(ang));
	
	if(dispersed){
		pushMatrix();
		translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));
		point(
			(px) * modfac,
			(py) * modfac
		);
		popMatrix();
		} else {
			pushMatrix();
			translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
			point(
				(px),
				(py)
				);
			popMatrix();
		}

}

void showAsLine(int x, int y, float energy) {
	float enc = lerp(-1., 1., energy);
	color cc = energyDegree(enc);
	stroke(cc);
	float ang = radians(energyAngle(enc));
	float px = x + (.5 * cos(ang));
	float py = y + (.5 * sin(ang));

	if(dispersed){
		pushMatrix();
		translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));
		line(
				x  * modfac,
				y  * modfac,
			(px) * modfac,
			(py) * modfac
		);
		popMatrix();
		} else {
			pushMatrix();
			translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
			line(x, y, px, py);
			popMatrix();
		}

}

void showTLines(PImage img, int x, int y, float energy) {

	int sloc = x+y*img.pixelWidth;
	sloc = constrain(sloc, 0, img.pixels.length - 1);
	color cc = img.pixels[sloc];

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
			
			strokeWeight(1);
			stroke(lerpColor(cc, cpx, energy), 255 * .125);

			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));

					line(
						(x + .5) * modfac,
						(y + .5) * modfac,
						(xloc + .5) * modfac,
						(yloc + .5) * modfac
						);
					popMatrix();
					} else {
						pushMatrix();
						translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
						line(
							(x + (.5)),
							(y + (.5)),
							(xloc + (.5)),
							(yloc + (.5))
							);
						popMatrix();
					}
			}
			}
		}
}

void showTRotator(PImage img, int x, int y, float energy) {

	float enc = lerp(-1., 1., energy);
	float ang = radians(energyAngle(enc));

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
			
			strokeWeight(1);
			stroke(energyDegree(energy));
			
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));
					line(
						(x + .5) * modfac,
						(y + .5) * modfac,
						(xloc + (.5 * cos(ang))) * modfac,
						(yloc + (.5 * sin(ang))) * modfac
						);
					popMatrix();
					} else {
						pushMatrix();
						translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
						line(
							(x + .5),
							(y + .5),
							(xloc + (.5 * cos(ang))),
							(yloc + (.5 * sin(ang)))
							);
						popMatrix();
					}
				}
			}
		}
}

void showTRotator2(PImage img, int x, int y, float energy) {
	float enc = lerp(-1., 1., energy);
	float ang = radians(energyAngle(enc));

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
			
			strokeWeight(1);
			stroke(energyDegree(energy));
			
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));
					PVector midpoint = new PVector(lerp(float(x), float(xloc), .5), lerp(float(y), float(yloc), .5));
					PVector p1 = new PVector(float(x), float(y));
					PVector p2 = new PVector(float(xloc), float(yloc));
					float l = PVector.dist(p1,p2);
					pushMatrix();
					translate((midpoint.x*modfac), (midpoint.y*modfac));
					rotate(ang);
					int mfd = 4;
					line(
						(-l * 0.5) * (modfac/mfd),
						(-l * 0.5) * (modfac/mfd),
						( l * 0.5) * (modfac/mfd) ,
						( l * 0.5) * (modfac/mfd)
						);
						
					popMatrix();
					popMatrix();
					} else {
						pushMatrix();
						translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
						rotate(ang);
						line(
							(x + .5),
							(y + .5),
							(xloc + (.5)),
							(yloc + (.5))
							);
						popMatrix();
					}
				}
			}
		}
}

float energyAngle(float ec) {
	float ecc = (ec + 1.0f) / 2.0f;
	float a = lerp(0.0f, 360.0f, ecc);
	return a;
}

color energyDegree(float energy) {
	float ne = (energy+1.0f)/2.0f;
	return lerpColor(color(0, 255, 255, 255), color(215, 0, 55, 255), ne);
}

float colorAmp(float min, float max, float value){
	return map(value, min, max, 0,255);
}

float colorAmp(float value, float min, float max, float hmin, float hmax){
	return map(value, min, max, hmin,hmax);
}

void switchdraw(int mod, int smearSelector){
	if(frameCount % mod == 0){
		drawswitch = 1 - drawswitch;
	}
	
	if(drawswitch == 0){
		af.setFilterMode("transmit");
	} else {
		af.selector = smearSelector;
		af.setFilterMode("smearTotal");
	}
}

void switchdrawTotal(int mod, int smearSelector){
	if(frameCount % mod == 0){
		drawswitch = 1 - drawswitch;
	}
	
	if(drawswitch == 0){
		af.setFilterMode("transmit");
	} else {
		af.selector = smearSelector;
		af.setFilterMode("smearTotal");
	}
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
			
			// the closer values are to 0 the more negative the transmission is, that's why a large value of kernelScale produces fast fades.
			kern[i][j] = map(gs, 0.0f, 1.0f, -1.0f*kernelScale,1.0f*kernelScale);
			// kern[i][j] = map(gs, 0, 1, -.5,.5);
			// kern[i][j] = map(gs, 0, 1, -.5*kernelScale,.5*kernelScale);
			// kern[i][j] = gs;
			// kern[i][j] = map(gs, 0, 1, 0.,1.*kernelScale);
			// kern[i][j] = map(gs, 0, 1, -1.,1.);
			// kern[i][j] = map(gs, 0.0f, gsd, -1.*kernelScale,1.*kernelScale);
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
			
			float gs = computeGS(color(rpx,gpx,bpx));
			
			kern[i][j] = map(gs, 0, 1, -1.*kernelScale,1.*kernelScale);
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