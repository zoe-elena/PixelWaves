class WaveType {
  int WIDTH_MIN;
  int WIDTH_MAX;
  float VELOCITY_MIN;
  float VELOCITY_MAX;
  float LIFESPAN_MIN;
  float LIFESPAN_MAX;
  float SPAWNFREQUENCY_MIN;
  float SPAWNFREQUENCY_MAX;
  float currentSpawnFrequency;
  float SPREAD;

  WaveType(int _wMin, int _wMax, float _vMin, float _vMax, float _lMin, float _lMax, float _fMin, float _fMax, float _currentf, float _s) {
    WIDTH_MIN = _wMin;
    WIDTH_MAX = _wMax;
    VELOCITY_MIN = _vMin;
    VELOCITY_MAX = _vMax;
    LIFESPAN_MIN = _lMin;
    LIFESPAN_MAX = _lMax;
    SPAWNFREQUENCY_MIN = _fMin;
    SPAWNFREQUENCY_MAX = _fMax;
    currentSpawnFrequency = _currentf;
    SPREAD = _s;
  }
}
