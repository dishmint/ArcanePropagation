// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PShader blueline;
PGraphics pg;

PImage simg,dimg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
int drawswitch = 0;
float scalefac,xsmnfactor,chance,displayscale,sw,sh,scale,gsd;

boolean dispersed, hav;

void setup(){
	size(1422,800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	// pixelDensity(displayDensity());
	pixelDensity(1);
	hint(ENABLE_STROKE_PURE);

	simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
		
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
	float sw = (float)simg.width;
	float sh = (float)simg.height;
	float scale = min(width/sw, height/sh);
	
	int nw = Math.round(sw*scale);
	int nh = Math.round(sh*scale);
	simg.resize(nw, nh);
	
	// sf ~~ rate of decay
	float sf = 0025.00;
	scalefac = 255./sf;
	
	// Determine the leak-rate (transmission factor) of each pixel
	// xsmnfactor = 1.;
	// xsmnfactor = pow(kwidth,0.5);
	// xsmnfactor = pow(kwidth,1.5);
	// xsmnfactor = pow(kwidth - 1,3.); /* default */
	// xsmnfactor = pow(kwidth, 2.); /* default */
	// xsmnfactor = pow(kwidth,3.);
	// xsmnfactor = pow(kwidth,4.);
	// xsmnfactor = pow(kwidth,6.);
	xsmnfactor = scalefac; /* makes transmission some value between 0 and 1*/
	
	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/
	gsd = 255.; /* 255 | 3 */
	hav = true;
	xmg = loadxm(simg, kwidth);
	
	dispersed = true;
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
	// blueline.set("rfac", 1.00000);
	blueline.set("rfac", 1.0625);
	// blueline.set("rfac", 1.25);
	// blueline.set("rfac", 1.300000);
	
	if(dispersed){
		useDispersed(modfac);
	} else {
		useOriginal();
	}
	
	// frameRate(1.);
	// frameRate(6.);
	// noLoop();
	background(0);
}

void draw(){
	// selectDraw("convolve");
	// selectDraw("transmit");
	// selectDraw("transmitMBL");
	// selectDraw("switch");
	// selectDraw("switchTotal");
	// selectDraw("blur");
	// selectDraw("dilate");
	selectDraw("gol");
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
		case "blur":
			simg.filter(BLUR);
			break;
		case "gol":
			gol(simg, xmg);
			break;
		// case "dilate":
		// 	simg.filter(DILATE);
		// 	break;
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
			int loc = xloc + img.width*yloc;
			
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
			
			kern[i][j] = map(gs, 0, 1, -1.*scalefac,1.*scalefac);
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

void convolve(PImage img, float[][][] ximage) {
	img.loadPixels();
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			color c =  convolution(i,j, kwidth, img, ximage);
			int index = (i + j * img.width);
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
				int loc = xloc + img.width*yloc;
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
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			color c =  smearing(i,j, kwidth, img, ximage, selector);
			int index = (i + j * img.width);
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
				int loc = xloc + img.width*yloc;
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
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			color c =  smearingTotal(i,j, kwidth, img, ximage, selector);
			int index = (i + j * img.width);
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
				int loc = xloc + img.width*yloc;
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
		for (int i = 0; i < img.width; i++){
			for (int j = 0; j < img.height; j++){
				transmission(i,j, kwidth, img, ximage);
			}
		}
		img.updatePixels();
	}

void transmission(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		color cpx = img.pixels[x+y*img.width];
		
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

void gol(PImage img, float[][][] ximage)
	{
		img.loadPixels();
		for (int i = 0; i < img.width; i++){
			for (int j = 0; j < img.height; j++){
				gols(i,j, kwidth, img, ximage);
			}
		}
		img.updatePixels();
	}

void gols(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		final float xmn = ximg[constrain(x+y*img.width, 0, ximg.length - 1)][1][1];
		
		final color cpx = img.pixels[x+y*img.width];
		
		float rpx = cpx >> 16 & 0xFF;
		float gpx = cpx >> 8 & 0xFF;
		float bpx = cpx & 0xFF;
		
		int count = 0;

		final int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
				loc = constrain(loc,0,img.pixels.length-1);

				color ipx = img.pixels[loc];
		
				float irpx = ipx >> 16 & 0xFF;
				float igpx = ipx >> 8 & 0xFF;
				float ibpx = ipx & 0xFF;

				if(xloc != x && yloc != y){
					float avg = ((irpx + igpx + ibpx) / 3.);
					count += (avg > (255./2.)) ? 1 : 0;
				}
			}
		}
		if((count < 2) || (count > 3)){
			// img.pixels[x+y*img.width] = color(rpx * .5, gpx * .5, bpx * .5);	
			// img.pixels[x+y*img.width] = color(0,0,0);
			rpx -= (xmn / (count + 1));
			gpx -= (xmn / (count + 1));
			bpx -= (xmn / (count + 1));
			
			img.pixels[x+y*img.width] = color(rpx, gpx, bpx);
		} 
		else if (count == 2 || count == 3){
			img.pixels[x+y*img.width] = color(rpx,gpx,bpx);
		} else {
			img.pixels[x+y*img.width] = color(255,255,255);
		}
	}

void transmitMBL(PImage img, float[][][] ximage)
	{
		img.loadPixels();
		for (int i = 0; i < img.width; i++){
			for (int j = 0; j < img.height; j++){
				transmissionMBL(i,j, kwidth, img, ximage);
			}
		}
		img.updatePixels();
	}

void transmissionMBL(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		int sloc = x+y*img.width;
		
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
				int loc = xloc + img.width*yloc;
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

PImage randomImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				color c = color(random(255.));
				int index = (i + j * rimg.width);
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
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				color c = color(lerp(0,1,noise(i*cos(i),j*sin(j), (i+j)/2))*255);
				int index = (i + j * rimg.width);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}

PImage kuficImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				chance = ((i % 2) + (j % 2));
				
				float wallornot = random(2.);
				int index = (i + j * rimg.width);
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
		for (int i = 0; i < source.width; i++){
			for (int j = 0; j < source.height; j++){
				
				int loc = (i + j * source.width);
				
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
