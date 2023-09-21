// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

import com.krab.lazy.*;

PImage simg;
ArcaneGenerator arcgen;

int kernelWidth;
ArcanePropagator parc;
float kernelScale,xsmnfactor,displayscale;
String[] afilter = {"amble", "transmit", "transmitMBL", "convolve", "collatz", "rdf", "rdft", "rdfm", "rdfr", "rdfx", "blur", "dilate"};
String[] xfactors = {"1 div kw^2", "1 div (kw^2 - 1)", "1 div kw", "kw", "kernel scale"};
String flt;

ArcaneGenerator ag;

LazyGui gui;

/* TODO: #69 Add performance mode so live parameter changes can be recorded and saved */
/* TODO: #71 Add ui to change shader parameters */
void setup(){
	/* ----------------------------- SKETCH SETTINGS ---------------------------- */
	size(1422, 800, P3D);
	surface.setTitle("Arcane Propagations");
	surface.setResizable(true);

	imageMode(CENTER);

	pixelDensity(displayDensity());
	hint(ENABLE_STROKE_PURE);
	background(0);

  	// surface.setLocation(18, 0); offset for me because I use Stage Manager on MacOS

	/* ------------------------------ GUI SETTINGS ------------------------------ */
	gui = new LazyGui(this, new LazyGuiSettings()
		.setMainFontSize(12)
		.setSideFontSize(9)
		.setLoadLatestSaveOnStartup(false)
		.setAutosaveOnExit(false)
		);
	
	gui.toggleSet("options/windows/separators/show", true);
	gui.sliderSet("options/windows/separators/weight", 0.2);

	gui.button("Reset");
	gui.toggleSet("Run", false);
	gui.sliderInt("Rate", 1, 1, 120);
	gui.slider("DisplayScale", 1.0f, 0.01f, 1.0f);

	gui.text("Save Frame/Filename","arcane_capture");
	gui.button("Save Frame/Capture");
	
	/* ------------------------------- LOAD IMAGE ------------------------------- */
	/* TODO: #79 Add image selector */
	gui.button("Select Image"); /* default image is universe */
	simg = loadImage("./imgs/universe.jpg");

	/* ---------------------------- KERNEL PROPERTIES --------------------------- */
	/* scales kernel values (-1.0~1.0) * kernelScale  */
	float factor = 1.0f/255.0f;
	gui.slider("ArcaneSettings/KernelScale", factor, 0.0f, 1.0f);
	gui.sliderInt("ArcaneSettings/KernelWidth", 3, 1, 7);

	gui.slider("ArcaneSettings/ColorFactor", factor, 0.0f, 1.0f);
	/* Divisor: kernelsum / xsmnfactor */
	gui.radio("ArcaneSettings/Xfac", xfactors, "1 div kw^2");

	/* ---------------------------- SHADER PROPERTIES --------------------------- */
	float usize, pixth, orbra;
	// usize=pixth=orbra=1.0f;
	usize=pixth=orbra=0.99f;

	gui.slider("ArcaneSettings/Shader/Unit Size"      , usize, 0.0f, 1.0f);
	gui.slider("ArcaneSettings/Shader/Pixel Thickness", pixth, 0.0f, 1.0f);
	gui.slider("ArcaneSettings/Shader/Orbit Radius"   , orbra, 0.0f, 1.0f);
	/* ---------------------------- ARCPROP INSTANCE ---------------------------- */
	parc = new ArcanePropagator(
		simg,
		gui.radio("ArcaneSettings/Filter", afilter, "transmit"), 
		gui.sliderInt("ArcaneSettings/KernelWidth"), 
		gui.slider("ArcaneSettings/KernelScale"), 
		xsmnfactor,
		gui.slider("DisplayScale"),
		gui.slider("ArcaneSettings/ColorFactor")
		);
	parc.debug();
}

void draw(){
	/* -------------------------------- PARC GUI -------------------------------- */
	parc.setDisplayScale(gui.slider("DisplayScale"));
	parc.setFilter(gui.radio("ArcaneSettings/Filter", afilter));
	parc.setKernelScale(gui.slider("ArcaneSettings/KernelScale"));
	parc.setTransmissionFactor(gui.radio("ArcaneSettings/Xfac", xfactors));
	parc.setColorDiv(gui.slider("ArcaneSettings/ColorFactor"));
	/* ------------------------------- SHADER GUI ------------------------------- */
	parc.ar.setShaderUnitSize(gui.slider("ArcaneSettings/Shader/Unit Size"));
	parc.ar.setShaderTFac(gui.slider("ArcaneSettings/Shader/Pixel Thickness"));
	parc.ar.setShaderRFac(gui.slider("ArcaneSettings/Shader/Orbit Radius"));

	/* ------------------------------- RESET IMAGE ------------------------------ */
	if(gui.button("Reset")){
		parc.reset();
	}

	/* -------------------------------- SIM RATE -------------------------------- */
	if (frameCount % gui.sliderInt("Rate") == 0){
		parc.run();
	}

	if(gui.button("Save Frame/Capture")){
		parc.save(gui.text("Save Frame/Filename"));
	}

	if(gui.button("Select Image")){
		selectInput("Select an image to process:", "imageSelected");
	}
}

void imageSelected(File selection){
	if (selection == null) {
    	println("Window was closed or the user hit cancel.");
	} else {
		PImage nimg = loadImage(selection.getAbsolutePath());
		parc.setImage(nimg);
		println("User selected " + selection.getAbsolutePath());
		}
}