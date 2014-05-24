
/*
 * This sketch uses the text drawn to an offscreen PGraphics to determine
 * if coordinate are inside the drawn text. If so, a growing Circle is added.
 * It grows until either the maxRadius is reached or there will be overlap
 * with another Circle.
 *
 * USAGE:
 * - press 's' to export a single frame as a PDF page
 */

import processing.pdf.*;

ArrayList <Circle> circles = new ArrayList <Circle> ();
color BACKGROUND_COLOR = color(255);
color PGRAPHICS_COLOR = color(0);
PGraphics pg;

boolean saveOneFrame = false; // variable used to save a single frame as a PDF page

void setup() {  
  size(1280, 720, P2D);
  smooth(16); // higher smooth setting = higher quality rendering
  // set colorMode for the sketch to Hue-Saturation-Brightness (HSB)
  colorMode(HSB, 360, 100, 100);
  // create the offscreen PGraphics with the text 
  pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  pg.textSize(500);
  pg.textAlign(CENTER, CENTER);
  pg.fill(PGRAPHICS_COLOR);
  pg.text("TYPE", pg.width/2, pg.height/2); 
  pg.endDraw();
}

void draw() {
  addCircles(25); // try (not enforced) to add N circles per frame

  // begin recording to PDF
  if(saveOneFrame == true) {
    beginRecord(PDF, "CirclePacking-" + timestamp() + ".pdf"); 
  }
  
  // must be called (again) after beginRecord to work for the exported PDF!
  colorMode(HSB, 360, 100, 100);

  // the drawing code (also updating the Circles)  
  background(BACKGROUND_COLOR);
  for (Circle c : circles) {
    c.update();
    c.display();
  }
  
  // end recording to PDF
  if(saveOneFrame) {
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
  return year() + nf(month(),2) + nf(day(),2) + "-"  + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
}

void addCircles(int num) {
  for (int i=0; i<num; i++) {
    // random point
    int x = int(random(width));
    int y = int(random(height));
    // is it inside the text?
    if (pg.get(x, y) == PGRAPHICS_COLOR) {
      // does it overlap with other Circles?
      boolean overlap = false;
      for (Circle c : circles) {
        if (dist(x, y, c.x, c.y) <= c.radius + 2) {
          overlap = true;
          break;
        }
      }
      if (!overlap) {
        circles.add(new Circle(x, y));
      }
    }
  }
}

