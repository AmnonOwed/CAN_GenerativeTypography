
/*
 * This example shows you how to use the Geomerative and the Hemesh library to:
 *  1. turn a String of text into a 2D shape (using Geomerative)
 *  2. turn a 2D shape into an extruded 3D mesh (using Hemesh)
 *
 * As the first basic 3D example, the code is kept as short and simple
 * as possible and the comments clearly indicate how responsibilities
 * are divided between Processing, Geomerative and Hemesh respectively.
 */

// import the required libraries
import geomerative.*;              // geomerative library for text manipulation and point extraction
import wblut.processing.*;         // hemesh library section for displaying shapes
import wblut.hemesh.*;             // hemesh library section with main HE_Mesh class 
import wblut.geom.*;               // hemesh library section with geometry classes

RFont font;                        // geomerative font used for creating the 3D text
WB_Render render;                  // hemesh class for displaying shapes
HE_Mesh mesh;                      // the main HE_Mesh instance to hold the 3D mesh
String input = "TYPE";             // the input string that is transformed into 3D mesh 

void setup() {
  // Processing
  size(1280, 720, P3D); // of course we need the 3D renderer
  smooth(16); // nice and smooth! ;-)

  // Geomerative
  RG.init(this); // initialize the Geomerative library
  RCommand.setSegmentator(RCommand.UNIFORMSTEP); // settings for the generated shape density
  RCommand.setSegmentStep(2); // settings for the generated shape density
  font = new RFont("../../Fonts/FreeSans.ttf", 350); // create font used by Geomerative

  // Hemesh
  render = new WB_Render(this); // setup the hemesh render class for displaying shapes

  // the two methods (see below) that do the actual work in this sketch 
  mesh = createHemeshFromString(input); // create a 3D mesh from an input string (using Geomerative & Hemesh)
  colorFaces(mesh); // color the faces of the generated mesh using a bit of custom code
}

void draw() {
  background(255);
  perspective(PI/3.0, (float) width/height, 1, 1000000);
  lights();
  translate(width/2, height/2);
  rotateY(frameCount * 0.01);

  // display colored faces and subtle edge lines
  stroke(0, 125);
  strokeWeight(0.5);
  HE_Face[] faces = mesh.getFacesAsArray();
  for (int i=0; i<faces.length; i++) {
    fill(faces[i].getLabel()); // colors are stored in each Face's label (see colorFaces method below)
    render.drawFace(faces[i], false, mesh);
  }
}

// Turn a string into a 3D HE_Mesh
HE_Mesh createHemeshFromString(String s) {
  // Geomerative
  RMesh rmesh = font.toGroup(s).toMesh(); // create a 2D mesh from a text
  rmesh.translate(-rmesh.getWidth()/2, rmesh.getHeight()/2); // center the mesh

  // Hemesh
  ArrayList <WB_Triangle> triangles = new ArrayList <WB_Triangle> (); // holds the 2D mesh
  ArrayList <WB_Triangle> trianglesFlipped = new ArrayList <WB_Triangle> (); // holds the flipped 2D mesh (for a mirror-closed 3D shape!)
  // extract the triangles from the 2D mesh and place them in the respective lists
  WB_Triangle t, tFlipped;
  for (int i=0; i<rmesh.strips.length; i++) {
    RPoint[] pnts = rmesh.strips[i].getPoints();
    for (int j=2; j<pnts.length; j++) {
      WB_Point a = new WB_Point(pnts[j-2].x, pnts[j-2].y, 0);
      WB_Point b = new WB_Point(pnts[j-1].x, pnts[j-1].y, 0);
      WB_Point c = new WB_Point(pnts[j].x, pnts[j].y, 0);
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

  // Creating a quality extruded 3D HE_Mesh in 4 steps
  
  // 1. create the base 3D Hemesh from the triangles of the 2D text shape
  // (at this point you basically have a 2D text shape stored in a HE_Mesh)
  HE_Mesh tmesh = new HE_Mesh(new HEC_FromTriangles().setTriangles(triangles));
  
  // 2. extrude the base mesh by a certain distance
  // (at this point you have an extruded shape, but it is open on the side where the original 2D base shape was!)
  tmesh.modify(new HEM_Extrude().setDistance(100));
  
  // 3. add the flipped faces to the extruded base mesh
  // (at this point we add the flipped faces to closes the mesh, the flipping ensures correct, outward normals) 
  tmesh.add(new HE_Mesh(new HEC_FromTriangles().setTriangles(trianglesFlipped)));
  
  // 4. now we return the final mesh
  // (we could just return tmesh, but to create a quality internal structure, which will be useful
  // later for mesh manipulation, the whole shape is recreated from polygon soup before returning it)
  return new HE_Mesh(new HEC_FromPolygons(tmesh.getPolygons()));
}

// color each face in the mesh based on it's xy-position using HSB colormode
void colorFaces(HE_Mesh mesh) {
  colorMode(HSB, 1);
  for (HE_Face face : mesh.getFacesAsArray ()) {
    WB_Point c = face.getFaceCenter();
    face.setLabel(color(map(c.xf() + c.yf(), -500, 500, 0, 1), 1, 1));
  }
  colorMode(RGB, 255);
}

