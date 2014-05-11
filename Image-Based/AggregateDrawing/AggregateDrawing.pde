
/*
 * This sketch uses the text drawn to an offscreen PGraphics to determine
 * if a randomly chosen xy-coordinate is inside the drawn text. If so it will
 * draw a shape to the main screen. In addition, the sketch has no background
 * call in draw(), so the drawings will accumulate on top of each other
 * much like a painting's canvas.
 * 
 * USAGE:
 * - click the mouse to move through the three different drawing modes
 */

int drawSpeed = 200; // number of drawn shapes per draw() call
int drawMode = 0; // move through the drawing modes by clicking the mouse
color BACKGROUND_COLOR = color(255);
color PGRAPHICS_COLOR = color(0);

PGraphics pg;

void setup() {
  size(1280, 720);
  background(BACKGROUND_COLOR); // start of with a white background
  colorMode(HSB, 360, 100, 100); // change to Hue-Saturation-Brightness color mode
  rectMode(CENTER);

  // create and draw to PPraphics (see Getting Started > UsingPGraphics example)
  pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  pg.textSize(500);
  pg.textAlign(CENTER, CENTER);
  pg.fill(PGRAPHICS_COLOR);
  pg.text("TYPE", pg.width/2, pg.height/2); 
  pg.endDraw();
}

void draw() {
  // This for loop ensures the code is repeated 'drawSpeed' times
  for (int i=0; i<drawSpeed; i++) {
    // pick a random coordinate
    int x = (int) random(width);
    int y = (int) random(height);
    // check if the coordinate is inside the text (in the offscreen PGraphics)
    boolean insideText = (pg.get(x, y) == PGRAPHICS_COLOR);
    // if it is indeed, then draw a shape in the main screen
    if (insideText) {
      // switch based on the current draw mode (move through them by clicking the mouse)
      // each drawing mode has custom settings (stroke, fill, shape, rotation) 
      pushMatrix();
      translate(x, y);
      switch (drawMode) {
      case 0:
        float er = random(5, 45);
        color ec = color(random(360), 100, 100);
        stroke(0);
        fill(ec);
        ellipse(0, 0, er, er);
        break;
      case 1: 
        float td = random(3, 10);
        float tr = random(TWO_PI);
        color tc = color(random(180, 300), 100, random(50, 100));
        noStroke();
        fill(tc);
        rotate(tr);
        triangle(0, -td, -td, td, td, td);
        break;
      case 2: 
        float rw = random(5, 20);
        float rh = random(5, 50);
        float rr = random(TWO_PI);
        color rc = color(random(20), random(70, 100), random(20, 100));
        stroke(0);
        fill(rc);
        rotate(rr);
        rect(0, 0, rw, rh);
        break;
      }
      popMatrix();
    }
  }
}

void mousePressed() {
  background(BACKGROUND_COLOR); // clear the screen when changing drawing mode
  drawMode = ++drawMode%3; // move through 3 drawing modes (0, 1, 2)
}

