
/*
 * The default text font in Processing is 'Lucida Sans'.
 * The textFont() method can be used to set a custom font.
 */

void setup() {
  size(640, 360); // set dimensions to width 640, height 360
  // Create the PFont from a font that is on YOUR computer
  // See the 'AvailableFonts' example for ways to get the list of possible fonts
  PFont f = createFont("Courier", 175); // create the font and set the text rendering size to 175
  textFont(f); // use the font for upcoming text rendering (i.e. when using the text() method)
  textAlign(CENTER, CENTER); // center the text horizontally and vertically
}

void draw() {
  background(255); // clear the background with a white color
  fill(0); // set the text fill color to black
  // display the String "TYPE" in the center of the display window
  text("TYPE", width/2, height/2); 
}

