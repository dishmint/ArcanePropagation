import java.util.function.*;
@FunctionalInterface
public interface ArcaneHue {
	color archue(float thetafactor);
    }

class ArcaneTheme {
	final static float TAU = TWO_PI;
	final static float QTAU = TWO_PI * 0.25;
	final static float DTAU = 1.0/TWO_PI;
	final static float CFAC = 1.0/255.0;
	String theme;
	float energy;
	float angle;
	String energyMode;
	// String alphaMode;
	ArcaneHue ahue;
	color px;

	ArcaneHue white = (thetafactor) -> {
		return color(255.0);
	};

	ArcaneHue red = (thetafactor) -> {
		return color(255.0 * thetafactor,0.0,0.0);
	};

	ArcaneHue blue = (thetafactor) -> {
		return color(0.0,0.0, 255.0 * thetafactor);
	};

	ArcaneHue green = (thetafactor) -> {
		PVector vec3 = new PVector(0.101961, 0.145098, 0.117647);
		vec3.mult(255.0);
		vec3.mult(thetafactor);
		return color(vec3.x, vec3.y, vec3.z);
	};

	ArcaneHue yellow = (thetafactor) -> {
		PVector vec3 = new PVector(1.0, 1.0, 0.0);
		vec3.mult(255.0);
		vec3.mult(thetafactor);
		return color(vec3.x, vec3.y, vec3.z);
	};
	
	ArcaneHue yellowbrick = (thetafactor) -> {
		PVector c1 = new PVector(.22, .06, 0.);
		c1.mult(255.0);
		PVector c2 = new PVector(1., .84, 0.);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
		// mix(vec3(.22, .06, 0.), vec3(1., .84, 0.), thetafactor);
	};
	
	ArcaneHue rblue = (thetafactor) -> {
		// PVector vec3 = new PVector(thetafactor*215.0, 255.-(abs(lerp(-1.0,1.0,thetafactor)) * 255.0), 255.0-(abs(lerp(-1.0,1.0,thetafactor))*200.0));
		float r = thetafactor*215.0;
		float g = (1.0 - abs(lerp(-1.0, 1.0, thetafactor))) * 255.0;
		// float b = 255.0 - abs(lerp(-200.0, 200.0, thetafactor));
		float b = (1.0 - (abs(lerp(-1.0, 1.0, thetafactor))*(200.0 * CFAC))) * 255.0;

		return color(r, g, b);
	};
	
	ArcaneHue gred = (thetafactor) -> {
		PVector c1 = new PVector(1., .16, 0.22);
		c1.mult(255.0);
		PVector c2 = new PVector(0.07, .42, 0.1);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
	};
	
	ArcaneHue reen = (thetafactor) -> {
		PVector c1 = new PVector(0.07, .42, 0.1);
		c1.mult(255.0);
		PVector c2 = new PVector(1., .16, 0.22);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
	};
	
	ArcaneHue starrynight = (thetafactor) -> {
		PVector c1 = new PVector(0.2, 0.4, 0.54);
		c1.mult(255.0);
		PVector c2 = new PVector(0.96, .68, 0.18);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
	};
	
	ArcaneHue ember = (thetafactor) -> {
		PVector c1 = new PVector(0.18, 0.28, 0.35);
		c1.mult(255.0);
		PVector c2 = new PVector(0.95, .39, 0.1);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
	};
	
	ArcaneHue bloodred = (thetafactor) -> {
		PVector c1 = new PVector(0.34, 0.0, 0.0);
		c1.mult(255.0);
		PVector c2 = new PVector(0.99, 1.0, 1.0);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
	};
	
	ArcaneHue gundam = (thetafactor) -> {
		PVector c1 = new PVector(0.12, 0.2, 0.19);
		c1.mult(255.0);
		PVector c2 = new PVector(0.86, 0.3, 0.25);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
	};
	
	ArcaneHue moonlight = (thetafactor) -> {
		PVector c1 = new PVector(0.10588235, 0.10588235, 0.11764706);
		c1.mult(255.0);
		PVector c2 = new PVector(1.0, 0.6627451, 0.08627451);
		c2.mult(255.0);

		c1.lerp(c2, thetafactor);
		return color(c1.x, c1.y, c1.z);
	};

	ArcaneTheme(String selectedTheme) {
		theme = selectedTheme;
		// energyMode = selectedEnergyMode;
		// alpha = selectedAlphaMode;

		setTheme(theme);

	}

	void setTheme(String th) { 
		switch(th) {
			case "red":
				ahue = red;
				break;
			case "blue":
				ahue = blue;
				break;
			case "green":
				ahue = green;
				break;
			case "yellow":
				ahue = yellow;
				break;
			case "yellowbrick":
				ahue = yellowbrick;
				break;
			case "rblue":
				ahue = rblue;
				break;
			case "gred":
				ahue = gred;
				break;
			case "reen":
				ahue = reen;
				break;
			case "starrynight":
				ahue = starrynight;
				break;
			case "ember":
				ahue = ember;
				break;
			case "bloodred":
				ahue = bloodred;
				break;
			case "gundam":
				ahue = gundam;
				break;
			case "moonlight":
				ahue = moonlight;
				break;
			default:
				ahue = white;
				break;
		}
	}

	float getEnergy(color c){
		float apx = c >> 24 & 0xFF;
		float rpx = c >> 16 & 0xFF;
		float gpx = c >> 8  & 0xFF;
		float bpx = c       & 0xFF;

		return energy = (rpx + gpx + bpx + apx) * D4;
	}

	void pushEnergyAngle(color c) {
		energy = getEnergy(c);
		angle = lerp(-TAU, TAU, energy);
	}

	void pushEnergyAngle(float e) {
		energy = e;
		angle = lerp(-TAU, TAU, e);
		// angle = lerp(-QTAU, QTAU, e) * 4.0;
	}
	
	color hue() {
		// float tf = angle * DTAU;
		//^ -1 ~ 1
		// float tf = (angle * DTAU) + 1.0;
		//^ 0 ~ 2
		float tf = ((angle * DTAU) + 1.0) * 0.5;
		//^ 0 ~ 1
		return ahue.archue(tf);
	}

}