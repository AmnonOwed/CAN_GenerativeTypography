
/*
 * This sketch uses the text drawn to an offscreen PGraphics as the basis
 * for setting the feed and kill rates in a reaction-diffusion simulation,
 * resulting in different patterns inside and outside the text respectively. 
 * 
 * USAGE:
 * - move the mouse around the screen to dynamically change the feed values
 */

RD rd;

color FOREGROUND_COLOR = color(0);
color BACKGROUND_COLOR = color(255);

color PGRAPHICS_COLOR = color(0);
PGraphics pg;
PImage result;

void setup() {
  size(1280, 720);

  // create the offscreen PGraphics with the text 
  pg = createGraphics(width, height, JAVA2D);
  pg.beginDraw();
  pg.textSize(500);
  pg.textAlign(CENTER, CENTER);
  pg.fill(PGRAPHICS_COLOR);
  pg.text("TYPE", pg.width/2, pg.height/2); 
  pg.endDraw();

  // setup the reaction-diffusion simulation
  rd = new RD(320, 180);            // set the width and height of the simulation
  rd.setFeedRates(0.0374, 0.0585);  // set the in & out feed rates (in this sketch also dynamically changed in the draw() loop)
  rd.setKillRates(0.0695, 0.0610);  // set the in & out kill rates
  rd.kickstart(150);                // randomly set N substance values to kickstart the simulation
  rd.setImage(pg);                  // use the offscreen PGraphics to set the division rates
}

void draw() {
  float innerFeedValue = map(mouseY, 0, height, 0.0222, 0.0888);
  float outerFeedValue = map(mouseX, 0, width, 0.0222, 0.0888);
  rd.setFeedRates(innerFeedValue, outerFeedValue);
  rd.step(25); // number of simulation steps per frame
  result = rd.getImage(FOREGROUND_COLOR, BACKGROUND_COLOR);
  image(result, 0, 0, width, height);
}

