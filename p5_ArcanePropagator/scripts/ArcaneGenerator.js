class ArcaneGenerator {
    constructor(generator, w, h) {
      this.w = w;
      this.h = h;
  
      this.randomImage = () => {
        let rimg = createImage(this.w, this.h);
        rimg.loadPixels();
        for (let i = 0; i < rimg.width; i++) {
          for (let j = 0; j < rimg.height; j++) {
            let c = color(random(255));
            let index = (i + j * rimg.width);
            rimg.set(i, j, c);
          }
        }
        rimg.updatePixels();
        return rimg;
      };
  
      this.noiseImage = (lod, falloff) => {
        noiseDetail(lod, falloff);
        let rimg = createImage(this.w, this.h);
        rimg.loadPixels();
        for (let i = 0; i < rimg.width; i++) {
          for (let j = 0; j < rimg.height; j++) {
            let c = color(lerp(0, 1, noise(i * cos(i), j * sin(j), (i + j) / 2)) * 255);
            let index = (i + j * rimg.width);
            rimg.set(i, j, c);
          }
        }
        rimg.updatePixels();
        return rimg;
      };
  
      this.kuficImage = () => {
        let chance;
        let rimg = createImage(this.w, this.h);
        rimg.loadPixels();
        for (let i = 0; i < rimg.width; i++) {
          for (let j = 0; j < rimg.height; j++) {
            chance = ((i % 2) + (j % 2));
  
            let wallornot = random(2);
            let index = (i + j * rimg.width);
            if (wallornot <= chance) {
              let c = color(0);
              rimg.set(i, j, c);
            } else {
              let c = color(255 - (255 * (wallornot / 2)));
              rimg.set(i, j, c);
            }
          }
        }
        rimg.updatePixels();
        return rimg;
      };
  
      switch (generator) {
        case "random":
          this.arcimg = this.randomImage;
          break;
        case "noise":
          this.arcimg = () => this.noiseImage(2, 0.5);
          break;
        case "kufic":
          this.arcimg = this.kuficImage;
          break;
        default:
          this.arcimg = this.randomImage;
          break;
      }
    }
  
    getImage() {
      return this.arcimg();
    }
  }
  