let simg, svid, parc

function preload(){
	simg = loadImage("./assets/imgs/universe.jpg")
}

function setup() {
	createCanvas(windowWidth, windowHeight);
	imageMode(CENTER)
	pixelDensity(displayDensity())
	background(0)
	let params = {
		kw: 3,
		xf: 4.0,
		ds: 1.0,
		td: settings.kf * settings.kf,
		sf: 255.0 * settings.xf,
		ft: "transmit"
	}
	
	parc = new ArcanePropagator(simg, params.ft, "shader", params.kw, params.sf, params.td, params.ds)
}

function draw() {
	parc.draw()
}
