class Beach {
  // Beach Sine Attributes
  final float amplitude;
  final float frequency;
  final float horizontalOffset;
  final float verticalOffset;
  final float hitbox;

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
