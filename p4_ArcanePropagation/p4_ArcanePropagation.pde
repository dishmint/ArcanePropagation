// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage img;

// https://processing.org/examples/convolution.html
// Convolution Kernel
float[][] matrix = {
	{ 1, 1, 1 },
	{ 1, 1, 1 },
	{ 1, 1, 1 }
};

int matrixsize = 3;

void setup(){
	size(400, 400, P3D);
	
	pg = createGraphics(400, 400, P2D);
	pg.noSmooth();
	
	// img = loadImage("./imgs/buff_skate.JPG");
	img = loadImage("./imgs/face.png");
	
	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", float(pg.width), float(pg.height));
	blueline.set("tex0", img);
	blueline.set("aspect", float(img.width)/float(img.height));
}


void draw(){
	// blueline.set("time", millis() / 1000.0);
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
	
	kernelp(img);
	
	blueline.set("tex0", img);
	image(pg, 0, 0, width, height);
	
}

// GrayScale-ificatino can be done in the shader
// let gs =
// 	(0.2989 * currentPixel[0] +
// 		0.5870 * currentPixel[1] +
// 		0.1140 * currentPixel[2]
// 	) / 255

// if (iShouldSetTransmissionStrengthByImage) {
// 	let tmS = map(gs, 0, 1, -.5, .5)
// 	cBit.setTransmissionStrength(tmS)
// }

// transmit(neighbors) {
// 	let transmission = this.energy * this.transmissionStrength
// 	let sum = 0
// 	for (let neighbor of neighbors) {
// 		sum += neighbor.energy
// 		this.energy -= (transmission / neighbors.length)
// 	}
// }

void kernelp(PImage image ) {
	image.loadPixels();
	for (int i = 0; i < image.width; i++){
		for (int j = 0; j < image.height; j++){
			
			color c = convolution(i,j, matrix, matrixsize, image);
			int index = (i + j * image.width);
			// image.pixels[index] = image.pixels[index];
			image.pixels[index] = c;
		}
	}
	image.updatePixels();
}



// https://processing.org/examples/convolution.html
/*

Since I am creating a new kernel per block, I don't need to supply a kernel to the convolution. Each kernel element is weighted by a transmissionStrength whose value corresponds to the value of the kernel element. Though for testing I will keep it.
*/
color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img)
{
	float rtotal = 0.0;
	float gtotal = 0.0;
	float btotal = 0.0;
	int offset = matrixsize / 2;
	for (int i = 0; i < matrixsize; i++){
		for (int j= 0; j < matrixsize; j++){
			// What pixel are we testing
			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;
			// Make sure we haven't walked off our image, we could do better here
			loc = constrain(loc,0,img.pixels.length-1);
			// Calculate the convolution
			rtotal += (red(img.pixels[loc]) * matrix[i][j]);
			gtotal += (green(img.pixels[loc]) * matrix[i][j]);
			btotal += (blue(img.pixels[loc]) * matrix[i][j]);
		}
	}
	// Make sure RGB is within range
	rtotal = constrain(rtotal, 0, 255);
	gtotal = constrain(gtotal, 0, 255);
	btotal = constrain(btotal, 0, 255);
	// Return the resulting color
	return color(rtotal, gtotal, btotal);
}
