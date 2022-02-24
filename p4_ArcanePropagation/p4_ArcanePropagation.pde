// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

PShader blueline;
PGraphics pg,canvas;

PImage img;


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
	blueline.set("time", millis() / 1000.0);
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
			int index = (i + j * image.width);
			image.pixels[index] = image.pixels[index];
		}
	}
	image.updatePixels();
}

// color nbpx(int position, int[] px){
// 	int[] ndx = new int[9];
// 	int count = 0;
// 	/*
// 	nw [-1, -w]; n [0, -w]; ne [1, -w];
// 	w  [-1,  0]; c [0,  0];  e [1,  0];
// 	sw [-1,  w]; s [0,  w]; se [1,  w];
// 	*/
//
// 	for(int v = -3; v == 3; v +=3){
// 		for( int h = -1; h == 1; h ++ ){
// 			int nx = position + h + v;
// 			if(nx < 0){
// 				ndx[count] = nx;
// 			}
// 			count++;
// 			}
// 		}
//
// 	return ndx;
// }
