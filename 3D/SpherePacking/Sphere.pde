
// Sphere class to grow Spheres (get a point in the text mesh, check overlap with other Spheres),
// display them in immediate mode and when grown place them in a retained PShape for display on the GPU
class Sphere {
  PVector loc;
  float radius, growRate;
  boolean isOverlap, addedToPShape;
  color c;

  Sphere() {
    loc = getPositionInMesh();
    growRate = random(0.2, 2);
    c = getColor(loc);
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

  // check against actual mesh (in this sketch we already know the point must be inside the boundingBox)
  boolean isInMesh(PVector p) {
    return mesh.contains(new WB_Point(p.x, p.y, p.z), false);
  }

  // get color where the hue is based on the relative xy-position and the brightness on the relative z-position
  color getColor(PVector p) {
    colorMode(HSB, 1);
    float rPos = map(loc.x, min.x, max.x, 0, 1) + map(loc.y, min.y, max.y, 0, 1);
    color col = color(rPos%1, 1, map(loc.z, min.z, max.z, 0.15, 1));
    colorMode(RGB, 255);
    return col;
  }

  void update() {
    // if not yet addded to PShape
    if (!addedToPShape) {
      // if not overlapping with other spheres
      if (!isOverlap) {
        radius += growRate; // grow
        isOverlap = overlap(); // check if overlapping with other Spheres
      } else {
        // once it's overlapping, add to PShape and set boolean accordingly
        addToPShape();
        addedToPShape = true;
      }
    }
  }

  // check (future) overlap with other spheres based on locations, radii and growth rate
  boolean overlap() {
    for (Sphere s : spheres) {
      if (s != this) {
        if (loc.dist(s.loc) <= s.radius + radius + growRate) {
          return true;
        }
      }
    }
    return false;
  }

  // display in immediate mode until it's added to PShape
  void display() {
    if (!addedToPShape) {
      pushMatrix();
      translate(loc.x, loc.y, loc.z);
      noStroke();
      fill(c);
      sphere(radius);
      popMatrix();
    }
  }
  
  // add (visually identical) sphere to the container PShape for quick display on the GPU
  void addToPShape() {
    PShape sphere = createShape(SPHERE, radius);
    sphere.translate(loc.x, loc.y, loc.z);
    sphere.setFill(c);
    sphere.setStroke(false);
    shape.addChild(sphere);
  }
}

