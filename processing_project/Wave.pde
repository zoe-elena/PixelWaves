class Wave {
  public WaveType waveType;
  public PVector Position;
  public float Velocity;
  public float Lifetime;
  public PImage Image;
  public float Angle = 20;
  public float Width;
  public float Height;
  public boolean collidedWithStone = false;
  
  private PImage sourceImage;
  private float lifespan;
  private float startWindAngle;
  private float startVelocity;
  
  Wave(WaveType _waveType){
    waveType = _waveType;
  }

  public PImage getSourceImage() {
    return sourceImage;
  }

  public void setSourceImage(PImage _i) {
    sourceImage = Image = _i;
  }

  public void setDimensions(int _min, int _max) {
    int randomWidth = (int)random(_min, _max);
    Width = randomWidth;
    int randomHeight = randomWidth / (int)random(2.0f, 2.5f);
    Height = randomHeight;
  }

  public void initializePosition(float _xPos, float _yPos) {
    Position = new PVector(_xPos, _yPos);
  }

  public float getLifespan() {
    return lifespan;
  }

  public void setLifespan(float _min, float _max) {
    float newLifespan = random(_min, _max);
    lifespan = newLifespan;
    Lifetime = newLifespan;
  }

  public float getStartWindAngle() {
    return startWindAngle;
  }

  public void setStartWindAngle(float _s) {
    startWindAngle = _s;
  }

 public float getStartVelocity() {
    return startVelocity;
  }
  
  public void setStartVelocity(float _v) {
    startVelocity = _v;
  }
}
