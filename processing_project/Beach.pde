class Beach {
  // Beach Sine Attributes
  private final float amplitude;
  private final float frequency;
  private final float horizontalOffset;
  private final float verticalOffset;
  private final float hitbox;
  private final float hitboxVelocity1 = 7;
  private final float hitboxVelocity2 = 5;

  Beach(float _amplitude, float _frequency, float _horizontalOffset, float _verticalOffset, float _beachHitbox) {
    amplitude = _amplitude;
    frequency = _frequency;
    horizontalOffset = _horizontalOffset;
    verticalOffset = _verticalOffset;
    hitbox = _beachHitbox;
  }

  public float GetY(int _x) {
    return verticalOffset + amplitude * sin((_x + horizontalOffset) * frequency);
  }

  public float GetDerivationY(int _x) {
    return frequency * amplitude * cos((_x + horizontalOffset) * frequency);
  }
}
