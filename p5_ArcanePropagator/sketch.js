// Still getting path issues with the shader, not sure what's going on..

let simg, svid, parc

let arcgen = new ArcaneGenerator("random", 512, 512)
let arcshader

function preload(){
	// simg = loadImage('assets/imgs/universe.jpg')
	arcshader = loadShader('assets/blueline.glsl') 
	simg = arcgen.getImage()
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
	parc = new ArcanePropagator(simg, arcshader, params.ft, "shader", params.kw, params.sf, params.td, params.ds)
}

function draw() {
	// parc.draw()
	rect(0,0, windowWidth, windowHeight)
	// image(simg, 0, 0, width, height)
}

function windowResized(){

	resizeCanvas(windowWidth, windowHeight);
  
  }
