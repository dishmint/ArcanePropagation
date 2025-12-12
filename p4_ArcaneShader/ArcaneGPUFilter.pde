class ArcaneGPUFilter {
    PGraphics workingBuffer, tempBuffer;
    PGraphics previousFrame;
    HashMap<String, PShader> shaders;
    ArcaneSettings settings;
    int frameCount = 0;
    
    ArcaneGPUFilter(int w, int h, ArcaneSettings arcSettings) {
        workingBuffer = createGraphics(w, h, P2D);
        tempBuffer = createGraphics(w, h, P2D);
        previousFrame = createGraphics(w, h, P2D);
        
        workingBuffer.noSmooth();
        tempBuffer.noSmooth();
        previousFrame.noSmooth();
        
        settings = arcSettings;
        loadShaders();
    }
    
    void loadShaders() {
        shaders = new HashMap<String, PShader>();
        
        String[] shaderNames = {
            "transmit", "rdf", "rdft", "rdfx", "rdfr", "rdfm",
            "collatz", "xcollatz", "xtcollatz", 
            "weightedblur", "smear", "smearTotal",
            "dilate", "xdilate", "xsdilate",
            "chladni", "conway", "blur", "amble",
            "convolve", "still", "transmitMBL"
        };
        
        for(String name : shaderNames) {
            try {
                PShader shader = loadShader(name + ".glsl");
                if(shader != null) {
                    shaders.put(name, shader);
                    // println("Loaded shader: " + name);
					// [*] could do a progress bar here
                }
            } catch(Exception e) {
                println("Error loading shader " + name + ": " + e.getMessage());
            }
        }

		println("Loaded " + shaders.size() + " shaders");

        try {
            PShader passthrough = loadShader("passthrough.glsl");
            if(passthrough != null) {
                shaders.put("passthrough", passthrough);
                println("Loaded fallback passthrough shader");
            }
        } catch(Exception e) {
            println("Error loading passthrough shader: " + e.getMessage());
        }
    }
    
    void initializeWithImage(PImage img) {
        workingBuffer.beginDraw();
        workingBuffer.clear();
        workingBuffer.image(img, 0, 0, workingBuffer.width, workingBuffer.height);
        workingBuffer.endDraw();
        
        previousFrame.beginDraw();
        previousFrame.clear();
        previousFrame.image(img, 0, 0, previousFrame.width, previousFrame.height);
        previousFrame.endDraw();
        
        frameCount = 0;
    }
    
    void applyFilter(String filterName) {
        PShader shader = shaders.get(filterName);
        if(shader == null) {
            shader = shaders.get("passthrough");
            if(shader == null) {
                println("No shader available for: " + filterName);
                return;
            }
        }
        
        // Store previous frame
        if(frameCount > 0) {
            previousFrame.beginDraw();
            previousFrame.clear();
            previousFrame.image(workingBuffer, 0, 0);
            previousFrame.endDraw();
        }
        
        // Render to temp buffer
        tempBuffer.beginDraw();
        tempBuffer.clear();
        tempBuffer.shader(shader);
        
        setCommonUniforms(shader, workingBuffer);
        setFilterSpecificUniforms(shader, filterName);
        
        tempBuffer.rect(0, 0, tempBuffer.width, tempBuffer.height);
        tempBuffer.endDraw();
        
        // Copy back to working buffer with corrected orientation
        workingBuffer.beginDraw();
        workingBuffer.clear();
        workingBuffer.pushMatrix();
        workingBuffer.scale(1, -1);
        workingBuffer.translate(0, -workingBuffer.height);
        workingBuffer.image(tempBuffer, 0, 0);
        workingBuffer.popMatrix();
        workingBuffer.endDraw();
        
        frameCount++;
    }
    
    void setCommonUniforms(PShader shader, PGraphics source) {
        shader.set("tex0", source);
        shader.set("resolution", (float)source.width, (float)source.height);
        shader.set("time", millis() * 0.001f);
    }
    
    void setFilterSpecificUniforms(PShader shader, String filterName) {
        switch(filterName) {
            case "transmit":
			case "transmitMBL":
			case "convolve":
                shader.set("kernelScale", settings.kernelScale);
                shader.set("transmissionfactor", settings.xfac);
                shader.set("kernelWidth", settings.kw);
                shader.set("colordiv", settings.colordiv);
                shader.set("hav", hav);
                break;
            case "rdf":
            case "rdft":
            case "rdfx":
            case "rdfr":
            case "rdfm":
                shader.set("dA", 1.0f);
                shader.set("dB", 0.5f);
                shader.set("fr", 0.055f);
                shader.set("kr", 0.062f);
                shader.set("dt", 0.1f);
                break;
                
            case "weightedblur":
                shader.set("kernelScale", settings.kernelScale);
                shader.set("kernelWidth", settings.kw);
                shader.set("blurStrength", 0.5f);
                break;
                
            case "smear":
            case "smearTotal":
                shader.set("prevFrame", previousFrame);
                shader.set("smearStrength", 2.0f);
                shader.set("smearDirection", 0.1f, 0.1f);
                break;
                
            case "dilate":
            case "xdilate":
            case "xsdilate":
                shader.set("dilateRadius", 2.0f);
                shader.set("threshold", 0.5f);
                shader.set("kernelSize", settings.kw);
                break;
                
            case "blur":
                shader.set("blurRadius", 2.0f);
                shader.set("blurSamples", 9);
                break;
        }
    }
    
    PGraphics getCurrentBuffer() {
        return workingBuffer;
    }
    
    boolean hasShader(String filterName) {
        return shaders.containsKey(filterName);
    }
    
    void printAvailableShaders() {
        println("Available GPU shaders:");
        for(String name : shaders.keySet()) {
            println("  - " + name);
        }
    }
}
