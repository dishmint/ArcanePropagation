/* 
    Making use of this article to implement functional interfaces
    https://dzone.com/articles/functional-programming-in-java-8-part-1-functions-as-objects
*/

import java.util.function.*;
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

    /* transmit */
	ArcaneProcess transmit = (x, y, img, xmg) -> {
					int sloc = x+y*img.width;
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
        			        int loc = xloc + img.width*yloc;
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
        				img.pixels[x+y*img.width] = color(rpx,gpx,bpx);
					};

    /* transmitMBL */
	ArcaneProcess transmitMBL = (x, y, img, xmg) -> {
					int sloc = x+y*img.width;
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
        			        int loc = xloc + img.width*yloc;
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
					int sloc = x+y*img.width;
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
							int loc = xloc + img.width*yloc;
							loc = constrain(loc,0,img.pixels.length-1);
							
							float xmsn = (xmg[loc][i][j] / transmissionfactor);
							
							color cpx = img.pixels[loc];
							
							float rpx = cpx >> 16 & 0xFF;
							float gpx = cpx >> 8 & 0xFF;
							float bpx = cpx & 0xFF;
							
							// if(xloc == x && yloc == y){
							// 	rtotal -= (rpx * xmsn);
							// 	gtotal -= (gpx * xmsn);
							// 	btotal -= (bpx * xmsn);
							// } else {
							// 	rtotal += (rpx * xmsn);
							// 	gtotal += (gpx * xmsn);
							// 	btotal += (bpx * xmsn);
							// }
							
							if(xloc == x && yloc == y){
								rtotal -= (rpx * xmsn) * j;
								gtotal -= (gpx * xmsn) * j;
								btotal -= (bpx * xmsn) * j;
							} else {
								rtotal += (rpx * xmsn) * j;
								gtotal += (gpx * xmsn) * j;
								btotal += (bpx * xmsn) * j;
							}
						}
					}
					img.pixels[sloc] = color(rtotal, gtotal, btotal);
				};
 	
    /* test */
	ArcaneProcess test = (x, y, img, xmg) -> {
					// CURRENT PIXEL POSITION
					int sloc = x+y*img.width;
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
							int loc = xloc + img.width*yloc;
							loc = constrain(loc,0,img.pixels.length-1);
							
							float xmsn = (xmg[loc][i][j] / transmissionfactor);
							
							color cpx = img.pixels[loc];
							
							float rpx = cpx >> 16 & 0xFF;
							float gpx = cpx >> 8 & 0xFF;
							float bpx = cpx & 0xFF;

							// float sval = ((rpx+gpx+bpx) * xmsn)/3.0;
							// float sval = ((rpx+gpx+bpx)/3.0 * xmsn);
							
							// if(xloc == x && yloc == y){
							// 	rtotal -= (sval);
							// 	gtotal -= (sval);
							// 	btotal -= (sval);
							// } else {
							// 	rtotal += (sval);
							// 	gtotal += (sval);
							// 	btotal += (sval);
							// }
							
							// if(xloc == x && yloc == y){
							// 	rtotal -= (rpx/255.0);
							// 	gtotal -= (gpx/255.0);
							// 	btotal -= (bpx/255.0);
							// } else {
							// 	rtotal += (rpx/255.0);
							// 	gtotal += (gpx/255.0);
							// 	btotal += (bpx/255.0);
							// }
							
							// if(xloc == x && yloc == y){
							// 	rtotal -= ((rpx/255.0) * xmsn);
							// 	gtotal -= ((gpx/255.0) * xmsn);
							// 	btotal -= ((bpx/255.0) * xmsn);
							// } else {
							// 	rtotal += ((rpx/255.0) * xmsn);
							// 	gtotal += ((gpx/255.0) * xmsn);
							// 	btotal += ((bpx/255.0) * xmsn);
							// }
							
							if(xloc == x && yloc == y){
								rtotal -= xmsn;
								gtotal -= xmsn;
								btotal -= xmsn;
							} else {
								rtotal += xmsn;
								gtotal += xmsn;
								btotal += xmsn;
							}
						}
					}
					img.pixels[sloc] = color(rtotal, gtotal, btotal);
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
		    case "test":
		    	arcfilter = test;
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
        for (int i = 0; i < img.width; i++){
            for (int j = 0; j < img.height; j++){
				img.loadPixels();
				
				arcfilter.filter(i,j,img,ximg);
				img.updatePixels();
            }
        }
        img.updatePixels();
    }
}