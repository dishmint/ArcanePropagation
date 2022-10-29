class ArcaneFilter {
    constructor(arcprop) {
        this.propagator = acrprop
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
        const sloc = constrain((x+y*img.pixelWidth),0,img.pixels.length-1);

        const cpx = img.pixels[sloc];

        let rpx = cpx >> 16 & 0xFF;
        let gpx = cpx >> 8 & 0xFF;
        let bpx = cpx & 0xFF;

        for (let k = 0; k < this.propagator.kw; k++){
            for (let l= 0; l < this.propagator.kw; l++){
                let xloc = x+k-this.propagator.offset;
                let yloc = y+l-this.propagator.offset;
                const loc = constrain((xloc + img.pixelWidth*yloc),0,img.pixels.length-1);

                xmsn = (xmg[loc][k][l] / this.propagator.xf);

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
	transmit = (x, y, img, xmg) => {
        const sloc = constrain((x+y*img.pixelWidth),0,img.pixels.length-1);

        const cpx = img.pixels[sloc];

        let rpx = cpx >> 16 & 0xFF;
        let gpx = cpx >> 8 & 0xFF;
        let bpx = cpx & 0xFF;

        for (let k = 0; k < this.propagator.kw; k++){
            for (let l= 0; l < this.propagator.kw; l++){
                let xloc = x+k-this.propagator.offset;
                let yloc = y+l-this.propagator.offset;
                const loc = constrain((xloc + img.pixelWidth*yloc),0,img.pixels.length-1);

                xmsn = (xmg[loc][k][l] / this.propagator.xf);

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
        img.forEach((column, i) => {
            column.forEach((row, j) => {
                this.arcfilter(i,j,img,ximg)
            });
        });
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