// General
final int SCALE = 10;
int previousTime;

// Beach
PImage beachImg;
Beach beach;
Beach offsetBeach;

// Waves
ArrayList<Wave> waves = new ArrayList<Wave>();
final int WIDTH_MAX = 20;
final int WIDTH_MIN = 5;
final float VELOCITY_MAX = 0.3f;
final float VELOCITY_MIN = 0.2f;
final float LIFESPAN_MAX = 5;
final float LIFESPAN_MIN = 3;
final float SPAWNFREQUENCY_MAX = 0.2f;
final float SPAWNFREQUENCY_MIN = 0.1f;
final float SPAWN_THRESHOLD = 5;
float currentSpawnFrequency = 0.1f;

// Wind
final float WIND_THRESHOLD = 5;
float windAngle = -20;

void setup() {
  size(800, 800);
  noSmooth(); // Disable anti-aliasing
  imageMode(CENTER);
  beach = new Beach(3.0f, 0.1f, 0.0f, 7.0f, 35.0f);
  offsetBeach = new Beach(3.0f, 0.1f, 10.0f, 4.0f, 0.0f);
}

void draw() {
  background(50, 150, 255);
  scale(SCALE);

  PImage ocean = loadImage("Ocean.png");
  image(ocean, ocean.width/2, height/SCALE - ocean.height/2);
  CreateBeachImage();

  if (currentSpawnFrequency > 0) {
    currentSpawnFrequency = currentSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    createNewWave(random(-SPAWN_THRESHOLD, width / SCALE + SPAWN_THRESHOLD), random(beach.hitbox, height / SCALE + SPAWN_THRESHOLD));
    currentSpawnFrequency = random(SPAWNFREQUENCY_MIN, SPAWNFREQUENCY_MAX);
  }

  image(beachImg, width / 2 / SCALE, beachImg.height / 2);
  updateWaves();
  previousTime = millis();

  PImage arrow = loadImage("Arrow.png");
  translate(2 + arrow.width/2, height/SCALE - 2 - arrow.height/2);
  rotate(-radians(windAngle));
  image(arrow, 0, 0);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    AngleWindToMouse();
  }
}

void AngleWindToMouse() {
  PVector p = new PVector(0, -height);
  PVector q = new PVector(mouseX - width/2, mouseY - height);
  if (mouseX > 0)
    windAngle = degrees(atan2(p.y, p.x) - atan2(q.y, q.x));
}

void CreateBeachImage() {
  int beachWidth = width / SCALE;
  int beachHeight = height / SCALE;
  PImage gradientImage = createImage(beachWidth, beachHeight, ARGB);

  for (int x = 0; x <= gradientImage.height; x++) {
    int yPixel = (int)beach.GetY(x);
    float gradientHeight = (int)offsetBeach.GetY(x);
    for (int y = 0; y <= yPixel; y++) {
      gradientImage.set(x, y, color(244, 220, 180, 255));
    }
    for (int y = 0; y < gradientHeight; y++) {
      int discreteHeight = (int)(gradientHeight / (gradientHeight - y)) + 1;
      gradientImage.set(x, yPixel + y, color(244, 220, 180, 255 / discreteHeight));
    }
  }

  beachImg = gradientImage;
}

void createNewWave(float _xPos, float _yPos) {
  // Add new Wave
  Wave newWave = new Wave();
  waves.add(newWave);

  // Set Values
  newWave.setDimensions(WIDTH_MIN, WIDTH_MAX);
  newWave.CurrentAngle = (int)random(windAngle - WIND_THRESHOLD, windAngle + WIND_THRESHOLD);
  newWave.Velocity = random(VELOCITY_MIN, VELOCITY_MAX);
  newWave.setLifespan(LIFESPAN_MIN, LIFESPAN_MAX);
  newWave.initializePosition(_xPos, _yPos);
  newWave.setStartWindAngle(windAngle);
  updateWaveImage(waves.size() - 1);
}

void updateWaves() {
  for (int i = waves.size() - 1; i >= 0; i--) {
    updateWaveImage(i);
  }
}

void updateWaveImage(int _index) {
  Wave wave = waves.get(_index);
  float currentLifespan = wave.CurrentLifespan;
  int w = (int)wave.getWidth();
  int h = (int)wave.getHeight();
  PImage image = createImage(w, w, ARGB);
  float beachY = beach.GetY((int)wave.Position.x) + h / 2;

  if (currentLifespan <= 0 || wave.Position.y <= beachY) {
    waves.remove(_index);
  } else {
    float beachAngle = degrees(atan(beach.GetDerivationY((int)wave.Position.x)));
    float lerpProgress = 1 - ((wave.Position.y - beach.verticalOffset) / (beach.hitbox - beach.verticalOffset));
    if (lerpProgress < 0)
      lerpProgress = 0;
    wave.CurrentAngle = lerp(wave.getStartWindAngle(), -beachAngle, lerpProgress);

    for (int x = 0; x < w; x++) {
      for (int y = 0; y < w; y++) {
        PVector distance = new PVector(x - w / 2.0f, y - w / 2.0f);

        if (wave.Position.y <= beach.hitbox) {
          distance.rotate(radians(wave.CurrentAngle));
        } else
          distance.rotate(radians(wave.getStartWindAngle()));

        float absDistance = dist(0, 0, distance.x / (w / 2.0f), distance.y / (h / 2.0f)); // Distance of pixel to center

        // Calculate alpha according to distance to middle, bottom and lifespan
        float alpha = 255 * absDistance;
        alpha *= -distance.y / h * 2.0f;

        // Calculate alpha accoring to lifetime and poximity to beach
        float normalizedLifespan = wave.getLifespan() - currentLifespan;
        float beachAlpha = (wave.Position.y - beach.GetY((int)wave.Position.x) + 1) / (beach.hitbox - beach.GetY((int)wave.Position.x + 1));
        float lifetimeAlpha;
        if (normalizedLifespan <= wave.getLifespan() / 2.0f) {
          lifetimeAlpha = 2.0f * normalizedLifespan / wave.getLifespan();
        } else {
          lifetimeAlpha = 2.0f - (2.0f * normalizedLifespan / wave.getLifespan());
        }
        alpha *= lerp(lifetimeAlpha, beachAlpha, lerpProgress);

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
    wave.setWidth(wave.getWidth() + 0.05f);
    wave.CurrentLifespan = currentLifespan - (millis() - previousTime) / 1000.0f;
  }
}
