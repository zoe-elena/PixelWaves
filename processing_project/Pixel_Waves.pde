int previousTime;
float friction = 0.003f;

// Wave Particle Attributes
final int SCALE = 10;
final int BEACH_SCALE = 2;
final int RANDOM_WIDTH_MAX = 30;
final int RANDOM_WIDTH_MIN = 15;
final float RANDOM_VELOCITY_MAX = 1.5f;
final float RANDOM_VELOCITY_MIN = 1.0f;
final float RANDOM_LIFESPAN_MAX = 5;
final float RANDOM_LIFESPAN_MIN = 2;

ArrayList<Wave> waves = new ArrayList<Wave>();

PImage beach;

void setup() {
  size(800, 800);
  noSmooth(); // Disable anti-aliasing
  CreateBeachImage();
}

void draw() {
  background(50, 150, 255);
  scale(SCALE);
  updateWaves();
  scale(BEACH_SCALE);
  image(beach, 0, 0);
  previousTime = millis();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    createNewWave();
  }
}

void CreateBeachImage() {
  int beachWidth = width/(SCALE+BEACH_SCALE)+1;
  int beachHeight = 30;
  PImage gradientImage = createImage(beachWidth, beachHeight, ARGB);
  int alphaStart = 255;
  int alphaEnd = 0;

  for (int y = 0; y <= gradientImage.height; y++) {
    float t = map(y, 0, gradientImage.height, 0, 1); // Interpolationswert für den Gradienten in Reihe y
    int blendedColor = lerpColor(color(244, 164, 96, alphaStart), color(244, 164, 96, alphaEnd), t);
    for (int x = 0; x <= gradientImage.width; x++) {
      gradientImage.set(x, y, blendedColor);
    }
  }

  beach = gradientImage;
}

void createNewWave() {
  // Add new Wave
  Wave newWave = new Wave();
  waves.add(newWave);

  // Set Values
  newWave.setDimensions(RANDOM_WIDTH_MIN, RANDOM_WIDTH_MAX);
  newWave.currentAngle = (int)random(-20, 20);
  newWave.velocity = random(RANDOM_VELOCITY_MIN, RANDOM_VELOCITY_MAX);
  newWave.setLifespan(RANDOM_LIFESPAN_MIN, RANDOM_LIFESPAN_MAX);
  newWave.initializePosition(mouseX, mouseY);
  updateWaveImage(waves.size()-1);
}

void updateWaves() {
  for (int i = waves.size() - 1; i >= 0; i--) {
    updateWaveImage(i);
  }
}

void updateWaveImage(int _index) {
  Wave wave = waves.get(_index);
  float currentLifespan = wave.currentLifespan;
  int w = wave.getWidth();
  int h = wave.getHeight();
  PImage image = createImage(w, w, ARGB);

  if (currentLifespan <= 0 || wave.position.y <= 0 - wave.getHeight() * SCALE) {
    waves.remove(_index);
  } else {
    for (int y = 0; y < w; y++) {
      for (int x = 0; x < w; x++) {
        PVector distance = new PVector(x - w / 2.0f, y - w / 2.0f);
        distance.rotate(radians(wave.currentAngle));
        float absDistance = dist(0, 0, distance.x / (w / 2.0f), distance.y / (h / 2.0f)); // Distance of pixel to center

        // Calculate alpha according to distance to middle, bottom and lifespan
        float alpha = 255 * absDistance;
        alpha *= -distance.y / h * 2.0f;
        alpha *= currentLifespan / wave.getLifespan();

        if (absDistance < 1) {
          image.set(x, y, color(255, 255, 255, alpha));
        } else {
          image.set(x, y, color(0, 0, 0, 0));
        }
      }
    }

    wave.currentImage = image;
    image(image, wave.position.x / SCALE, wave.position.y / SCALE);
    wave.position.x -= wave.velocity * sin(radians(wave.currentAngle));
    wave.position.y -= wave.velocity * cos(radians(wave.currentAngle));
    if (wave.velocity > friction) {
      wave.velocity -= friction;
    }
    wave.currentLifespan = currentLifespan - (millis() - previousTime) / 1000.0f;
  }

  wave.setSourceImage(image);
}
