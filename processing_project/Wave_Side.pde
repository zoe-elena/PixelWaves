PVector[] particlesPos;
int numParticles = 300;
float particleSize = 6;

void setup() {
  size(800, 800);
  particlesPos = new PVector[numParticles];
  for (int i = 0; i < numParticles; i++) {
    particlesPos[i] = new PVector();
    particlesPos[i].x = random(particleSize, width);
    particlesPos[i].y = random(height / 2, height);
  }
}

void draw() {
  background(0, 50, 100);
  
  // Welle zeichnen
  stroke(255);
  strokeWeight(2);
  noFill();
  beginShape();
  for (float x = 0; x <= width; x += 10) {
    float y = height / 2.15f + 10 * sin(frameCount * 0.05f + x * 0.02f);
    vertex(x, y);
  }
  endShape();
  
  // Partikel bewegen
  noStroke();
  fill(255);
  for (int i = 0; i < numParticles; i++) {
    float x = particlesPos[i].x - 20 + 20 * (1 - particlesPos[i].y / height) * cos(frameCount * 0.05f + particlesPos[i].x * 0.02f);
    float y = particlesPos[i].y - 20 + 20 * (1 - particlesPos[i].y / height) * sin(frameCount * 0.05f + particlesPos[i].x * 0.02f);
    ellipse(x, y, particleSize, particleSize);
  }
}
