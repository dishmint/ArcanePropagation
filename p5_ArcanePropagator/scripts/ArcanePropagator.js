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
        this.source = this.resize(img)
        this.ximage = this.loadxm(source)
        /* GUTS */
        this.af = new ArcaneFilter(this)
        this.ar = new ArcaneRender(img, this.rm, "blueline.glsl", this.ds)

        this.updater = () => {
            this.update()
        }
    }

    update(){
        this.af.kernelmap()
    }

    show(){
        this.ar.show(this)
    }

    draw(){
        this.updater(this)
        this.ar.show()
    }

    resize(imageToResize){
        let sw = imageToResize.pixelWidth
        let sh = imageToResize.pixelHeight
        let sc = min(width/sw, height/sh)
        
        let nw = round(sw*sc)
        let nh = round(sh*sc)
        imageToResize.resize(nw, nh)
        
        return imageToResize
    }

    computeGS(pixel){
        rpx = pixel >> 16 & 0xFF
		gpx = pixel >> 8 & 0xFF
		bpx = pixel & 0xFF

        return (
            0.2989 * rpx +
            0.5870 * gpx +
            0.1140 * bpx
            ) / 255.0
    }

    loadxm(img){
        let xms = new Array(img.pixelWidth*img.pixelHeight)
        let knl = new Array(this.kw)
        img.loadPixels()
        xms.forEach((column, i) => {
            column.forEach((row, j) => {
                const index = constrain(i+j*img.pixelWidth, 0, img.pixels.length-1)
                for (let k = 0; k < this.kw; k++) {
                    knl.push([])
                    for (let l = 0; l < this.kw; l++) {
                        knl[k].push([])
                        const xloc = i+k-this.offset
                        const yloc = j+l-this.offset
                        const loc = constrain(xloc+imgpixelWidth*yloc, 0, img.pixels.length-1)

                        cpx = img.pixels[loc]
                        gs  = this.computeGS(cpx)
                        knl[k][l] = map(gs, 0, 1, -1, 1) 
                        // knl[k][l] = map(gs, 0, 1, -1*this.sf, 1*this.sf) 
                    }
                }
                xms.push(knl)
            });
        });
        img.updatePixels()
        return xms
    }
}