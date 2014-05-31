
/*
 * This example shows you how to use the Geomerative library to:
 * - Load an external TrueType-font into an RFont
 * - Create an RShape from a text using the loaded font
 * - Extract points from the RShape
 *
 * In addition the extracted text points and a number of generated
 * lines are translated using a flowfield in an ocean-like manner.
 *
 * Finally the sketch allows you to export the frame as a PDF.
 *
 * USAGE:
 * - press SPACE to reset the text and background lines
 * - press 's' to export a single frame as a PDF page
 */

// import the required libraries
import processing.pdf.*;        // library for PDF export
import geomerative.*;           // library for text manipulation and point extraction

boolean saveOneFrame = false;   // variable used to save a single frame as a PDF page
RShape shape;                   // holds the base shape created from the text
RPoint[][] allPaths;            // holds the extracted points
ArrayList <Line> lines;         // holds the background lines

float maxOceanSpeed = 0.65;     // limits (not sets!) the speed at which the text and background lines are deformed  

// wave boundaries (optimized for graphical effect and a 1280 x 720 canvas)
float minX = 0;;
float maxX = 1500;
float minY = -500;
float maxY = 1000;

void setup() {
  size(1280, 720, P2D); // with this many lines we need the OpenGL renderer for fast display
  smooth(16); // keep it nice and smooth

  // initialize the Geomerative library
  RG.init(this);
  // create font used by Geomerative
  RFont font = new RFont("../../Fonts/FreeSans.ttf", 350);
  // create base shape from text using the loaded font
  shape = font.toShape("TYPE");
  // center the shape in the middle of the screen
  shape.translate(width/2 - shape.getWidth()/2, height/2 + shape.getHeight()/2);
  // set Segmentator (read: point retrieval) settings
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH); // use a uniform distance between points
  RCommand.setSegmentLength(5); // set segmentLength between points

  lines = new ArrayList <Line> ();
  reset();
}

void draw() {
  // begin recording to PDF
  if (saveOneFrame == true) {
    beginRecord(PDF, "Ocean-" + timestamp() + ".pdf");
  }

  // clear the background
  background(255);

  // turn off fill for the rest of the sketch
  noFill();

  // move and display the background lines
  strokeWeight(0.65);
  stroke(95);
  for (Line l : lines) {
    l.update();
    l.display();
  }

  // move and display the text (points)
  strokeWeight(1.5);
  stroke(0);
  for (RPoint[] singlePath : allPaths) {
    beginShape();
    for (RPoint p : singlePath) {
      PVector vel = getVelocity(p.x, p.y);
      p.translate(vel.x, vel.y);
      vertex(p.x, p.y);
    }
    endShape();
  }
  
  // end recording to PDF
  if (saveOneFrame) {
    endRecord();
    saveOneFrame = false;
  }
}

void keyPressed() {
  if (key == ' ') { reset(); } // reset the sketch
  if (key == 's') { saveOneFrame = true; } // save a PDF
}

String timestamp() {
  return year() + nf(month(), 2) + nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}

void reset() {
  // extract paths and points from the base shape
  allPaths = shape.getPointsInPaths();

  // create the background lines
  lines.clear();
  lines.add(new Line());
  while (lines.get(lines.size()-1).insideBoundaries()) {
    lines.get(lines.size()-1).addLine();
  }
}

// flowfield to generate the velocities for the points in the text and background lines
PVector getVelocity(float x, float y) {
  float angle = noise(x * 0.01, y * 0.01, frameCount * 0.01) * TWO_PI;
  PVector vel = PVector.fromAngle(angle);
  vel.limit(maxOceanSpeed); // maximize the movement speed
  return vel;
}

