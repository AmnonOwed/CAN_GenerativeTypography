
class Line {
  ArrayList <PVector> vertices;

  // the first Line is created at the lower boundary with random (horizontal) vertices
  Line() {
    vertices = new ArrayList <PVector> ();
    float d12 = (maxX-minX)/12.0;
    float d6 = (maxX-minX)/6.0;
    float x = minX;
    while (x < maxX) {
      vertices.add(new PVector(x += random(d12, d6), maxY));
    }
  }

  // all other Lines are created from the previous Line's addLine() method
  Line(ArrayList <PVector> vertices) {
    this.vertices = vertices;
  }

  // until the upper boundary is reached, move all the vertices a bit, then create a new Line
  void addLine() {
    if (insideBoundaries()) {
      PVector moveSpeed = new PVector(random(-2, 3), random(-8, 2));
      ArrayList <PVector> vCopy = new ArrayList <PVector> ();
      for (PVector p : vertices) vCopy.add(PVector.add(p, moveSpeed));
      vCopy.get(0).x = min(vCopy.get(0).x, minX);
      lines.add(new Line(vCopy));
    }
  }

  // check if all vertices are above the upper boundary (then it will return false)
  boolean insideBoundaries() {
    for (PVector v : vertices) if (v.y > minY) return true;
    return false;
  }

  // move all vertices
  void update() {
    for (PVector v : vertices) {
      v.add(getVelocity(v.x, v.y));
    }
  }

  // display the line
  void display() {
    beginShape();
    curveVertex(minX, vertices.get(0).y);
    for (PVector v : vertices) {
      curveVertex(v.x, v.y);
    } 
    curveVertex(maxX, vertices.get(vertices.size()-1).y);
    endShape();
  }
}

