
/*
 * Identical to the Image-Based > Waves code example, but with added PDF support!
 *
 * This sketch uses the text drawn to an offscreen PGraphics to determine
 * if coordinate are inside the drawn text. If so, a curveVertex is added.
 * The code ensures that a separate Shape is drawn for each continuous
 * stream of horizontal points within the text.
 *
 * USAGE:
 * - press 's' to export a single frame as a PDF page
 */

import processing.pdf.*;

int gridX = 200;                       // number of horizontal grid points
int gridY = 75;                        // number of vertical grid points
float waveHeight = 55;                 // maximum height of each wave (vertex)
float baseHeight = 4;                  // default base weight of each wave (vertex)
color BACKGROUND_COLOR = color(255);   // background color of the sketch

color PGRAPHICS_COLOR = color(0);
PGraphics pg;

boolean saveOneFrame = false;          // variable used to save a single frame as a PDF page

void setup() {
  size(1280, 720, P2D);
  smooth(16); // higher smooth setting = higher quality rendering
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
  // begin recording to PDF
  if(saveOneFrame == true) {
    beginRecord(PDF, "Waves-" + timestamp() + ".pdf"); 
  }
  
  // set colorMode for the sketch to Hue-Saturation-Brightness (HSB)
  // must be called after beginRecord to work for the exported PDF!
  colorMode(HSB, 360, 100, 100);
  
  // the original draw() calls from the Image-Based > Waves code example
  background(BACKGROUND_COLOR);
  float w = float(width) / gridX;
  float h = float(height) / gridY;
  translate(w/2, h/2);
  float fc = frameCount * 0.01;
  // for each 'row'
  for (int y=0; y<gridY; y++) {
    boolean continuous = false;
    // go over all the 'columns'
    for (int x=0; x<gridX; x++) {
      // for each point, determine it's position in the grid
      float vx = x * w;
      float vy = y * h;
      // determine of this point is inside the text
      color c = pg.get(int(vx), int(vy));
      boolean inText = (c == PGRAPHICS_COLOR);
      if (inText) {
        if (!continuous) {
          // when entering the text
          continuous = true;
          fill((vx + 2 * vy + frameCount) % 360, 75, 85);
          beginShape();
          vertex(vx, vy);
        }
        // add a curveVertex point which is moved upwards using noise()
        float n = noise(vx + fc, vy, fc);
        vy -= n * n * waveHeight + baseHeight;
        curveVertex(vx, vy);
      } else {
        if (continuous) {
          // when exiting the text
          continuous = false;
          vertex(vx, vy);
          endShape(CLOSE);
        }
      }
    }
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

