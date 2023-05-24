ArrayList<Wave> waves = new ArrayList<Wave>();
PImage beach;
int previousTime;
float waveSpawnFrequency = 0.1f;

// Wave Particle Attributes
final int SCALE = 10;
final int RANDOM_WIDTH_MAX = 30;
final int RANDOM_WIDTH_MIN = 5;
final float RANDOM_VELOCITY_MAX = 0.3f;
final float RANDOM_VELOCITY_MIN = 0.3f;
final float RANDOM_LIFESPAN_MAX = 3;
final float RANDOM_LIFESPAN_MIN = 2;
final float WIND_ANGLE = 20;
final float WIND_THRESHOLD = 5;

void setup() {
  size(800, 800);
  noSmooth(); // Disable anti-aliasing
  imageMode(CENTER);
  CreateBeachImage();
}

void draw() {
  background(50, 150, 255);
  scale(SCALE);
  if (waveSpawnFrequency > 0) {
    waveSpawnFrequency = waveSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    createNewWave(random(-5, width / SCALE + 5), random(height / SCALE - 5, height / SCALE + 5));
    waveSpawnFrequency = random(0.1f, 0.5f);
  }

  image(beach, width / 2 / SCALE, beach.height / 2);
  updateWaves();
  previousTime = millis();

  PImage arrow = loadImage("Arrow.png");
  translate(2 + arrow.width/2, height/SCALE - 2 - arrow.height/2);
  rotate(-radians(WIND_ANGLE));
  image(arrow, 0, 0);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    createNewWave(mouseX / SCALE, mouseY / SCALE);
  }
}

void CreateBeachImage() {
  int beachWidth = width / SCALE;
  int beachHeight = height / SCALE;
  PImage gradientImage = createImage(beachWidth, beachHeight, ARGB);
  float frequency = 0.1f;
  float amplitude = 3f;
  float verticalOffset = 7;
  float horizontalOffset = 0;
  for (int x = 0; x <= gradientImage.height; x++) {
    int yPixel = (int)(verticalOffset + amplitude * sin((x + horizontalOffset) * frequency));
    float gradientHeight = (int)(10 + 3 * sin((x + 10) * frequency));
    for (int y = 0; y <= yPixel; y++) {
      gradientImage.set(x, y, color(244, 200, 96, 255));
    }
    for (int y = 0; y < gradientHeight; y++) {
      int discreteHeight = (int)(gradientHeight / (gradientHeight - y)) + 1;
      gradientImage.set(x, yPixel + y, color(244, 200, 96, 255 / discreteHeight));
    }
  }

  beach = gradientImage;
}

void createNewWave(float _xPos, float _yPos) {
  // Add new Wave
  Wave newWave = new Wave();
  waves.add(newWave);

  // Set Values
  newWave.setDimensions(RANDOM_WIDTH_MIN, RANDOM_WIDTH_MAX);
  newWave.CurrentAngle = (int)random(WIND_ANGLE - WIND_THRESHOLD, WIND_ANGLE + WIND_THRESHOLD);
  newWave.Velocity = random(RANDOM_VELOCITY_MIN, RANDOM_VELOCITY_MAX);
  newWave.setLifespan(RANDOM_LIFESPAN_MIN, RANDOM_LIFESPAN_MAX);
  newWave.initializePosition(_xPos, _yPos);
  updateWaveImage(waves.size() - 1);
}

void updateWaves() {
  for (int i = waves.size() - 1; i >= 0; i--) {
    Wave wave = waves.get(i);
    wave.setWidth(wave.getWidth() + 0.05f);
    updateWaveImage(i);
  }
}

void updateWaveImage(int _index) {
  Wave wave = waves.get(_index);
  float currentLifespan = wave.CurrentLifespan;
  int w = (int)wave.getWidth();
  int h = (int)wave.getHeight();
  PImage image = createImage(w, w, ARGB);

  if (currentLifespan <= 0 || wave.Position.y <= 0 - wave.getHeight() * SCALE) {
    waves.remove(_index);
  } else {
    for (int y = 0; y < w; y++) {
      for (int x = 0; x < w; x++) {
        PVector distance = new PVector(x - w / 2.0f, y - w / 2.0f);
        distance.rotate(radians(wave.CurrentAngle));
        float absDistance = dist(0, 0, distance.x / (w / 2.0f), distance.y / (h / 2.0f)); // Distance of pixel to center

        // Calculate alpha according to distance to middle, bottom and lifespan
        float alpha = 255 * absDistance;
        alpha *= -distance.y / h * 2.0f;

        if (currentLifespan > wave.getLifespan() / 2)
          alpha *= (wave.getLifespan() - currentLifespan) / wave.getLifespan();
        else
          alpha *= currentLifespan / wave.getLifespan();

        if (absDistance < 1) {
          image.set(x, y, color(255, 255, 255, alpha));
        } else {
          image.set(x, y, color(0, 0, 0, 0));
        }
      }
    }

    wave.CurrentImage = image;
    wave.Position.x -= wave.Velocity * sin(radians(wave.CurrentAngle));
    wave.Position.y -= wave.Velocity * cos(radians(wave.CurrentAngle));
    image(image, wave.Position.x, wave.Position.y);
    wave.CurrentImage = image;

    wave.CurrentLifespan = currentLifespan - (millis() - previousTime) / 1000.0f;
  }
}
