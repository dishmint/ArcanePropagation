import java.util.function.*;
@FunctionalInterface
public interface ArcaneHue {
	color archue(float thetafactor);
    }


class ArcaneOrbit {
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
		float g = 255.0 - abs(lerp(-255.0, 255.0, thetafactor));
		// float b = 255.0 - abs(lerp(-200.0, 200.0, thetafactor));
		float b = (1.0 - (abs(lerp(-1.0, 1.0, thetafactor))*(200.0 * CFAC))) * 255.0;

		return color(r, g, b);
	};
	
	// ArcaneHue gred = (thetafactor) -> {
	// 	mix(vec3(1., .16, 0.22), vec3(0.07, .42, 0.1), thetafactor);
	// }
	
	// ArcaneHue starrynight = (thetafactor) -> {
	// 	mix(vec3(0.2, 0.4, 0.54), vec3(0.96, .68, 0.18), thetafactor);
	// }
	
	// ArcaneHue ember = (thetafactor) -> {
	// 	mix(vec3(0.18, 0.28, 0.35), vec3(0.95, .39, 0.1), thetafactor);
	// }
	
	// ArcaneHue bloodred = (thetafactor) -> {
	// 	mix(vec3(0.34, 0.0, 0.0), vec3(0.99, 1.0, 1.0), thetafactor);
	// }
	
	// ArcaneHue gundam = (thetafactor) -> {
	// 	mix(vec3(0.12, 0.2, 0.19), vec3(0.86, 0.3, 0.25), thetafactor);
	// }

	ArcaneOrbit(String selectedTheme) {
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

	// void getQTau(color c){
	// 	float e = getEnergy(c);
	// 	float theta = lerp(-QTAU, QTAU, e);
	// 	theta *= 4.0;
	// 	// theta *= DTAU;
	// 	return theta;
	// }

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
		float tf = angle * DTAU;
		// float tf = angle/TAU;
		// float tf = abs(angle/TAU);
		// float tf = map(angle/TAU, -1.0, 1.0, 0.0, 1.0);
		return ahue.archue(tf);
	}

}