/* autogenerated by Processing revision 1281 on 2022-02-27 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class p4_ArcanePropagation extends PApplet {

// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg;

PImage simg,dimg;
float[][][] xmg;
int kwidth, modfac;
float scalefac,chance,wdf;


 public void setup(){
	/* size commented out by preprocessor */;
	surface.setTitle("Arcane Propagations");
	/* pixelDensity commented out by preprocessor */;
	pg = createGraphics(width,height, P2D);
	pg.noSmooth();
	
	// simg = loadImage("./imgs/buff_skate.JPG");
	// simg = loadImage("./imgs/face.png");
	// simg = loadImage("./imgs/p5sketch1.jpg");
	// simg = loadImage("./imgs/fezHassan.JPG");
	// simg = loadImage("./imgs/buildings.jpg");
	// simg = loadImage("./imgs/clouds.jpg");
	// simg = loadImage("./imgs/nasa.jpg");
	// simg = loadImage("./imgs/mwrTn-pixelmaze.gif");
	// simg = loadImage("./imgs/fruit.jpg");
	// simg = loadImage("./imgs/enrapture-captivating-media-8_oFcxtXUSU-unsplash.jpg");
	// simg = loadImage("./imgs/fzn_dishmint.JPG");
	// simg = loadImage("./imgs/roc_flour.jpg");
	// simg = loadImage("./imgs/nestedsquare.png");
	// simg = randomImage(width,height);
	// simg = noiseImage(width, height, 3, .6);
	simg = kuficImage(width/4, height/4);
	dimg = createImage((simg.width*2), (simg.height*2), ARGB);
	
	// simg.filter(GRAY);
	simg.resize(width, 0);;
	dimg.resize(width, 0);
	
	kwidth = 3;
	modfac = 1;

	// scalefac = 000.25; /*nasa*/
	// scalefac = 000.50; /*nasa*/
	// scalefac = 000.75; /*nasa*/
	// scalefac = 000.80; /*nasa*/
	// scalefac = 000.90; /*nasa*/
	// scalefac = 000.95; /*nasa*/
	// scalefac = 001.00; /*nasa*/
	// scalefac = 002.00; /*nasa*/
	// scalefac = 002.50; /*nasa*/
	scalefac = 003.00f; /*nasa*/
	// scalefac = 003.50; /*nasa*/
	// scalefac = 003.75; /*nasa*/
	// scalefac = 005.00; /*nasa*/
	// scalefac = 007.00; /*nasa*/
	// scalefac = 010.00; /*nasa*/
	// scalefac = 500.00;
	xmg = loadxm(simg, kwidth);
	
	setDispersedImage(simg, dimg);

	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", PApplet.parseFloat(pg.width), PApplet.parseFloat(pg.height));
	blueline.set("tex0", dimg);
	blueline.set("aspect", PApplet.parseFloat(simg.width)/PApplet.parseFloat(simg.height));
	// scale the radius and thickness of each point drawn in the shader
	wdf = 1.f;
	blueline.set("widthFactor", wdf);
	// blueline.set("widthFactor", 1.);
	// scale the angle computed from a pixel value
	blueline.set("angleFactor", 1.f);
	
	// frameRate(1.);
}

 public void draw(){
	// wdf += 100.;
	// blueline.set("widthFactor", wdf);
	
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	kernelp(simg, xmg);
	setDispersedImage(simg,dimg);
	
	blueline.set("tex0", dimg);
	image(pg, 0, 0, width, height);
}


 public float[][] loadkernel(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	img.loadPixels();
	int offset = dim / 2;
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){
			
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			
			loc = constrain(loc,0,img.pixels.length-1);
			float gs = (
				0.2989f *   red(img.pixels[loc]) +
				0.5870f * green(img.pixels[loc]) +
				0.1140f *  blue(img.pixels[loc])
				) / 255;
				
				kern[i][j] = map(gs, 0, 1, -1.f*scalefac,1.f*scalefac);
			}
		}
		img.updatePixels();
		return kern;
	}

 public float[][][] loadxm(PImage img, int kwidth) {
	float[][][] xms = new float[PApplet.parseInt(img.width * img.height)][kwidth][kwidth];
	float[][] kernel = new float[kwidth][kwidth];
	img.loadPixels();
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			kernel = loadkernel(i,j, kwidth, img);
			int index = (i + j * img.width);
			xms[index] = kernel;
		}
	}
	img.updatePixels();
	return xms;
}

 public void setDispersedImage(PImage source, PImage di) {
	source.loadPixels();
	di.loadPixels();
	for (int i = 0; i < di.width; i++){
		for (int j = 0; j < di.height; j++){
			int dindex = (i + j * di.width);
			if(i % modfac == 0 && j % modfac == 0){
				int x = i - 1;
				int y = j - 1;
				x = constrain(x, 0, source.width - 1);
				y = constrain(y, 0, source.height - 1);
				int sindex = (x + (y *source.width));
				if (sindex < source.pixels.length){
					di.pixels[dindex] = source.pixels[sindex];
				}
			} else {
				di.pixels[dindex] = color(0);
				}
			}
		}
	source.updatePixels();
	di.updatePixels();
}

 public void kernelp(PImage img, float[][][] ximage) {
	img.loadPixels();
	for (int i = 0; i < img.width; i++){
		for (int j = 0; j < img.height; j++){
			int c = convolution(i,j, kwidth, img, ximage);
			int index = (i + j * img.width);
			img.pixels[index] = c;
		}
	}
	img.updatePixels();
}

// https://processing.org/examples/convolution.html
// Adjusted slightly for the purposes of this sketch
 public int convolution(int x, int y, int kwidth, PImage img, float[][][] ximg)
	{
		float rtotal = 0.0f;
		float gtotal = 0.0f;
		float btotal = 0.0f;
		int offset = kwidth / 2;
		for (int i = 0; i < kwidth; i++){
			for (int j= 0; j < kwidth; j++){
				
				int xloc = x+i-offset;
				int yloc = y+j-offset;
				int loc = xloc + img.width*yloc;
				loc = constrain(loc,0,img.pixels.length-1);
				float xmsn = (ximg[loc][i][j] / kwidth);
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 1.5));
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 2));
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 3));
				if(xloc == x && yloc == y){
					rtotal -= (  red(img.pixels[loc]) * xmsn);
					gtotal -= (green(img.pixels[loc]) * xmsn);
					btotal -= ( blue(img.pixels[loc]) * xmsn);
				} else {
					rtotal += (  red(img.pixels[loc]) * xmsn);
					gtotal += (green(img.pixels[loc]) * xmsn);
					btotal += ( blue(img.pixels[loc]) * xmsn);
				}
			}
		}
		
		return color(rtotal, gtotal, btotal);
	}

 public PImage randomImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				int c = color(random(255.f));
				int index = (i + j * rimg.width);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}

 public PImage noiseImage(int w, int h, int lod, float falloff){
	  noiseDetail(lod, falloff);
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				int c = color(lerp(0,1,noise(i*cos(i),j*sin(j), (i+j)/2))*255);
				int index = (i + j * rimg.width);
				rimg.pixels[index] = c;
			}
		}
		rimg.updatePixels();
		return rimg;
	}


 public boolean leftsidetest(int x1, int y1, int x2, int y2, int xp, int yp){
	return ((x2 - x1) * (yp - y1) - (xp - x1) * (y2 - y1) > 0) ? true : false;
}

 public PImage kuficImage(int w, int h){
		PImage rimg = createImage(w,h, ARGB);
		rimg.loadPixels();
		for (int i = 0; i < rimg.width; i++){
			for (int j = 0; j < rimg.height; j++){
				
				if(leftsidetest(i,j, rimg.width - i, rimg.height - j, i, j)){
					chance = 0.00f;
				} else {
					chance = ((i % 2) + (j % 2));
					// chance = ((i % 2) * (j % 2));
				}

				float wallornot = random(2.f);
				int index = (i + j * rimg.width);
				
				if((i == 0 || i == rimg.width) || (j == 0 || j == rimg.height)){
					int c = color(0);
					rimg.pixels[index] = c;
				} else {
					if(wallornot <= chance){
							int c = color(0);
							rimg.pixels[index] = c;
						} else {
							int c = color(255);
							rimg.pixels[index] = c;
						}
				}
				}
			}
		rimg.updatePixels();
		return rimg;
	}


  public void settings() { size(900, 900, P3D);
pixelDensity(1); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "p4_ArcanePropagation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
