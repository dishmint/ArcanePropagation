class ArcaneRender {
    /* 
    (img, this.rm, "blueline.glsl", this.ds)
    */
    constructor(src, mode, shader, displayscale) {
        this.source = src
        this.mode = mode
        this.blueline = shader
        this.displayscale = displayscale
        this.w = 100.0
        this.h = 100.0

        this.buffer = createGraphics(2.0*this.source.width, 2.0*this.source.height, WEBGL)
        this.buffer.noSmooth()

        switch(this.mode){
            case "shader":
                this.setShader()
                break
            default:
                this.setShader()
                break
        }
    }

    parentDimensions(w, h){
        this.w = w
        this.h = h
    }

    setShader(){
        this.blueline.setUniform("ascpet", this.source.width/this.source.height)
        this.blueline.setUniform("tex0", this.source)
        this.blueline.setUniform("displayscale", 1.0/displayDensity())
        
        this.blueline.setUniform("resolution", 1000.0 * this.buffer.width, 1000.0 * this.buffer.height)
        this.blueline.setUniform("unitsize", 1.00)
        this.blueline.setUniform("tfac", 1.00)
        this.blueline.setUniform("rfac", 1.00)

        this.renderer = (simg, ds) => {
            // console.log(simg.source)
            this.blueline.setUniform("tex0", simg.source)
            // console.log(simg)
            image(this.buffer, this.w/2, this.h/2, simg.source.width*ds, simg.source.height*ds)
        }
    }

    show(aprop){
        background(0)
        // this.buffer.beginDraw()
		this.buffer.background(0)
		this.buffer.shader(this.blueline)
		this.buffer.rect(0, 0, this.buffer.width, this.buffer.height)
		// this.buffer.endDraw()

        this.renderer(aprop, this.displayscale)
    }
}