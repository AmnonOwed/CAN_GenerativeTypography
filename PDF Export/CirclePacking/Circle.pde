
class Circle {
  int x, y;
  float radius, maxRadius, growRate;
  boolean isMaxRadius, isOverlap;
  color c;

  Circle(int x, int y) {
    this.x = x;
    this.y = y;
    maxRadius = random(3, 25);
    growRate = random(0.2, 2);
    c = color((x + 2 * y + frameCount) % 360, 75, 85);
  }

  void update() {
    if (!isMaxRadius && !isOverlap) {
      radius += growRate;
      isMaxRadius = radius >= maxRadius; 
      isOverlap = overlap();
    }
  }

  void display() {
    fill(c);
    ellipse(x, y, 2*radius, 2*radius);
  }

  boolean overlap() {
    for (Circle c : circles) {
      if (c != this) {
        if (dist(x, y, c.x, c.y) <= c.radius + radius + growRate) {
          return true;
        }
      }
    }
    return false;
  }
}

