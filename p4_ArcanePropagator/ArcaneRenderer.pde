class ArcaneRenderer {
	String rendermode;
	PGraphics buffer;
	
	ArcaneRenderer(String renderer){
		rendermode = renderer;
	}
	
	void setup(){
		switch(rendermode){
			case "shader":
				// SHADER SETUP
				// uniforms other params etc.
				break;
			case "geo":
				// GEO SETUP
				break;
			default:
				// SHADER SETUP
				break;
		}
	}
	
	void show(ArcanePropagator aprop){
		switch(rendermode){
			case "shader":
				// SHADER Draw
				pgDraw();
				shaderDraw();
				break;
			case "geo":
				// GEO Draw
				pointDraw();
				break;
			default:
				// SHADER SETUP
				break;
		}
	}
}
