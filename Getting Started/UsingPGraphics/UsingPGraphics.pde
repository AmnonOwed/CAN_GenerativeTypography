
/*
 * The PGraphics class can be used for offscreen rendering.
 * You can use all of Processing's default drawing commands on a PGraphics.
 */

PGraphics pg; // initialize PGraphics instance

void setup() {
  size(640, 360); // set dimensions to width 640, height 360
  pg = createGraphics(width, height, JAVA2D); // create a PGraphics the same size as the main sketch display window

  // Now let's draw something to the created PGraphics instance called 'pg'.  
  // Note 1: Always put all drawing commands to a PGraphics between beginDraw/endDraw calls
  // Note 2: Always put the name of the PGraphics (in this case 'pg') plus a . (aka dot) before the drawing commands to a PGraphics
  pg.beginDraw(); // start drawing to the PGraphics
  pg.textSize(175); // set the text rendering size (of the PGraphics!) to 175
  pg.textAlign(CENTER, CENTER); // center the text (of the PGraphics!) horizontally and vertically
  pg.background(255); // clear the background (of the PGraphics!) with a white color
  pg.fill(0); // set the text fill color (of the PGraphics!) to black
  // display the String "TYPE" in the center of the PGraphics
  pg.text("TYPE", pg.width/2, pg.height/2); 
  pg.endDraw(); // finish drawing to the PGraphics
  // For this sketch, we don't be drawing anymore to the PGraphics. We will just display what we have drawn now (see the image() call below).
  
  imageMode(CENTER); // set the image display mode to centered, so the supplied coordinates in image() are the center display coordinates
}

void draw() {
  background(255, 0, 0); // clear the background with a red color
  // A PGraphics is a kind of 'enhanced image' that you can draw to, so it can be easily displayed as any regular image
  // The PGraphics image is centered around (see imageMode() call above) the position of the mouse
  // Try it! Move the mouse around, to move the PGraphics image around
  image(pg, mouseX, mouseY);
}

