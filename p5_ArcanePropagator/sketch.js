// Still getting path issues with the shader, not sure what's going on..

let simg, svid, parc

let arcgen = new ArcaneGenerator("random", 512, 512)
let arcshader

function preload(){
	// simg = loadImage('assets/imgs/universe.jpg')
	arcshader = loadShader("assets/shaders/vs.vert","assets/shaders/blueline.frag")
	console.log(arcshader)
	simg = arcgen.getImage()
	/* TODO: I'll need a buffer shader to load pixels into + read from. */
}

function setup() {
	createCanvas(windowWidth, windowHeight, WEBGL);
	rectMode(CENTER)
	imageMode(CENTER)
	pixelDensity(displayDensity())
	background(0)
	let params = {
		kw: 3,
		xf: 4.0,
		ds: 1.0,
		ft: "transmit"
	}
	params.td = params.kw * params.kw,
	params.sf = 255.0 * params.xf
	console.log("Setup")
	parc = new ArcanePropagator(simg, arcshader, params.ft, "shader", params.kw, params.sf, params.td, params.ds)
	parc.ar.parentDimensions(width,height)
}

function draw() {
	parc.draw() 
	rect(0,0, windowWidth, windowHeight)
	image(simg, 0, windowHeight / 8.0, simg.width * 1.0, simg.height * 1.0)
}

function windowResized(){

	resizeCanvas(windowWidth, windowHeight);
  
  }