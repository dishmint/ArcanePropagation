// FILE: ArcanePropagation
// AUTHOR: Faizon Zaman

import com.krab.lazy.*; /* LazyGui */

PImage simg;
ArcaneGenerator arcgen;

int kernelWidth;
ArcanePropagator parc;
float kernelScale,xsmnfactor,displayscale;
String[] afilter = {"amble", "transmit", "transmitMBL", "convolve", "collatz", "rdf", "rdft", "rdfm", "rdfr", "rdfx", "arcblur","xdilate", "xsdilate", "blur", "dilate", "erode", "invert"};
String[] xfactors = {"1 div kw^2", "1 div (kw^2 - 1)", "1 div kw", "kw", "kernel scale"};
String[] themes = {"red","green","blue","yellow","yellowbrick","rblue","gred", "starrynight","ember","bloodred","gundam"};
String[] grades = {"grade","nograde","source"};
String[] states = {"normal","inverse"};
String[] alphas = {"alpha1", "alphaC", "alphaY"};
String[] emaps = {"C4Z","C4B","C4C","C3M","C3Z"};

String flt;

/* TODO: #81 add gui for ArcaneGenerator */
ArcaneGenerator ag;

LazyGui gui;

/* TODO: #69 Add performance mode so live parameter changes can be recorded and saved */
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
	float ds = 0.99f;
	gui.slider("DisplayScale", ds, 0.01f, 1.0f);

	gui.text("Save Frame/Filename","arcane_capture");
	gui.button("Save Frame/Capture");
	
	/* ------------------------------- LOAD IMAGE ------------------------------- */
	gui.button("Select Image"); /* default image is universe */
	simg = loadImage("./imgs/universe.jpg");

	/* ---------------------------- KERNEL PROPERTIES --------------------------- */
	/* scales kernel values (-1.0~1.0) * kernelScale  */
	float factor = 1.0f/255.0f;
	gui.slider("ArcaneSettings/Kernel/KernelScale", factor, 0.0f, 1.0f);
	gui.sliderInt("ArcaneSettings/Kernel/KernelWidth", 3, 1, 7);

	gui.slider("ArcaneSettings/Kernel/ColorFactor", factor, 0.0f, 1.0f);
	/* Divisor: kernelsum / xsmnfactor */
	gui.radio("ArcaneSettings/Kernel/Xfac", xfactors, "1 div kw^2");
	xsmnfactor = 1.0f / pow(gui.sliderInt("ArcaneSettings/Kernel/KernelWidth"), 2.0f);
	/* ---------------------------- SHADER PROPERTIES --------------------------- */
	float usize, pixth, orbra;
	/* 
		when set to 1.0f the slider effectively toggles between 1 and 0 even though it's not a sliderInt
		so I've set the default to 0.99f which avoids this
		then I set it to 1.00f afterward for a pseudo-default.
		The only problem with this is that when reset is triggered over the slider it goes back to 0.99f instead of 1.00f
		*/
	usize=pixth=orbra=0.99f;

	gui.slider("ArcaneSettings/Shader/PixelMax"      , usize, 0.0f, 2.0f);
	gui.slider("ArcaneSettings/Shader/OrbitThickness", pixth, 0.0f, 2.0f);
	gui.slider("ArcaneSettings/Shader/OrbitRadius"   , orbra, 0.0f, 2.0f);
	
	gui.sliderSet("ArcaneSettings/Shader/PixelMax"      , 1.00f);
	gui.sliderSet("ArcaneSettings/Shader/OrbitThickness", 1.00f);
	gui.sliderSet("ArcaneSettings/Shader/OrbitRadius"   , 1.00f);

	gui.radio("ArcaneSettings/Shader/Theme", themes, "gred");
	gui.toggleSet("ArcaneSettings/Shader/GeoQ", true);
	gui.radio("ArcaneSettings/Shader/Grader", grades, "grade");
	gui.radio("ArcaneSettings/Shader/State", states, "normal");
	gui.radio("ArcaneSettings/Shader/Alpha", alphas, "alphaY");
	gui.radio("ArcaneSettings/Shader/EMap", emaps, "C4B");
	/* ---------------------------- ARCPROP INSTANCE ---------------------------- */
	parc = new ArcanePropagator(
		simg,
		gui.radio("ArcaneSettings/Kernel/Filter", afilter, "transmit"), 
		gui.sliderInt("ArcaneSettings/Kernel/KernelWidth"), 
		gui.slider("ArcaneSettings/Kernel/KernelScale"), 
		xsmnfactor,
		gui.slider("DisplayScale"),
		gui.slider("ArcaneSettings/Kernel/ColorFactor")
		);
	parc.debug();
}

void draw(){
	/* -------------------------------- PARC GUI -------------------------------- */
	parc.setDisplayScale(gui.slider("DisplayScale"));
	parc.setFilter(gui.radio("ArcaneSettings/Kernel/Filter", afilter));
	parc.setTransmissionFactor(gui.radio("ArcaneSettings/Kernel/Xfac", xfactors));
	/* ------------------------------- SHADER GUI ------------------------------- */
	parc.ar.blueline.set("unitsize", gui.slider("ArcaneSettings/Shader/PixelMax"));
	parc.ar.blueline.set("tfac", gui.slider("ArcaneSettings/Shader/OrbitThickness"));
	parc.ar.blueline.set("rfac", gui.slider("ArcaneSettings/Shader/OrbitRadius"));

	setShaderTheme();
	setShaderGeo();
	setShaderGrader();
	setShaderState();
	setShaderAlpha();
	setShaderEmap();

	/* ------------------------------- RESET IMAGE ------------------------------ */
	if(gui.button("Reset")){
		parc.reset();
	}

	/* -------------------------------- SIM RATE -------------------------------- */
	if (frameCount % gui.sliderInt("Rate") == 0){
		parc.run();
	}

	/* ---------------------- CAPTURE FRAME / SELECT IMAGE ---------------------- */
	if(gui.button("Save Frame/Capture")){
		parc.save(gui.text("Save Frame/Filename"));
	}

	if(gui.button("Select Image")){
		selectInput("Select an image to process:", "imageSelected");
	}
}

void setShaderTheme(){
	String stheme = gui.radio("ArcaneSettings/Shader/Theme", themes);
	switch (stheme) {
		case "red":
			parc.ar.blueline.set("theme", 1);
			break;
		case "blue":
			parc.ar.blueline.set("theme", 2);
			break;
		case "green":
			parc.ar.blueline.set("theme", 3);
			break;
		case "yellow":
			parc.ar.blueline.set("theme", 4);
			break;
		case "rblue":
			parc.ar.blueline.set("theme", 5);
			break;
		case "yellowbrick":
			parc.ar.blueline.set("theme", 6);
			break;
		case "gred":
			parc.ar.blueline.set("theme", 7);
			break;
		case "starrynight":
			parc.ar.blueline.set("theme", 8);
			break;
		case "ember":
			parc.ar.blueline.set("theme", 9);
			break;
		case "bloodred":
			parc.ar.blueline.set("theme", 10);
			break;
		case "gundam":
			parc.ar.blueline.set("theme", 11);
			break;
		default:
			parc.ar.blueline.set("theme", 5);
			break;
	}
}

void setShaderGeo(){
	boolean geoQ = gui.toggle("ArcaneSettings/Shader/GeoQ");
	if (geoQ) {
		parc.ar.blueline.set("geoQ", 1);
	} else {
		parc.ar.blueline.set("geoQ", 2);
	}
}

void setShaderGrader(){
	String grader = gui.radio("ArcaneSettings/Shader/Grader", grades);
	switch (grader) {
		case "grade":
			parc.ar.blueline.set("grader", 1);
			break;
		case "nograde":
			parc.ar.blueline.set("grader", 2);
			break;
		case "source":
			parc.ar.blueline.set("grader", 3);
			break;
		default:
			parc.ar.blueline.set("grader", 1);
			break;
	}
}

void setShaderState(){
	String state = gui.radio("ArcaneSettings/Shader/State", states);
	switch (state) {
		case "normal":
			parc.ar.blueline.set("state", 1);
			break;
		case "inverse":
			parc.ar.blueline.set("state", 2);
			break;
		default:
			parc.ar.blueline.set("state", 1);
			break;
	}
}

void setShaderAlpha(){
	String alpha = gui.radio("ArcaneSettings/Shader/Alpha", alphas);
	switch (alpha) {
		case "alpha1":
			parc.ar.blueline.set("alpha", 1);
			break;
		case "alphaC":
			parc.ar.blueline.set("alpha", 2);
			break;
		case "alphaY":
			parc.ar.blueline.set("alpha", 3);
			break;
		default:
			parc.ar.blueline.set("alpha", 3);
			break;
	}
}

void setShaderEmap(){
	String emap = gui.radio("ArcaneSettings/Shader/EMap", emaps);
	switch (emap) {
		case "C4Z":
			parc.ar.blueline.set("emap", 1);
			break;
		case "C4B":
			parc.ar.blueline.set("emap", 2);
			break;
		case "C4C":
			parc.ar.blueline.set("emap", 4);
			break;
		case "C3M":
			parc.ar.blueline.set("emap", 5);
			break;
		case "C3Z":
			parc.ar.blueline.set("emap", 6);
			break;
		default:
			parc.ar.blueline.set("emap", 2);
			break;
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

void exit(){
	// https://stackoverflow.com/a/28693343/12317788
	println("");
	println("Exiting...");
	println("");
	parc.debug();
	super.exit();//let processing carry with it's regular exit routine
}