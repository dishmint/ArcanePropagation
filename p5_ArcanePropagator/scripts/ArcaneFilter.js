class ArcaneFilter {
    constructor(arcprop) {
        console.log("Creating ArcaneFilter")
        // console.log(arcprop)
        this.propagator = arcprop
        switch (this.propagator.fm) {
            case "transmit":
                this.arcfilter = this.transmit
                break;
            case "convolve":
                this.arcfilter = this.convolve
                break;
            case "transmitMBL":
                this.arcfilter = this.transmitMBL
                break;
            case "collatz":
                this.arcfilter = this.collatz
                break;
            case "rdf":
                this.arcfilter = this.rdf
                this.rdfsettings = {
                    rdfkernel: this.createRDFKernel(),
                    dA: 1.000,
                    dB: 0.500,
                    fr: 0.055,
                    kr: 1.062,
                }
                break;
            case "rdft":
                this.arcfilter = this.rdft
                this.rdfsettings = {
                    rdfkernel: this.createRDFKernel(),
                    dA: 1.000,
                    dB: 0.500,
                    fr: 0.055,
                    kr: 1.062,
                }
                break;
            case "rdfx":
                this.arcfilter = this.rdf
                this.rdfsettings = {
                    rdfkernel: this.createRDFKernel(-1.0, 0.50),
                    dA: 1.000,
                    dB: 0.500,
                    fr: 0.055,
                    kr: 1.062,
                }
                break;
            case "blur": case "dilate": case "erode": case "invert":
                /* These are handled by p5's built-in filters */
                break;
            default:
                this.arcfilter = this.transmit
                break;
        }
    }

    /* FILTERS */
    /* transmit */
	transmit = (x, y, img, xmg) => {
        const sloc = constrain((x+y*img.width),0,img.pixels.length-1);

        const cpx = img.pixels[sloc];

        let rpx = cpx >> 16 & 0xFF;
        let gpx = cpx >> 8 & 0xFF;
        let bpx = cpx & 0xFF;

        for (let k = 0; k < this.propagator.kw - 1; k++){
            for (let l= 0; l < this.propagator.kw - 1; l++){
                let xloc = x+k-this.propagator.offset;
                let yloc = y+l-this.propagator.offset;

                const loc = int(constrain((xloc + img.width*yloc),0,img.pixels.length-1));
                // console.log(loc,k,l)

                let xmsn = (xmg[loc][k][l] / this.propagator.xf);
                // console.log(xmsn)

                if(xloc == x && yloc == y){
                        rpx -= (xmsn * l);
                        gpx -= (xmsn * l);
                        bpx -= (xmsn * l);
                    } else {
                        rpx += (xmsn * l);
                        gpx += (xmsn * l);
                        bpx += (xmsn * l);
                    }
                }
            }
            img.pixels[sloc] = [rpx,gpx,bpx];
        };
    /* transmitMBL */
	transmitMBL = (x, y, img, xmg) => {
        const sloc = constrain((x+y*img.width),0,img.pixels.length-1);

        const cpx = img.pixels[sloc];

        let rpx = cpx >> 16 & 0xFF;
        let gpx = cpx >> 8 & 0xFF;
        let bpx = cpx & 0xFF;

        for (let k = 0; k < this.propagator.kw; k++){
            for (let l= 0; l < this.propagator.kw; l++){
                let xloc = x+k-this.propagator.offset;
                let yloc = y+l-this.propagator.offset;
                const loc = parseInt(constrain((xloc + img.width*yloc),0,img.pixels.length-1));

                let xmsn = (xmg[loc][k][l] / this.propagator.xf);

                if(xloc == x && yloc == y){
                        rpx -= (rpx * xmsn)
                        gpx -= (gpx * xmsn)
                        bpx -= (bpx * xmsn)
                    } else {
                        rpx += xmsn
                        gpx += xmsn
                        bpx += xmsn
                    }
                }
            }
            img.pixels[sloc] = [rpx,gpx,bpx];
        };

    /* APPLY FILTER */

    customfilter(img, ximg){
        img.loadPixels()
        for (let i = 0; i < img.width; i++){
            for(let j = 0; j < img.height; j++){
                this.arcfilter(i,j,img,ximg)
            }
        }
        img.updatePixels()
    }

    kernelmap(){
        switch (this.propagator.fm) {
            case "blur":
                this.propagator.source.filter(BLUR)
                break;
            case "dilate":
                this.propagator.source.filter(DILATE)
                break;
            case "erode":
                this.propagator.source.filter(ERODE)
                break;
            case "invert":
                this.propagator.source.filter(INVERT)
                break;
            default:
                this.customfilter(this.propagator.source, this.propagator.ximage)
                break;
        }
    }
}