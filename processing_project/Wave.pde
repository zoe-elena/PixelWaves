class Wave {

  public PVector Position;
  public float Velocity;
  public float CurrentLifespan;
  public PImage CurrentImage;
  public float CurrentAngle = 20;

  private PImage sourceImage;
  private float waveWidth;
  private float waveHeight;
  private float lifespan;

  public PImage getSourceImage() {
    return sourceImage;
  }

  public void setSourceImage(PImage image) {
    sourceImage = CurrentImage = image;
  }

  public float getWidth() {
    return waveWidth;
  }

  public float getHeight() {
    return waveHeight;
  }

  public void setDimensions(int _min, int _max) {
    int randomWidth = (int)random(_min, _max);
    waveWidth = randomWidth;
    int randomHeight = randomWidth / (int)random(2, 3);
    waveHeight = randomHeight;
  }

  public void setWidth(float width) {
    waveWidth = width;
  }

  public void setHeight(float height) {
    waveHeight = height;
  }

  public void initializePosition(float _mouseX, float _mouseY) {
    float xPos = _mouseX / SCALE;
    float yPos = _mouseY / SCALE;
    Position = new PVector(xPos, yPos);
  }

  public float getLifespan() {
    return lifespan;
  }

  public void setLifespan(float _min, float _max) {
    float newLifespan = random(_min, _max);
    lifespan = newLifespan;
    CurrentLifespan = newLifespan;
  }
}
