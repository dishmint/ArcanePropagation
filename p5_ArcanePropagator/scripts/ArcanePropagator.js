class ArcanePropagator {
    constructor(img, filtermode, rendermode, kw, sf, xf, ds) {
        /* PARAMS */
        this.fm = filtermode
        this.rm = rendermode

        this.kw = kw
        this.sf = sf
        this.xf = xf
        this.ds = ds

        this.offset = (this.kw/2)
        /* IMAGE */
        img.loadPixels()
        this.source = this.imagefit(img)
        img.updatePixels()
        this.ximage = this.loadxm(this.source)
        /* GUTS */
        this.af = new ArcaneFilter(this)
        this.ar = new ArcaneRender(img, this.rm, "blueline.glsl", this.ds)

        // this.updater = (ap) => {
        //     ap.update()
        // }
    }

    update(){
        this.af.kernelmap()
    }

    show(){
        this.ar.show(this)
    }

    draw(){
        this.update()
        this.ar.show()
    }

    imagefit(imageToResize){
        let sw = imageToResize.width /* pw etc were not valid properties */
        let sh = imageToResize.height
        let sc = min(width/sw, height/sh)
        
        let nw = round(sw*sc)
        let nh = round(sh*sc)
        imageToResize.resize(nw, nh)
        
        return imageToResize
    }

    computeGS(pixel){
        let rpx = pixel >> 16 & 0xFF
		let gpx = pixel >> 8 & 0xFF
		let bpx = pixel & 0xFF

        return (
            0.2989 * rpx +
            0.5870 * gpx +
            0.1140 * bpx
            ) / 255.0
    }

    loadxm(img){
        let xms = new Array(img.width*img.height)
        let knl = [...Array(this.kw)].map(e => Array(this.kw))
        img.loadPixels()
        for(let i = 0; i < img.width; i++) {
            for(let j = 0; j < img.height; j++){
                const index = constrain(i+j*img.width, 0, img.pixels.length-1)
                for (let k = 0; k < this.kw; k++) {
                    for (let l = 0; l < this.kw; l++) {
                        const xloc = i+k-this.offset
                        const yloc = j+l-this.offset
                        const loc = constrain(xloc+img.width*yloc, 0, img.pixels.length-1)

                        let cpx = img.pixels[loc]
                        let gs  = this.computeGS(cpx)
                        knl[k][l] = map(gs, 0, 1, -1, 1) 
                        // knl[k][l] = map(gs, 0, 1, -1*this.sf, 1*this.sf) 
                    }
                }
                xms[index] = knl
            };
        };
        img.updatePixels()
        return xms
    }
}