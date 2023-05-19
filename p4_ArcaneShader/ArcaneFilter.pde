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

	/* selector */
	int selector;

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
        			        float xmsn = (xmg[loc][k][l] * transmissionfactor);

        			        if(xloc == x && yloc == y){
									rpx -= (rpx * xmsn);
									gpx -= (gpx * xmsn);
									bpx -= (bpx * xmsn);
        			            } else {
									rpx += xmsn;
									gpx += xmsn;
									bpx += xmsn;
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

					float rtotal = rspx; /* 0.0f */
					float gtotal = gspx; /* 0.0f */
					float btotal = bspx; /* 0.0f */

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
					rspx = (int(rspx) & 1) == 0 ? (rspx*0.5f) : (3.0f * rspx) + 1.0f;
					gspx = (int(gspx) & 1) == 0 ? (gspx*0.5f) : (3.0f * gspx) + 1.0f;
					bspx = (int(bspx) & 1) == 0 ? (bspx*0.5f) : (3.0f * bspx) + 1.0f;

					img.pixels[sloc] = color(rspx, gspx, bspx);
				};

	ArcaneProcess weightedblur = (x, y, img, ximg) ->
	{
		int cloc = x+y*img.pixelWidth;
		color cpx = img.pixels[cloc];
		
		float rpx = cpx >> 16 & 0xFF;
		float gpx = cpx >> 8 & 0xFF;
		float bpx = cpx & 0xFF;
		
		int offset = kernelwidth / 2;
		for (int i = 0; i < kernelwidth; i++){
			for (int j= 0; j < kernelwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				color npx = img.pixels[loc];
				float xmsn = (ximg[loc][i][j] * transmissionfactor);

				float nrpx = npx >> 16 & 0xFF;
				float ngpx = npx >> 8 & 0xFF;
				float nbpx = npx & 0xFF;
				
				rpx += (nrpx * xmsn);
				gpx += (ngpx * xmsn);
				bpx += (nbpx * xmsn);
			}
		}

		img.pixels[cloc] = color(rpx,gpx,bpx);
	};

	ArcaneProcess smear = (x, y, img, ximg) ->
	{
		int cloc = x+y*img.pixelWidth;
		cloc = constrain(cloc,0,img.pixels.length-1);

		float rpx = 0.0;
		float gpx = 0.0;
		float bpx = 0.0;
		
		
		int offset = kernelwidth / 2;
		for (int i = 0; i < kernelwidth; i++){
			for (int j= 0; j < kernelwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] * transmissionfactor);
				
				color cpx = img.pixels[loc];
				rpx = cpx >> 16 & 0xFF;
				gpx = cpx >> 8 & 0xFF;
				bpx = cpx & 0xFF;

				switch(selector){
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
		img.pixels[cloc] =  color(rpx, gpx, bpx);
	};

	ArcaneProcess smearTotal = (x, y, img, ximg) ->
	{
		int cloc = x+y*img.pixelWidth;
		cloc = constrain(cloc,0,img.pixels.length-1);

		float rtotal = 0.0;
		float gtotal = 0.0;
		float btotal = 0.0;
		
		
		int offset = kernelwidth / 2;
		for (int i = 0; i < kernelwidth; i++){
			for (int j= 0; j < kernelwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.pixelWidth*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] * transmissionfactor);
				
				color cpx = img.pixels[loc];
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;

				switch(selector){
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
		img.pixels[cloc] = color(rtotal, gtotal, btotal);
	};

	float chladnifunction(int x, int y, float n, float m){
		float fx = float(x);
		float fy = float(y);
		float fn = n / 255.0;
		float c1 = sin(fn * PI * fx) * sin(m * PI * fy);
		float c2 = sin(m * PI * fx) * sin(fn * PI * fy);
		return c1 - c2;
	}

	float chladnifunction(int x, int y){
		return (sin(10.0 * PI * x) * sin( 5.0 * PI * y)) - (sin( 5.0 * PI * x) * sin(10.0 * PI * y));
	}

	// https://processing.org/examples/convolution.html
	// Adjusted slightly for the purposes of this sketch
	// chladnitize is also quite slow. I think using a shader might make more sense.
	ArcaneProcess chladni = (x, y, img, ximg) ->
	{
		int cloc = x+y*img.pixelWidth;
		cloc = constrain(cloc,0,img.pixels.length-1);

		float rtotal = 0.0;
		float gtotal = 0.0;
		float btotal = 0.0;

		int offset = kernelwidth / 2;
		for (int i = 0; i < kernelwidth; i++){
			for (int j= 0; j < kernelwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				
				float xmsn = (ximg[loc][i][j] * transmissionfactor);
				
				color cpx = img.pixels[loc];
				
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;

				rtotal += chladnifunction(xloc, yloc, rpx, xmsn);
				gtotal += chladnifunction(xloc, yloc, gpx, xmsn);
				btotal += chladnifunction(xloc, yloc, bpx, xmsn);

				// rtotal += ((rpx * xmsn) + chladnifunction(xloc, yloc));
				// gtotal += ((gpx * xmsn) + chladnifunction(xloc, yloc));
				// btotal += ((bpx * xmsn) + chladnifunction(xloc, yloc));

				// rtotal += ((rpx * xmsn) + chladnifunction(xloc, yloc));
				// gtotal += ((gpx * xmsn) + chladnifunction(xloc, yloc));
				// btotal += ((bpx * xmsn) + chladnifunction(xloc, yloc));

				
				// if(xloc == x && yloc == y){
				// 	rtotal -= ((rpx * xmsn) + chladnifunction(xloc, yloc));
				// 	gtotal -= ((gpx * xmsn) + chladnifunction(xloc, yloc));
				// 	btotal -= ((bpx * xmsn) + chladnifunction(xloc, yloc));
				// } else {
				// 	rtotal += ((rpx * xmsn) + chladnifunction(xloc, yloc));
				// 	gtotal += ((gpx * xmsn) + chladnifunction(xloc, yloc));
				// 	btotal += ((bpx * xmsn) + chladnifunction(xloc, yloc));
				// }
				
			}
		}
		
		img.pixels[cloc] = color(rtotal, gtotal, btotal);
	};

	ArcaneProcess gol = (x, y, img, ximg) ->
	{
		final int cloc = constrain(x+y*img.width, 0, ximg.length - 1);
		final float xmn = ximg[cloc][1][1];
		
		final color cpx = img.pixels[cloc];
		
		float rpx = cpx >> 16 & 0xFF;
		float gpx = cpx >> 8 & 0xFF;
		float bpx = cpx & 0xFF;
		
		int count = 0;

		final int offset = kernelwidth / 2;
		for (int i = 0; i < kernelwidth; i++){
			for (int j= 0; j < kernelwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
				loc = constrain(loc,0,img.pixels.length-1);

				color ipx = img.pixels[loc];
		
				float irpx = ipx >> 16 & 0xFF;
				float igpx = ipx >> 8 & 0xFF;
				float ibpx = ipx & 0xFF;

				if(xloc != x && yloc != y){
					float avg = ((irpx + igpx + ibpx) * 0.33f);
					count += (avg > (255.0f * 0.50f)) ? 1 : 0;
				}
			}
		}
		float countd = 1.0f / (count + 1.0f);
		if((count < 2) || (count > 3)){
			// img.pixels[x+y*img.width] = color(rpx * .5, gpx * .5, bpx * .5);	
			// img.pixels[x+y*img.width] = color(0,0,0);
			/* 
			rpx -= xmn;
			gpx -= xmn;
			bpx -= xmn;
			 */
			rpx -= (xmn * countd);
			gpx -= (xmn * countd);
			bpx -= (xmn * countd);
			// ^^ could also add to those neighboring pixels
			img.pixels[cloc] = color(rpx, gpx, bpx);
		} 
		else if (count == 2 || count == 3){
			img.pixels[cloc] = color(rpx,gpx,bpx);
		} else {
			img.pixels[cloc] = color(255,255,255);
		}
	};

    ArcaneFilter(String fmode, int kw, float xsmnfac){
		filtermode = fmode;
        kernelwidth = kw;
        modfactor = 1;
        downsample = 1;
        transmissionfactor = xsmnfac;

		setFilterMode(filtermode);
    }

    void setFilterMode(String newfiltermode){
        filtermode = newfiltermode;

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
		    case "amble":
		    	arcfilter = amble;
		    	break;
		    case "collatz":
		    	arcfilter = collatz;
		    	break;
		    case "weightedblur":
		    	arcfilter = weightedblur;
		    	break;
		    case "chladni":
		    	arcfilter = chladni;
		    	break;
		    case "gol":
		    	arcfilter = gol;
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
		    case "smear":
		    	arcfilter = smear;
				selector = 1;
		    	break;
		    case "smearTotal":
		    	arcfilter = smearTotal;
				selector = 1;
		    	break;
		    case "blur":
		    	break;
		    case "dilate":
		    	break;
		    case "still":
		    	break;
		    default:
		    	arcfilter = transmit;
		    	break;
	    }
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

    void kernelmap(PImage arcimg, float[][][] ximg){
        switch(filtermode){
            case "blur":
                arcimg.filter(BLUR);
                break;
            case "dilate":
                arcimg.filter(DILATE);
                break;
            case "erode":
                arcimg.filter(ERODE);
                break;
            case "invert":
                arcimg.filter(INVERT);
                break;
            case "still":
                break;
            default:
				customfilter(arcimg, ximg);
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
