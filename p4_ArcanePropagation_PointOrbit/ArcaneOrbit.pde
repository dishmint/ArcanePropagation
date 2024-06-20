/* 
	Making use of this article to implement functional interfaces
	https://dzone.com/articles/functional-programming-in-java-8-part-1-functions-as-objects
*/
import java.util.function.*;
import java.util.Arrays;
@FunctionalInterface
public interface ArcaneDraw {
	void draw(PImage img, int x, int y, color src, float energy);
	}

@FunctionalInterface
public interface ArcaneDrawXMG {
	void drawXMG(int x, int y, PImage img, float[][][] xmg);
	}

class ArcaneOrbit {
	String shapemode;
	ArcaneDraw arcorbit;
	final float pixelRes = 0.50f;
	// bool disperse = true /* dispersed */

	/* points */
	ArcaneDraw points = (img, x, y, src, energy) -> {
		color c = src;
		// This mult of modfac should be implemented with a slider. The look is cool, but it's not faithful to the original image, so should be set by user.
		if (dispersed) {
			energy *= modfac;
			c *= modfac;
		}

		at.pushEnergyAngle(energy);
		final float ang = at.angle;

		// float ang = at.angle;
		// if (dispersed) {
		// 	ang *= fmfd;			
		// }
		if (at.theme.equals("truth")) {			
			stroke(c);
		} else {
			stroke(at.hue());
		}
		
		float px = x + (fmfd * cos(ang));
		float py = y + (fmfd * sin(ang));

		// FIXME: `if (dispersal)` called for every pixel, the check should run before the for loop.
		/* 
		
			if (dispersed) {
				show_dispersed
			} else {
				show
			}
		
		*/
	
		if(dispersed) {
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
			point(px,py);
			popMatrix();
		}
	};
	
	/* lines */
	ArcaneDraw lines = (img, x, y, src, energy) -> {
		color c = src;
		// if (dispersed) {
		// 	energy *= modfac;
		// 	c *= modfac;
		// }

		at.pushEnergyAngle(energy);
		float ang = at.angle;

		// float ang = at.angle;
		// if (dispersed) {
		// 	ang *= fmfd;			
		// }		
		if (at.theme.equals("truth")) {			
			stroke(c);
		} else {
			stroke(at.hue());
		}

		float px = x + (.5 * cos(ang));
		float py = y + (.5 * sin(ang));

		strokeWeight(pixelRes);

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
	};
	
	/* Tlines */
	ArcaneDraw tlines = (img, x, y, src, energy) -> {
		color c = src;
		// if (dispersed) {
		// 	energy *= modfac;
		// 	c *= modfac;
		// }

		at.pushEnergyAngle(energy);
		float ang = at.angle;

		// float ang = at.angle;
		// if (dispersed) {
		// 	ang *= fmfd;			
		// }		
		if (at.theme.equals("truth")) {			
			stroke(c);
		} else {
			stroke(at.hue());
		}

		float px = x + (.5 * cos(ang));
		float py = y + (.5 * sin(ang));

		strokeWeight(pixelRes);

		int offset = int(kw * 0.5);
		for (int i = 0; i < kw; i++){
			for (int j= 0; j < kw; j++){
				
				final int xloc = x+i-offset;
				final int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				
				loc = constrain(loc,0,img.pixels.length-1);
				
				color cpx = img.pixels[loc];
				
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;
				
				strokeWeight(pixelRes);
				// if (dispersed) {
				// 	cpx *= modfac;
				// }

				if (at.theme.equals("truth")) {			
					stroke(lerpColor(c, cpx, energy), 255 * .125);
				} else {
					stroke(lerpColor(at.hue(), at.outhue(cpx), energy), 255 * .125);
				}

				if(xloc == x && yloc == y){
					continue;
				} else {
					if(dispersed){
						pushMatrix();
						translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));

						line(
							(x + .5) * modfac, (y + .5) * modfac,
							(xloc + .5) * modfac, (yloc + .5) * modfac
						);
						popMatrix();
					} else {
						pushMatrix();
						translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
						line(
							(x + (.5)), (y + (.5)),
							(xloc + (.5)), (yloc + (.5))
						);
						popMatrix();
					}
				}
			}
		}
	};
	
	void setDraw(String fm){
		switch(fm){
			case "points":
				arcorbit = points;
				break;
			case "lines":
				arcorbit = lines;
				break;
			case "tlines":
				arcorbit = tlines;
				break;
			default:
				arcorbit = points;
				break;
	    }
	}

	ArcaneOrbit(String smode){
		shapemode = smode;

		setDraw(shapemode);
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

	void show(PImage smg) {
		smg.loadPixels();
		for (int i = 0; i < smg.pixelWidth; i++){
			for (int j = 0; j < smg.pixelHeight; j++){
				int sloc = i+j*smg.pixelWidth;
				sloc = constrain(sloc,0,smg.pixels.length-1);
				color cpx = smg.pixels[sloc];
				float energy = computeGS(cpx);
				pushMatrix();
				arcorbit.draw(smg, i, j, cpx, energy);
				popMatrix();
			}
		}
		smg.updatePixels();
	}
}

// void showTLines(PImage img, int x, int y, float energy) {

// 	int sloc = x+y*img.pixelWidth;
// 	sloc = constrain(sloc, 0, img.pixels.length - 1);
// 	color cc = img.pixels[sloc];

// 	int offset = int(kwidth * 0.5);
// 	for (int i = 0; i < kwidth; i++){
// 		for (int j= 0; j < kwidth; j++){
			
// 			int xloc = x+i-offset;
// 			int yloc = y+j-offset;
// 			int loc = xloc + img.pixelWidth*yloc;
			
// 			loc = constrain(loc,0,img.pixels.length-1);
			
// 			color cpx = img.pixels[loc];
			
// 			float rpx = cpx >> 16 & 0xFF;
// 			float gpx = cpx >> 8 & 0xFF;
// 			float bpx = cpx & 0xFF;
			
// 			strokeWeight(1);
// 			stroke(lerpColor(cc, cpx, energy), 255 * .125);

// 			if(xloc == x && yloc == y){
// 				continue;
// 			} else {
// 				if(dispersed){
// 					pushMatrix();
// 					translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));

// 					line(
// 						(x + .5) * modfac, (y + .5) * modfac,
// 						(xloc + .5) * modfac, (yloc + .5) * modfac
// 					);
// 					popMatrix();
// 				} else {
// 					pushMatrix();
// 					translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
// 					line(
// 						(x + (.5)), (y + (.5)),
// 						(xloc + (.5)), (yloc + (.5))
// 					);
// 					popMatrix();
// 				}
// 			}
// 		}
// 	}
// }

// void showTRotator(PImage img, int x, int y, float energy) {

// 	float enc = lerp(-1., 1., energy);
// 	float ang = radians(energyAngle(enc));

// 	int offset = int(kwidth * 0.5);
// 	for (int i = 0; i < kwidth; i++){
// 		for (int j= 0; j < kwidth; j++){
			
// 			int xloc = x+i-offset;
// 			int yloc = y+j-offset;
// 			int loc = xloc + img.pixelWidth*yloc;
			
// 			loc = constrain(loc,0,img.pixels.length-1);
			
// 			color cpx = img.pixels[loc];
			
// 			float rpx = cpx >> 16 & 0xFF;
// 			float gpx = cpx >> 8 & 0xFF;
// 			float bpx = cpx & 0xFF;
			
// 			strokeWeight(1);
// 			stroke(energyDegree(energy));
			
// 			if(xloc == x && yloc == y){
// 				continue;
// 			} else{
// 				if(dispersed){
// 					pushMatrix();
// 					translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));
// 					line(
// 						(x + .5) * modfac,
// 						(y + .5) * modfac,
// 						(xloc + (.5 * cos(ang))) * modfac,
// 						(yloc + (.5 * sin(ang))) * modfac
// 						);
// 					popMatrix();
// 					} else {
// 						pushMatrix();
// 						translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
// 						line(
// 							(x + .5),
// 							(y + .5),
// 							(xloc + (.5 * cos(ang))),
// 							(yloc + (.5 * sin(ang)))
// 							);
// 						popMatrix();
// 					}
// 				}
// 			}
// 		}
// }

// void showTRotator2(PImage img, int x, int y, float energy) {
// 	float enc = lerp(-1., 1., energy);
// 	float ang = radians(energyAngle(enc));

// 	int offset = int(kwidth * 0.5);
// 	for (int i = 0; i < kwidth; i++){
// 		for (int j= 0; j < kwidth; j++){
			
// 			int xloc = x+i-offset;
// 			int yloc = y+j-offset;
// 			int loc = xloc + img.pixelWidth*yloc;
			
// 			loc = constrain(loc,0,img.pixels.length-1);
			
// 			color cpx = img.pixels[loc];
			
// 			float rpx = cpx >> 16 & 0xFF;
// 			float gpx = cpx >> 8 & 0xFF;
// 			float bpx = cpx & 0xFF;
			
// 			strokeWeight(1);
// 			stroke(energyDegree(energy));
			
// 			if(xloc == x && yloc == y){
// 				continue;
// 			} else{
// 				if(dispersed){
// 					pushMatrix();
// 					translate((width * 0.5)-(modfac*(dximg.pixelWidth * 0.5)),(height * 0.5)-(modfac*(dximg.pixelHeight * 0.5)));
// 					PVector midpoint = new PVector(lerp(float(x), float(xloc), .5), lerp(float(y), float(yloc), .5));
// 					PVector p1 = new PVector(float(x), float(y));
// 					PVector p2 = new PVector(float(xloc), float(yloc));
// 					float l = PVector.dist(p1,p2);
// 					pushMatrix();
// 					translate((midpoint.x*modfac), (midpoint.y*modfac));
// 					rotate(ang);
// 					// int mfd = 4;
// 					line(
// 						(-l * 0.5) * dmfd,
// 						(-l * 0.5) * dmfd,
// 						( l * 0.5) * dmfd,
// 						( l * 0.5) * dmfd
// 					);
						
// 					popMatrix();
// 					popMatrix();
// 					} else {
// 						pushMatrix();
// 						translate((width * 0.5)-(simg.pixelWidth * 0.5),(height * 0.5)-(simg.pixelHeight * 0.5));
// 						rotate(ang);
// 						line(
// 							(x + .5),
// 							(y + .5),
// 							(xloc + (.5)),
// 							(yloc + (.5))
// 							);
// 						popMatrix();
// 					}
// 				}
// 			}
// 		}
// }