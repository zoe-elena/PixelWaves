/*PImage img;
PImage arcImage;
int waveLength = 5;
int imgScale = 8;
int yPos = 0;

int diameterWidth = 100; // Diameter of the arc
int diameterHeight = 20; // Diameter of the arc

void setup() {
  size(800, 100);
  img = createImage(waveLength, waveLength, ARGB);

  // Pixel für Pixel hinzufügen
  img.set(0, img.height-1, color(255, 255, 255, 200));
  img.set(1, img.height-2, color(255, 255, 255, 200));
  img.set(2, img.height-2, color(255, 255, 255, 200));
  img.set(3, img.height-2, color(255, 255, 255, 200));
  img.set(4, img.height-1, color(255, 255, 255, 200));

  noSmooth(); // Disable anti-aliasing

  CreateWaveImage();
}

void draw() {
  background(0, 0, 255);

  scale(imgScale);
  image(arcImage, 0, 0); // Display the PImage on the screen

}

void CreateWaveImage() {
  arcImage = createImage(diameterWidth, diameterHeight, ARGB); // Create a new PImage with the pixelated dimensions
  for (int y = 0; y < diameterHeight; y++) {
    for (int x = 0; x < diameterWidth; x++) {
      int i = y * diameterWidth + x;
      float distanceX = (x - diameterWidth / 2.0) / (diameterWidth / 2.0);
      float distanceY = (y - diameterHeight / 2.0) / (diameterHeight / 2.0);
      float distance = sqrt(pow(distanceX, 2) + pow(distanceY, 2)); //distance of pixel to center


      float alpha = 255 - abs(distance - 1) * 255;
      alpha = alpha * (1- (float)y / diameterHeight * 2);

      if (distance < 1) {
        arcImage.pixels[i] = color(255, 255, 255, alpha);
      } else {
        arcImage.pixels[i] = color(0, 0, 0, 0);
      }
    }
  }

  arcImage.loadPixels(); // Load the pixels of the PImage

  int x = 0;
  int y = 0;
  int w = arcImage.width;
  int h = arcImage.height - arcImage.height / 2;
  arcImage = arcImage.get(x, y, w, h);
}*/
