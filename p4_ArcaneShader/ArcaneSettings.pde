class ArcaneSettings {
    
    /* ------------------------------ KERNELWIDTHS ------------------------------ */
    public final int[] kwOptions = {
        /* 0 */ 1,
        /* 1 */ 2,
        /* 2 */ 3,
        /* 3 */ 4,
        /* 4 */ 5,
        /* 5 */ 6,
        /* 6 */ 7,
        /* 7 */ 8
    };
    
    public int kwIndex = 2;
    public int kw;
    public int kwsq;
    
    /* ------------------------------ KERNELSCALES ------------------------------ */
    //                           0      1      2      3      4       5       6         7         8           9
    public final float[] ksOptions = {1.00f, 0.75f, 0.50f, 0.33f, 0.25f, 0.125f, 0.0625f, 0.03125f, 0.015625f, 0.0078125f};
    //                            0      1       2          3        4           5
    public final float[] ksfOptions = {1.00f, 10.00f, 100.00f, 1000.00f, 10000.00f, 100000.00f};
    public int ksIndex = 0;
    public int ksfIndex = 0;
    public float kernelScale;
    
    /* ------------------------------- DOWNSAMPLES ------------------------------ */
    /* higher dsfloat -> higher framerate | 1.0~N | 2.25 Default */
    //                                   0       1      2      3      4      5      6
    public final float[] downsampleOptions = {1.00f, 1.125f, 1.25f, 1.50f, 2.25f, 3.00f, 6.00f};
    public int downsampleIndex = 1;
    public float downsample;
    public boolean dispersed = false;
    // [^] setting to true reduces framerate
    public final int[] modfacs = {1, 2, 3, 4, 5, 6, 7, 8};
    public int modfacIndex = 0;
    public int modfac;
    
    public final int mfd = 4;
    public float dmfd;
    public float fmfd;
    
    /* ------------------------------ IMAGE SOURCE ------------------------------ */
    public final String[] sourcepathOptions = {
        /* 0 */"imgs/nasa.jpg",
        /* 1 */"imgs/face.png",
        /* 2 */"imgs/buildings.jpg",
        /* 3 */"imgs/mwrTn-pixelmaze.gif",
        /* 4 */"imgs/ryoji-iwata-n31JPLu8_Pw-unsplash.jpg",
        /* 5 */"imgs/buff_skate.JPG",
        /* 6 */"imgs/universe.jpg",
        /* 7 */"imgs/enrapture-captivating-media-8_oFcxtXUSU-unsplash.jpg",
        /* 8 */"imgs/planetsAbstract.jpg",
        /* 9 */"imgs/enter.jpg",
       /* 10 */"imgs/sign1.jpg",
       /* 11 */"imgs/p5sketch1.jpg",
       /* 12 */"imgs/mountains_1.jpg",
       /* 13 */"imgs/clouds.jpg",
       /* 14 */"imgs/sora-sagano-7LWIGWh-YKM-unsplash.jpg",
       /* 15 */"imgs/fruit.jpg",
       /* 16 */"imgs/randomdisk-200.png",
       /* 17 */"imgs/randomdisk-2000.png",
       /* 18 */"imgs/randomdisk-10_000.png",
       /* 19 */"imgs/randomdisk-10_000-binarized.png",
    
       /* 20 */"imgs/calendar/2025-01-21.png",
       /* 21 */"imgs/calendar/2025-01-22.png",
       /* 22 */"imgs/calendar/2025-01-24.png",
       /* 23 */"imgs/binarized_moon_ineverted.png",
       /* 24 */"imgs/center-1080.png",
       /* 25 */"imgs/patchwork-1080-image.png",
       /* 26 */"imgs/age/2025-04.png"
    };
    public int sourcepathIndex = 5;
    public String sourcepath;
    public String mazesource;
    
    //                                    0        1        2       3
    public final String[] generatorOptions = {"random", "kufic", "maze", "noise"};
    public int generatorIndex = 3;
    public String generator;
    
    /* --------------------------------- THEMES --------------------------------- */
    // THEMES
    public final int WHITE = 1;
    public final int RED = 2;
    public final int BLUE = 3;
    public final int GREEN = 4;
    public final int YELLOW = 5;
    public final int RBLUE = 6;
    public final int YELLOWBRICK = 7;
    public final int GRED = 8;
    public final int REEN = 9;
    public final int STARRYNIGHT = 10;
    public final int EMBER = 11;
    public final int BLOODRED = 12;
    public final int GUNDAM = 13;
    public final int MOONLIGHT = 14;
    
    // ALPHAS
    public final int ALPHA1 = 1;
    public final int ALPHAC = 2;
    public final int ALPHAY = 3;
    
    // GRADERS
    public final int GRADE   = 1;
    public final int NOGRADE = 2;
    public final int SOURCE  = 3;
    
    //                     0     1      2     3       4      5         6         7     8       9         10       11       12        13
    public final int[] themes = {WHITE, RED, BLUE, GREEN, YELLOW, RBLUE, YELLOWBRICK, GRED, REEN, STARRYNIGHT, EMBER, BLOODRED, GUNDAM, MOONLIGHT};
    public int themeIndex = 5;
    public int theme;
    
    /* --------------------------------- ALPHAS --------------------------------- */
    public final int[] alphas = {ALPHA1, ALPHAC, ALPHAY};
    public int alphaIndex = 0;
    public int alpha;
    
    /* --------------------------------- GRADES --------------------------------- */
    public final int[] grades = {GRADE, NOGRADE, SOURCE};
    public int gradeIndex = 0;
    public int grade;
    
    /* --------------------------------- FILTERS -------------------------------- */
    public final String[] filterOptions = {
        /*  0 */ "still",
        /*  1 */ "transmit",
        /*  2 */ "transmitMBL",
        /*  3 */ "convolve",
        /*  4 */ "amble",
        /*  5 */ "collatz",
        /*  6 */ "xcollatz",
        /*  7 */ "xtcollatz",
        /*  8 */ "rdf",
        /*  9 */ "rdft",
        /* 10 */ "rdfx",
        /* 11 */ "rdfr",
        /* 12 */ "rdfm",
        /* 13 */ "weightedblur",
        /* 14 */ "smear",
        /* 15 */ "smearTotal",
        /* 16 */ "xdilate",
        /* 17 */ "xsdilate",
        /* 18 */ "blur",
        /* 19 */ "dilate",
        /* 20 */ "chladni",
        /* 21 */ "conway",
    };
    public int filterIndex = 1;
    public String filter;
    
    /* -------------------------------- SET VARS -------------------------------- */
    public final float[] colordivOptions = {1.0f/255.0f, 1.0f/ 765.0f, 255.0f, 9.0f, 85.0f, 3.0f };
    public int colordivIndex = 0;
    public float colordiv;
    
    public final float D4 = 0.25;
    //                               0    1   2   3   4   5   6   7  8  9
    public final int[] framerateOptions = {120, 90, 75, 60, 48, 30, 24, 12, 6, 1};
    public int framerateIndex = 0;
    public int framerate;
    
    public float displayscale = 1.0;
    public float resolutionScale = 10000.00f;
    
    // Computed values
    public float[] xfacs;
    public int xfacIndex = 0;
    public float xfac;
    
    public ArcaneSettings() {
        updateComputedValues();
    }
    
    public void updateComputedValues() {
        // Update kernel values
        kw = kwOptions[kwIndex];
        kwsq = (int)(pow(kw, 2));
        
        // Update kernel scale
        kernelScale = ksOptions[ksIndex] * ksfOptions[ksfIndex];
        
        // Update downsample
        downsample = downsampleOptions[downsampleIndex];
        
        // Update modfac and related values
        modfac = modfacs[modfacIndex];
        dmfd = modfac/mfd;
        fmfd = 1.0/modfac;
        
        // Update source path
        sourcepath = sourcepathOptions[sourcepathIndex];
        mazesource = sourcepath;
        
        // Update generator
        generator = generatorOptions[generatorIndex];
        
        // Update theme
        theme = themes[themeIndex];
        
        // Update alpha
        alpha = alphas[alphaIndex];
        
        // Update grade
        grade = grades[gradeIndex];
        
        // Update filter
        filter = filterOptions[filterIndex];
        
        // Update colordiv
        colordiv = colordivOptions[colordivIndex];
        
        // Update framerate
        framerate = framerateOptions[framerateIndex];
        
        // Update xfacs array (depends on kw and kernelScale)
        xfacs = new float[]{1.0f/pow(float(kw), 2.0), 1.0f/kw, kw, kernelScale, 1.0};
        xfac = xfacs[xfacIndex];
    }
    
    // Setter methods for easy configuration
    public void setKernelWidth(int index) {
        kwIndex = constrain(index, 0, kwOptions.length - 1);
        updateComputedValues();
    }
    
    public void setKernelScale(int ksIdx, int ksfIdx) {
        ksIndex = constrain(ksIdx, 0, ksOptions.length - 1);
        ksfIndex = constrain(ksfIdx, 0, ksfOptions.length - 1);
        updateComputedValues();
    }
    
    public void setDownsample(int index) {
        downsampleIndex = constrain(index, 0, downsampleOptions.length - 1);
        updateComputedValues();
    }
    
    public void setSourcePath(int index) {
        sourcepathIndex = constrain(index, 0, sourcepathOptions.length - 1);
        updateComputedValues();
    }
    
    public void setGenerator(int index) {
        generatorIndex = constrain(index, 0, generatorOptions.length - 1);
        updateComputedValues();
    }
    
    public void setTheme(int index) {
        themeIndex = constrain(index, 0, themes.length - 1);
        updateComputedValues();
    }
    
    public void setAlpha(int index) {
        alphaIndex = constrain(index, 0, alphas.length - 1);
        updateComputedValues();
    }
    
    public void setGrade(int index) {
        gradeIndex = constrain(index, 0, grades.length - 1);
        updateComputedValues();
    }
    
    public void setFilter(int index) {
        filterIndex = constrain(index, 0, filterOptions.length - 1);
        updateComputedValues();
    }
    
    public void setFramerate(int index) {
        framerateIndex = constrain(index, 0, framerateOptions.length - 1);
        updateComputedValues();
    }
    
    public void setColordiv(int index) {
        colordivIndex = constrain(index, 0, colordivOptions.length - 1);
        updateComputedValues();
    }
    
    public void setXfac(int index) {
        xfacIndex = constrain(index, 0, xfacs.length - 1);
        updateComputedValues();
    }
    
    public void setModfac(int index) {
        modfacIndex = constrain(index, 0, modfacs.length - 1);
        updateComputedValues();
    }
}