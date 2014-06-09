
// Particle class to start inside a mesh, move through a 3D vector field and generate a PShape of the trail
class Particle {
  ArrayList <PVector> history;
  int maxStates;
  PVector loc;

  Particle() {
    history = new ArrayList <PVector> ();
    float rnd = random(1);
    maxStates = int(rnd * rnd * maxHistoryStates * 0.65 + maxHistoryStates * 0.35);
    loc = getPositionInMesh();
  }

  // keep moving and adding positions to the history until max states is reached
  void update() {
    if (history.size() < maxStates) { 
      loc.add(getVelocityVector(loc));
      history.add(loc.get());
    }
  }

  // keep trying until we get a position within the text mesh
  PVector getPositionInMesh() {
    PVector p = getRandomVector();
    while (!isInMesh (p)) p = getRandomVector();
    return p;
  }

  // random vector within text mesh bounding box
  PVector getRandomVector() {
    float x = random(min.x, max.x);
    float y = random(min.y, max.y);
    float z = random(min.z, max.z);
    return new PVector(x, y, z);
  }

  // color with hue based on x position and brightness based on history index
  color getColor(PVector p, float perc) {
    colorMode(HSB, 1);
    color col = color(map(p.x, min.x, max.x, 0.55, 0.25), 0.85, perc);
    colorMode(RGB, 255);
    return col;
  }

  // check against actual mesh (in this sketch we already know the point must be inside the boundingBox)
  boolean isInMesh(PVector p) {
    return mesh.contains(new WB_Point(p.x, p.y, p.z), false);
  }

  // couldn't finding anything useful on the internet about 3D vector fields, 
  // so I just threw some stuff together myself that seems to resemble it! ;-)
  // (please let me know if you have an implementation that is more accurate)
  PVector getVelocityVector(PVector p) {
    float angleXY = noise(p.x * 0.01, (p.y + p.z) * 0.01, frameCount * 0.01) * TWO_PI;
    float angleZ = noise(p.z * 0.01, (p.x + p.y) * 0.005, frameCount * 0.0025) * TWO_PI;
    float vz = sin(angleZ);
    float vx = cos(angleXY);
    float vy = sin(angleXY);
    return new PVector(vx, vy, vz);
  }

  // create a PShape from the particle trail
  // since everything happens in setup() in this sketch, there is no Particle display method
  PShape getPShape() {
    PShape particle = createShape();
    particle.beginShape();
    particle.noFill();
    for (int i=0; i<history.size (); i++) {
      PVector p = history.get(i);
      // base strokeWeight on the history index
      particle.strokeWeight(map(i, 0, history.size(), maxStrokeWeight, 0));
      // base color on the position (hue) and the history index (brightness)
      particle.stroke(getColor(p, float(i)/history.size()));
      particle.vertex(p.x, p.y, p.z);
    }
    particle.endShape();
    return particle;
  }
}

