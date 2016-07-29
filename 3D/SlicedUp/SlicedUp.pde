
/*
 * This code example shows you how to:
 *  1. turn a String of text into a 2D shape (using Geomerative)
 *  2. turn a 2D shape into an extruded 3D mesh (using Hemesh)
 *  3. manipulate the mesh using modifiers (using Hemesh)
 *
 * In this code example we cut up the mesh into little pieces!
 * Then click the left mouse button... :D
 *
 * USAGE:
 * - click the LEFT mouse to toggle the movement
 * - click the RIGHT mouse to reset the sketch
 * - move the mouse horizontally (mouseX) to rotate horizontally (around the Y axis)
 * - move the mouse vertically (mouseY) to zoom in and out
 *
 * WARNING: Mesh creation may take a while, println's added for notification.
 */

// import the required libraries
import geomerative.*;              // geomerative library for text manipulation and point extraction
import wblut.hemesh.*;             // hemesh library section with main HE_Mesh class 
import wblut.geom.*;               // hemesh library section with geometry classes
import wblut.processing.*;         // hemesh library section for displaying shapes

RFont font;                        // geomerative font used for creating the 3D text
WB_Render render;                  // hemesh class for displaying shapes
HE_Mesh mesh;                      // the main HE_Mesh instance to hold the original 3D mesh
ArrayList <HE_Mesh> meshes;        // the list to hold all the meshes
String input = "TYPE";             // the input string that is transformed into a 3D mesh 
int numIterations = 9;             // the number of times the list of meshes is sliced (warning exponential growth!)
float initialOffset = 0;           // the offset between slices (unused in this sketch, but quite useful for other experiments)
float moveOffset = 0.35;           // the movement speed of the meshes, set to slow-motion so we can see it better
boolean exploding;                 // toggle movement (by left mouse click)

void setup() {
  // Processing
  size(1280, 720, P3D); // of course we need the 3D renderer
  smooth(16); // nice and smooth! ;-)

  // Geomerative
  RG.init(this); // initialize the Geomerative library
  RCommand.setSegmentator(RCommand.UNIFORMSTEP); // settings for the generated shape density
  RCommand.setSegmentStep(2); // settings for the generated shape density
  font = new RFont("../../Fonts/FreeSans.ttf", 350); // create the font used by Geomerative

  // Hemesh
  render = new WB_Render(this); // setup the hemesh render class for displaying shapes

  // call the methods (see below) that do the actual work in this sketch 
  mesh = createHemeshFromString(input); // create a 3D mesh from an input string (using Geomerative & Hemesh)
  colorFaces(mesh); // apply color before cutting up the shape so the inside is not colored (which gives a nice effect) ;-)
  generateMeshes(mesh); // cut the mesh into little pieces!
}

void draw() {
  background(255); // clear the background
  perspective(PI/3.0, (float) width/height, 1, 1000000); // wide clipping planes
  directionalLight(255, 255, 255, 1, 1, -1); // custom lights for more contrast
  directionalLight(127, 127, 127, -1, -1, 1); // custom lights for more contrast
  translate(width/2, height/2, map(mouseY, 0, height, 450, -1000)); // center the shape on screen, zoom with mouseY
  rotateY(map(mouseX, 0, width, -PI, PI)); // rotate around the Y axis with mouseX

  if (exploding) move(meshes, moveOffset); // move the meshes (toggle with left mouse)

  noStroke();
  for (HE_Mesh mesh : meshes) {
    for (HE_Face face : mesh.getFacesAsArray ()) {
      color c = face.getLabel();
      fill(c==-1 ? 255 : c); // inside or colored
      render.drawFace(face, false);
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT) {
    exploding = !exploding; // toggle movement with LEFT mouse click
  } else if (mouseButton == RIGHT) {
    println("Resetting sketch.");
    exploding = false;
    generateMeshes(mesh); // reset sketch with RIGHT mouse click
  }
}

// Turn a string into a 3D HE_Mesh
HE_Mesh createHemeshFromString(String s) {
  println("Creating mesh.");

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
  tmesh.modify(new HEM_Extrude().setDistance(100));
  tmesh.add(new HE_Mesh(new HEC_FromTriangles().setTriangles(trianglesFlipped)));
  tmesh.clean();
  return tmesh;
}

// color each face in the mesh based on it's xy-position using HSB colormode
void colorFaces(HE_Mesh mesh) {
  colorMode(HSB, 1); // set colorMode to HSB
  for (HE_Face face : mesh.getFacesAsArray ()) {
    WB_Coord c = face.getFaceCenter();
    face.setLabel(color(map(c.xf() + c.yf(), -500, 500, 0, 1), 1, 1));
  }
  colorMode(RGB, 255); // (re)set colorMode to RGB
}

// cut the mesh into little pieces
void generateMeshes(HE_Mesh mesh) {
  println("Modifying mesh.");
  meshes = new ArrayList <HE_Mesh> ();
  meshes.add(mesh);
  for (int i=0; i<numIterations; i++) {
    meshes = slice(meshes, initialOffset);
  }
  println("Done.");
}

// cut each mesh in the list
ArrayList <HE_Mesh> slice(ArrayList <HE_Mesh> meshList, float offset) {
  ArrayList <HE_Mesh> newList = new ArrayList <HE_Mesh> ();
  for (HE_Mesh mesh : meshList) {
    WB_Coord center = mesh.getCenter();
    HEMC_SplitMesh multiCreator = new HEMC_SplitMesh();
    multiCreator.setMesh(mesh);
    multiCreator.setOffset(offset);
    multiCreator.setPlane(new WB_Plane(center.xf(), center.xf(), center.xf(), random(-1, 1), random(-1, 1), random(-1, 1)));
    HE_MeshCollection meshCollection = multiCreator.create();
    for (int i=0; i<meshCollection.size(); i++) {
      newList.add(meshCollection.getMesh(i));
    }
  }
  return newList;
}

// the movement
void move(ArrayList <HE_Mesh> meshList, float offset) {
  for (HE_Mesh mesh : meshList) {
    WB_Point center = (WB_Point) mesh.getCenter();
    center.normalizeSelf();
    center.mulSelf(offset);
    mesh.move(center);
  }
}
