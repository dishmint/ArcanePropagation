/* 
    Making use of this article to implement functional interfaces
    https://dzone.com/articles/functional-programming-in-java-8-part-1-functions-as-objects
*/
import java.util.function.*;
import java.util.Arrays;
@FunctionalInterface
public interface ArcaneProcess {
	void filter(int x, int y, PImage img, float[][][] xmg);
    }

class ArcaneFilter {
	String filtermode;
    int pfilter;
    int kernelwidth;
    int modfactor;
    int downsample;
    float transmissionfactor;
    ArcaneProcess arcfilter;
	/* reaction diffusion params */
	float[][] rdfkernel;
	float dA;
	float dB;
	float dC;
	float fr;
	float kr;

    /* transmit */
	ArcaneProcess transmit = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);

					color cpx = img.pixels[sloc];
        
        			float rpx = cpx >> 16 & 0xFF;
        			float gpx = cpx >> 8 & 0xFF;
        			float bpx = cpx & 0xFF;

        			int offset = kernelwidth / 2;
        			for (int k = 0; k < kernelwidth; k++){
        			    for (int l= 0; l < kernelwidth; l++){
        			        int xloc = x+k-offset;
        			        int yloc = y+l-offset;
        			        int loc = xloc + img.pixelWidth*yloc;
        			        loc = constrain(loc,0,img.pixels.length-1);
        			        float xmsn = (xmg[loc][k][l] * transmissionfactor);

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
					};

    /* transmitMBL */
	ArcaneProcess transmitMBL = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);

					color cpx = img.pixels[sloc];
        
        			float rpx = cpx >> 16 & 0xFF;
        			float gpx = cpx >> 8 & 0xFF;
        			float bpx = cpx & 0xFF;

        			int offset = kernelwidth / 2;
        			for (int k = 0; k < kernelwidth; k++){
        			    for (int l= 0; l < kernelwidth; l++){
        			        int xloc = x+k-offset;
        			        int yloc = y+l-offset;
        			        int loc = xloc + img.pixelWidth*yloc;
        			        loc = constrain(loc,0,img.pixels.length-1);
        			        float xmsn = (xmg[loc][k][l] * transmissionfactor);
							/* 
								The reason these fade so easily is that the same amount is subtracted from the current pixel and added to the neighboring pixel.
							 */
        			        if(xloc == x && yloc == y){
									// rpx -= (rpx * xmsn);
									// gpx -= (gpx * xmsn);
									// bpx -= (bpx * xmsn);
									rpx -= (rpx * (xmsn * ((k + l) * 0.5)));
									gpx -= (gpx * (xmsn * ((k + l) * 0.5)));
									bpx -= (bpx * (xmsn * ((k + l) * 0.5)));
        			            } else {
									rpx += xmsn;
									gpx += xmsn;
									bpx += xmsn;
									// rpx += (rpx * xmsn);
									// gpx += (gpx * xmsn);
									// bpx += (bpx * xmsn);
        			        	}
        			    	}
        				}
        				img.pixels[sloc] = color(rpx,gpx,bpx);
					};

    /* amble */
	ArcaneProcess amble = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);

					color cpx = img.pixels[sloc];
        
        			float rpx = cpx >> 16 & 0xFF;
        			float gpx = cpx >> 8 & 0xFF;
        			float bpx = cpx & 0xFF;

					float avg = map((rpx+gpx+bpx)/3.0, 0, 255, 0, 1);

        			int offset = kernelwidth / 2;
					if(avg < 0.5){
						for (int k = 0; k < kernelwidth; k++){
							for (int l= 0; l < kernelwidth; l++){
								if(avg < ((k * l) / Math.pow(kernelwidth, 2.))){
									int xloc = x+k-offset;
									int yloc = y+l-offset;
									int loc = xloc + img.pixelWidth*yloc;
									loc = constrain(loc,0,img.pixels.length-1);
									float xmsn = (xmg[loc][k][l] * transmissionfactor);

									color icpx = img.pixels[loc];

									float irpx = icpx >> 16 & 0xFF;
									float igpx = icpx >> 8 & 0xFF;
									float ibpx = icpx & 0xFF;

									if(xloc == x && yloc == y){
											rpx -= (rpx * xmsn) * l;
											gpx -= (gpx * xmsn) * l;
											bpx -= (bpx * xmsn) * l;
										} else {
											rpx += (irpx * xmsn) * l;
											gpx += (igpx * xmsn) * l;
											bpx += (ibpx * xmsn) * l;
										}
									}
								}
							}
							img.pixels[sloc] = color(rpx,gpx,bpx);
						} else {
							img.pixels[sloc] = color(255,255,255);
						}
					};
 	
    /* convolve */
	ArcaneProcess convolve = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);
					
					color spx = img.pixels[sloc];
					float rspx = spx >> 16 & 0xFF;
					float gspx = spx >> 8 & 0xFF;
					float bspx = spx & 0xFF;

					float rtotal = rspx;
					float gtotal = gspx;
					float btotal = bspx;

					int offset = kernelwidth / 2;
					for (int i = 0; i < kernelwidth; i++){
						for (int j= 0; j < kernelwidth; j++){
							
							int xloc = x+i-offset;
							int yloc = y+j-offset;
							int loc = xloc + img.pixelWidth*yloc;
							loc = constrain(loc,0,img.pixels.length-1);
							
							float xmsn = (xmg[loc][i][j] * transmissionfactor);

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
					img.pixels[sloc] = color(rtotal, gtotal, btotal);
				};
 	
    /* reaction-diffusion */
	float[][] createrdfkernel(){
		float nk[][] = new float[kernelwidth][kernelwidth];
		float center = kernelwidth == 1 ? (kernelwidth / 2.0) : (kernelwidth / 2);
		int offset = int(center);
		for (int i = 0; i < kernelwidth; i++){
			for (int j= 0; j < kernelwidth; j++){
				/* map distance between [x,y] and [offset,offset] to [0..-1.0] */
				// nk[x][y] = map(dist(offset,offset,x,y), -offset, offset, -1.0, 0.0);
				// nk[x][y] = (dist(offset,offset,x,y)/offset);
				// nk[i][j] = map(dist(offset,offset,x,y), 0.0, offset, -1.0, 0.0);
				// nk[x][y] = map(dist(offset,offset,i,j), 0.0, offset, -1.0, 0.0);
				
				float d = dist(center,center,float(i),float(j));
				
				nk[i][j] = map(d, 0.0f, center, -1.0, 0.0f);
				
			}
		}

		return nk;
	}
	float[][] createrdfkernel(float min, float max){
		float nk[][] = new float[kernelwidth][kernelwidth];
		float center = kernelwidth == 1 ? (kernelwidth / 2.0) : (kernelwidth / 2);
		int offset = int(center);
		for (int i = 0; i < kernelwidth; i++){
			for (int j= 0; j < kernelwidth; j++){				
				float d = dist(center,center,float(i),float(j));
				nk[i][j] = map(d, 0.0, center, min, max);
				
			}
		}

		return nk;
	}

	/* TODO: move rdf code to a new class ArcaneReact */
	color reactdiffuse(float r, float g, float b, float lA, float lB, float lC){
		r += (dA * lA) - (r * g * b) + ( fr       * (1.0 - r)); /* 1.0 -r may need to be 2.0 - r */
		g += (dB * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -g may need to be 2.0 - g */
		b += (dC * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */

		return color(r,g,b);
	}

	color reactdiffuse2(float xg, float r, float g, float b, float lA, float lB, float lC){
		r += (xg * lA) - (r * g * b) + ( fr       * (1.0 - r)); /* 1.0 -r may need to be 2.0 - r */
		g += (xg * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -g may need to be 2.0 - g */
		b += (xg * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */

		return color(r,g,b);
	}

	color reactdiffuse3(float r, float g, float b, float lA, float lB, float lC){
		r += (r * lA) - (r * g * b) + ( fr       * (1.0 - r)); /* 1.0 -r may need to be 2.0 - r */
		g += (g * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -g may need to be 2.0 - g */
		b += (b * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */

		return color(r,g,b);
	}

	color reactdiffuse4(float r, float g, float b, float lA, float lB, float lC){
		r += (dA * lA) - (r * g * b) + ( fr       * (1.0 - r)); /* 1.0 -r may need to be 2.0 - r */
		g += (dB * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -g may need to be 2.0 - g */
		b += (dC * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */

		return color(r,g,b);
	}

	color reactdiffuse5(float r, float g, float b, float lA, float lB, float lC){
		/* might need separate r's,g's and b's */
		
		/* R */
		r += (dA * lA) - (r * g * b) + ( fr       * (1.0 - r)); /* 1.0 -r may need to be 2.0 - r */
		g += (dB * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -g may need to be 2.0 - g */
		b += (dC * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */
		/* G */
		g += (dA * lA) - (r * g * b) + ( fr       * (1.0 - g)); /* 1.0 -r may need to be 2.0 - r */
		r += (dB * lB) + (r * g * b) - ((kr + fr) *        r ); /* 1.0 -g may need to be 2.0 - g */
		/* B */
		b += (dA * lA) - (r * g * b) + ( fr       * (1.0 - b)); /* 1.0 -r may need to be 2.0 - r */

		return color(r,g,b);
	}

	color reactdiffuse6(float r, float g, float b, float lA, float lB, float lC){
		/* might need separate r's,g's and b's */
		
		/* R */
		r += (dA * lA) - (r * g * b) + ( fr       * (1.0 - r)); /* 1.0 -r may need to be 2.0 - r */
		g += (dB * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -g may need to be 2.0 - g */
		b += (dC * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */
		/* G */
		g += (dB * lB) - (r * g * b) + ( fr       * (1.0 - g)); /* 1.0 -r may need to be 2.0 - r */
		r += (dA * lA) + (r * g * b) - ((kr + fr) *        r ); /* 1.0 -g may need to be 2.0 - g */
		b += (dC * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */
		// b /=b;
		/* B */
		b += (dC * lC) - (r * g * b) + ( fr       * (1.0 - b)); /* 1.0 -r may need to be 2.0 - r */
		r += (dA * lA) + (r * g * b) - ((kr + fr) *        r ); /* 1.0 -g may need to be 2.0 - g */
		g += (dB * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -b may need to be 2.0 - b */

		// return color(r/3.0,g/3.0,b/3.0);
		return color(r,g,b);
	}

	color reactdiffuse7(float r, float g, float b, float lA, float lB, float lC){
		/* might need separate r's,g's and b's */
		float rnew = r;
		float gnew = g;
		float bnew = b;

		/* R */
		rnew += (dA * lA) - (r * g * b) + ( fr       * (1.0 - r)); /* 1.0 -r may need to be 2.0 - r */
		gnew += (dB * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -g may need to be 2.0 - g */
		bnew += (dC * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */
		/* G */
		gnew += (dB * lB) - (r * g * b) + ( fr       * (1.0 - g)); /* 1.0 -r may need to be 2.0 - r */
		rnew += (dA * lA) + (r * g * b) - ((kr + fr) *        r ); /* 1.0 -g may need to be 2.0 - g */
		bnew += (dC * lC) + (r * g * b) - ((kr + fr) *        b ); /* 1.0 -b may need to be 2.0 - b */
		// b /=b;
		/* B */
		bnew += (dC * lC) - (r * g * b) + ( fr       * (1.0 - b)); /* 1.0 -r may need to be 2.0 - r */
		rnew += (dA * lA) + (r * g * b) - ((kr + fr) *        r ); /* 1.0 -g may need to be 2.0 - g */
		gnew += (dB * lB) + (r * g * b) - ((kr + fr) *        g ); /* 1.0 -b may need to be 2.0 - b */

		// return color(r/3.0,g/3.0,b/3.0);
		return color(rnew,gnew,bnew);
	}

	ArcaneProcess rdf = (x, y, img, xmg) -> {
					// CURRENT PIXEL POSITION
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);
					color spx = img.pixels[sloc];
							
					float srpx = spx >> 16 & 0xFF;
					float sgpx = spx >> 8 & 0xFF;
					float sbpx = spx & 0xFF;

					float rtotal = 0;
					float gtotal = 0;
					float btotal = 0;

					// float rtotal = srpx;
					// float gtotal = sgpx;
					// float btotal = sbpx;

					int offset = kernelwidth / 2;
					for (int i = 0; i < kernelwidth; i++){
						for (int j= 0; j < kernelwidth; j++){
							
							int xloc = x+i-offset;
							int yloc = y+j-offset;
							int loc = xloc + img.pixelWidth*yloc;
							loc = constrain(loc,0,img.pixels.length-1);
							
							float xmsn = rdfkernel[i][j];
							
							color cpx = img.pixels[loc];
							
							float rpx = cpx >> 16 & 0xFF;
							float gpx = cpx >> 8 & 0xFF;
							float bpx = cpx & 0xFF;

							rtotal += (rpx * xmsn);
							gtotal += (gpx * xmsn);
							btotal += (bpx * xmsn);
						}
					}

					// rtotal *= 0.11111111;
					// gtotal *= 0.11111111;
					// btotal *= 0.11111111;

					color next = reactdiffuse(srpx, sgpx, sbpx, rtotal, gtotal, btotal);
					
					// color next = reactdiffuse2(xmg[sloc][1][1], srpx, sgpx, sbpx, rtotal, gtotal, btotal);
					// color next = reactdiffuse3(srpx, sgpx, sbpx, rtotal, gtotal, btotal);
					// color next = reactdiffuse4(srpx, sgpx, sbpx, rtotal, gtotal, btotal);
					// color next = reactdiffuse5(srpx, sgpx, sbpx, rtotal, gtotal, btotal);
					// color next = reactdiffuse6(srpx, sgpx, sbpx, rtotal, gtotal, btotal);
					// color next = reactdiffuse7(srpx, sgpx, sbpx, rtotal, gtotal, btotal);

					// float avg = (srpx+sgpx+sbpx / 3.0);
					// float avg = (srpx+sgpx+sbpx / 3.0) * xmg[sloc][1][1];
					// color next = reactdiffuse(avg, avg, avg, rtotal, gtotal, btotal);
					img.pixels[sloc] = next;
				};

	
	ArcaneProcess rdft = (x, y, img, xmg) -> {
					// CURRENT PIXEL POSITION
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);
					color spx = img.pixels[sloc];
							
					float srpx = spx >> 16 & 0xFF;
					float sgpx = spx >> 8 & 0xFF;
					float sbpx = spx & 0xFF;
					
					// float rtotal = 0;
					// float gtotal = 0;
					// float btotal = 0;
					
					float rtotal = srpx;
					float gtotal = sgpx;
					float btotal = sbpx;

					int offset = kernelwidth / 2;
					for (int i = 0; i < kernelwidth; i++){
						for (int j= 0; j < kernelwidth; j++){
							
							int xloc = x+i-offset;
							int yloc = y+j-offset;
							int loc = xloc + img.pixelWidth*yloc;
							loc = constrain(loc,0,img.pixels.length-1);
							
							float xmsn = rdfkernel[i][j] * transmissionfactor;
							
							color cpx = img.pixels[loc];
							
							float rpx = cpx >> 16 & 0xFF;
							float gpx = cpx >> 8 & 0xFF;
							float bpx = cpx & 0xFF;

							rtotal += (rpx * xmsn);
							gtotal += (gpx * xmsn);
							btotal += (bpx * xmsn);
						}
					}
					color next = reactdiffuse(srpx, sgpx, sbpx, rtotal, gtotal, btotal);
					img.pixels[sloc] = next;
				};
 	
    /* collatz */
	ArcaneProcess collatz = (x, y, img, xmg) -> {
					// CURRENT PIXEL POSITION
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);
					color spx = img.pixels[sloc];
					float rspx = spx >> 16 & 0xFF;
					float gspx = spx >> 8 & 0xFF;
					float bspx = spx & 0xFF;
					/*  
						& is more efficient than using mod
						https://stackoverflow.com/a/2229966
					*/
					rspx = (int(rspx) & 1) == 0 ? (rspx*0.5) : (3.0 * rspx) + 1.0;
					gspx = (int(gspx) & 1) == 0 ? (gspx*0.5) : (3.0 * gspx) + 1.0;
					bspx = (int(bspx) & 1) == 0 ? (bspx*0.5) : (3.0 * bspx) + 1.0;

					img.pixels[sloc] = color(rspx, gspx, bspx);
				};
 	
    /* arcblur */
	ArcaneProcess arcblur = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);

					color cpx = img.pixels[sloc];
        
        			// float rpx = cpx >> 16 & 0xFF;
        			// float gpx = cpx >> 8 & 0xFF;
        			// float bpx = cpx & 0xFF;
        
        			float rpx = 0;
        			float gpx = 0;
        			float bpx = 0;

        			int offset = kernelwidth / 2;
        			for (int k = 0; k < kernelwidth; k++){
        			    for (int l= 0; l < kernelwidth; l++){
        			        int xloc = x+k-offset;
        			        int yloc = y+l-offset;
        			        int loc = xloc + img.pixelWidth*yloc;
        			        loc = constrain(loc,0,img.pixels.length-1);
							color npx = img.pixels[loc];

							float nrpx = npx >> 16 & 0xFF;
							float ngpx = npx >> 8 & 0xFF;
							float nbpx = npx & 0xFF;

        			        rpx += nrpx;
							gpx += ngpx;
							bpx += nbpx;
        			    	}
        				}

					// rpx *= (1.0/(kernelwidth * kernelwidth));
					// gpx *= (1.0/(kernelwidth * kernelwidth));
					// bpx *= (1.0/(kernelwidth * kernelwidth));

					rpx *= transmissionfactor;
					gpx *= transmissionfactor;
					bpx *= transmissionfactor;
        			img.pixels[x+y*img.pixelWidth] = color(rpx,gpx,bpx);
					};
 	
    /* xdilate */
	ArcaneProcess xdilate = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);

					color cpx = img.pixels[sloc];
        
 					float rpx = cpx >> 16 & 0xFF;
        			float gpx = cpx >> 8 & 0xFF;
        			float bpx = cpx & 0xFF;

        			int offset = kernelwidth / 2;
        			for (int k = 0; k < kernelwidth; k++){
        			    for (int l= 0; l < kernelwidth; l++){
        			        int xloc = x+k-offset;
        			        int yloc = y+l-offset;
        			        int loc = xloc + img.pixelWidth*yloc;
							/* FIXME: sometimes there's an ArrayOutOfBoundsException when switching images — not sure why it's happening when the image is changed _after_ the filter is applied */
        			        loc = constrain(loc,0,img.pixels.length-1);
        			        float xmsn = (xmg[loc][k][l] * transmissionfactor);

							color npx = img.pixels[loc];

							float nrpx = npx >> 16 & 0xFF;
							float ngpx = npx >> 8 & 0xFF;
							float nbpx = npx & 0xFF;

							/* immediate settlement */
							if(nrpx + ngpx + nbpx > rpx + gpx + bpx){
								rpx = nrpx*xmsn;
								gpx = ngpx*xmsn;
								bpx = nbpx*xmsn;
								}
        			    	}
        				}
        				img.pixels[x+y*img.pixelWidth] = color(rpx,gpx,bpx);
					};
 	
    /* xsdilate */
	ArcaneProcess xsdilate = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);

					color cpx = img.pixels[sloc];
        
 					float rpx = cpx >> 16 & 0xFF;
        			float gpx = cpx >> 8 & 0xFF;
        			float bpx = cpx & 0xFF;

        			int offset = kernelwidth / 2;
        			for (int k = 0; k < kernelwidth; k++){
        			    for (int l= 0; l < kernelwidth; l++){
        			        int xloc = x+k-offset;
        			        int yloc = y+l-offset;
        			        int loc = xloc + img.pixelWidth*yloc;
							/* FIXME: sometimes there's an ArrayOutOfBoundsException when switching images — not sure why it's happening when the image is changed _after_ the filter is applied */
        			        loc = constrain(loc,0,img.pixels.length-1);
        			        float xmsn = (xmg[loc][k][l] * transmissionfactor);

							color npx = img.pixels[loc];

							float nrpx = npx >> 16 & 0xFF;
							float ngpx = npx >> 8 & 0xFF;
							float nbpx = npx & 0xFF;

							if(nrpx + ngpx + nbpx > rpx + gpx + bpx){
								rpx += nrpx*xmsn;
								gpx += ngpx*xmsn;
								bpx += nbpx*xmsn;
								}
        			    	}
        				}
        				img.pixels[x+y*img.pixelWidth] = color(rpx,gpx,bpx);
					};

	void setArcaneProcess(String fm){
		switch(fm){
		    case "transmit":
		    	arcfilter = transmit;
		    	break;
		    case "convolve":
		    	arcfilter = convolve; /* Behavior of convolve is different here. Maybe I'm missing something */
		    	break;
		    case "transmitMBL":
		    	arcfilter = transmitMBL;
		    	break;
		    case "amble":
		    	arcfilter = amble;
		    	break;
		    case "collatz":
		    	arcfilter = collatz;
		    	break;
		    case "rdf":
		    	arcfilter = rdf;
				rdfkernel = createrdfkernel();
				dA = 1.00;
				dB = 0.50;
				dC = 0.00 /* 1.00 */ /* -1.00 */;
				/* Default */
				/* https://karlsims.com/rd.html */
				/* TODO: add gui element for feedrate and killrate */
				fr = 0.055;
				kr = 0.062;

				// /* mitosis */
				// fr = 0.0367;
				// kr = 0.0649;

				// /* Coral Growth */
				// fr = 0.0545;
				// kr = 0.062;
		    	break;
		    case "rdft":
		    	arcfilter = rdft;
				rdfkernel = createrdfkernel();
				dA = 1.00;
				dB = 0.50;
				dC = 0.00 /* 1.00 */ /* -1.00 */;
				fr = 0.055;
				kr = 0.062;
		    	break;
		    case "arcblur":
				arcfilter = arcblur;
		    	break;
			case "xdilate":
				arcfilter = xdilate;
		    	break;
			case "xsdilate":
				arcfilter = xsdilate;
		    	break;
		    case "blur":
		    	break;
		    case "dilate":
		    	break;
		    default:
		    	arcfilter = transmit;
		    	break;
	    }
	}


    ArcaneFilter(String fmode, int kw, float xsmnfac){
		filtermode = fmode;
        kernelwidth = kw;
        modfactor = 1;
        downsample = 1;
        transmissionfactor = xsmnfac;

        setArcaneProcess(filtermode);
    }

    void setFilterMode(String newfiltermode){
        filtermode = newfiltermode;
		setArcaneProcess(filtermode);
    }

    void setFilter(ArcaneProcess newfilter){
        arcfilter = newfilter;
    }

    void setModFactor(int nmf){
        modfactor = nmf;
    }
    
    void setSampleStep(int nds){
        downsample = nds;
    }
    
    void setKernelWidth(int nkw){
        kernelwidth = nkw;
    }

    void kernelmap(ArcanePropagator arcprop){
        switch(filtermode){
            case "blur":
                arcprop.source.filter(BLUR);
                break;
            case "dilate":
                arcprop.source.filter(DILATE);
                break;
            case "erode":
                arcprop.source.filter(ERODE);
                break;
            case "invert":
                arcprop.source.filter(INVERT);
                break;
            default:
				customfilter(arcprop.source, arcprop.ximage);
                break;
        }
    }

    void customfilter(PImage img, float[][][] ximg){
        img.loadPixels();
        for (int i = 0; i < img.pixelWidth; i++){
            for (int j = 0; j < img.pixelHeight; j++){
				arcfilter.filter(i,j,img,ximg);
            }
        }
        img.updatePixels();
    }
}
