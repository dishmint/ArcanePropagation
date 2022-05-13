class ArcanePropagator(){
	/* VARS */
	// SETUP
	
	//  WL Kernel Link
	KernelLink kl; /* null */
	Expr imgClusters; /* null */
	// IMAGE
	PImage source;
	ArcaneProcessor ap;
	// RENDER
	ArcaneRenderer ar;
	/* CNSR */
	ArcanePropagator(PImage img, String method, String renderer){
		//	SETUP IMAGE
		source = img;
		//	SETUP PROCESSOR
		ap = new ArcaneProcessor(method);
		//	SETUP RENDERER
		ar = new ArcaneRenderer(renderer);
	}
	/* MTHD */
	initialize(){
		// ap.setup();
		ar.setup();
	}
	
	update(){
		ap.kernelmap(this);
	}
	
	show(){
		ar.show(this);
	}

	// I should have one function that iterates over pixels and separate functions for each processor (convolution/transmission etc...)
	convolve(){
		
	}
	transmit(){
		
	}
}
