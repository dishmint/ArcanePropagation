/* autogenerated by Processing revision 1281 on 2022-02-25 */
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
PGraphics pg,canvas;

PImage simg;
float[][][] xmg;

float maxsum;
int kwidth;

 public void setup(){
	/* size commented out by preprocessor */;
	surface.setTitle("Arcane Propagations");
	/* pixelDensity commented out by preprocessor */;
	pg = createGraphics(400,400, P2D);
	pg.noSmooth();
	
	
	// simg = loadImage("./imgs/buff_skate.JPG");
	// simg = loadImage("./imgs/face.png");
	// simg = loadImage("./imgs/p5sketch1.jpg");
	// simg = loadImage("./imgs/fezHassan.JPG");
	// simg = loadImage("./imgs/buildings.jpg");
	simg = loadImage("./imgs/clouds.jpg");
	// simg = loadImage("./imgs/nasa.jpg");
	// simg = randomImage(width,height);
	
	
	// simg.filter(GRAY);
	simg.resize(width,0);
	
	kwidth = 3;
	xmg = loadxm(simg, kwidth);
	
	
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", PApplet.parseFloat(pg.width), PApplet.parseFloat(pg.height));
	blueline.set("tex0", simg);
	blueline.set("aspect", PApplet.parseFloat(simg.width)/PApplet.parseFloat(simg.height));
	
	// frameRate(1.);
}

 public void draw(){
	
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	kernelp(simg,xmg);
	
	blueline.set("tex0", simg);
	
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
				
				// Large Output Scales generally will slow down the dispersion
				// kern[i][j] = gs*255.;
				// kern[i][j] = map(gs, 0, 1, -1.,1.);
				// kern[i][j] = map(gs, 0, 1, -10.,10.);
				// kern[i][j] = map(gs, 0, 1, -100.,100.);
				kern[i][j] = map(gs, 0, 1, -1000.f,1000.f);
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
				// float xmsn = (ximg[loc][i][j] / kwidth);
				// float xmsn = (ximg[loc][i][j] / pow(kwidth, 2));
				float xmsn = (ximg[loc][i][j] / pow(kwidth, 3));
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


  public void settings() { size(400, 400, P3D);
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
