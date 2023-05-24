// General
final int SCALE = 10;
int previousTime;

// Beach
PImage beachImg;
Beach beach;
Beach offsetBeach;

// Wave Arrays
ArrayList<Wave> waves = new ArrayList<Wave>();
ArrayList<Wave> collisionWaves = new ArrayList<Wave>();

// Random Waves
WaveType randomWave;


// Swell Waves
WaveType swellWave;

// Wind
final float WIND_THRESHOLD = 5;
float windAngle = -10;

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
  offsetBeach = new Beach(3.0f, 0.1f, 10.0f, 7.0f, 0.0f);

  randomWave = new WaveType(5, 8, 0.15f, 0.25f, 2.0f, 3.0f, 0.2f, 0.3f, 0.4f, 0.05f);
  swellWave = new WaveType(5, 15, 0.2f, 0.2f, 4.0f, 20.0f, 1.0f, 1.2f, 0.4f, 0.05f);
  collisionWave = new WaveType(0, 0, 0.0f, 0.0f, 0.4f, 0.7, 0.6f, 1.0f, 0.3f, 0.3f);

  stoneImg = loadImage("Stone.png");
  stonePos = new PVector(60, 30);
  stone = new Obstacle(stonePos, stoneImg, new PVector(stoneImg.width, stoneImg.height / 2));
}

void draw() {
  background(50, 150, 255);
  scale(SCALE);

  DrawOcean();
  CheckForSwellWaveSpawn();
  CheckForRandomWaveSpawn();
  updateWaves();
  updateCollisionWaves();
  DrawObstacle();
  DrawWindSock();

  previousTime = millis();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    AngleWindToMouse();
  }
}

void DrawOcean() {
  PImage oceanImg = loadImage("Ocean.png");
  image(oceanImg, oceanImg.width/2, height/SCALE - oceanImg.height/2);
  CreateBeachImage();
  image(beachImg, width / 2 / SCALE, beachImg.height / 2);
}

void DrawObstacle() {
  image(stoneImg, stonePos.x, stonePos.y);
}

void DrawWindSock() {
  PImage arrowImg = loadImage("Arrow.png");
  translate(2 + arrowImg.width/2, height/SCALE - 2 - arrowImg.height/2);
  rotate(-radians(windAngle));
  image(arrowImg, 0, 0);
}

void CheckForSwellWaveSpawn() {
  if (swellWave.currentSpawnFrequency > 0) {
    swellWave.currentSpawnFrequency = swellWave.currentSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    SpawnSwellWave();
  }
}

void CheckForRandomWaveSpawn() {
  if (randomWave.currentSpawnFrequency > 0) {
    randomWave.currentSpawnFrequency = randomWave.currentSpawnFrequency - (millis() - previousTime) / 1000.0f;
  } else {
    SpawnRandomWave();
  }
}

void SpawnSwellWave() {
  PVector center = new PVector(width / 2 / SCALE, height / 2 / SCALE);
  PVector windDirection = new PVector(0, sqrt(height * height + width * width) / 2 / SCALE);
  windDirection.rotate(radians(-windAngle));
  PVector offsetWindDirection = windDirection.copy().rotate(radians(90));
  offsetWindDirection.setMag(width / SCALE / 3);
  PVector spawnPos = center.copy().add(windDirection);

  for (int i = -1; i <= 1; i++) {
    createNewWave(swellWave, spawnPos.copy().add(offsetWindDirection.copy().mult((float)i + random(-0.3f, 0.3f))));
  }

  swellWave.currentSpawnFrequency = random(swellWave.SPAWNFREQUENCY_MIN, swellWave.SPAWNFREQUENCY_MAX);
}

void SpawnRandomWave() {
  PVector randomSpawnPos = new PVector();
  randomSpawnPos.x = random(-0.5f, width / SCALE + 0.5f);
  randomSpawnPos.y = random(20, height / SCALE + 0.5f);
  createNewWave(randomWave, randomSpawnPos);
  randomWave.currentSpawnFrequency = random(randomWave.SPAWNFREQUENCY_MIN, randomWave.SPAWNFREQUENCY_MAX);
}

void AngleWindToMouse() {
  PVector p = new PVector(0, -height);
  PVector q = new PVector(mouseX - width/2, mouseY - height);
  if (mouseX > 0) {
    windAngle = degrees(atan2(p.y, p.x) - atan2(q.y, q.x));
  }
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
  newWave.setStartLifespan(_waveType.LIFESPAN_MIN, _waveType.LIFESPAN_MAX);
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
  float lifespan = wave.Lifespan;
  int w = (int)wave.Width;
  int h = (int)wave.Height;
  PImage waveImg = createImage(w, w, ARGB);
  float beachY = beach.GetY((int)wave.Position.x) + h / 2;

  lifespan = CheckForCollision(wave, lifespan);

  if (lifespan <= 0 || wave.Position.y <= beachY) {
    waves.remove(_index);
  } else {
    float lerpProgress = 1 - ((wave.Position.y - beach.verticalOffset) / (beach.hitbox - beach.verticalOffset));
    if (lerpProgress < 0) {
      lerpProgress = 0;
    }
    CalculateWaveAngle(wave, lerpProgress);
    CalculateVelocityAndLifespan(wave, beachY);

    for (int x = 0; x < w; x++) {
      for (int y = 0; y < w; y++) {
        PVector radius = new PVector(x - w / 2.0f, y - w / 2.0f);
        if (wave.Position.y <= beach.hitbox) {
          radius.rotate(radians(wave.Angle));
        } else {
          radius.rotate(radians(wave.getStartWindAngle()));
        }
        float absDistance = dist(0, 0, radius.x / (w / 2.0f), radius.y / (h / 2.0f)); // Distance of pixel to center
        float alpha = 255 * absDistance;
        alpha = CalculateBottomGradientAlpha(alpha, radius, h);
        alpha = CalculateLifespanAlpha(alpha, lerpProgress, wave);

        SetPixelAlpha(alpha, absDistance, waveImg, x, y);
      }
    }

    UpdatePosition(wave);
    wave.Image = waveImg;
    wave.Width = wave.Width + wave.waveType.SPREAD;

    image(waveImg, wave.Position.x, wave.Position.y);
  }
}

void CalculateWaveAngle(Wave _wave, float _lerpProgress) {
  float beachAngle = degrees(atan(beach.GetDerivationY((int)_wave.Position.x)));
  _wave.Angle = lerp(_wave.getStartWindAngle(), -beachAngle, _lerpProgress);
}

void CalculateVelocityAndLifespan(Wave _wave, float _beachY) {
  float velocityLerpProgress;
  if (_wave.Position.y > _beachY + 1) {
    velocityLerpProgress = 1 - ((_wave.Position.y - (_beachY + 1)) / (_beachY + 1));
    if (velocityLerpProgress < 0) {
      velocityLerpProgress = 0;
    }
    _wave.Velocity = lerp(_wave.getStartVelocity(), (_wave.getStartVelocity() / 3.0f), velocityLerpProgress);
    _wave.Lifespan = _wave.Lifespan - (millis() - previousTime) / 1000.0f;
  } else {
    velocityLerpProgress = 1 - ((_wave.Position.y - _beachY) / _beachY);
    if (velocityLerpProgress < 0) {
      velocityLerpProgress = 0;
    }
    _wave.Velocity = lerp(_wave.getStartVelocity() / 3.0f, -(_wave.getStartVelocity()), velocityLerpProgress);
    _wave.Lifespan = lerp(_wave.Lifespan, 0, velocityLerpProgress);
  }
}

float SetCenterGradientAlpha(float _dist, float _innerBorder, float _outerBorder) {
  float alpha;
  if (_dist > 1 || _dist <= _innerBorder) {
    alpha = 0;
  } else if (_dist <= _outerBorder) {
    // Calculate alpha according to distance to middle, bottom and lifespan
    alpha = 255 * ((_dist - _innerBorder) / (_outerBorder - _innerBorder));
  } else {
    alpha = 255 * (1 - ((_dist - _outerBorder) / (1 - _outerBorder)));
  }

  return alpha;
}

float CalculateBottomGradientAlpha(float _alpha, PVector _radius, int _h) {
  _alpha *= -_radius.y / _h * 2.0f;
  return _alpha;
}

float CheckForCollision(Wave _wave, float _lifetime) {
  PVector waveStoneDiff = _wave.Position.copy().sub(stone.getPosition());
  waveStoneDiff.rotate(radians(_wave.Angle));
  if (waveStoneDiff.y - _wave.Height < 0 && abs(waveStoneDiff.x) < _wave.Width / 3.0f) {
    if (abs(waveStoneDiff.x) < stone.bounds.x / 2) {
      _lifetime = _wave.Lifespan = 0;
    }
    if (!_wave.collidedWithStone) {
      createNewCollisionWave(_wave);
      _wave.collidedWithStone = true;
    }
  }

  return _lifetime;
}

void createNewCollisionWave(Wave _wave) {
  // Add new Wave
  Wave newWave = new Wave(collisionWave);
  collisionWaves.add(newWave);

  // Set Values
  newWave.Width = newWave.Height =(int)stone.getHitbox().x;
  newWave.setStartVelocity(_wave.Velocity);
  newWave.Velocity = newWave.getStartVelocity();
  newWave.setStartLifespan(collisionWave.LIFESPAN_MIN, collisionWave.LIFESPAN_MAX);
  newWave.initializePosition(stone.getPosition().x, stone.getPosition().y);
  newWave.Angle = _wave.Angle;
  updateCollisionWaveImage(collisionWaves.size() - 1);
}

void updateCollisionWaves() {
  for (int i = collisionWaves.size() - 1; i >= 0; i--) {
    updateCollisionWaveImage(i);
  }
}

void updateCollisionWaveImage(int _index) {
  Wave wave = collisionWaves.get(_index);
  float currentLifespan = wave.Lifespan;
  int pixelW = (int)wave.Width;
  if (pixelW % 2 == 1) {
    pixelW += 1;
  }
  PImage waveImg = createImage(pixelW, pixelW, ARGB);

  if (currentLifespan <= 0) {
    collisionWaves.remove(_index);
  } else {
    for (int x = 0; x < pixelW; x++) {
      for (int y = 0; y < pixelW; y++) {
        PVector radius = new PVector(x - pixelW / 2.0f, y - pixelW / 2.0f);
        float absDistance = dist(0, 0, radius.x / (pixelW / 2.0f), radius.y / (pixelW / 2.0f)); // Distance of pixel to center
        float alpha = SetCenterGradientAlpha(absDistance, 0.2f, 0.9f);
        alpha = CalculateConeAlpha(alpha, x, y, pixelW, wave.Angle);
        alpha *= currentLifespan / wave.getStartLifespan();

        SetPixelAlpha(alpha, absDistance, waveImg, x, y);
      }
    }

    wave.Image = waveImg;
    wave.Height = wave.Width = wave.Width + collisionWave.SPREAD;
    wave.Lifespan = currentLifespan - (millis() - previousTime) / 1000.0f;

    image(waveImg, wave.Position.x, wave.Position.y);
  }
}

float CalculateConeAlpha(float _alpha, int _x, int _y, int _pixelW, float _waveAngle) {
  float angleDiff = CalculateAngleDiff(_x, _y, _pixelW, _waveAngle);
  float waveAngleWidth = 80;
  if (angleDiff > waveAngleWidth) {
    _alpha = 0;
  } else {
    _alpha *= (1 - angleDiff / waveAngleWidth);
  }

  return _alpha;
}

float CalculateAngleDiff(int _x, int _y, int _pixelW, float _waveAngle) {
  PVector pixelSlope = new PVector(_x - _pixelW / 2.0f, _y - _pixelW / 2.0f);
  float pixelAngle = -degrees(atan2(pixelSlope.y, pixelSlope.x)) + 90;
  float angleDiff = abs(pixelAngle - _waveAngle);
  if (angleDiff > 360) {
    angleDiff -= 360;
  }
  if (angleDiff > 180) {
    angleDiff = 360 - angleDiff;
  }

  return angleDiff;
}

float CalculateLifespanAlpha(float _alpha, float _lerpProgress, Wave _wave) {
  float startLifespan = _wave.getStartLifespan();
  float normalizedLifespan = startLifespan - _wave.Lifespan;
  float beachAlpha = (_wave.Position.y - beach.GetY((int)_wave.Position.x) + 1) / (beach.hitbox - beach.GetY((int)_wave.Position.x + 1));
  float lifespanAlpha;
  if (normalizedLifespan <= startLifespan / 2.0f) {
    lifespanAlpha = 2.0f * normalizedLifespan / startLifespan;
  } else {
    lifespanAlpha = 2.0f - (2.0f * normalizedLifespan / startLifespan);
  }
  _alpha *= lerp(lifespanAlpha, beachAlpha, _lerpProgress);
  return _alpha;
}

void SetPixelAlpha(float _alpha, float _dist, PImage _img, int _x, int _y) {
  if (_dist < 1) {
    _img.set(_x, _y, color(255, 255, 255, _alpha));
  } else {
    _img.set(_x, _y, color(0, 0, 0, 0));
  }
}

void UpdatePosition(Wave _wave) {
  _wave.Position.x -= _wave.Velocity * sin(radians(_wave.Angle));
  _wave.Position.y -= _wave.Velocity * cos(radians(_wave.Angle));
}
