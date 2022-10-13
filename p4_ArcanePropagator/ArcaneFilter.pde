/* 
    Making use of this article to implement functional interfaces
    https://dzone.com/articles/functional-programming-in-java-8-part-1-functions-as-objects
*/

// public static PImage arcprocess(Function<PImage, PImage> function, PImage simg, float[][][] xmg) {
//     return function.apply(simg, xmg);
//     }

class ArcaneFilter {
    BiFunction<float, float, float> arcfilter;
    int pfilter;
    int kernelwidth;
    // int modfactor;
    // int downsample;
    float transmissionfactor;


    /* transmit */
    float transmit(float c, float transmission)
        {
            return c + transmission;
        }
    /* transmitMBL */
    /* convolve */


    ArcaneFilter(String filtermode, float kw, float xsmnfac){
        kernelwidth = kw;
        // modfactor = 1;
        // downsample = 1;
        transmissionfactor = xsmnfac;

        switch(filtermode){
		    case "transmit":
		    	arcfilter = ArcaneFilter::transmit;
		    	break;
		    case "convolve":
		    	arcfilter = ArcaneFilter::convolve;
		    	break;
		    case "transmitMBL":
		    	arcfilter = ArcaneFilter::transmitMBL;
		    	break;
		    case "blur":
		    	break;
		    case "dilate":
		    	break;
		    default:
		    	arcfilter = ArcaneFilter::transmit;
		    	break;
	    }
    }

    void setFilterMode(String newfiltermode){
        filtermode = newfiltermode;
    }

    void setFilter(BiFunction<float,float,float> newfilter){
        arcfilter = newfilter;
    }

    void setModFactor(int nmf){
        modfactor = nmf;
    }
    
    void setSampleStep(int nds){
        downsample = nds;
    }

    void kernelmap(ArcanePropagator arcprop){
        PImage arcsource = arcprop.source;
        switch(filtermode){
            case "blur":
                arcsource.filter(BLUR);
                break;
            case "dilate":
                arcsource.filter(DILATE);
                break;
            case "erode":
                arcsource.filter(ERODE);
                break;
            case "invert":
                arcsource.filter(INVERT);
                break;
            default:
                customfilter(arcsource, arcprop.ximage);
                break;
        }

        
    }

    void customfilter(PImage img, float[][][] ximg){
        img.loadPixels();
        for (int i = 0; i < img.width; i++){
            for (int j = 0; j < img.height; j++){
                color cpx = img.pixels[i+j*img.width];
        
                float rpx = cpx >> 16 & 0xFF;
                float gpx = cpx >> 8 & 0xFF;
                float bpx = cpx & 0xFF;
        
                int offset = kernelwidth / 2;
                for (int k = 0; k < kernelwidth; k++){
                    for (int l= 0; l < kernelwidth; l++){
                        int xloc = i+k-offset;
                        int yloc = j+l-offset;
                        int loc = xloc + img.width*yloc;
                        loc = constrain(loc,0,img.pixels.length-1);
                        float xmsn = (ximg[loc][k][l] / transmissionfactor);

                        if(xloc == i && yloc == j){
                            rpx = arcfilter(rpx, -xmsn)
                            gpx = arcfilter(gpx, -xmsn)
                            bpx = arcfilter(bpx, -xmsn)
                            } else {
                            rpx = arcfilter(rpx,  xmsn)
                            gpx = arcfilter(gpx,  xmsn)
                            bpx = arcfilter(bpx,  xmsn)
                        }
                    }
                }
                img.pixels[i+j*img.width] = color(rpx,gpx,bpx);
            }
        }
        img.updatePixels();
    }


}

/* 

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
		float gs = computeGS(spx);
		
		float xmsn = map(gs, 0., 1., -.5, .5) / xsmnfactor;
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
				} else {
					// float xmsn = ximg[sloc][i][j] / xsmnfactor;
					rpx += xmsn;
					gpx += xmsn;
					bpx += xmsn;
				}
				img.pixels[loc] = color(rpx,gpx,bpx);
			}
		}
	}

 */