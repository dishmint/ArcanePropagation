class ArcaneRender {
    /* 
    (img, this.rm, "blueline.glsl", this.ds)
    */
    constructor(src, mode, shader, displayscale) {
        this.source = src
        this.mode = mode
        this.blueline = shader
        this.displayscale = displayscale

        this.buffer = createGraphics(2.0*this.source.width, 2.0*this.source.height, P2D)
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

    setShader(){
        this.blueline.setUniform("ascpet", this.source.width/this.source.height)
        this.blueline.setUniform("tex0", this.source)
        this.blueline.setUniform("displayscale", 1.0/displayDensity())
        
        this.blueline.setUniform("resolution", 1000.0 * this.buffer.width, 1000.0 * this.buffer.height)
        this.blueline.setUniform("unitsize", 1.00)
        this.blueline.setUniform("tfac", 1.00)
        this.blueline.setUniform("rfac", 1.00)

        this.renderer = (simg, ds) => {
            this.blueline.set("tex0", simg)
            image(buffer, width/2, height/2, simg.width*ds, simg.height*ds)
        }
    }

    show(aprop){
        background(0)
        this.buffer.beginDraw()
		this.buffer.background(0)
		this.buffer.shader(blueline)
		this.buffer.rect(0, 0, buffer.width, buffer.height)
		this.buffer.endDraw()

        this.renderer(aprop, this.displayscale)
    }
}