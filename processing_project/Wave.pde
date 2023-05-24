class Wave {

  public PVector position;
  public float velocity;
  public float currentLifespan;
  public PImage currentImage;
  public int currentAngle = 20;

  private PImage sourceImage;
  private int waveWidth;
  private int waveHeight;
  private float lifespan;

  public PImage getSourceImage() {
    return sourceImage;
  }

  public void setSourceImage(PImage image) {
    sourceImage = currentImage = image;
  }

  public int getWidth() {
    return waveWidth;
  }

  public int getHeight() {
    return waveHeight;
  }

  public void setDimensions(int _min, int _max) {
    int randomWidth = (int)random(_min, _max);
    setWidth(randomWidth);
    int randomHeight = randomWidth / (int)random(2, 3);
    setHeight(randomHeight);
  }

  public void setWidth(int width) {
    waveWidth = width;
  }

  public void setHeight(int height) {
    waveHeight = height;
  }

  public void initializePosition(float _mouseX, float _mouseY) {
    if (waveWidth <= 0 && waveHeight <= 0)
      return;
    float xPos = _mouseX - waveWidth / 2 * SCALE;
    float yPos = _mouseY - waveHeight / 2 * SCALE;
    position = new PVector(xPos, yPos);
  }

  public float getLifespan() {
    return lifespan;
  }

  public void setLifespan(float _min, float _max) {
    float newLifespan = random(_min, _max);
    lifespan = newLifespan;
    currentLifespan = newLifespan;
  }
}
