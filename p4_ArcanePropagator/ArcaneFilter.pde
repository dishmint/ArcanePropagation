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
					color cpx = img.pixels[x+y*img.width];
        
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
        			    		continue;
        			            } else {
        			            rpx += xmsn;
        			            gpx += xmsn;
        			            bpx += xmsn;
        			        	}
        			    	}
        				}
        				img.pixels[sloc] = color(rpx,gpx,bpx);
					};
 	
    /* convolve */
	ArcaneProcess convolve = (x, y, img, xmg) -> {
					int sloc = x+y*img.width;
					sloc = constrain(sloc,0,img.pixels.length-1);
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
							
							float xmsn = (xmg[loc][i][j] / transmissionfactor);
							
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
					img.pixels[sloc] = color(rtotal/9.0, gtotal/9.0, btotal/9.0);
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
				arcfilter.filter(i,j,img,ximg);
            }
        }
        img.updatePixels();
    }
}