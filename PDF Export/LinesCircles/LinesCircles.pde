
/*
 * This example shows you how to use the Geomerative library to:
 * - Load an external TrueType-font into an RFont
 * - Create an RShape from a text using the loaded font
 * - Generate a set of random points inside the RShape
 * - Display the points in different ways
 *
 * In addition the sketch allows you to export the displayed frame as a PDF.
 *
 * USAGE:
 * - click the mouse to generate a new set of points and colors
 * - press 's' to export a single frame as a PDF page
 */

// import the required libraries
import processing.pdf.*;              // library for PDF export
import geomerative.*;                 // library for text manipulation and point extraction

int numPoints = 150;                  // the number of points generated
float maxDistance = 55;               // maximum distance between two points to draw a line
color BACKGROUND_COLOR = color(255);  // background color of the sketch
color LINE_COLOR = color(0, 125);     // color of interconnected lines

RShape shape;                         // holds the base shape created from the text
ArrayList <PVector> points;           // list to store all the points
ArrayList <Integer> colors;           // list to store all the colors
boolean saveOneFrame = false;         // variable used to save a single frame as a PDF page

void setup() {
  size(1280, 720);
  
  // setup lists and colorMode
  points = new ArrayList <PVector> ();
  colors = new ArrayList <Integer> ();
  colorMode(HSB, 360, 100, 100, 100);

  // initialize the Geomerative library
  RG.init(this);
  // create font used by Geomerative
  RFont font = new RFont("../../Fonts/FreeSans.ttf", 350);
  // create base shape from text using the loaded font
  shape = font.toShape("TYPE");
  // center the shape in the middle of the screen
  shape.translate(width/2 - shape.getWidth()/2, height/2 + shape.getHeight()/2);
  resetPointsAndColors(); // generate the points based on the text shape, for each point generate a color
}

void draw() {
  // begin recording to PDF
  if (saveOneFrame == true) {
    beginRecord(PDF, "LinesCircles-" + timestamp() + ".pdf");
  }
  
  // set colorMode for the sketch to Hue-Saturation-Brightness (HSB)
  // must be called after beginRecord to work for the exported PDF!
  colorMode(HSB, 360, 100, 100, 100);

  // clear the background
  background(BACKGROUND_COLOR);

  // draw colored ellipses
  noStroke();
  for (int i=0; i<points.size(); i++) {
    PVector p = points.get(i);
    fill(colors.get(i));
    ellipse(p.x, p.y, p.z, p.z);
  }

  // draw lines between the points within a certain distance of each other
  strokeWeight(0.5);
  stroke(LINE_COLOR);
  for (int i=0; i<points.size(); i++) {
    PVector p = points.get(i);
    for (int j=i+1; j<points.size(); j++) {
      PVector q = points.get(j);
      if (p.dist(q) < maxDistance) {
        line(p.x, p.y, q.x, q.y);
      }
    }
  }

  // end recording to PDF
  if (saveOneFrame) {
    endRecord();
    saveOneFrame = false;
  }
}

void resetPointsAndColors() {
  points.clear();
  colors.clear();
  while (points.size() < numPoints) {
    float x = random(width);
    float y = random(height);
    if (shape.contains(x, y)) {
      float radius = random(1)<0.075?random(20, 75):random(3, 33);
      points.add(new PVector(x, y, radius));
      color c = color(random(360), 60, 85, 65);
      colors.add(c);
    }
  }
}

void mousePressed() {
  resetPointsAndColors();
  redraw();
}

void keyPressed() {
  if (key == 's') {
    saveOneFrame = true; // set the variable to true to save a single frame as a PDF file / page
    redraw();
  }
}

String timestamp() {
  return year() + nf(month(), 2) + nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}

