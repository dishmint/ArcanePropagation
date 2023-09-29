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
				
				nk[i][j] = map(d, 0.0, center, -1.0, 0.00);
				
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
	float[] reactdiffuse(float a, float b, float la, float lb){
		float[] result = new float[2];
		/* 
			a' = a+(d_a * l_a^2 - ab^2 + (f * (1-a)^2))
			b' = b+(d_b * l_b^2 + ab^2 - ((k+f) * b))

			https://editor.p5js.org/codingtrain/sketches/govdEW5aE
		*/
		a += (dA * la) - (a * b * b) + (fr * (1 - a));
		b += (dB * lb) + (a * b * b) - ((kr + fr) * b);
		result[0] = a; 
		result[1] = b; 
		return result;
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

					/* ------------------------- reaction diffusion one ------------------------- */
					float[] sr = reactdiffuse(srpx ,  sgpx, rtotal, gtotal); /* default */
					float[] sg = reactdiffuse(sr[1],  sbpx, gtotal, btotal); /* default */
					float[] sb = reactdiffuse(sg[1], sr[0], btotal, rtotal); /* default */

					// float[] sr = reactdiffuse(srpx,  sgpx, rtotal, gtotal);
					// float[] sg = reactdiffuse(sgpx,  sbpx, gtotal, btotal);
					// float[] sb = reactdiffuse(sbpx,  srpx, btotal, rtotal);

					/* take the latest diffused channel value to be the new channel color */
					float newr = sb[1];
					float newg = sg[0];
					float newb = sb[0];
					
					/* ------------------------- reaction diffusion two ------------------------- */
				
					// float[] sr1 = reactdiffuse(srpx ,  sgpx, rtotal, gtotal);
					// float[] sr2 = reactdiffuse(sr1[0] ,  sbpx, rtotal, btotal);


					// float[] sg1 = reactdiffuse(sr1[1],  sr2[1], gtotal, btotal);
					// float[] sg2 = reactdiffuse(sg1[0],  sr2[0], gtotal, rtotal);


					// float[] sb1 = reactdiffuse(sg1[1], sg2[1], btotal, rtotal);
					// float[] sb2 = reactdiffuse(sb1[0], sg2[0], btotal, gtotal);


					// float newr = (sr1[0] + sr2[0] + sg2[1] + sb1[1]) * 0.5;
					// float newg = (sr1[1] + sg1[0] + sg2[0] + sb2[1]) * 0.5;
					// float newb = (sr2[1] + sg1[1] + sb1[0] + sb2[0]) * 0.5;
					
					img.pixels[sloc] = color(newr, newg, newb);
				};

	ArcaneProcess rdft = (x, y, img, xmg) -> {
					// CURRENT PIXEL POSITION
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);
					color spx = img.pixels[sloc];
							
					float srpx = spx >> 16 & 0xFF;
					float sgpx = spx >> 8 & 0xFF;
					float sbpx = spx & 0xFF;
					
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

					/* ------------------------- reaction diffusion one ------------------------- */
					float[] sr = reactdiffuse(srpx ,  sgpx, rtotal, gtotal); /* default */
					float[] sg = reactdiffuse(sr[1],  sbpx, gtotal, btotal); /* default */
					float[] sb = reactdiffuse(sg[1], sr[0], btotal, rtotal); /* default */

					// float[] sr = reactdiffuse(srpx,  sgpx, rtotal, gtotal);
					// float[] sg = reactdiffuse(sgpx,  sbpx, gtotal, btotal);
					// float[] sb = reactdiffuse(sbpx,  srpx, btotal, rtotal);

					/* take the latest diffused channel value to be the new channel color */
					float newr = sb[1];
					float newg = sg[0];
					float newb = sb[0];
					
					img.pixels[sloc] = color(newr, newg, newb);
				};
 	
    /* reaction-diffusion with xmg */
	ArcaneProcess rdfx = (x, y, img, xmg) -> {
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
							
							/* --------------------------- xmg <op> rdfkernel --------------------------- */
							// float xmsn = xmg[loc][i][j] + rdfkernel[i][j]; /* Makes a triangle w/ nw hypotenuse */
							
							/* ------------------------ (xmg <op> rdfkernel) * tf ----------------------- */
							float xmsn = ((xmg[loc][i][j]) + rdfkernel[i][j]) * transmissionfactor; /* Noise buckets */
							
							/* ------------------------ (xmg <op> tf) + rdfkernel ----------------------- */
							// float xmsn = ((xmg[loc][i][j]) * transmissionfactor) + rdfkernel[i][j]; /* Makes a triangle w/ nw hypotenuse */
							
							color cpx = img.pixels[loc];
							
							float rpx = cpx >> 16 & 0xFF;
							float gpx = cpx >> 8 & 0xFF;
							float bpx = cpx & 0xFF;

							/* TRY: different ops between _px and xmsn */
							/* ------------------------------- _px * xmsn ------------------------------- */
							rtotal += (rpx * xmsn);
							gtotal += (gpx * xmsn);
							btotal += (bpx * xmsn);

							/* ------------------------------- _px - xmsn ------------------------------- */
							// rtotal += (rpx - xmsn);
							// gtotal += (gpx - xmsn);
							// btotal += (bpx - xmsn);

							/* ------------------------------- _px / xmsn ------------------------------- */
							// rtotal += (rpx / xmsn);
							// gtotal += (gpx / xmsn);
							// btotal += (bpx / xmsn);
						}
					}

					float[] sr = reactdiffuse(srpx ,  sgpx, rtotal, gtotal);
					float[] sg = reactdiffuse(sr[1],  sbpx, gtotal, btotal);
					float[] sb = reactdiffuse(sg[1], sr[0], btotal, rtotal);

					/* take the latest diffused channel value to be the new channel color */
					float newr = sb[1];
					float newg = sg[0];
					float newb = sb[0];

					img.pixels[sloc] = color(newr, newg, newb);
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
        			        loc = constrain(loc,0,img.pixels.length-1);
        			        float xmsn = (xmg[loc][k][l] * transmissionfactor);

							color npx = img.pixels[loc];

							float nrpx = npx >> 16 & 0xFF;
							float ngpx = npx >> 8 & 0xFF;
							float nbpx = npx & 0xFF;

							if(nrpx + ngpx + nbpx > rpx + gpx + bpx){
								rpx = nrpx*xmsn;
								gpx = ngpx*xmsn;
								bpx = nbpx*xmsn;
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
				fr = 0.055;
				kr = 0.062;
		    	break;
		    case "rdft":
		    	arcfilter = rdft;
				rdfkernel = createrdfkernel();
				dA = 1.00;
				dB = 0.50;
				fr = 0.055;
				kr = 0.062;
		    	break;
		    case "rdfr":
		    	arcfilter = rdf;
				rdfkernel = createrdfkernel();
				dA = random(1.00);
				dB = random(1.00);
				fr = random(1.00);
				kr = random(1.00);
		    	break;
		    case "rdfm":
		    	arcfilter = rdf;
				rdfkernel = createrdfkernel();
				dA = random(-1.00, 1.00);
				dB = random(-1.00, 1.00);
				fr = random(-1.00, 1.00);
				kr = random(-1.00, 1.00);
		    	break;
		    case "rdfx":
		    	arcfilter = rdfx;
				rdfkernel = createrdfkernel(-1.0, .50);
				dA = 1.00;
				dB = 0.50;
				fr = 0.055;
				kr = 0.062;
		    	break;
		    case "arcblur":
				arcfilter = arcblur;
		    	break;
			case "xdilate":
				arcfilter = xdilate;
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
