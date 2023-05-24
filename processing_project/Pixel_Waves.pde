// General
final int SCALE = 10;
int previousTime;

// Beach
PImage beachImg;
Beach beach;
Beach offsetBeach;

// Wave Arrays
ArrayList<Wave> waves = new ArrayList<Wave>();
ArrayList<Wave> circularWaves = new ArrayList<Wave>();

// Random Waves
WaveType randomWave;


// Swell Waves
WaveType swellWave;

// Wind
final float WIND_THRESHOLD = 5;
float windAngle = 0;

// Obstacle
PImage stoneImg;
Obstacle stone;
PVector stonePos;
WaveType collisionWave;

void setup() {
  size(800, 800);
  noSmooth(); // Disable anti-aliasing
  imageMode(CENTER);
  beach = new Beach(5.0f, 0.1f, 0.0f, 7.0f, 35.0f);
  offsetBeach = new Beach(5.0f, 0.1f, 10.0f, 4.0f, 0.0f);
  randomWave = new WaveType(5, 8, 0.15f, 0.25f, 2.0f, 3.0f, 0.2f, 0.3f, 0.4f, 0.05f);
  swellWave = new WaveType(5, 15, 0.2f, 0.2f, 4.0f, 20.0f, 1.0f, 1.2f, 0.4f, 0.05f);
  stoneImg = loadImage("Stone.png");
  stonePos = new PVector(60, 30);
  stone = new Obstacle(stonePos, stoneImg, new PVector(stoneImg.width, stoneImg.height / 2));
  collisionWave = new WaveType(0, 0, 0.0f, 0.0f, 0.4f, 0.7, 0.6f, 1.0f, 0.3f, 0.3f);
}

void draw() {
  background(50, 150, 255);
  scale(SCALE);

  PImage oceanImg = loadImage("Ocean.png");
  image(oceanImg, oceanImg.width/2, height/SCALE - oceanImg.height/2);
  CreateBeachImage();
  image(beachImg, width / 2 / SCALE, beachImg.height / 2);

  PVector center = new PVector(width / 2 / SCALE, height / 2 / SCALE);
  PVector windDirection = new PVector(0, sqrt(height * height + width * width) / 2 / SCALE);
  windDirection.rotate(radians(-windAngle));
  PVector offsetWindDirection = windDirection.copy().rotate(radians(90));
  offsetWindDirection.setMag(width / SCALE / 3);

  if (swellWave.currentSpawnFrequency > 0) {
    swellWave.currentSpawnFrequency = swellWave.currentSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    PVector spawnPos = center.copy().add(windDirection);
    for (int i = -1; i <= 1; i++) {
      createNewWave(swellWave, spawnPos.copy().add(offsetWindDirection.copy().mult((float)i + random(-0.3f, 0.3f))));
    }
    swellWave.currentSpawnFrequency = random(swellWave.SPAWNFREQUENCY_MIN, swellWave.SPAWNFREQUENCY_MAX);
  }

  if (randomWave.currentSpawnFrequency > 0) {
    randomWave.currentSpawnFrequency = randomWave.currentSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    PVector randomSpawnPos = new PVector();
    randomSpawnPos.x = random(-0.5f, width / SCALE + 0.5f);
    randomSpawnPos.y = random(20, height / SCALE + 0.5f);
    createNewWave(randomWave, randomSpawnPos);
    randomWave.currentSpawnFrequency = random(randomWave.SPAWNFREQUENCY_MIN, randomWave.SPAWNFREQUENCY_MAX);
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

void createNewWave(WaveType _waveType, PVector _spawnPos) {
  // Add new Wave
  Wave newWave = new Wave(_waveType);
  waves.add(newWave);

  // Set Values
  newWave.setDimensions(_waveType.WIDTH_MIN, _waveType.WIDTH_MAX);
  newWave.Angle = (int)random(windAngle - WIND_THRESHOLD, windAngle + WIND_THRESHOLD);
  newWave.setStartVelocity(random(_waveType.VELOCITY_MIN, _waveType.VELOCITY_MAX));
  newWave.Velocity = newWave.getStartVelocity();
  newWave.setLifespan(_waveType.LIFESPAN_MIN, _waveType.LIFESPAN_MAX);
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

  PVector waveStoneDiff = wave.Position.copy().sub(stone.getPosition());
  waveStoneDiff.rotate(radians(wave.Angle));
  if (waveStoneDiff.y - wave.Height < 0 && abs(waveStoneDiff.x) < wave.Width / 3.0f) {
    if (abs(waveStoneDiff.x) < stone.bounds.x / 2) {
      lifetime = wave.Lifetime = 0;
    }
    if (!wave.collidedWithStone) {
      createNewCircularWave(wave);
      wave.collidedWithStone = true;
    }
  }

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
    wave.Width = wave.Width + wave.waveType.SPREAD;
  }
}

void createNewCircularWave(Wave _wave) {
  // Add new Wave
  Wave newWave = new Wave(collisionWave);
  circularWaves.add(newWave);

  // Set Values
  newWave.Width = (int)stone.getHitbox().x;
  newWave.Height = (int)stone.getHitbox().x;
  newWave.setStartVelocity(_wave.Velocity);
  newWave.Velocity = newWave.getStartVelocity();
  newWave.setLifespan(collisionWave.LIFESPAN_MIN, collisionWave.LIFESPAN_MAX);
  newWave.initializePosition(stone.getPosition().x, stone.getPosition().y);
  newWave.Angle = _wave.Angle;
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
        float angleDiff = abs(pixelAngle - wave.Angle);
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
    wave.Height = wave.Width = wave.Width + collisionWave.SPREAD;
    wave.Lifetime = currentLifespan - (millis() - previousTime) / 1000.0f;
  }
}
