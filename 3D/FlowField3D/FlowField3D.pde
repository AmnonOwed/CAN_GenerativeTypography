
/*
 * A particle system is run from setup() to create 3D trails originating from the text mesh.
 * The velocities of the particles are determined by a 3D vector field. The meshes for both
 * the text and the particles are generated once, then stored in PShapes for quick display.
 * 
 * USAGE:
 * - move the mouse horizontally (mouseX) to rotate horizontally (around the Y axis)
 * - move the mouse vertically (mouseY) to zoom in and out
 *
 * WARNING: Mesh creation (text, particles) may take a while, println's added for notification.
 */

// import the required libraries
import geomerative.*;              // geomerative library for text manipulation and point extraction
import wblut.hemesh.*;             // hemesh library section with main HE_Mesh class 
import wblut.geom.*;               // hemesh library section with geometry classes

RFont font;                        // geomerative font used for creating the 3D text
HE_Mesh mesh;                      // the main HE_Mesh instance to hold the 3D mesh
WB_AABB boundingBox;               // the bounding box of the main mesh
PVector min, max;                  // the bounding box of the main mesh in PVector format
PShape shape, particleShape;       // the PShapes to store the 3D meshes (text and particles) for fast display on the GPU

String input = "TYPE";             // the input string that is transformed into a 3D mesh 
int maxParticles = 2750;           // the number of initial particles
int maxHistoryStates = 115;        // the length of the trail per particle
float maxStrokeWeight = 10;        // the maximum / initial strokeWeight of each particle trail

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
  getBoundaries(); // get the boundaries for efficient point generation, boundary checks and colors
  particleShape = createPShapeFromParticles(); // creating the particle shape before subdividing the mesh is less accurate, but much faster
  manipulateMesh(mesh); // apply modifiers to the HE_Mesh to subdivide and distort it
  colorFaces(mesh); // color the faces of the generated mesh using a bit of custom code
  shape = createPShapeFromHemesh(mesh, false); // store the HE_Mesh in a PShape for fast display on the GPU
}

void draw() {
  background(255); // clear the background
  perspective(PI/3.0, (float) width/height, 1, 1000000); // wide clipping planes
  directionalLight(255, 255, 255, 1, 1, -1); // custom lights for more contrast
  directionalLight(127, 127, 127, -1, -1, 1); // custom lights for more contrast
  translate(width/2, height/2, map(mouseY, 0, height, 450, -100)); // center the shape on screen, zoom with mouseY
  rotateY(map(mouseX, 0, width, -PI, PI)); // rotate around the Y axis with mouseX
  shape(shape); // display the text PShape
  shape(particleShape); // display the particle PShape
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

// store boundaries for use later on
void getBoundaries() {
  boundingBox = mesh.getAABB();
  min = new PVector((float)boundingBox.getMinX(), (float)boundingBox.getMinY(), (float)boundingBox.getMinZ());
  max = new PVector((float)boundingBox.getMaxX(), (float)boundingBox.getMaxY(), (float)boundingBox.getMaxZ());
}

// in this sketch the whole particle system is created and run from inside setup(), the end result is a PShape
PShape createPShapeFromParticles() {
  println("Adding " + maxParticles + " particles.");
  ArrayList <Particle> particles = new ArrayList <Particle> ();  
  while (particles.size () < maxParticles) { particles.add(new Particle()); }

  println("Running particle system " + maxHistoryStates + " times.");
  for (int i=0; i<maxHistoryStates; i++) {
    for (Particle p : particles) {
      p.update();
    }
  }

  println("Creating particle PShape.");
  PShape group = createShape(GROUP);
  for (Particle p : particles) {
    // each particle trail is a separate PShape child
    group.addChild(p.getPShape());
  }
  return group;
}

// manipulate the mesh (this may cause some differences with the particle trail starting points, which were based on the original text mesh)
void manipulateMesh(HE_Mesh mesh) {
  println("Modifying mesh.");

  // A random selection + order of subdividers & modifiers ;-)
  mesh.subdivide(new HES_CatmullClark()); // subdivide all
  mesh.subdivideSelected(new HES_CatmullClark(), getRandomSelection(mesh, 0.05)); // subdivide selection
  mesh.modifySelected(new HEM_VertexExpand().setDistance(10), getRandomSelection(mesh, 0.10)); // vertex expand selection
  mesh.modifySelected(new HEM_Extrude().setDistance(15).setRelative(true).setChamfer(0.55), getRandomSelection(mesh, 0.2)); // extrude selection
  mesh.modifySelected(new HEM_Extrude().setDistance(10).setRelative(true).setChamfer(0.75), getRandomSelection(mesh, 0.1)); // extrude selection
  mesh.subdivideSelected(new HES_CatmullClark(), getRandomSelection(mesh, 0.05)); // subdivide selection
}

// get a random selection of faces from the mesh, given a certain threshold
HE_Selection getRandomSelection(HE_Mesh mesh, float threshold) {
  HE_Selection selection = new HE_Selection(mesh);
  for (HE_Face face : mesh.getFacesAsArray ()) {
    if (random(1) < threshold) selection.add(face);
  }
  return selection;
}

// color each face in the mesh based on it's xy-position using HSB colormode
void colorFaces(HE_Mesh mesh) {
  colorMode(HSB, 1); // set colorMode to HSB
  for (HE_Face face : mesh.getFacesAsArray ()) {
    WB_Coord c = face.getFaceCenter();
    face.setLabel(color(map(c.xf() + c.yf(), -500, 500, 0.15, 0.65), 0.65, 1));
  }
  colorMode(RGB, 255); // (re)set colorMode to RGB
}

// store the geometry from a HE_Mesh in a PShape for quick display on the GPU
PShape createPShapeFromHemesh(HE_Mesh mesh, boolean perVertexNormals) {
  println("Triangulating mesh.");
  mesh.triangulate(); // ensure it's triangles only (CPU-intensive, but necessary)

  // get all the shape data from the HE_Mesh
  int[][] facesHemesh = mesh.getFacesAsInt();
  float[][] verticesHemesh = mesh.getVerticesAsFloat();
  HE_Face[] faceArray = mesh.getFacesAsArray();
  WB_Coord normal = null;
  WB_Coord[] vertexNormals = null;
  if (perVertexNormals) { 
    vertexNormals = mesh.getVertexNormals();
  }

  println("Storing mesh in PShape.");
  // create a PShape from the HE_Mesh shape data
  PShape shape = createShape();
  shape.beginShape(TRIANGLES);
  shape.stroke(0, 125);
  shape.strokeWeight(0.5);
  for (int i=0; i<facesHemesh.length; i++) {
    if (!perVertexNormals) { 
      normal = faceArray[i].getFaceNormal();
    }
    shape.fill(faceArray[i].getLabel());
    for (int j = 0; j < 3; j++) {
      int index = facesHemesh[i][j];
      float[] vertexHemesh = verticesHemesh[index];
      if (perVertexNormals) { 
        normal = vertexNormals[index];
      }
      shape.normal(normal.xf(), normal.yf(), normal.zf());
      shape.vertex(vertexHemesh[0], vertexHemesh[1], vertexHemesh[2]);
    }
  }
  shape.endShape();

  println("Done.");
  // return the PShape
  return shape;
}

