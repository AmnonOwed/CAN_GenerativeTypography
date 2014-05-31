
/*
 * This example shows you how to use the Geomerative library to:
 * - Load an external TrueType-font into an RFont
 * - Create an RShape from a text using the loaded font
 * - Extract points from the RShape
 * - Generate a set of random points outside the RShape
 *
 * In addition the sketch utilizes Lee Byron's Mesh library to
 * generate a Voronoi Diagram based on the point set.
 *
 * Finally the sketch allows you to export the frame as a PDF.
 *
 * USAGE:
 * - press SPACE to randomly generate voronoi regions and colors
 * - press 'p' to toggle point display
 * - press 's' to export a single frame as a PDF page
 */

// import the required libraries
import processing.pdf.*;          // library for PDF export
import geomerative.*;             // library for text manipulation and point extraction
import megamu.mesh.*;             // library for creation of the Voronoi diagram

int numPointsGenerated = 250;     // the number of points generated
boolean saveOneFrame = false;     // variable used to save a single frame as a PDF page
RShape shape;                     // holds the base shape created from the text
MPolygon[] myRegions;             // holds the voronoi regions generated from the points
color[] colors;                   // holds the colors for the voronoi regions
int numPointsText;                // the number of points generated from the text
int currentPoint;                 // holds the current point used for the 'moving points' effect
float interpolationBetweenPoints; // holds the interpolation value used for the 'moving points' effect
float[][] points;                 // holds the text and randomly generated points
boolean displayPoints = true;     // variable used to toggle the display of points

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
  RCommand.setSegmentLength(6); // set segmentLength between points
  // extract paths and points from the base shape using the above Segmentator settings
  RPoint[] allPoints = shape.getPoints(); // holds the extracted points
  numPointsText = allPoints.length;
  colors = new color[numPointsText];
  points = new float[numPointsText + numPointsGenerated][2];
  // add text point coordinates to the data structure used to create the voronoi
  for (int i=0; i<numPointsText; i++) {
    points[i][0] = allPoints[i].x;
    points[i][1] = allPoints[i].y;
  }
  generateRegionsAndColors();
}

void draw() {
  // begin recording to PDF
  if (saveOneFrame == true) {
    beginRecord(PDF, "VoronoiType-" + timestamp() + ".pdf");
  }

  // clear the background
  background(255);

  // draw the Voronoi Polygons related to the text points
  strokeWeight(0.75);
  stroke(0, 125);
  for (int i=0; i<numPointsText; i++) {
    float[][] regionCoordinates = myRegions[i].getCoords();
    fill(colors[i]);
    beginShape();
    for (int j=0; j<regionCoordinates.length; j++) {
      vertex(regionCoordinates[j][0], regionCoordinates[j][1]);
    }
    endShape(CLOSE);
  }

  if (displayPoints) {
    // global variables for the 'moving points' effect
    interpolationBetweenPoints += 0.01;
    if (interpolationBetweenPoints >= 1) {
      interpolationBetweenPoints = 0;
      currentPoint++;
    }
    // display one point per voronoi region, which interpolate through the edges
    strokeWeight(3);
    stroke(0);
    beginShape(POINTS);
    for (int i=0; i<numPointsText; i++) {
      float[][] regionCoordinates = myRegions[i].getCoords();
      float interpolationOfPoints = currentPoint % regionCoordinates.length / float(regionCoordinates.length);
      int start = int(interpolationOfPoints * regionCoordinates.length);
      int end = (start + 1) % regionCoordinates.length;
      float x = lerp(regionCoordinates[start][0], regionCoordinates[end][0], interpolationBetweenPoints);
      float y = lerp(regionCoordinates[start][1], regionCoordinates[end][1], interpolationBetweenPoints);
      vertex(x, y);
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
  if (key == ' ') { generateRegionsAndColors(); } // generate new voronoi regions and colors
  if (key == 'p') { displayPoints = !displayPoints; } // toggle display of points
  if (key == 's') { saveOneFrame = true; } // save PDF
}

String timestamp() {
  return year() + nf(month(), 2) + nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}

void generateRegionsAndColors() {
  // set random points outside the text
  for (int i=numPointsText; i<points.length; i++) {
    points[i] = getRandomPoint();
  }
  // check for identical points (which would crash the Mesh library)
  checkIdentical(points);
  // use points to generate a Voronoi Diagram
  Voronoi myVoronoi = new Voronoi(points);
  // get the Voronoi regions
  myRegions = myVoronoi.getRegions();
  // generate a color for each voronoi region in the text
  colorMode(HSB, 1);
  float c = random(1);
  for (int i=0; i<numPointsText; i++) {
    colors[i] = color(c, 1, 1);
    c = (c + 0.618) % 1;
  }
  colorMode(RGB, 255);
}

float[] getRandomPoint() {
  float[] point = new float[2];
  point[0] = random(width);
  point[1] = random(height);
  // make sure it's outside the text
  while (shape.contains (point[0], point[1])) {
    point[0] = random(width);
    point[1] = random(height);
  }
  return point;
}

void checkIdentical(float[][] points) {
  for (int i=0; i<points.length; i++) {
    for (int j=0; j<i; j++) {
      if (points[i][0]==points[j][0]&&points[i][1]==points[j][1]) {
        points[i][0]+=random(1);
        points[i][1]+=random(1);
        points[j][0]+=random(-1);
        points[j][1]+=random(-1);
      }
    }
  }
}

