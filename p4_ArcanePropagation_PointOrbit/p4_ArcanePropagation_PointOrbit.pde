// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PGraphics pg;

PImage simg,dximg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
int drawswitch = 0;
float scalefac,xsmnfactor,chance,displayscale,sw,sh,scale,gsd,downsampleFloat;

boolean dispersed, hav;

void setup(){
	// size(1422,800, P3D);
	size(1600,900, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(displayDensity());
	
	hint(ENABLE_STROKE_PURE);
	
	// simg = loadImage("./imgs/buff_skate.JPG");
	// simg = loadImage("./imgs/face.png");
	// simg = loadImage("./imgs/p5sketch1.jpg");
	// simg = loadImage("./imgs/fruit.jpg");
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
	
	// simg = loadImage("./imgs/buildings.jpg");
	// simg = loadImage("./imgs/clouds.jpg");
	simg = loadImage("./imgs/nasa.jpg");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// simg = loadImage("./imgs/nestedsquare.png");
	// simg = loadImage("./imgs/mountains_1.jpg");
	// simg = randomImage(width, height);
	// simg = randomImage(width/32, height/32);
	// simg = randomImage(width/4, height/4);
	// simg = noiseImage(width/16, height/16, 3, .6);
	// simg = noiseImage(height/16, height/16, 3, .6);
	// simg = noiseImage(height/32, height/32, 3, .6);
	// simg = noiseImage(height/32, height/64, 3, .6);
	// simg = noiseImage(width/32, height/64, 3, .6);
	// simg = kuficImage(width, height);
	// simg = kuficImage(width/16, height/16);
	// simg = kuficImage(width/16, height/32);
	// simg = kuficImage(width/32, height/32);
	// simg = kuficImage(width/64, height/64);
	// simg = kuficImage(width/5, height/5);
	
	// mazeImage(simg);
	
	// simg.filter(GRAY);
	// simg.filter(POSTERIZE, 4);
	// simg.filter(BLUR, 2);
	// simg.filter(DILATE);
	// simg.filter(ERODE);
	// simg.filter(INVERT);
	// simg.filter(THRESHOLD, .8);
	
	
	// downsample functions much like displayscale does in the shader project, except that it can't make the image bigger, only smaller.
	// dmfac = 1;
	// downsample = modfac = dmfac;
	// downsampleFloat = .5;
	// downsampleFloat = 1.0;
	downsampleFloat = 1.5;
	// downsampleFloat = 2.0;
	// downsampleFloat = 3.0;
	// downsampleFloat = 4.0;
	// modfac = 1;
	// modfac = 2;
	// modfac = 3;
	modfac = 5;
	// modfac = 8;
	// modfac = 10;
	// modfac = 20;
	
	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	float sw = (float)simg.width;
	float sh = (float)simg.height;
	float scale = min(width/sw, height/sh);
	// float sw = (float)simg.pixelWidth;
	// float sh = (float)simg.pixelHeight;
	// float scale = min(pixelWidth/sw, pixelHeight/sh);
	
	int nw = Math.round(sw*scale/downsampleFloat);
	int nh = Math.round(sh*scale/downsampleFloat);
	// int nw = Math.round(sw*scale);
	// int nh = Math.round(sh*scale);
	simg.resize(nw, nh);
	// simg.resize(nw/downsample, nh/downsample);
	
	// sf ~~ rate of decay
	// convolve: As sf increases decay-rate increases
	// transmit: As sf increases decay-rate decreases
	// smear: As sf increases      smear decreases
	// float sf = 0000.50;   /* 510.00 */
	// float sf = 0001.00;   /* 255.00 */
	// float sf = 0005.00;   /* 051.00 */
	// float sf = 0015.00;   /* 017.00 */
	// float sf = 0017.00;   /* 015.00 */
	// float sf = 0051.00;   /* 005.00 */
	// float sf = 0255.00;   /* 001.00 */
	// float sf = 0510.00;   /* 000.50 */
	// float sf = 0765.00;   /* 000.33 */ /* works well with transmit */
	// float sf = 1020.00;   /* 000.25 */
	// float sf = 2040.00;   /* 000.125 */
	// float sf = 2040.00;   /* 000.125 */
	// float sf = 3750.00;   /* 000.068 */
	float sf = 4080.00;   /* 000.0625 */

	scalefac = 255./sf;
	
	// Determine the leak-rate (transmission factor) of each pixel
	// xsmnfactor = 1.;
	// xsmnfactor = pow(kwidth,0.5);
	// xsmnfactor = pow(kwidth,1.5);
	// xsmnfactor = pow(kwidth - 1,3.); /* default */
	// xsmnfactor = pow(kwidth,2.); /* default */
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
	dximg = createImage(simg.width/modfac, simg.height/modfac, ARGB);
	background(0);
}

void draw(){
	
	// selectDraw("convolve", "point");
	// selectDraw("convolve", "line");
	// selectDraw("convolve", "xline");
	// selectDraw("convolve", "xliner");
	// selectDraw("convolve", "xliner2");
	
	selectDraw("transmit", "point");
	// selectDraw("transmit", "line");
	// selectDraw("transmit", "xline");
	// selectDraw("transmit", "xliner");
	// selectDraw("transmit", "xliner2");

	// selectDraw("transmitMBL", "point");
	// selectDraw("transmitMBL", "line");
	// selectDraw("transmitMBL", "xline");
	// selectDraw("transmitMBL", "xliner");
	// selectDraw("transmitMBL", "xliner2");
	
	// selectDraw("switch", "point");
	// selectDraw("switch", "line");
	// selectDraw("switch", "xline");
	// selectDraw("switch", "xliner");
	// selectDraw("switch", "xliner2");
	
	// selectDraw("switchTotal", "point");
	// selectDraw("switchTotal", "line");
	// selectDraw("switchTotal", "xline");
	// selectDraw("switchTotal", "xliner");
	// selectDraw("switchTotal", "xliner2");
}

void selectDraw(String selector, String style){
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
		case "switch":
		// switchdraw(20, 1);
			switchdraw(60, 1);
			break;
		case "switchTotal":
		// switchdrawTotal(60, 1);
		// switchdrawTotal(60, 2);
		// switchdrawTotal(60, 3);
			switchdrawTotal(100, 4);
			break;
		default:
			transmit(simg, xmg);
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

void pointorbit(PImage nimg, String selector){
	nimg.loadPixels();
	for(int x = 0; x < nimg.width;x++){
		for(int y = 0; y < nimg.height; y++){
			int index = (x + (y * nimg.width));
			color cpx = nimg.pixels[index];
			float gs = computeGS(cpx);
			pushMatrix();
			
			switch(selector){
				case "point":
					showAsPoint(x,y,gs);
					break;
				case "line":
					showAsLine(x,y,gs);
					break;
				case "xline":
					showTLines(nimg,x,y,gs);
					break;
				case "xliner":
					showTRotator(nimg,x,y,gs);
					break;
				case "xliner2":
					showTRotator2(nimg,x,y,gs);
					break;
				default:
					showAsPoint(x,y,gs);
					break;
			}
			popMatrix();
		}
	}
	nimg.updatePixels();
}


void showAsPoint(int x, int y, float energy) {
	float enc = lerp(-1., 1., energy);
	color cc = energyDegree(enc);
	stroke(cc);
	float ang = radians(energyAngle(enc));
	// float px = x + (.25 * cos(ang));
	// float py = y + (.25 * sin(ang));
	float px = x + (.5 * cos(ang));
	float py = y + (.5 * sin(ang));
	// float px = x + ((1./float(modfac)) * cos(ang));
	// float py = y + ((1./float(modfac)) * sin(ang));
	// float px = x + ((scale * (1./float(modfac))) * cos(ang));
	// float py = y + ((scale * (1./float(modfac))) * sin(ang));
	// float px = x + (.5+(scale/float(modfac))) * cos(ang);
	// float py = y + (.5+(scale/float(modfac))) * sin(ang);
	// float px = x + ((1./float(modfac))*.5) * cos(ang);
	// float py = y + ((1./float(modfac))*.5) * sin(ang);

	if(dispersed){
		pushMatrix();
		translate((width/2)-(modfac*(dximg.width/2)),(height/2)-(modfac*(dximg.height/2)));
		point(
			(px) * modfac,
			(py) * modfac
		);
		popMatrix();
		} else {
			pushMatrix();
			translate((width/2)-(simg.width/2),(height/2)-(simg.height/2));
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
		translate((width/2)-(modfac*(dximg.width/2)),(height/2)-(modfac*(dximg.height/2)));
		line(
				x  * modfac,
				y  * modfac,
			(px) * modfac,
			(py) * modfac
		);
		popMatrix();
		} else {
			pushMatrix();
			translate((width/2)-(simg.width/2),(height/2)-(simg.height/2));
			line(x, y, px, py);
			popMatrix();
		}

}

void showTLines(PImage img, int x, int y, float energy) {

	int sloc = x+y*img.width;
	sloc = constrain(sloc, 0, img.pixels.length - 1);
	color cc = img.pixels[sloc];

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
			
			strokeWeight(1);
			// stroke(lerpColor(cc, cpx, energy), 255 * .125);
			stroke(energyDegree(energy), 255 * .125);
			// stroke(lerpColor(0, 255, energy), 255 * .125);
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width/2)-(modfac*(dximg.width/2)),(height/2)-(modfac*(dximg.height/2)));

					line(
						(x + .5) * modfac,
						(y + .5) * modfac,
						(xloc + .5) * modfac,
						(yloc + .5) * modfac
						);
					popMatrix();
					} else {
						pushMatrix();
						translate((width/2)-(simg.width/2),(height/2)-(simg.height/2));
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

	// int sloc = x+y*img.width;
	// sloc = constrain(sloc, 0, img.pixels.length - 1);
	// color cc = img.pixels[sloc];

	float enc = lerp(-1., 1., energy);
	float ang = radians(energyAngle(enc));

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
			
			strokeWeight(1);
			// stroke(lerpColor(cc, cpx, energy), 255 * .125);
			stroke(energyDegree(energy), 255 * .125);
			// stroke(lerpColor(0, 255, energy), 255 * .125);
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width/2)-(modfac*(dximg.width/2)),(height/2)-(modfac*(dximg.height/2)));
					line(
						(x + .5) * modfac,
						(y + .5) * modfac,
						(xloc + (.5 * cos(ang))) * modfac,
						(yloc + (.5 * sin(ang))) * modfac
						);
					popMatrix();
					} else {
						pushMatrix();
						translate((width/2)-(simg.width/2),(height/2)-(simg.height/2));
						line(
							(x + .5),
							(y + .5),
							(xloc + (.5 * cos(ang))),
							(yloc + (.5 * sin(ang)))
							);
						popMatrix();
					}
				// if(dispersed){
				// 	pushMatrix();
				// 	translate((width/2)-(modfac*(dximg.width/2)),(height/2)-(modfac*(dximg.height/2)));
				// 	line(
				// 		(x + (.5 * cos(ang))) * modfac,
				// 		(y + (.5 * sin(ang))) * modfac,
				// 		(xloc + (.5 * cos(ang))) * modfac,
				// 		(yloc + (.5 * sin(ang))) * modfac
				// 		);
				// 	popMatrix();
				// 	} else {
				// 		pushMatrix();
				// 		translate((width/2)-(simg.width/2),(height/2)-(simg.height/2));
				// 		line(
				// 			(x + (.5 * cos(ang))),
				// 			(y + (.5 * sin(ang))),
				// 			(xloc + (.5 * cos(ang))),
				// 			(yloc + (.5 * sin(ang)))
				// 			);
				// 		popMatrix();
				// 	}
			}
			}
		}
}

void showTRotator2(PImage img, int x, int y, float energy) {

	// int sloc = x+y*img.width;
	// sloc = constrain(sloc, 0, img.pixels.length - 1);
	// color cc = img.pixels[sloc];

	float enc = lerp(-1., 1., energy);
	float ang = radians(energyAngle(enc));

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
			
			strokeWeight(1);
			// stroke(lerpColor(cc, cpx, energy), 255 * .125);
			stroke(energyDegree(energy), 255 * .125);
			// stroke(lerpColor(0, 255, energy), 255 * .125);
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width/2)-(modfac*(dximg.width/2)),(height/2)-(modfac*(dximg.height/2)));
					PVector midpoint = new PVector(lerp(float(x), float(xloc), .5), lerp(float(y), float(yloc), .5));
					PVector p1 = new PVector(float(x), float(y));
					PVector p2 = new PVector(float(xloc), float(yloc));
					float l = PVector.dist(p1,p2);
					pushMatrix();
					// translate((x*modfac)+midpoint.x, (y*modfac)+midpoint.y);
					translate((midpoint.x*modfac), (midpoint.y*modfac));
					rotate(ang);
					// translate(-midpoint.x, -midpoint.y);
					// float distance = dist();
					// line(
					// 	(-l/2) * modfac,
					// 	(-l/2) * modfac,
					// 	(l/2) * modfac,
					// 	(l/2) * modfac
					// 	);
					// popMatrix();
					// line(
					// 	(-l/2),
					// 	(-l/2),
					// 	(l/2) ,
					// 	(l/2)
					// 	);
					line(
						(-l/2) * (modfac/2),
						(-l/2) * (modfac/2),
						(l/2) * (modfac/2) ,
						(l/2) * (modfac/2)
						);
					popMatrix();
					// rotate(-ang);
					popMatrix();
					} else {
						pushMatrix();
						translate((width/2)-(simg.width/2),(height/2)-(simg.height/2));
						rotate(ang);
						line(
							(x + .5),
							(y + .5),
							(xloc + (.5)),
							(yloc + (.5))
							);
						// rotate(-ang);
						popMatrix();
					}
				}
			}
		}
}

float energyAngle(float ec) {
	// float ecc = (ec + 1.) / 2.;
	// float a = ecc * 360.;
	float a = map(ec, -1., 1., 0., 360.);
	return constrain(a, 0, 360);
}

color energyDegree(float energy) {
	// float ac = energyAngle(energy);
	// float ac4 = lerp(0., 1., ac / 360.) * 215.;
	// float rpx = ac4;
	// float gpx = 255. - (abs(energy) * 255.);
	// float bpx = 255. - (abs(energy) * 200.);
	
	// return color(rpx, gpx, bpx, 255/9);
	// return color(rpx, gpx, bpx);
	// return color(rpx, gpx, bpx, 255. - (255*energy));
	// return lerpColor(color(0, 255, 255), color(215, 0, 55), energy);
	// return lerpColor(color(0, 0, 0), color(255, 0, 0), energy);
	// return lerpColor(color(50, 0, 0), color(255, 0, 0), energy);
	// return lerpColor(color(50, 0, 0), color(255, 0, 0), energy);
	
	// return lerpColor(color(50.*0.101961, 50.*0.145098, 50.*0.117647), color(255.*0.101961, 255.*0.145098, 255.*0.117647), energy);
	color c1 = color(
		map(0.101961, 0.,.145098, 0, 50),
		map(0.145098, 0.,.145098, 0, 50),
		map(0.117647, 0.,.145098, 0, 50)
		);
	color c2 = color(
		map(0.101961, 0.,.145098, 0, 255),
		map(0.145098, 0.,.145098, 0, 255),
		map(0.117647, 0.,.145098, 0, 255)
		);
	return lerpColor(c1, c2, energy);
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
			// kern[i][j] = map(gs, 0, 1, -1.*scalefac,1.*scalefac);
			kern[i][j] = map(gs, 0, 1, -.5,.5);
			// kern[i][j] = gs;
			// kern[i][j] = map(gs, 0, 1, 0.,1.*scalefac);
			// kern[i][j] = map(gs, 0, 1, -1.,1.);
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
		//  TODO: It may be the case that (rgb)total shouldn't start at 0.
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
		float srpx = spx >> 16 & 0xFF;
		float sgpx = spx >> 8 & 0xFF;
		float sbpx = spx & 0xFF;
		
		
		float gs = 1.;
		if(hav){
			// human grayscale
			gs = (
				0.2989 * srpx +
				0.5870 * sgpx +
				0.1140 * sbpx
				) / gsd;
		} else {
			// channel average
			gs = (srpx + sgpx + sbpx) / gsd;
		}
		
		// float xmsn = map(gs, 0., 1., -.5, .5) / xsmnfactor;
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
					// float xmsn = ximg[sloc][i][j] / 8;
					// rpx -= xmsn;
					// gpx -= xmsn;
					// bpx -= xmsn;
				} else {
					float xmsn = ximg[sloc][i][j] / xsmnfactor;
					// float xmsn = ximg[sloc][i][j] / 8;
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
