// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg;

PImage simg,dimg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
float scalefac,xsmnfactor,chance,displayscale;

boolean dispersed;

void setup(){
	size(800,800, P3D);
	// size(1000,1000, P3D);
	surface.setTitle("Arcane Propagations");
	pixelDensity(1);
	
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
	// simg = loadImage("./imgs/buildings.jpg");
	// simg = loadImage("./imgs/clouds.jpg");
	simg = loadImage("./imgs/nasa.jpg");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// simg = loadImage("./imgs/nestedsquare.png");
	// simg = randomImage(width/32, height/32);
	// simg = randomImage(width/4, height/4);
	// simg = noiseImage(width/16, height/16, 3, .6);
	// simg = kuficImage(width, height);
	// simg = kuficImage(width/16, height/16);

	// mazeImage(simg);
	
	// simg.filter(GRAY);
	// simg.filter(POSTERIZE, 4);
	// simg.filter(BLUR, 2);
	// simg.filter(DILATE);
	// simg.filter(ERODE);
	 //simg.filter(INVERT);
	
	// max height and with is 16384 for the Apple M1 graphics card (according to Processing debug message)
	// pg = createGraphics(400,400, P2D);
	// pg = createGraphics(1200,1200, P2D);
	pg = createGraphics(4000,4000, P2D);
	pg.noSmooth();
	
	// dmfac = 1;
	// downsample = modfac = dmfac;
	downsample = 1;
	modfac = 1;
	simg.resize(width/downsample,0);
	
	// sf ~~ rate of decay
	// convolve: As sf increases decay-rate increases
	// transmit: As sf increases decay-rate decreases
	//    smear: As sf increases      smear decreases
	// float sf = 000.50;   /* 510.00 */
	// float sf = 001.00;   /* 255.00 */
	// float sf = 002.00;   /* 127.50 */
	// float sf = 003.00;   /* 085.00 */
	// float sf = 004.00;   /* 063.75 */
	// float sf = 005.00;   /* 051.00 */
	// float sf = 006.00;   /* 042.50 */
	// float sf = 010.00;   /* 025.50 */
	// float sf = 012.00;   /* 021.25 */
	// float sf = 015.00;   /* 017.00 */
	// float sf = 017.00;   /* 015.00 */
	// float sf = 020.00;   /* 012.75 */
	float sf = 025.00;   /* 010.20 */
	// float sf = 027.00;   /* ————— */
	// float sf = 030.00;   /* 008.50 */
	// float sf = 034.00;   /* 007.50 */
	// float sf = 050.00;   /* 005.10 */
	// float sf = 051.00;   /* 005.00 */
	// float sf = 060.00;   /* 004.25 */
	// float sf = 068.00;   /* 003.75 */
	// float sf = 075.00;   /* 003.40 */
	// float sf = 085.00;   /* 003.00 */
	// float sf = 100.00;   /* 002.55 */
	// float sf = 102.00;   /* 002.50 */
	// float sf = 125.00;   /* 002.04 */
	// float sf = 150.00;   /* 001.70 */
	// float sf = 170.00;   /* 001.50 */
	// float sf = 204.00;   /* 001.25 */
	// float sf = 250.00;   /* 001.02 */
	// float sf = 255.00;   /* 001.00 */
	// float sf = 382.50;   /* 000.66 */
	// float sf = 510.00;   /* 000.50 */
	// float sf = 637.50;   /* 000.40 */
	// float sf = 765.00;   /* 000.33 */

	scalefac = 255./sf;;
	
	// xsmnfactor = 1.;
	// xsmnfactor = pow(kwidth,1.5);
	xsmnfactor = pow(kwidth,2.);
	// xsmnfactor = pow(kwidth,3.);
	
	xmg = loadxm(simg, kwidth);
	
	blueline = loadShader("blueline.glsl");
	blueline.set("rfac", 2.0);
	// blueline.set("rfac", (float)modfac*100);
	
	dispersed = true;
	if(dispersed){
		useDispersed(modfac);
	} else {
		useOriginal();
	}
	blueline.set("resolution", float(pg.width), float(pg.height));
	imageMode(CENTER);
	
	displayscale = 1.0;
	// displayscale = .98;
	// displayscale = .5;
	
	// frameRate(1.);
	// frameRate(6.);
}

void draw(){
	
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	convolve(simg, xmg);
	// transmit(simg, xmg);
	// smear(simg, xmg);
	
	if(dispersed){
		drawDispersed();
	} else {
		drawOriginal();
	}
	image(pg, width/2, height/2, width*displayscale, height*displayscale);
}


void useDispersed(int factor){
	dimg = createImage((simg.width*factor), (simg.height*factor), ARGB);
	dimg.resize(width/downsample,0);
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
			
			float rpx = cpx >> 16 & 0xFF;
			float gpx = cpx >> 8 & 0xFF;
			float bpx = cpx & 0xFF;
			
			float gs = (
				0.2989 * rpx +
				0.5870 * gpx +
				0.1140 * bpx
				) / 255;
			
			// more interesting for p5sketch1
			// float gs = (
			// 	0.2989 *   red(img.pixels[loc]) +
			// 	0.5870 * green(img.pixels[loc]) +
			// 	0.1140 *  blue(img.pixels[loc])
			// 	) / 3;

			// float gs = (red(img.pixels[loc]) + green(img.pixels[loc]) + blue(img.pixels[loc])) / 3;
				
				kern[i][j] = map(gs, 0, 1, -1.*scalefac,1.*scalefac);
				// kern[i][j] = map(gs, 0, 1, 1.*scalefac,-1.*scalefac);
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
			
			// float gs = (
			// 	0.2989 * rpx +
			// 	0.5870 * gpx +
			// 	0.1140 * bpx
			// 	) / 255;
			
			// more interesting for p5sketch1
			float gs = (
				0.2989 * rpx +
				0.5870 * gpx +
				0.1140 * bpx
				) / 3;

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

void smear(PImage img, float[][][] ximage) {
	img.loadPixels();
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			color c =  smearing(i,j, kwidth, img, ximage);
			int index = (i + j * img.width);
			img.pixels[index] = c;
		}
	}
	img.updatePixels();
	}

color smearing(int x, int y, int kwidth, PImage img, float[][][] ximg)
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

				if(xloc == x && yloc == y){
					rpx -= (xmsn);
					gpx -= (xmsn);
					bpx -= (xmsn);
				} else {
					rpx += (xmsn);
					gpx += (xmsn);
					bpx += (xmsn);
				}
			}
		}
		return color(rpx, gpx, bpx);
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
