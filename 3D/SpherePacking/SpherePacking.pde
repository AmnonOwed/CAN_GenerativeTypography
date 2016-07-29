
/*
 * Spheres are generated in the 3D text mesh and grow until they overlap. The code
 * is an adapted combination of the CirclePacking and FlowField3D examples. Once
 * the Sphere has reached the max radius or is overlapping, it is added to a PShape
 * for quick display on the GPU.
 * 
 * WARNING: may be a little sluggish intially when growing Spheres are displayed in
 *          immediate mode and then added to the PShape
 * 
 * USAGE:
 * - move the mouse horizontally (mouseX) to rotate horizontally (around the Y axis)
 * - move the mouse vertically (mouseY) to zoom in and out
 */

// import the required libraries
import geomerative.*;              // geomerative library for text manipulation and point extraction
import wblut.hemesh.*;             // hemesh library section with main HE_Mesh class 
import wblut.geom.*;               // hemesh library section with geometry classes

RFont font;                        // geomerative font used for creating the 3D text
HE_Mesh mesh;                      // the main HE_Mesh instance to hold the 3D mesh
WB_AABB boundingBox;               // the bounding box of the main mesh
PVector min, max;                  // the bounding box of the main mesh in PVector format
ArrayList <Sphere> spheres;        // list to hold the Spheres
PShape shape;                      // PShape to hold the grown Spheres for quick display on the GPU
String input = "TYPE";             // the input string that is transformed into a 3D mesh 
int numSpheres = 3500;             // the maximum number of Spheres
int addSpeed = 25;                 // the number of Spheres that is added per draw() loop

void setup() {
  // Processing
  size(1280, 720, P3D); // of course we need the 3D renderer
  smooth(16); // nice and smooth! ;-)

  // Geomerative
  RG.init(this); // initialize the Geomerative library
  RCommand.setSegmentator(RCommand.UNIFORMSTEP); // settings for the generated shape density
  RCommand.setSegmentStep(2); // settings for the generated shape density
  font = new RFont("../../Fonts/FreeSans.ttf", 350); // create the font used by Geomerative

  // call the methods (see below) that do the actual work in this sketch
  mesh = createHemeshFromString(input); // create a 3D mesh from an input string (using Geomerative & Hemesh)
  getBoundaries(); // get the boundaries for efficient point generation and boundary checks
  spheres = new ArrayList <Sphere> (); // create list to hold the Spheres
  shape = createShape(GROUP); // create container shape for the grown Spheres for quick display on the GPU
  sphereDetail(18); // set the sphereDetail for the Spheres (both in immediate and retained mode)
}

void draw() {
  background(0); // clear the background
  perspective(PI/3.0, (float) width/height, 1, 1000000); // wide clipping planes
  lights(); // add general Processing lights
  translate(width/2, height/2, map(mouseY, 0, height, 450, -350)); // center the shape on screen, zoom with mouseY
  rotateY(map(mouseX, 0, width, -PI, PI)); // rotate around the Y axis with mouseX

  if (spheres.size() < numSpheres) { for (int i=0; i<addSpeed; i++) spheres.add(new Sphere()); } // add N Spheres until the maximum is reached
  for (Sphere s : spheres) {
    s.update(); // grow Spheres until they overlap
    s.display(); // growing Spheres are shown separately via immediate mode
  }
  shape(shape); // all grown Spheres are shown via a single retained mode PShape
  surface.setTitle("Added to PShape: " + shape.getChildCount() + " of " + numSpheres + (shape.getChildCount()==numSpheres ? " (completed)" : " (may be sluggish while growing Spheres)"));
}

// Turn a string into a 3D HE_Mesh
HE_Mesh createHemeshFromString(String s) {
  RMesh rmesh = font.toGroup(s).toMesh(); // create a 2D mesh from a text
  rmesh.translate(-rmesh.getWidth()/2, rmesh.getHeight()/2); // center the mesh

  ArrayList <WB_Triangle> triangles = new ArrayList <WB_Triangle> (); // holds the original 2D text mesh
  ArrayList <WB_Triangle> trianglesFlipped = new ArrayList <WB_Triangle> (); // holds the flipped 2D text mesh
  RPoint[] pnts;
  WB_Triangle t, tFlipped;
  WB_Point a, b, c;
  // extract the triangles from geomerative's 2D text mesh, then place them
  // as hemesh's 3D WB_Triangle's in their respective lists (normal & flipped)
  for (int i=0; i<rmesh.strips.length; i++) {
    pnts = rmesh.strips[i].getPoints();
    for (int j=2; j<pnts.length; j++) {
      a = new WB_Point(pnts[j-2].x, pnts[j-2].y, 0);
      b = new WB_Point(pnts[j-1].x, pnts[j-1].y, 0);
      c = new WB_Point(pnts[j].x, pnts[j].y, 0);
      if (j % 2 == 0) {
        t = new WB_Triangle(a, b, c);
        tFlipped = new WB_Triangle(c, b, a);
      } else {
        t = new WB_Triangle(c, b, a);
        tFlipped = new WB_Triangle(a, b, c);
      }
      // add the original and the flipped triangle (to close the 3D shape later on) to their respective lists
      triangles.add(t);
      trianglesFlipped.add(tFlipped);
    }
  }

  HE_Mesh tmesh = new HE_Mesh(new HEC_FromTriangles().setTriangles(triangles));
  tmesh.modify(new HEM_Extrude().setDistance(145));
  tmesh.add(new HE_Mesh(new HEC_FromTriangles().setTriangles(trianglesFlipped)));
  tmesh.clean();
  return tmesh;
}

// store boundaries for use later on
void getBoundaries() {
  boundingBox = mesh.getAABB();
  min = new PVector((float)boundingBox.getMinX(), (float)boundingBox.getMinY(), (float)boundingBox.getMinZ());
  max = new PVector((float)boundingBox.getMaxX(), (float)boundingBox.getMaxY(), (float)boundingBox.getMaxZ());
}

