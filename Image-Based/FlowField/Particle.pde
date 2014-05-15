
class Particle {
  PVector loc;
  float maxLife, life, lifeRate;

  Particle() {
    getPosition();
    // set the maximum life of the Particles depending on the drawMode
    switch(drawMode) {
      case 0: maxLife = 1.25; break;
      case 1: maxLife = 1.0; break;
      case 2: maxLife = 0.75; break;
      case 3: maxLife = 0.5; break;
    }
    // randomly set a life and lifeRate for each Particle
    life = random(0.5 * maxLife, maxLife);
    lifeRate = random(0.01, 0.02);
  }

  void update() {
    // the velocity/direction of each Particle is based on a flowfield using Processing's noise() method
    // drawMode 0: no extras (an xy-position will always return the same angle)
    // drawMode 1: dynamic noise (an xy-position will return a slightly different angle on every frame)
    // drawMode 2: rotation (the angle of each xy-position is globally rotated)
    // drawMode 3: dynamic noise + rotation (combines drawModes 1 & 2)
    float angle = noise(loc.x * 0.01, loc.y * 0.01, drawMode==1 || drawMode==3 ? fc001 : 0) * TWO_PI;
    PVector vel = PVector.fromAngle(angle + (drawMode==2 || drawMode==3 ? fc001 : 0));
    loc.add(vel);
    life -= lifeRate; // decrease life by the lifeRate (the particle is removed by the addRemoveParticles() method when no life is left)
  }

  void display() {
    fill(255); // white fill
    stroke(0, 125); // transparant black stroke
    float r = 8 * life/maxLife; // radius of the ellipse
    ellipse(loc.x, loc.y, r, r); // draw ellipse
  }

  // get a random position inside the text
  void getPosition() {
    while (loc == null || !isInText (loc)) loc = new PVector(random(width), random(height));
  }

  // return if point is inside the text
  boolean isInText(PVector v) {
    return pg.get(int(v.x), int(v.y)) == PGRAPHICS_COLOR;
  }
}

