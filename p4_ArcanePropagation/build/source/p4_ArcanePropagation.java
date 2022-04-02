/* autogenerated by Processing revision 1281 on 2022-04-02 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class p4_ArcanePropagation extends PApplet {

// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg;

PImage simg,dimg,dximg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
int drawswitch = 0;
float scalefac,xsmnfactor,chance,displayscale,sw,sh,scale;

boolean dispersed, hav;

 public void setup(){
	// size(800,800, P3D);
	// size(900,900, P3D);
	// size(1200,1200, P3D);
	// size(1440,1440, P3D);
	// size(1280,720, P3D);
	// size(1422,800, P3D);
	/* size commented out by preprocessor */;
	// size(1778,1000, P3D);
	surface.setTitle("Arcane Propagations");
	// pixelDensity(1);
	
	// simg = loadImage("./imgs/buff_skate.JPG");
	// simg = loadImage("./imgs/face.png");
	// simg = loadImage("./imgs/p5sketch1.jpg");
	// simg = loadImage("./imgs/abstract_1.PNG");
	// simg = loadImage("./imgs/abstract_2.PNG");
	// simg = loadImage("./imgs/fruit.jpg");
	// simg = loadImage("./imgs/abstract_3.PNG");
	// simg = loadImage("./imgs/abstract_4.JPG");
	// simg = loadImage("./imgs/andrea-leopardi-5qhwt_Lula4-unsplash.jpg");
	// simg = loadImage("./imgs/fzn_dishmint.JPG");
	// simg = loadImage("./imgs/fezHassan.JPG");
	// simg = loadImage("./imgs/enter.jpg");
	// simg = loadImage("./imgs/enrapture-captivating-media-8_oFcxtXUSU-unsplash.jpg");
	
	// simg = loadImage("./imgs/roc_flour.jpg");
	// simg = loadImage("./imgs/ryoji-iwata-n31JPLu8_Pw-unsplash.jpg");
	// simg = loadImage("./imgs/shio-yang-b6i9pe16pAg-unsplash.jpg");
	// simg = loadImage("./imgs/sora-sagano-7LWIGWh-YKM-unsplash.jpg");
	// simg = loadImage("./imgs/universe.jpg" ) ;
	
	simg = loadImage("./imgs/buildings.jpg");
	// simg = loadImage("./imgs/clouds.jpg");
	// simg = loadImage("./imgs/nasa.jpg");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// simg = loadImage("./imgs/nestedsquare.png");
	// simg = loadImage("./imgs/mountains_1.jpg");
	// simg = randomImage(width, height);
	// simg = randomImage(width/32, height/32);
	// simg = randomImage(width/4, height/4);
	// simg = noiseImage(width/16, height/16, 3, .6);
	// simg = noiseImage(height/16, height/16, 3, .6);
	// simg = noiseImage(height/32, height/32, 3, .6);
	// simg = kuficImage(width, height);
	// simg = kuficImage(width/16, height/16);
	// simg = kuficImage(height/16, height/16);
	
	// mazeImage(simg);
	
	// simg.filter(GRAY);
	// simg.filter(POSTERIZE, 4);
	// simg.filter(BLUR, 2);
	// simg.filter(DILATE);
	// simg.filter(ERODE);
	// simg.filter(INVERT);
	// simg.filter(THRESHOLD, .8);
	
	// max height and with is 16384 for the Apple M1 graphics card (according to Processing debug message)
	// pg = createGraphics(400,400, P2D);
	// pg = createGraphics(1200,1200, P2D);
	// pg = createGraphics(4000,4000, P2D);
	pg = createGraphics(5000,5000, P2D);
	// pg = createGraphics(10000,10000, P2D);
	// pg = createGraphics(11000,11000, P2D);
	// pg = createGraphics(14000,14000, P2D);
	pg.noSmooth();
	
	// dmfac = 1;
	// downsample = modfac = dmfac;
	downsample = 1;
	modfac = 4;
	
	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	float sw = (float)simg.width;
	float sh = (float)simg.height;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	simg.resize(nw, nh);
	
	dximg = createImage(simg.width/modfac, simg.height/modfac, ARGB);
	
	
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
	// float sf = 0025.00;   /* 010.20 */
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
	float sf = 2040.00f;   /* 000.125 */

	scalefac = 255.f/sf;
	
	// xsmnfactor = 1.;
	// xsmnfactor = pow(kwidth,0.5);
	// xsmnfactor = pow(kwidth,1.5);
	xsmnfactor = pow(kwidth,2.f); /* default */
	// xsmnfactor = pow(kwidth,3.);
	// xsmnfactor = pow(kwidth,4.);
	// xsmnfactor = pow(kwidth,6.);
	// xsmnfactor = scalefac; /* makes transmission some value between 0 and 1*/
	
	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/
	hav = true;
	xmg = loadxm(simg, kwidth);
	
	blueline = loadShader("blueline.glsl");
	// the unitsize determines the dimensions of a pixels for the shader
	// blueline.set("unitsize", 2.00);
	blueline.set("unitsize", 1.00f);
	// blueline.set("unitsize", 0.50);
	// blueline.set("unitsize", 0.25);
	// the thickness used to determine a points position is determined by thickness/tfac
	blueline.set("tfac", 1.0f);
	// blueline.set("tfac", .05);
	// blueline.set("tfac", .005);
	
	/*
	- The radius of a point orbit is determined by rfac * thickness
	- when 1.0000 < rfac < 1.0009 values begin to display as black pixels, kind of like a mask.
	*/
	
	// blueline.set("rfac", 0.000000);
	// blueline.set("rfac", 0.000100);
	// blueline.set("rfac", 0.125000);
	// blueline.set("rfac", 0.250000);
	// blueline.set("rfac", 0.750000);
	// blueline.set("rfac", 1.000000);
	// blueline.set("rfac", 1.000900);
	// blueline.set("rfac", 1.001000);
	// blueline.set("rfac", 1.010000);
	// blueline.set("rfac", 1.100000);
	// blueline.set("rfac", 1.200000);
	// blueline.set("rfac", 1.250000);
	blueline.set("rfac", 1.300000f); /* Default */
	// blueline.set("rfac", 1.400000);
	// blueline.set("rfac", 1.410000);
	// blueline.set("rfac", 1.500000); /* black screen */
	// blueline.set("rfac", 2.000000); /* black screen */
	
	dispersed = true;
	if(dispersed){
		useDispersed(modfac);
	} else {
		useOriginal();
	}
	// blueline.set("resolution", float(pg.width), float(pg.height));
	float resu = 100.f;
	blueline.set("resolution", resu*PApplet.parseFloat(pg.width), resu*PApplet.parseFloat(pg.height));
	imageMode(CENTER);
	
	// displayscale = 2.0;
	// displayscale = 1.50;
	// displayscale = 1.25;
	displayscale = 1.0f;
	// displayscale = .98;
	// displayscale = .75;
	// displayscale = .65;
	// displayscale = .5;
	
	// frameRate(1.);
	// frameRate(6.);
	// noLoop();
	background(0);
}

 public void draw(){
	background(0);
	// pgDraw();
	
	// convolve(simg, xmg);
	transmit(simg, xmg);
	// smear(simg, xmg);
	
	// switchdraw(20);
	
	if(dispersed){
		// drawDispersed();
		// dximg = simg;
		loadDX();
		pointorbit(dximg);
	} else {
		drawOriginal();
		pointorbit(simg);
	}
	// image(pg, width/2, height/2, simg.width*displayscale, simg.height*displayscale);
}


 public void loadDX(){
	simg.loadPixels();
	dximg.loadPixels();
	for (int i = 0; i < dximg.width; i++){
		for (int j = 0; j < dximg.height; j++){
			int dindex = (i + j * dximg.width);
			int x = i - 1;
			int y = j - 1;
			x = constrain(x, 0, dximg.width - 1);
			y = constrain(y, 0, dximg.height - 1);
			int sindex = ((x*modfac) + ((y*modfac) * (simg.width)));
			if (sindex < simg.pixels.length){
				dximg.pixels[dindex] = simg.pixels[sindex];
				}
			}
		}
	simg.updatePixels();
	dximg.updatePixels();
}

 public void pgDraw(){
	pg.beginDraw();
	pg.background(0);
	// pg.background(0,0,0,25);
	// pg.background(0,0,0,100);
	// pg.background(0,0,0,125);
	// pg.background(0,0,0,150);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
}

 public void pointorbit(PImage nimg){
	nimg.loadPixels();
	for(int x = 0; x < nimg.width;x++){
		for(int y = 0; y < nimg.height; y++){
			int index = (x + (y * nimg.width));
			int cpx = nimg.pixels[index];
			
			float rpx = cpx >> 16 & 0xFF;
			float gpx = cpx >> 8 & 0xFF;
			float bpx = cpx & 0xFF;
			
			float gs = 1.f;
			if(hav){
				// human grayscale
				gs = (
					0.2989f * rpx +
					0.5870f * gpx +
					0.1140f * bpx
					) / 255.f;
			} else {
				// channel average
				gs = (rpx + gpx + bpx) / 255.f;
			}
			pushMatrix();
			showAsPoint(x,y,gs);
			popMatrix();
		}
	}
	nimg.updatePixels();
}


 public void showAsPoint(int x, int y, float energy) {
	float enc = lerp(-1.f, 1.f, energy);

	int cc = energyDegree(enc);
	stroke(cc);
	float ang = radians(energyAngle(enc));
	// float ang = energyAngle(enc);
	float px = x + (.5f * cos(ang));
	float py = y + (.5f * sin(ang));
	// float px = x + (1./float(modfac) * cos(ang));
	// float py = y + (1./float(modfac) * sin(ang));

	if(dispersed){
		translate((width/2)-(modfac*(dximg.width/2)),(height/2)-(modfac*(dximg.height/2)));
		point(
			(px) * modfac,
			(py) * modfac
		);
		} else {
		translate((width/2)-(simg.width/2),(height/2)-(simg.height/2));
		point(
			(px),
			(py)
		);
		}

}


 public float energyAngle(float ec) {
	float ecc = (ec + 1.f) / 2.f;
	float a = ecc * 360.f;
	return constrain(a, 0, 360);
}

 public int energyDegree(float energy) {
	float ac = energyAngle(energy);
	float ac4 = lerp(0.f, 1.f, ac / 360.f) * 215.f;
	
	float rpx = ac4;
	float gpx = 255.f - (abs(energy) * 255.f);
	float bpx = 255.f - (abs(energy) * 200.f);
	// return color(rpx, gpx, bpx, 255/9);
	return color(rpx, gpx, bpx);
}

 public void switchdraw(int mod){
	if(frameCount % mod == 0){
		drawswitch = 1 - drawswitch;
	}
	
	if(drawswitch == 0){
		transmit(simg, xmg);
	} else {
		smear(simg, xmg, 4);
	}
}

 public void useDispersed(int factor){
	dimg = createImage((simg.width*factor), (simg.height*factor), ARGB);
	
	float sw = (float)dimg.width;
	float sh = (float)dimg.height;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	dimg.resize(nw, nh);
	
	setDispersedImage(simg, dimg);
	blueline.set("aspect", PApplet.parseFloat(dimg.width)/PApplet.parseFloat(dimg.height));
	blueline.set("tex0", dimg);
}

 public void useOriginal(){
	blueline.set("aspect", PApplet.parseFloat(simg.width)/PApplet.parseFloat(simg.height));
	blueline.set("tex0", simg);
}

 public void drawDispersed(){
	setDispersedImage(simg,dimg);
	blueline.set("tex0", dimg);
}

 public void drawOriginal(){
	blueline.set("tex0", simg);
}


 public float[][] loadkernel(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	img.loadPixels();
	int offset = dim / 2;
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			// TODO: should gs be computed with a different divisor. 3? or should I just take the natural mean values instead of the graded grayscale?
			
			int cpx = img.pixels[loc];
			
			float rpx = cpx >> 16 & 0xFF;
			float gpx = cpx >> 8 & 0xFF;
			float bpx = cpx & 0xFF;
			
			float gs = 1.f;
			if(hav){
				// human grayscale
				gs = (
					0.2989f * rpx +
					0.5870f * gpx +
					0.1140f * bpx
					) / 255.f;
			} else {
				// channel average
				gs = (rpx + gpx + bpx) / 255.f;
			}
			
			// the close values are to 0 the more negative the transmission is, that's why a large value of scalefac produces fast fades.
			kern[i][j] = map(gs, 0, 1, -1.f*scalefac,1.f*scalefac);
			// kern[i][j] = gs;
			// kern[i][j] = map(gs, 0, 1, 0.,1.*scalefac);
			// kern[i][j] = map(gs, 0, 1, -1.,1.);
			}
		}
		img.updatePixels();
		return kern;
	}

 public int kerncenter(int dim){
	float kcenter = -0.5f + (0.5f *dim);
	return (int)kcenter;
}

 public int[][] makeEdgeKernel(int dim, int min, int max){
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
 public float[][] loadEdgeWeight(int x, int y, int dim, PImage img){
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
			
			int cpx = img.pixels[loc];
			
			float rpx = cpx >> 16 & 0xFF;
			float gpx = cpx >> 8 & 0xFF;
			float bpx = cpx & 0xFF;
			
			rpx += edge[i][j]/9;
			gpx += edge[i][j]/9;
			bpx += edge[i][j]/9;
			
			// float gs = (
			// 	0.2989 * rpx +
			// 	0.5870 * gpx +
			// 	0.1140 * bpx
			// 	) / 255;
			
			// more interesting for p5sketch1
			float gs = (
				0.2989f * rpx +
				0.5870f * gpx +
				0.1140f * bpx
				) / 3;

				kern[i][j] = map(gs, 0, 1, -1.f*scalefac,1.f*scalefac);
			}
		}
		img.updatePixels();
		return kern;
	}

 public float[][][] loadxm(PImage img, int kwidth) {
	float[][][] xms = new float[PApplet.parseInt(img.width * img.height)][kwidth][kwidth];
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

 public void setDispersedImage(PImage source, PImage di) {
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

 public void convolve(PImage img, float[][][] ximage) {
	img.loadPixels();
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			int c =  convolution(i,j, kwidth, img, ximage);
			int index = (i + j * img.width);
			img.pixels[index] = c;
		}
	}
	img.updatePixels();
}

// https://processing.org/examples/convolution.html
// Adjusted slightly for the purposes of this sketch
 public int convolution(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		float rtotal = 0.0f;
		float gtotal = 0.0f;
		float btotal = 0.0f;

		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] / xsmnfactor);
				
				int cpx = img.pixels[loc];
				
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

 public void smear(PImage img, float[][][] ximage, int selector) {
	img.loadPixels();
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			int c =  smearing(i,j, kwidth, img, ximage, selector);
			int index = (i + j * img.width);
			img.pixels[index] = c;
		}
	}
	img.updatePixels();
	}

 public int smearing(int x, int y, int kwidth, PImage img, float[][][] ximg, int sel)
	{
		
		float rpx = 0.0f;
		float gpx = 0.0f;
		float bpx = 0.0f;
		
		
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] / xsmnfactor);
				
				int cpx = img.pixels[loc];
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

 public void transmit(PImage img, float[][][] ximage)
	{
		img.loadPixels();
		for (int i = 0; i < img.width; i++){
			for (int j = 0; j < img.height; j++){
				transmission(i,j, kwidth, img, ximage);
			}
		}
		img.updatePixels();
	}

 public void transmission(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		int cpx = img.pixels[x+y*img.width];
		
		float rpx = cpx >> 16 & 0xFF;
		float gpx = cpx >> 8 & 0xFF;
		float bpx = cpx & 0xFF;
		
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
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
		img.pixels[x+y*img.width] = color(rpx,gpx,bpx);
	}

 public PImage randomImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				int c = color(random(255.f));
				int index = (i + j * rimg.width);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}

 public PImage noiseImage(int w, int h, int lod, float falloff){
	  noiseDetail(lod, falloff);
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				int c = color(lerp(0,1,noise(i*cos(i),j*sin(j), (i+j)/2))*255);
				int index = (i + j * rimg.width);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}

 public PImage kuficImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				chance = ((i % 2) + (j % 2));
				
				float wallornot = random(2.f);
				int index = (i + j * rimg.width);
				if(wallornot <= chance){
						int c = color(0);
						rimg.pixels[index] = c;
					} else {
						int c = color(255-(255*(wallornot/2.f)));
						rimg.pixels[index] = c;
					}
				}
			}
		rimg.updatePixels();
		return rimg;
	}


 public void mazeImage(PImage source){
		source.loadPixels();
		for (int i = 0; i < source.width; i++){
			for (int j = 0; j < source.height; j++){
				
				int loc = (i + j * source.width);
				
				int cpx = source.pixels[loc];
				
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;
				float apx = alpha(cpx);
				
				float avgF = ((rpx+gpx+bpx+apx)/4.f)/255.f;
				
				float r = round(avgF);
				int c = color(r*255);
				source.pixels[loc] = c;
				}
			}
		source.updatePixels();
	}


  public void settings() { size(1422, 800, P3D); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "p4_ArcanePropagation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
