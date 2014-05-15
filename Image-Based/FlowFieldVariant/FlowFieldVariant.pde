
/*
 * Simply a visual variant of the main FlowField example! :-)
 * See the main example for more information on the used techniques.
 * 
 * USAGE:
 * - click the mouse to restart the sketch  
 */

int maxParticles = 1000; // the maximum number of active particles
ArrayList <Particle> particles = new ArrayList <Particle> (); // the list of particles
color BACKGROUND_COLOR = color(0);
color PGRAPHICS_COLOR = color(0);
float globalRotation;
PGraphics pg;

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
  background(BACKGROUND_COLOR);
}

void draw() {
  addRemoveParticles();
  // update and display each particle in the list
  for (Particle p : particles) {
    p.update();
    p.display();
  }
}

void mousePressed() {
  background(BACKGROUND_COLOR); // clear the screen
  particles.clear(); // remove all particles
  globalRotation = random(TWO_PI); // randomly set the global rotation/direction of the Particles
}

void addRemoveParticles() {
  // remove particles with no life left
  for (int i=particles.size()-1; i>=0; i--) {
    Particle p = particles.get(i);
    if (p.life <= 0) {
      particles.remove(i);
    }
  }
  // add particles until the maximum
  while (particles.size () < maxParticles) {
    particles.add(new Particle());
  }
}

