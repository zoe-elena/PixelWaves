class Obstacle {
  private final PVector position;
  private final PImage image;
  private final PVector hitbox;

  Obstacle(PVector _position, PImage _image, PVector _hitbox) {
    position = _position;
    image = _image;
    hitbox = _hitbox;
  }

  public PVector getPosition() {
    return position;
  }
  
  public PVector getHitbox() {
    return hitbox;
  }
}
