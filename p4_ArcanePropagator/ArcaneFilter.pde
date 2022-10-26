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
        			        float xmsn = (xmg[loc][k][l] / transmissionfactor);

        			        // if(xloc == x && yloc == y){
							// 		rpx -= xmsn;
							// 		gpx -= xmsn;
							// 		bpx -= xmsn;
        			        //     } else {
							// 		rpx += xmsn;
							// 		gpx += xmsn;
							// 		bpx += xmsn;
        			        // 	}

        			        if(xloc == x && yloc == y){
									rpx -= (xmsn * l);
									gpx -= (xmsn * l);
									bpx -= (xmsn * l);
        			            } else {
									rpx += (xmsn * l);
									gpx += (xmsn * l);
									bpx += (xmsn * l);
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
        			        float xmsn = (xmg[loc][k][l] / transmissionfactor);

        			        if(xloc == x && yloc == y){
									rpx -= (rpx * xmsn);
									gpx -= (gpx * xmsn);
									bpx -= (bpx * xmsn);
        			            } else {
									rpx += xmsn;
									gpx += xmsn;
									bpx += xmsn;
        			        	}

        			        // if(xloc == x && yloc == y){
							// 		rpx -= (rpx * xmsn) * l;
							// 		gpx -= (gpx * xmsn) * l;
							// 		bpx -= (bpx * xmsn) * l;
        			        //     } else {
							// 		rpx += (xmsn * l);
							// 		gpx += (xmsn * l);
							// 		bpx += (xmsn * l);
        			        // 	}

        			        // if(xloc == x && yloc == y){
							// 		rpx -= (rpx * xmsn) * (kernelwidth - l);
							// 		gpx -= (gpx * xmsn) * (kernelwidth - l);
							// 		bpx -= (bpx * xmsn) * (kernelwidth - l);
        			        //     } else {
							// 		rpx += (xmsn * (kernelwidth - l));
							// 		gpx += (xmsn * (kernelwidth - l));
							// 		bpx += (xmsn * (kernelwidth - l));
        			        // 	}
        			    	}
        				}
        				img.pixels[sloc] = color(rpx,gpx,bpx);
					};
 	
    /* convolve */
	ArcaneProcess convolve = (x, y, img, xmg) -> {
					int sloc = x+y*img.pixelWidth;
					sloc = constrain(sloc,0,img.pixels.length-1);
					/* 
						// Instead of starting from 0, I'm starting from the current pixel (line:105)
						float rtotal = 0.0;
						float gtotal = 0.0;
						float btotal = 0.0;
					*/

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
							
							float xmsn = (xmg[loc][i][j] / transmissionfactor);

							/* some xmsn variants */
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) * i;
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) * j;
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) - (i * j);
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) - (i + j);
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) * (i + j);
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) * ((i-offset) + (j-offset));
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) * (offset - i);
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) * (offset - j);
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) - ((i*j)/(kernelwidth*2.0));
							// float xmsn = (xmg[loc][i][j] / transmissionfactor) * ((abs(i-offset) * abs(j-offset))/kernelwidth);
							
							/* since I'm trying to affect the xmg, I could do these ^^ in loadxm. xmg values never change anyway (and maybe that's something I can add later) */
							
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
							
							// if(xloc == x && yloc == y){
							// 	rtotal -= (rpx * xmsn) * j;
							// 	gtotal -= (gpx * xmsn) * j;
							// 	btotal -= (bpx * xmsn) * j;
							// } else {
							// 	rtotal += (rpx * xmsn) * j;
							// 	gtotal += (gpx * xmsn) * j;
							// 	btotal += (bpx * xmsn) * j;
							// }
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

		// println(Arrays.deepToString(nk).replace("], ", "]\n"));
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

		// println(Arrays.deepToString(nk).replace("], ", "]\n"));
		return nk;
	}
	float[] reactdiffuse(float a, float b, float la, float lb){
		float[] result = new float[2];
		/* 
			a' = a+(d_a * l_a^2 - ab^2 + (f * (1-a)^2))
			b' = b+(d_b * l_b^2 + ab^2 - ((k+f) * b))

			https://editor.p5js.org/codingtrain/sketches/govdEW5aE
		*/
		a += (dA * la) - (a * pow(b,2.0)) + (fr * (1. - a));
		b += (dB * lb) + (a * pow(b,2.0)) - ((kr + fr) * b);
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

					float[] sr = reactdiffuse(srpx ,  sgpx, rtotal, gtotal);
					float[] sg = reactdiffuse(sr[1],  sbpx, gtotal, btotal);
					float[] sb = reactdiffuse(sg[1], sr[0], btotal, rtotal);

					// float[] sr = reactdiffuse(srpx,  sgpx, rtotal, gtotal);
					// float[] sg = reactdiffuse(sgpx,  sbpx, gtotal, btotal);
					// float[] sb = reactdiffuse(sbpx,  srpx, btotal, rtotal);

					/* take the latest diffused channel value to be the new channel color */
					float newr = sb[1];
					float newg = sg[0];
					float newb = sb[0];

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

					// float[] sr1 = reactdiffuse(srpx ,  sgpx, rtotal, gtotal);
					// float[] sr2 = reactdiffuse(srpx ,  sbpx, rtotal, btotal);


					// float[] sg1 = reactdiffuse(sgpx,  sbpx, gtotal, btotal);
					// float[] sg2 = reactdiffuse(sgpx,  srpx, gtotal, rtotal);


					// float[] sb1 = reactdiffuse(sbpx, srpx, btotal, rtotal);
					// float[] sb2 = reactdiffuse(sbpx, sgpx, btotal, gtotal);

					float[] sr1 = reactdiffuse(srpx ,  sgpx, rtotal, gtotal);
					float[] sr2 = reactdiffuse(sr1[0] ,  sbpx, rtotal, btotal);


					float[] sg1 = reactdiffuse(sr1[1],  sr2[1], gtotal, btotal);
					float[] sg2 = reactdiffuse(sg1[0],  sr2[0], gtotal, rtotal);


					float[] sb1 = reactdiffuse(sg1[1], sg2[1], btotal, rtotal);
					float[] sb2 = reactdiffuse(sb1[0], sg2[0], btotal, gtotal);


					float newr = (sr1[0] + sr2[0] + sg2[1] + sb1[1]) * 0.5;
					float newg = (sr1[1] + sg1[0] + sg2[0] + sb2[1]) * 0.5;
					float newb = (sr2[1] + sg1[1] + sb1[0] + sb2[0]) * 0.5;
					
					// float newr = sb1[1];
					// float newg = sb2[1];
					// float newb = sb2[0];

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
							
							// float xmsn = ((xmg[loc][i][j]) * rdfkernel[i][j]) / transmissionfactor;
							float xmsn = ((xmg[loc][i][j]) * rdfkernel[i][j]);
							// float xmsn = ((xmg[loc][i][j]) + rdfkernel[i][j]);
							
							color cpx = img.pixels[loc];
							
							float rpx = cpx >> 16 & 0xFF;
							float gpx = cpx >> 8 & 0xFF;
							float bpx = cpx & 0xFF;

							rtotal += (rpx * xmsn);
							gtotal += (gpx * xmsn);
							btotal += (bpx * xmsn);

							// rtotal += (rpx + xmsn);
							// gtotal += (gpx + xmsn);
							// btotal += (bpx + xmsn);

							// rtotal += (rpx - xmsn);
							// gtotal += (gpx - xmsn);
							// btotal += (bpx - xmsn);

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


    ArcaneFilter(String fmode, int kw, float xsmnfac){
		filtermode = fmode;
        kernelwidth = kw;
        modfactor = 1;
        downsample = 1;
        transmissionfactor = xsmnfac;

        switch(filtermode){
		    case "transmit":
		    	arcfilter = transmit;
		    	break;
		    case "convolve":
		    	arcfilter = convolve; /* Behavior of convolve is different here. Maybe I'm missing something */
		    	break;
		    case "transmitMBL":
		    	arcfilter = transmitMBL;
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
		    case "rdfx":
		    	arcfilter = rdfx;
				rdfkernel = createrdfkernel(-1.0, .50);
				dA = 1.00;
				dB = 0.50;
				fr = 0.055;
				kr = 0.062;
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

    void setFilterMode(String newfiltermode){
        filtermode = newfiltermode;
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
				// img.loadPixels(); /* not sure if these load/updates are necessary here */
				
				arcfilter.filter(i,j,img,ximg);
				// img.updatePixels();
            }
        }
        img.updatePixels();
    }
}
