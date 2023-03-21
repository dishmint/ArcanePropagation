class ArcaneGenerator  {
    PImage arcimg;

    ArcaneGenerator (String generator, int w, int h) {
        switch (generator) {
            case "random":
                arcimg = randomImage(w, h);
                break;
            case "noise":
                arcimg = noiseImage(w, h, 2, 0.5);
                break;
            case "kufic":
                arcimg = kuficImage(w, h);
                break;
            default:
                arcimg = randomImage(w, h);
                break;
            }   
        }
	
	PImage getImage(){
		return arcimg;
		}

    PImage randomImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
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
		}

    PImage noiseImage(int w, int h, int lod, float falloff){
    	  noiseDetail(lod, falloff);
    		PImage rimg = createImage(w,h, ARGB);
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
    	}

    PImage kuficImage(int w, int h){
    		float chance;
    		PImage rimg = createImage(w,h, ARGB);
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
    	}

    }