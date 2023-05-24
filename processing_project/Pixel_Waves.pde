// General
final int SCALE = 10;
int previousTime;

// Beach
PImage beachImg;
Beach beach;
Beach offsetBeach;

// Waves
ArrayList<Wave> waves = new ArrayList<Wave>();
ArrayList<Wave> circularWaves = new ArrayList<Wave>();
final int WIDTH_MAX = 20;
final int WIDTH_MIN = 5;
final float VELOCITY_MAX = 0.25f;
final float VELOCITY_MIN = 0.15f;
final float LIFESPAN_MAX = 5.0f;
final float LIFESPAN_MIN = 3.0f;
final float WAVE_SPAWNFREQUENCY_MAX = 0.3f;
final float WAVE_SPAWNFREQUENCY_MIN = 0.2f;
final float WAVE_SPAWN_THRESHOLD = 5.0f;
float currentWaveSpawnFrequency = 0.1f;

// Wind
final float WIND_THRESHOLD = 5;
float windAngle = 0;

// Obstacle
PImage stoneImg;
Obstacle stone;
PVector stonePos;
final float STONEWAVE_LIFESPAN_MAX = 0.7f;
final float STONEWAVE_LIFESPAN_MIN = 0.4f;
final float STONEWAVE_SPAWNFREQUENCY_MAX = 1.0f;
final float STONEWAVE_SPAWNFREQUENCY_MIN = 0.6f;
final float STONEWAVE_SPREAD = 0.3f;
float currentStonewaveSpawnFrequency = 0.3f;

void setup() {
  size(800, 800);
  noSmooth(); // Disable anti-aliasing
  imageMode(CENTER);
  beach = new Beach(5.0f, 0.1f, 0.0f, 7.0f, 35.0f);
  offsetBeach = new Beach(5.0f, 0.1f, 10.0f, 4.0f, 0.0f);
  stoneImg = loadImage("Stone.png");
  stonePos = new PVector(60, 30);
  stone = new Obstacle(stonePos, stoneImg, new PVector(stoneImg.width, stoneImg.height / 2));
}

void draw() {
  background(50, 150, 255);
  scale(SCALE);

  PImage oceanImg = loadImage("Ocean.png");
  image(oceanImg, oceanImg.width/2, height/SCALE - oceanImg.height/2);
  CreateBeachImage();
  image(beachImg, width / 2 / SCALE, beachImg.height / 2);

  if (currentWaveSpawnFrequency > 0) {
    currentWaveSpawnFrequency = currentWaveSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    PVector randomSpawnPos = new PVector();
    randomSpawnPos.x = random(-WAVE_SPAWN_THRESHOLD, width / SCALE + WAVE_SPAWN_THRESHOLD);
    randomSpawnPos.y = random(20, height / SCALE + WAVE_SPAWN_THRESHOLD);
    createNewWave(randomSpawnPos, LIFESPAN_MIN, LIFESPAN_MAX);
    currentWaveSpawnFrequency = random(WAVE_SPAWNFREQUENCY_MIN, WAVE_SPAWNFREQUENCY_MAX);
  }

  if (currentStonewaveSpawnFrequency > 0) {
    currentStonewaveSpawnFrequency = currentStonewaveSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    createNewCircularWave();
    currentStonewaveSpawnFrequency = random(STONEWAVE_SPAWNFREQUENCY_MIN, STONEWAVE_SPAWNFREQUENCY_MAX);
  }

  updateWaves();
  updateCircularWaves();

  image(stoneImg, stonePos.x, stonePos.y);

  PImage arrowImg = loadImage("Arrow.png");
  translate(2 + arrowImg.width/2, height/SCALE - 2 - arrowImg.height/2);
  rotate(-radians(windAngle));
  image(arrowImg, 0, 0);

  previousTime = millis();
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
  PImage gradientImg = createImage(beachWidth, beachHeight, ARGB);

  for (int x = 0; x <= gradientImg.height; x++) {
    int yPixel = (int)beach.GetY(x);
    float gradientHeight = (int)offsetBeach.GetY(x);
    for (int y = 0; y <= yPixel; y++) {
      gradientImg.set(x, y, color(244, 220, 180, 255));
    }
    for (int y = 0; y < gradientHeight; y++) {
      int discreteHeight = (int)(gradientHeight / (gradientHeight - y)) + 1;
      gradientImg.set(x, yPixel + y, color(244, 220, 180, 255 / discreteHeight));
    }
  }

  beachImg = gradientImg;
}

void createNewWave(PVector _spawnPos, float _lifespanMin, float _lifespanMax) {
  // Add new Wave
  Wave newWave = new Wave();
  waves.add(newWave);

  // Set Values
  newWave.setDimensions(WIDTH_MIN, WIDTH_MAX);
  newWave.Angle = (int)random(windAngle - WIND_THRESHOLD, windAngle + WIND_THRESHOLD);
  newWave.setStartVelocity(random(VELOCITY_MIN, VELOCITY_MAX));
  newWave.Velocity = newWave.getStartVelocity();
  newWave.setLifespan(_lifespanMin, _lifespanMax);
  newWave.initializePosition(_spawnPos.x, _spawnPos.y);
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
  float lifetime = wave.Lifetime;
  int w = (int)wave.Width;
  int h = (int)wave.Height;
  PImage waveImg = createImage(w, w, ARGB);
  float beachY = beach.GetY((int)wave.Position.x) + h / 2;

  if (lifetime <= 0 || wave.Position.y <= beachY) {
    waves.remove(_index);
  } else {
    float beachAngle = degrees(atan(beach.GetDerivationY((int)wave.Position.x)));
    float lerpProgress = 1 - ((wave.Position.y - beach.verticalOffset) / (beach.hitbox - beach.verticalOffset));
    if (lerpProgress < 0)
      lerpProgress = 0;
    wave.Angle = lerp(wave.getStartWindAngle(), -beachAngle, lerpProgress);

    float velocityLerpProgress;
    if (wave.Position.y > beachY + 1) {
      velocityLerpProgress = 1 - ((wave.Position.y - (beachY + 1)) / (beachY + 1));
      if (velocityLerpProgress < 0)
        velocityLerpProgress = 0;
      wave.Velocity = lerp(wave.getStartVelocity(), (wave.getStartVelocity() / 3.0f), velocityLerpProgress);
      wave.Lifetime = lifetime - (millis() - previousTime) / 1000.0f;
    } else {
      velocityLerpProgress = 1 - ((wave.Position.y - beachY) / beachY);
      if (velocityLerpProgress < 0)
        velocityLerpProgress = 0;
      wave.Velocity = lerp(wave.getStartVelocity() / 3.0f, -(wave.getStartVelocity()), velocityLerpProgress);
      wave.Lifetime = lerp(wave.Lifetime, 0, velocityLerpProgress);
    }


    for (int x = 0; x < w; x++) {
      for (int y = 0; y < w; y++) {
        PVector radius = new PVector(x - w / 2.0f, y - w / 2.0f);

        if (wave.Position.y <= beach.hitbox) {
          radius.rotate(radians(wave.Angle));
        } else
          radius.rotate(radians(wave.getStartWindAngle()));

        float absDistance = dist(0, 0, radius.x / (w / 2.0f), radius.y / (h / 2.0f)); // Distance of pixel to center

        // Calculate alpha according to distance to middle, bottom and lifespan
        float alpha = 255 * absDistance;
        alpha *= -radius.y / h * 2.0f;

        // Calculate alpha accoring to lifetime and poximity to beach
        float normalizedLifespan = wave.getLifespan() - lifetime;
        float beachAlpha = (wave.Position.y - beach.GetY((int)wave.Position.x) + 1) / (beach.hitbox - beach.GetY((int)wave.Position.x + 1));
        float lifetimeAlpha;
        if (normalizedLifespan <= wave.getLifespan() / 2.0f) {
          lifetimeAlpha = 2.0f * normalizedLifespan / wave.getLifespan();
        } else {
          lifetimeAlpha = 2.0f - (2.0f * normalizedLifespan / wave.getLifespan());
        }
        alpha *= lerp(lifetimeAlpha, beachAlpha, lerpProgress);

        if (absDistance < 1) {
          waveImg.set(x, y, color(255, 255, 255, alpha));
        } else {
          waveImg.set(x, y, color(0, 0, 0, 0));
        }
      }
    }

    wave.Position.x -= wave.Velocity * sin(radians(wave.Angle));
    wave.Position.y -= wave.Velocity * cos(radians(wave.Angle));
    image(waveImg, wave.Position.x, wave.Position.y);
    wave.Image = waveImg;
    wave.Width = wave.Width + 0.05f;
  }
}

void createNewCircularWave() {
  // Add new Wave
  Wave newWave = new Wave();
  circularWaves.add(newWave);

  // Set Values
  newWave.Width = (int)stone.getHitbox().x;
  newWave.Height = (int)stone.getHitbox().x;
  newWave.setStartVelocity(random(VELOCITY_MIN, VELOCITY_MAX));
  newWave.Velocity = newWave.getStartVelocity();
  newWave.setLifespan(STONEWAVE_LIFESPAN_MIN, STONEWAVE_LIFESPAN_MAX);
  newWave.initializePosition(stone.getPosition().x, stone.getPosition().y);
  updateCircularWaveImage(circularWaves.size() - 1);
}

void updateCircularWaves() {
  for (int i = circularWaves.size() - 1; i >= 0; i--) {
    updateCircularWaveImage(i);
  }
}

void updateCircularWaveImage(int _index) {
  Wave wave = circularWaves.get(_index);
  float currentLifespan = wave.Lifetime;
  int pixelW = (int)wave.Width;
  if (pixelW % 2 == 1)
    pixelW += 1;
  PImage waveImg = createImage(pixelW, pixelW, ARGB);
  wave.Angle = windAngle;

  if (currentLifespan <= 0) {
    circularWaves.remove(_index);
  } else {
    for (int x = 0; x < pixelW; x++) {
      for (int y = 0; y < pixelW; y++) {
        PVector radius = new PVector(x - pixelW / 2.0f, y - pixelW / 2.0f);
        float absDistance = dist(0, 0, radius.x / (pixelW / 2.0f), radius.y / (pixelW / 2.0f)); // Distance of pixel to center

        float alpha;
        float innerBorder = 0.2f;
        float outerBorder = 0.9f;
        if (absDistance > 1 || absDistance <= innerBorder)
          alpha = 0;
        else if (absDistance <= outerBorder)
          // Calculate alpha according to distance to middle, bottom and lifespan
          alpha = 255 * ((absDistance - innerBorder) / (outerBorder - innerBorder));
        else
          alpha = 255 * (1 - ((absDistance - outerBorder) / (1 - outerBorder)));

        // Calculate alpha according to angle
        PVector pixelSlope = new PVector(x - pixelW / 2.0f, y - pixelW / 2.0f);
        float pixelAngle = -degrees(atan2(pixelSlope.y, pixelSlope.x)) + 90;
        float angleDiff = abs(pixelAngle - windAngle);
        if (angleDiff > 360)
          angleDiff -= 360;
        if (angleDiff > 180)
          angleDiff = 360 - angleDiff;
        float waveAngleWidth = 80;
        if (angleDiff > waveAngleWidth)
          alpha = 0;
        else
          alpha *= (1 - angleDiff / waveAngleWidth);

        // Calculate alpha accoring to lifetime
        alpha *= currentLifespan / wave.getLifespan();

        if (absDistance < 1) {
          waveImg.set(x, y, color(255, 255, 255, alpha));
        } else {
          waveImg.set(x, y, color(0, 0, 0, 0));
        }
      }
    }

    //    wave.Position.x -= wave.Velocity * sin(radians(wave.CurrentAngle)) / 5.0f;
    //    wave.Position.y -= wave.Velocity * cos(radians(wave.CurrentAngle)) / 5.0f;
    image(waveImg, wave.Position.x, wave.Position.y);
    wave.Image = waveImg;
    wave.Height = wave.Width = wave.Width + STONEWAVE_SPREAD;
    wave.Lifetime = currentLifespan - (millis() - previousTime) / 1000.0f;
  }
}
