// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PGraphics pg;

PImage simg,dximg;
float[][][] xmg;
int downsample,modfac,dmfac;
int kwidth = 3;
int kwidthsq = (int)(pow(kwidth, 2));
int drawswitch = 0;
float scalefac,xsmnfactor,chance,displayscale,sw,sh,scale,gsd,downsampleFloat;

boolean dispersed, hav;

void setup(){
	size(1422, 800, P3D);
	// size(1600, 900, P3D);
	// size(2880, 1620, P3D);
	// size(3840, 2160, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(displayDensity());
	
	hint(ENABLE_STROKE_PURE);
	
	// LOAD IMAGE
	
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
	// simg = loadImage("./imgs/universe.jpg");
	
	// simg = loadImage("./imgs/buildings.jpg");
	simg = loadImage("./imgs/clouds.jpg");
	// simg = loadImage("./imgs/nasa.jpg");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// simg = loadImage("./imgs/nestedsquare.png");
	// simg = loadImage("./imgs/mountains_1.jpg");
	
	// int noisew =  width/32;
	// int noiseh = height/32;
	// simg = randomImage(noisew, noiseh);
	// simg = noiseImage(noisew, noiseh, 3, .6);
	// simg = kuficImage(noisew, noiseh);
	
	// mazeImage(simg);
	
	// APPLY BASE FILTER
	// simg.filter(GRAY);
	// simg.filter(POSTERIZE, 4);
	// simg.filter(BLUR, 2);
	// simg.filter(DILATE);
	// simg.filter(ERODE);
	// simg.filter(INVERT);
	// simg.filter(THRESHOLD, .8);
	
	downsampleFloat = 1.25;
	modfac = 3;
	
	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	float sw = (float)simg.pixelWidth;
	float sh = (float)simg.pixelHeight;
	float scale = min(pixelWidth/sw, pixelHeight/sh);
	
	int nw = Math.round(sw*scale/downsampleFloat);
	int nh = Math.round(sh*scale/downsampleFloat);
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
	float sf = 0510.00;   /* 000.50 */
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
	xsmnfactor = pow(kwidth,2.); /* default */
	// xsmnfactor = pow(kwidth,3.);
	// xsmnfactor = pow(kwidth,4.);
	// xsmnfactor = pow(kwidth,6.);
	// xsmnfactor = scalefac; /* makes transmission some value between 0 and 1*/
	
	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/
	gsd = 255.; /* 255 | 3 */
	hav = false;
	xmg = loadxm(simg, kwidth);
	
	dispersed = true;
	dximg = createImage(simg.pixelWidth/modfac, simg.pixelHeight/modfac, ARGB);
	
	background(0);
	noCursor();
}

void draw(){
	//selectDraw(String convolution, String style)
	//convolution — still | convolve | transmit | transmitMBL | switch | switchTotal | blur | weighted blur
	//style — point | line | xline | xliner | xliner2

	selectDraw("still", "point");
	// selectDraw("transmitMBL", "point");
	// selectDraw("posterize", "point", 25);
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
		// switchdraw(int frames, int selector);
			switchdraw(20, 2);
			break;
		case "switchTotal":
		// switchdrawTotal(int frames, int selector);
			switchdrawTotal(20, 4);
			break;
		case "blur":
			simg.filter(BLUR, 1);
			break;
		case "posterize":
			simg.filter(POSTERIZE, (frameCount % 253) + 2);
			break;
		case "dilate":
			simg.filter(DILATE);
			break;
		case "erode":
			simg.filter(ERODE);
			break;
		case "weightedblur":
			weightedblur(simg, xmg);
			break;
		default:
			break;
		}
	
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
			) / gsd;
	} else if(!hav) {
		// channel average
		igs = (rpx + gpx + bpx) / gsd;
	} else {
		igs = 1.;
	}
	// return igs;
	return map(igs, 0., 1., -.5*scalefac, .5*scalefac);
	// return map(igs, 0., 1., -1.*scalefac, 1.*scalefac);
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
			) / gsd;
	} else {
		// channel average
		igs = (rpx + gpx + bpx) / gsd;
	}
	return igs;
}

void pointorbit(PImage nimg, String selector){
	nimg.loadPixels();
	for(int x = 0; x < nimg.pixelWidth;x++){
		for(int y = 0; y < nimg.pixelHeight; y++){
			int index = (x + (y * nimg.pixelWidth));
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
	// float enc = lerp(-1., 1., energy/scalefac);
	// float enc = lerp(-1., 1., (energy+1.)/2.);
	stroke(energyDegree(energy));
	float ang = radians(energyAngle(enc));
	
	// float px = x + (1./(modfac/2) * cos(ang));
	// float py = y + (1./(modfac/2) * sin(ang));
	
	float px = x + (1./(modfac) * cos(ang));
	float py = y + (1./(modfac) * sin(ang));
	
	if(dispersed){
		pushMatrix();
		translate((width/2)-(modfac*(dximg.pixelWidth/2)),(height/2)-(modfac*(dximg.pixelHeight/2)));
		point(
			(px) * modfac,
			(py) * modfac
		);
		popMatrix();
		} else {
			pushMatrix();
			translate((width/2)-(simg.pixelWidth/2),(height/2)-(simg.pixelHeight/2));
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
		translate((width/2)-(modfac*(dximg.pixelWidth/2)),(height/2)-(modfac*(dximg.pixelHeight/2)));
		line(
				x  * modfac,
				y  * modfac,
			(px) * modfac,
			(py) * modfac
		);
		popMatrix();
		} else {
			pushMatrix();
			translate((width/2)-(simg.pixelWidth/2),(height/2)-(simg.pixelHeight/2));
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
			// stroke(energyDegree(energy), 255 * .125);
			// stroke(lerpColor(0, 255, energy), 255 * .125);
			// stroke(energyDegree(energy));
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width/2)-(modfac*(dximg.pixelWidth/2)),(height/2)-(modfac*(dximg.pixelHeight/2)));

					line(
						(x + .5) * modfac,
						(y + .5) * modfac,
						(xloc + .5) * modfac,
						(yloc + .5) * modfac
						);
					popMatrix();
					} else {
						pushMatrix();
						translate((width/2)-(simg.pixelWidth/2),(height/2)-(simg.pixelHeight/2));
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
			// stroke(lerpColor(cc, cpx, energy), 255 * .125);
			// stroke(energyDegree(energy), 255 * .125);
			// stroke(lerpColor(0, 255, energy), 255 * .125);
			stroke(energyDegree(energy));
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width/2)-(modfac*(dximg.pixelWidth/2)),(height/2)-(modfac*(dximg.pixelHeight/2)));
					line(
						(x + .5) * modfac,
						(y + .5) * modfac,
						(xloc + (.5 * cos(ang))) * modfac,
						(yloc + (.5 * sin(ang))) * modfac
						);
					popMatrix();
					} else {
						pushMatrix();
						translate((width/2)-(simg.pixelWidth/2),(height/2)-(simg.pixelHeight/2));
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
			// stroke(lerpColor(cc, cpx, energy), 255 * .125);
			// stroke(energyDegree(energy), 255 * .125);
			// stroke(energyDegree(energy), 255 * .0625);
			// stroke(lerpColor(0, 255, energy), 255 * .125);
			stroke(energyDegree(energy));
			if(xloc == x && yloc == y){
				continue;
			} else{
				if(dispersed){
					pushMatrix();
					translate((width/2)-(modfac*(dximg.pixelWidth/2)),(height/2)-(modfac*(dximg.pixelHeight/2)));
					PVector midpoint = new PVector(lerp(float(x), float(xloc), .5), lerp(float(y), float(yloc), .5));
					PVector p1 = new PVector(float(x), float(y));
					PVector p2 = new PVector(float(xloc), float(yloc));
					float l = PVector.dist(p1,p2);
					pushMatrix();
					translate((midpoint.x*modfac), (midpoint.y*modfac));
					rotate(ang);
					int mfd = 4;
					line(
						(-l/2) * (modfac/mfd),
						(-l/2) * (modfac/mfd),
						( l/2) * (modfac/mfd) ,
						( l/2) * (modfac/mfd)
						);
						
					popMatrix();
					popMatrix();
					} else {
						pushMatrix();
						translate((width/2)-(simg.pixelWidth/2),(height/2)-(simg.pixelHeight/2));
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
	float ecc = (ec + 1.) / 2.;
	float a = lerp(0., 360., ecc);
	return a;
}

color energyDegree(float energy) {
	float ne = (energy+1.)/2.;
	// COLOR BY ANGLE
	// float ac = energyAngle(energy);
	// float ac4 = lerp(0., 1., ac / 360.) * 215.;
	
	// float ac4 = lerp(0., 1., ac / radians(360.)) * 215.;
	// float rpx = ac4;
	//
	// float gpx = 255. - (abs(energy) * 255.);
	// float bpx = 255. - (abs(energy) * 200.);
	
	// float gpx = 255. - (ne * 255.);
	// float bpx = 255. - (ne * 200.);
	
	// return color(rpx, gpx, bpx, lerp(0., 255., (ac/radians(360.))));
	// return color(rpx, gpx, bpx, lerp(0., 255., energy*(ac/radians(360.))));
	// return color(rpx, gpx, bpx, lerp(0., 255., energy));
	// return color(rpx, gpx, bpx, lerp(0., 255., ne));
	// return color(rpx, gpx, bpx);
	// return color(rpx, gpx, bpx, 255. - (255*energy));
	
	// COLOR BY ENERGY
	return lerpColor(color(0, 255, 255, 255), color(215, 0, 55, 255), ne);
	
	// return lerpColor(color(0, 255, 255), color(215, 0, 55) , ne);
	// return lerpColor(color(0, 0, 0), color(255, 255, 255)  , ne);
	// return lerpColor(color(0, 0, 255), color(255, 255, 255), ne);
	// return lerpColor(color(255, 255, 255), color(0, 0, 255), ne);
	
	// DRAGON
	// float bezr = bezierPoint(255, 63.75, 15.7, 0., ne);
	// float bezg = bezierPoint(0, 191.25, 50,  67.5, ne);
	// float bezb = bezierPoint(0, 102, 19.50,  76. , ne);
	// return color(bezr, bezg, bezb);
	
	// FLIR
	// float bezr = bezierPoint(255, 255,   0,   0, ne);
	// float bezg = bezierPoint(  0, 255, 255,   0, ne);
	// float bezb = bezierPoint(  0,   0,   0, 255, ne);
	// return color(bezr, bezg, bezb);
	
	// BEACH
	// float bezr = bezierPoint(  0, 63.75,   220, 255, abs(energy));
	// float bezg = bezierPoint(  0, 53.75,   167, 255, abs(energy));
	// float bezb = bezierPoint(  0,  0.00,   49,  255, abs(energy));
	// return color(bezr, bezg, bezb);
	
	// BEACH2
	// float bezr = bezierPoint(  0, 63.75,   220, 255, ne);
	// float bezg = bezierPoint(  0, 53.75,   167, 255, ne);
	// float bezb = bezierPoint(  0,  0.00,   49,  255, ne);
	// return color(bezr, bezg, bezb);

	// GOLD SHEEN3
	// float bezr = bezierPoint(  0, 63.75,   220, 255, ne);
	// float bezg = bezierPoint(  0, 53.75,   167, 255, ne);
	// float bezb = bezierPoint(  0,  0.00,   49,  255, ne);
	// float balpha = lerp(0.,255., ne);
	// float balpha = 255*.125;
	// return color(bezr, bezg, bezb, balpha);
	
	// return lerpColor(color(0, 0, 0), color(255, 255, 255), energy);
	// return lerpColor(color(0, 0, 0), color(255, 255, 255), radians(ac)/radians(360.));
	/* since ac is already between 0 and 360, there's no reason to convert 360 to radians... and ac is just energy sclaed to 360, so I can just scale energy between 0 and 1 instead. */
	// return lerpColor(color(0, 0, 0), color(255, 255, 255), ac/360.);
	// return lerpColor(color(87,114,118,0), color(255, 158, 61,255), ac/360.);
	// return lerpColor(color(0,0,0), color(255, 158, 61), (energy+1.)/2.);
	// return lerpColor(color(0,0,0), color(255, 158, 61), ac/radians(360.));
	
	// return lerpColor(color(255, 255, 255, energy*255), color(215, 0, 55, energy*255), energy);
	// return lerpColor(color(255, 255, 255, 255), color(215, 0, 55, 255), energy);
	// return lerpColor(color(255, 255, 255, 255), color(215, 0, 55, 255), lerp(0.,1.,energy));
	
	// return lerpColor(color(255, 255, 255), color(215, 0, 55), lerp(0.,1.,energy));
	//
	// return lerpColor(color(0, 0, 0), color(215, 0, 55), lerp(-1.,1.,energy));
	
	// return lerpColor(color(255, 255, 255), color(215, 0, 55), (energy+1.)/2.);
	// return lerpColor(color(255, 255, 255), color(215, 0, 55), energy);
	
	// return lerpColor(color(255, 255, 255,0), color(215, 0, 55, 255), energy);
	
	// return lerpColor(color(255, 255, 255,150), color(215, 0, 55, 255), energy);
	// return lerpColor(color(255, 255, 255,200), color(215, 0, 55, 255), energy);
	
	// return lerpColor(color(255, 255, 255, 255), color(215, 0, 55, 255), energy);
	
	// return lerpColor(color(0, 0, 0), color(215, 0, 55), (energy+1.)/2.);
	
	// return lerpColor(color(0, 0, 0), color(215, 0, 55), (energy+1.)/2.);
	
	// return lerpColor(color(215, 0, 55), color(20,20,20), (energy+1.)/2.);
	
	// return lerpColor(color(215, 0, 55), color(20,20,20), ac/radians(360.));
	
	// return lerpColor(color(0,0,0), color(215, 0, 55), ac/radians(360.));
	
	// return lerpColor(color(255,255,255), color(215, 0, 55), ac/radians(360.));
	
	// return lerpColor(color(0,0,0), color(215, 0, 55), (energy+1.)/2.);
	
	// return lerpColor(color(255, 255, 255), color(215, 0, 55), energy);
	// return lerpColor(color(0, 0, 128), color(255, 255, 255), energy);
	// return lerpColor(color(255, 215, 0), color(55, 15, 05), energy);
	// return lerpColor(color(255, 215, 0), color(0, 0, 0), energy);
	// return lerpColor(color(255, 215, 0), color(255, 0, 55), energy);
	// return lerpColor(color(0, 0, 0), color(255, 0, 0), energy);
	// return lerpColor(color(50, 0, 0), color(255, 0, 0), energy);
	// return lerpColor(color(50, 0, 0), color(255, 0, 0), energy);
	
	// color c1 = color(
	// 	map(0.101961, 0.,.145098, 0, 50),
	// 	map(0.145098, 0.,.145098, 0, 50),
	// 	map(0.117647, 0.,.145098, 0, 50)
	// 	);
	// color c2 = color(
	// 	map(0.101961, 0.,.145098, 0, 255),
	// 	map(0.145098, 0.,.145098, 0, 255),
	// 	map(0.117647, 0.,.145098, 0, 255)
	// 	);
	// return lerpColor(c1, c2, energy);
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
			int loc = xloc + img.pixelWidth*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			// TODO: should gs be computed with a different divisor. 3? or should I just take the natural mean values instead of the graded grayscale?
			
			color cpx = img.pixels[loc];
			float gs = computeGS(cpx);
			
			// the closer values are to 0 the more negative the transmission is, that's why a large value of scalefac produces fast fades.
			kern[i][j] = map(gs, 0, 1, -1.*scalefac,1.*scalefac);
			// kern[i][j] = map(gs, 0, 1, -.5,.5);
			// kern[i][j] = map(gs, 0, 1, -.5*scalefac,.5*scalefac);
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
		//  TODO: It may be the case that (rgb)total shouldn't start at 0.
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
				// float xmsn = (ximg[loc][i][j] / xsmnfactor);
				
				float xmsn = computeGS(cpx) / xsmnfactor;
				
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
		float rpx = spx >> 16 & 0xFF;
		float gpx = spx >> 8 & 0xFF;
		float bpx = spx & 0xFF;
		
		
		float xmission = gs * ximg[sloc][1][1];
		float abse = abs(xmission - gs);
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				color cpx = img.pixels[loc];
				
				float crpx = cpx >> 16 & 0xFF;
				float cgpx = cpx >> 8 & 0xFF;
				float cbpx = cpx & 0xFF;
				
				// if(abse <= .4){
				// 	rpx -= (xmission / crpx);
				// 	gpx -= (xmission / cgpx);
				// 	bpx -= (xmission / cbpx);
				// } else {
				// 	rpx += (xmission / crpx);
				// 	gpx += (xmission / cgpx);
				// 	bpx += (xmission / cbpx);
				// }
				
				// if(abse <= .1){
				// 	rpx -= (xmission + crpx);
				// 	gpx -= (xmission + cgpx);
				// 	bpx -= (xmission + cbpx);
				// } else {
				// 	rpx += (xmission - crpx);
				// 	gpx += (xmission - cgpx);
				// 	bpx += (xmission - cbpx);
				// }
				
				// if(abse <= .1){
				// 	rpx -= (xmission - crpx);
				// 	gpx -= (xmission - cgpx);
				// 	bpx -= (xmission - cbpx);
				// } else {
				// 	rpx += (xmission - crpx);
				// 	gpx += (xmission - cgpx);
				// 	bpx += (xmission - cbpx);
				// }
				
				if(abse <= .1){
					rpx -= (xmission);
					gpx -= (xmission);
					bpx -= (xmission);
				} else {
					rpx += (xmission);
					gpx += (xmission);
					bpx += (xmission);
				}
				// setting the pixel per iteration slows things down quite a bit
				// img.pixels[sloc] = color(rpx,gpx,bpx);
			}
		}
		img.pixels[sloc] = color(rpx,gpx,bpx);
	}

	void weightedblur(PImage img, float[][][] ximage)
		{
			img.loadPixels();
			for (int i = 0; i < img.pixelWidth; i++){
				for (int j = 0; j < img.pixelHeight; j++){
					weightedblurring(i,j, kwidth, img, ximage);
				}
			}
			img.updatePixels();
		}

	void weightedblurring(int x, int y, int kwidth, PImage img, float[][][] ximg)
		{
			int cloc = x+y*img.pixelWidth;
			color cpx = img.pixels[cloc];
			
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
					color npx = img.pixels[loc];
					float xmsn = (ximg[loc][i][j] / xsmnfactor);
					
					// float xmsn = computeGS(cpx) / xsmnfactor;
					// float xmsn = computeGS(npx) / xsmnfactor;
					
					float nrpx = npx >> 16 & 0xFF;
					float ngpx = npx >> 8 & 0xFF;
					float nbpx = npx & 0xFF;
					
					// if(xloc != x && yloc != y){
					// 	// rpx += nrpx;
					// 	// gpx += ngpx;
					// 	// bpx += nbpx;
					//
					// 	rpx += xmsn;
					// 	gpx += xmsn;
					// 	bpx += xmsn;
					// }
					
					// rpx += xmsn;
					// gpx += xmsn;
					// bpx += xmsn;
					
					rpx += (nrpx * xmsn);
					gpx += (ngpx * xmsn);
					bpx += (nbpx * xmsn);
				}
			}
			
			// rpx /= (kwidthsq - 1);
			// gpx /= (kwidthsq - 1);
			// bpx /= (kwidthsq - 1);
			
			// rpx;
			// gpx;
			// bpx;
			
			img.pixels[cloc] = color(rpx,gpx,bpx);
		}


// IMAGE GENERATORS
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
