import java.util.function.*;
import java.util.Arrays;
@FunctionalInterface
public interface ArcaneImager {
	PImage generator();
    }

class ArcaneGenerator  {
    // PImage arcimg;
	int lod;
	float falloff;

	PImage mazeSource;
	ArcaneImager arcgen;
	int arcwidth;
	int archeight;

	PImage resize(PImage img, int mw, int mh){
		// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
		float sw = (float)img.pixelWidth;
		float sh = (float)img.pixelHeight;
		float scale = min(mw/sw, mh/sh);

		int nw = Math.round(sw*scale);
		int nh = Math.round(sh*scale);
		img.resize(nw, nh);
		return img; /* might not need to return this if img.resize is changing the original image */
	}


	ArcaneImager randomImage = () -> {
		PImage rimg = createImage(arcwidth, archeight, ARGB);
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
	};

	ArcaneImager noiseImage = () -> {
    	noiseDetail(lod, falloff);
    	PImage rimg = createImage(arcwidth, archeight, ARGB);
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
	};

	ArcaneImager kuficImage = () -> {
    	float chance;
    	PImage rimg = createImage(arcwidth, archeight, ARGB);
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
	};

	ArcaneImager mazeImage = () -> {
		mazeSource = resize(mazeSource, arcwidth, archeight);

		mazeSource.loadPixels();
		for (int i = 0; i < mazeSource.pixelWidth; i++){
			for (int j = 0; j < mazeSource.pixelHeight; j++){
				
				int loc = (i + j * mazeSource.pixelWidth);
				
				loc = constrain(loc, 0, mazeSource.pixels.length-1);

				color cpx = mazeSource.pixels[loc];
				
				float rpx = cpx >> 16 & 0xFF;
				float gpx = cpx >> 8 & 0xFF;
				float bpx = cpx & 0xFF;
				float apx = alpha(cpx);
				
				float avgF = ((rpx+gpx+bpx+apx)/4.)/255.;
				
				float r = round(avgF);
				color c = color(r*255);
				mazeSource.pixels[loc] = c;
				}
			}
		mazeSource.updatePixels();
		return mazeSource;
	};

    ArcaneGenerator (String generator, int w, int h) {
		arcwidth = w;
		archeight = h;
        switch (generator) {
            case "random":
                arcgen = randomImage;
                break;
            case "noise":
				lod = 2;
				falloff = 0.5;
                arcgen = noiseImage;
                break;
            case "kufic":
                arcgen = kuficImage;
                break;
            case "maze":
                arcgen = mazeImage;
                break;
            default:
                arcgen = randomImage;
                break;
            }   
        }
	
	void setLod(int l){
		lod = l;
		}
	
	void setFalloff(float f){
		falloff = f;
		}
	
	void setMazeSource(PImage m){
		mazeSource = m;
		}
	
	PImage getImage(){
		return arcgen.generator();
		}


    }