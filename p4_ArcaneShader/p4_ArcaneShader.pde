// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman
PShader blueline;
PGraphics pg;

PImage simg,dimg;
float[][][] xmg;

boolean hav;

ArcaneFilter af;
ArcaneGenerator ag;
ArcaneSettings settings;
ArcaneGPUFilter gpuFilter;
boolean useGPUFilter = true; // Toggle between CPU and GPU filtering
boolean showDebugInfo = false;
int lastFrameTime = 0;
float avgFrameTime = 0.0;

void setup(){
	// size(1422,800, P3D);
	size(800,800, P3D);
	surface.setTitle("Arcane Propagations");
	imageMode(CENTER);
	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);

	// Initialize settings
	settings = new ArcaneSettings();
	// settings.setFramerate(7);
	settings.setFramerate(0);
	settings.setFilter(1);

	// Example: Configure settings using the new API
	// settings.setKernelWidth(4);  // Use kwOptions[4] = 5
	// settings.setTheme(10);       // Use EMBER theme
	// settings.setSourcePath(26);  // Use age/2025-04.png
	// settings.setFilter(13);      // Use weightedblur filter
	// settings.setFramerate(3);    // Use 60fps
	// settings.setDownsample(0);   // Use no downsampling

	println("GPU Filter Mode: " + (useGPUFilter ? "ENABLED" : "DISABLED"));

	/* -------------------------------------------------------------------------- */
	/*                                 Load Image                                 */
	/* -------------------------------------------------------------------------- */

	simg = loadImage(settings.sourcepath);
	// simg = genImage(settings.generator);
	// simg.filter(GRAY);

	/* -------------------------------------------------------------------------- */
	/*                             Remaining Settings                             */
	/* -------------------------------------------------------------------------- */

	// https://stackoverflow.com/questions/1373035/how-do-i-scale-one-rectangle-to-the-maximum-size-possible-within-another-rectang
	final float sw = (float)simg.width;
	final float sh = (float)simg.height;
	final float scale = min(width/sw, height/sh);

	final int nw = Math.round(sw*scale/settings.downsample);
	final int nh = Math.round(sh*scale/settings.downsample);
	simg.resize(nw, nh);

	/*
	setting hav to true scales the rgb channels of a pixel to represent human perceptual color cruves before computing the average. It produces more movement since it changes the transmission rate of each channel.
	*/
	hav = true;
	// hav = false;
	xmg = loadxm(simg, settings.kw);

	// max width and height is 16384 for the Apple M1 graphics card (according to Processing debug message)
	pg = createGraphics(2*simg.width,2*simg.height, P2D);
	pg.noSmooth();

	blueline = loadShader("blueline.glsl");
	blueline.set("resolution", settings.resolutionScale*float(pg.width), settings.resolutionScale*float(pg.height));

	// the unitsize determines the dimensions of a pixels for the shader
	blueline.set("unitsize", 1.00);
	blueline.set("densityscale", 1.00/displayDensity());
	// the thickness used to determine a points position is determined by thickness/tfac
	blueline.set("tfac", 1.0);

	/*
	- The radius of a point orbit is determined by rfac * thickness
	- when 1.0000 < rfac < 1.0009 values begin to display as black pixels, kind of like a mask.
	- rfac >= 1.5 == black screen
	- rfac == 0.0 == 1:1
	*/

	// TODO: add rfac slider
	// blueline.set("rfac", 0.0);
	// blueline.set("rfac", 0.50);
	// blueline.set("rfac", 0.75);
	blueline.set("rfac", 1.0);

	blueline.set("theme", settings.theme);
	blueline.set("alpha", settings.alpha);
	blueline.set("grader", settings.grade);
	blueline.set("gpuMode", useGPUFilter);

	if(settings.dispersed){
		useDispersed(settings.modfac);
	} else {
		useOriginal();
	}

	background(0);

	// Initialize filters
	af = new ArcaneFilter(settings.filter, settings.kw, settings.xfac);

	if(useGPUFilter) {
		gpuFilter = new ArcaneGPUFilter(simg.width, simg.height, settings);
		gpuFilter.initializeWithImage(simg);
		gpuFilter.printAvailableShaders();
	}

	frameRate(settings.framerate);
}

void draw(){
	int frameStart = millis();

	try {
		if(useGPUFilter && gpuFilter != null && gpuFilter.hasShader(settings.filter)) {
			// GPU-accelerated filtering
			gpuFilter.applyFilter(settings.filter);

			// Use GPU result for display
			PGraphics gpuResult = gpuFilter.getCurrentBuffer();
			if(settings.dispersed){
				// For dispersed mode, we need to handle the GPU buffer differently
				setDispersedImageFromBuffer(gpuResult, dimg);
				blueline.set("tex0", dimg);
			} else {
				blueline.set("tex0", gpuResult);
			}
		} else {
			// Fallback to CPU filtering
			af.kernelmap(simg, xmg);

			// Use original shader path
			if(settings.dispersed){
				drawDispersed();
			} else {
				drawOriginal();
			}
		}
	} catch(Exception e) {
		println("Error in filter processing: " + e.getMessage());
		// Emergency fallback - just display original
		drawOriginal();
	}

	background(0);
	pgDraw();
	shaderDraw();

	// Performance monitoring
	int frameTime = millis() - frameStart;
	updatePerformanceMetrics(frameTime);

	showFrameRate();
	if(showDebugInfo) {
		showDebugInfo();
	}
}

void showFrameRate(){
	pushMatrix();
	final String fr = "fps: " + str(frameRate);
	stroke(255);
	text(fr, 25,25);
	popMatrix();
}

void shaderDraw(){
	// Shader drawing is now handled in draw() function
	// This maintains the final display step
	image(pg, width/2, height/2, simg.width*settings.displayscale, simg.height*settings.displayscale);
}

void pgDraw(){
	pg.beginDraw();
	pg.background(0);
	pg.shader(blueline);
	pg.rect(0, 0, pg.width, pg.height);
	pg.endDraw();
}

void useDispersed(int factor){
	dimg = createImage((simg.width*factor), (simg.height*factor), ARGB);

	final float sw = (float)dimg.width;
	final float sh = (float)dimg.height;
	final float scale = min(width/sw, height/sh);

	final int nw = Math.round(sw*scale);
	final int nh = Math.round(sh*scale);
	dimg.resize(nw, nh);

	setDispersedImage(simg, dimg);
	blueline.set("aspect", float(dimg.width)/float(dimg.height));
	blueline.set("tex0", dimg);
}

void useOriginal(){
	blueline.set("aspect", float(simg.width)/float(simg.height));
	blueline.set("tex0", simg);
}

void drawDispersed(){
	setDispersedImage(simg,dimg);
	blueline.set("tex0", dimg);
}

void drawOriginal(){
	blueline.set("tex0", simg);
}

float computeGS(color px){
	final float rpx = px >> 16 & 0xFF;
	final float gpx = px >> 8 & 0xFF;
	final float bpx = px & 0xFF;

	float gs = 1.;
	if(hav){
		// human grayscale
		gs = (
			0.2989 * rpx +
			0.5870 * gpx +
			0.1140 * bpx
			) * settings.colordiv;
	} else {
		// channel average
		gs = (rpx + gpx + bpx) * settings.colordiv;
	}
	return gs;
}

float[][] loadkernel(int x, int y, int dim, PImage img){
	float[][] kern = new float[dim][dim];
	img.loadPixels();
	int offset = dim / 2;
	for (int i = 0; i < dim; i++){
		for (int j= 0; j < dim; j++){

			int xloc = x+i-offset;
			int yloc = y+j-offset;
			int loc = xloc + img.width*yloc;

			loc = constrain(loc,0,img.pixels.length-1);

			color cpx = img.pixels[loc];

			float gs = computeGS(cpx);

			// the closer values are to 0 the more negative the transmission is, that's why a large value of kernelScale produces fast fades.
			kern[i][j] = map(gs, 0, 1, -1.*settings.kernelScale,1.*settings.kernelScale);
			}
		}
		img.updatePixels();
		return kern;
	}

float[][][] loadxm(PImage img, int kwidth) {
	float[][][] xms = new float[int(img.width * img.height)][kwidth][kwidth];
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

void setDispersedImage(PImage source, PImage di) {
	source.loadPixels();
	di.loadPixels();
	for (int i = 0; i < di.width; i++){
		for (int j = 0; j < di.height; j++){
			int dindex = (i + j * di.width);
			if(i % settings.modfac == 0 && j % settings.modfac == 0){
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

void setDispersedImageFromBuffer(PGraphics source, PImage di) {
	source.loadPixels();
	di.loadPixels();
	for (int i = 0; i < di.width; i++){
		for (int j = 0; j < di.height; j++){
			int dindex = (i + j * di.width);
			if(i % settings.modfac == 0 && j % settings.modfac == 0){
				int x = constrain(i, 0, source.width - 1);
				int y = constrain(j, 0, source.height - 1);
				int sindex = (x + (y * source.width));
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

// Keyboard controls for switching between GPU and CPU modes
void keyPressed() {
	if(key == 'g' || key == 'G') {
		useGPUFilter = !useGPUFilter;
		println("Switched to " + (useGPUFilter ? "GPU" : "CPU") + " filtering mode");
	}
	if(key == 's' || key == 'S') {
		if(useGPUFilter && gpuFilter != null) {
			gpuFilter.printAvailableShaders();
		}
	}
	if(key == 'd' || key == 'D') {
		showDebugInfo = !showDebugInfo;
		println("Debug info: " + (showDebugInfo ? "ON" : "OFF"));
	}

}

void updatePerformanceMetrics(int frameTime) {
	lastFrameTime = frameTime;
	avgFrameTime = avgFrameTime * 0.9 + frameTime * 0.1; // Exponential moving average
}

void showDebugInfo() {
	pushMatrix();
	stroke(255);
	fill(255);
	textAlign(LEFT);

	int yOffset = 50;
	text("Mode: " + (useGPUFilter ? "GPU" : "CPU"), 25, yOffset);
	yOffset += 20;
	text("Filter: " + settings.filter, 25, yOffset);
	yOffset += 20;
	text("Frame time: " + lastFrameTime + "ms", 25, yOffset);
	yOffset += 20;
	text("Avg frame time: " + nf(avgFrameTime, 0, 1) + "ms", 25, yOffset);
	yOffset += 20;

	if(useGPUFilter && gpuFilter != null) {
		text("GPU Filter available: " + gpuFilter.hasShader(settings.filter), 25, yOffset);
		yOffset += 20;
	}

	text("Press 'D' to hide debug", 25, yOffset);

	popMatrix();
}

PImage genImage(String generator){
	int noisew = int(0.0625 *  width);
	int noiseh = int(0.0625 * height);
	switch (generator) {
		case "random":
			ag = new ArcaneGenerator("random", noisew, noiseh);
			break;
		case "kufic":
			ag = new ArcaneGenerator("kufic", noisew, noiseh);
			break;
		case "maze":
			final PImage mimg = loadImage(settings.mazesource);
			ag = new ArcaneGenerator("maze", noisew, noiseh);
			ag.setMazeSource(mimg);
			break;
		case "noise":
			ag = new ArcaneGenerator("noise", noisew, noiseh);
			ag.setLod(3); ag.setFalloff(0.6f);
			break;
		default:
			ag = new ArcaneGenerator("random", noisew, noiseh);
			break;
	}
	return ag.getImage();
}
