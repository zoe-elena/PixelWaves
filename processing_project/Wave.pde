class Wave {
  public final int randomWidthMax = 30;
  public final int randomWidthMin = 15;
  public final float randomVelocityMax = 1.5f;
  public final float randomVelocityMin = 1.0f;
  public final float randomLifespanMax = 5;
  public final float randomLifespanMin = 2;

  private PImage sourceImage;
  private PImage currentImage;
  private int waveWidth;
  private int waveHeight;
  private PVector position;
  private float velocity;
  private float lifespan;
  private float currentLifespan;
  private float rotation;


  public PImage getSourceImage() {
    return sourceImage;
  }
  public void setSourceImage(PImage _s) {
    sourceImage = _s;
  }
  public PImage getCurrentImage() {
    return currentImage;
  }
  public void setCurrentImage(PImage _i) {
    currentImage = _i;
  }
  public int getWidth() {
    return waveWidth;
  }
  public int getHeight() {
    return waveHeight;
  }
  public void setDimensions(int _x, int _y) {
    waveWidth = _x;
    waveHeight = _y;
  }
  public void setWidth(int _x) {
    waveWidth = _x;
  }
  public void setHeight(int _y) {
    waveHeight = _y;
  }
  public PVector getPosition() {
    return position;
  }
  public void setPosition(PVector _p) {
    position = _p;
  }
  public float getVelocity() {
    return velocity;
  }
  public void setVelocity(float _v) {
    velocity = _v;
  }
  public float getLifespan() {
    return lifespan;
  }
  public void setLifespan(float _l) {
    lifespan = _l;
  }
  public float getCurrentLifespan() {
    return currentLifespan;
  }
  public void setCurrentLifespan(float _c) {
    currentLifespan = _c;
  }
  public float getRotation() {
    return rotation;
  }
  public void setRotation(float _r) {
    rotation = _r;
  }
}
