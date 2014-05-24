
/*
 * This example shows you how to use the Geomerative library to:
 * - Load an external TrueType-font into an RFont
 * - Create an RShape from a text using the loaded font
 * - Extract points from the RShape
 * - Display the data (shape/points) in different ways
 *
 * In addition the sketch allows you to export the frame as a PDF.
 *
 * USAGE:
 * - press 's' to export a single frame as a PDF page
 */

// import the required libraries
import processing.pdf.*;        // library for PDF export
import geomerative.*;           // library for text manipulation and point extraction

float nextPointSpeed = 0.65;    // speed at which the sketch cycles through the points
boolean saveOneFrame = false;   // variable used to save a single frame as a PDF page
RShape shape;                   // holds the base shape created from the text
RPoint[][] allPaths;            // holds the extracted points

void setup() {
  size(1280, 720);

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
  RCommand.setSegmentLength(10); // set segmentLength between points
  // extract paths and points from the base shape using the above Segmentator settings
  allPaths = shape.getPointsInPaths();
}

void draw() {
  // begin recording to PDF
  if (saveOneFrame == true) {
    beginRecord(PDF, "UsingGeomerative-" + timestamp() + ".pdf");
  }

  // clear the background
  background(255);

  // draw the whole text shape as a thick outline
  noFill();
  stroke(0, 225, 255);
  strokeWeight(15);
  shape.draw();

  // draw the extracted points as black points
  stroke(0);
  strokeWeight(2);
  beginShape(POINTS);
  for (RPoint[] singlePath : allPaths) {
    for (RPoint p : singlePath) {
      vertex(p.x, p.y);
    }
  }
  endShape();

  // draw thin transparant lines between two points within a path (a letter can have multiple paths)
  // dynamically set the 'opposite' point based on the current frameCount
  int fc = int(frameCount * nextPointSpeed);
  stroke(0, 125);
  strokeWeight(0.75);
  for (RPoint[] singlePath : allPaths) {
    beginShape(LINES);
    for (int i=0; i<singlePath.length; i++) {
      RPoint p = singlePath[i];
      vertex(p.x, p.y);
      RPoint n = singlePath[(fc+i)%singlePath.length];
      vertex(n.x, n.y);
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
  if (key == 's') {
    saveOneFrame = true; // set the variable to true to save a single frame as a PDF file / page
  }
}

String timestamp() {
  return year() + nf(month(), 2) + nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}

