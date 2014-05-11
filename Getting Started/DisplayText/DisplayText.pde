
/*
 * The setup() method runs once at the beginning of the program.
 * Here you do the initial setup, for example:
 * - Set the dimensions and renderer of the main display window
 * - Load things (i.e. fonts, images, data)
 * - Make initial settings (i.e. text size, align, frameRate)
 */
void setup() {
  size(640, 360); // set dimensions to width 640, height 360
  textSize(175); // set the text rendering size to 175
  textAlign(CENTER, CENTER); // center the text horizontally and vertically
}

/*
 * The draw() method runs continuously ad infinitum
 * Here you put the code you need to run each frame, for example:
 * - Update things (i.e. position, adding/removing objects)
 * - Display things (i.e. 2d and 3d shapes, text, UI)
 */
void draw() {
  background(255); // clear the background with a white color
  fill(0); // set the text fill color to black
  // display the String "TYPE" in the center of the display window
  text("TYPE", width/2, height/2); 
}

