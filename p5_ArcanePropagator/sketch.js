let simg, svid, parc

function preload(){
	simg = loadImage('assets/imgs/universe.jpg')
}

function setup() {
	createCanvas(windowWidth, windowHeight, WEBGL);
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
	
	parc = new ArcanePropagator(simg, params.ft, "shader", params.kw, params.sf, params.td, params.ds)
}

function draw() {
	parc.draw()
	rect(0,0, width, height)
}

function windowResized(){

	resizeCanvas(windowWidth, windowHeight);
  
  }
