final int imgScale = 10;
int yPos = 0;
int previousTime;
float friction = 0.003f;

ArrayList<Wave> waves = new ArrayList<Wave>();

void setup() {
  size(800, 800);
  colorMode(RGB, 255);
  noSmooth(); // Disable anti-aliasing
}

void draw() {
  background(0, 0, 255);
  scale(imgScale);
  UpdateWaves();
  previousTime = millis();
}

void mousePressed() {
  if (mousePressed && mouseButton == LEFT)
    CreateNewWave();
}

void CreateNewWave() {
  Wave newWave = new Wave();
  int randomWidth = (int)random(newWave.randomWidthMin, newWave.randomWidthMax);
  newWave.setWidth(randomWidth);
  int randomHeight = randomWidth / (int)random(2, 3);
  newWave.setHeight(randomHeight);
  waves.add(newWave);
  CreateNewWaveImage(newWave);
  newWave.setVelocity(random(newWave.randomVelocityMin, newWave.randomVelocityMax)); // Randomize the speed value
  float xPos = mouseX - randomWidth/2*imgScale;
  float yPos = mouseY - randomHeight/2*imgScale;
  newWave.setPosition(new PVector(xPos, yPos));
  image(newWave.getSourceImage(), xPos, yPos);
  float newLifespan = random(newWave.randomLifespanMin, newWave.randomLifespanMax);
  newWave.setLifespan(newLifespan);
  newWave.setCurrentLifespan(newLifespan);
}

void CreateNewWaveImage(Wave wave) {
  int w = wave.getWidth();
  int h = wave.getHeight();
  PImage sourceImage = createImage(w, h, ARGB);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      float distanceX = (x - w / 2.0) / (w / 2.0);
      float distanceY = (y - h / 2.0) / (h / 2.0);
      float distance = dist(0, 0, distanceX, distanceY); // Distance of pixel to center

      float alpha = 255 - abs(distance - 1) * 255;
      alpha *= (1 - (float) y / h * 2); // Calculate alpha according to distance to middle and bottom

      if (distance < 1) {
        sourceImage.set(x, y, color(255, 255, 255, alpha));
      } else {
        sourceImage.set(x, y, color(0, 0, 0, 0));
      }
    }
  }

  int wCropped = sourceImage.width;
  int hCopped = (int) (sourceImage.height * 0.5);
  PImage croppedImage = sourceImage.get(0, 0, wCropped, hCopped); // Extract the desired portion of the image

  wave.setSourceImage(croppedImage);
  wave.setCurrentImage(croppedImage);
}


void UpdateWaves() {
  for (int i = 0; i < waves.size(); i++) {
    Wave currentWave = waves.get(i);
    PImage sourceImage = currentWave.getSourceImage();
    PImage currentImage = currentWave.getCurrentImage().copy();
    PVector pos = currentWave.getPosition();
    float currentLifespan = currentWave.getCurrentLifespan();
    float currentVelocity = currentWave.getVelocity();
    if (currentLifespan <= 0 || pos.y <= 0 - currentWave.getHeight() * imgScale) {
      waves.remove(i);
      i--; // Reduziere den Index, da ein Element entfernt wurde
    } else {
      currentImage.loadPixels();
      for (int j = 0; j < sourceImage.pixels.length; j++) {
        float pixelAlpha = alpha(sourceImage.pixels[j]);
        float newAlpha = pixelAlpha * currentLifespan / currentWave.getLifespan();
        currentImage.pixels[j] = color(255, 255, 255, newAlpha);
      }
      currentImage.updatePixels();
      currentWave.setCurrentImage(currentImage);
      image(currentImage, pos.x / imgScale, pos.y / imgScale);
      pos.y -= currentVelocity;
      if (currentVelocity > friction)
        currentWave.setVelocity(currentVelocity - friction);
      currentWave.setCurrentLifespan(currentLifespan - (millis() - previousTime) / 1000.0f);
    }
  }
}
