
/*
 * This code example shows you how to:
 *  1. turn a String of text into a 2D shape (using Geomerative)
 *  2. turn a 2D shape into an extruded 3D mesh (using Hemesh)
 *  3. store a 3D mesh in a PShape (using Processing)
 *
 * This sketch is visually identical to the Basic3DType example, however
 * the techniques used to display the geometry will allow us to display
 * much higher resolution meshes at realtime frameRates later on. 
 */

// import the required libraries
import geomerative.*;              // geomerative library for text manipulation and point extraction
import wblut.hemesh.*;             // hemesh library section with main HE_Mesh class 
import wblut.geom.*;               // hemesh library section with geometry classes

RFont font;                        // geomerative font used for creating the 3D text
PShape shape;                      // the PShape to store the 3D mesh for fast display on the GPU
String input = "TYPE";             // the input string that is transformed into a 3D mesh 

void setup() {
  // Processing
  size(1280, 720, P3D); // of course we need the 3D renderer
  smooth(16); // nice and smooth! ;-)

  // Geomerative
  RG.init(this); // initialize the Geomerative library
  RCommand.setSegmentator(RCommand.UNIFORMSTEP); // settings for the generated shape density
  RCommand.setSegmentStep(2); // settings for the generated shape density
  font = new RFont("../../Fonts/FreeSans.ttf", 350); // create the font used by Geomerative

  // call the three methods (see below) that do the actual work in this sketch 
  HE_Mesh mesh = createHemeshFromString(input); // create a 3D mesh from an input string (using Geomerative & Hemesh)
  colorFaces(mesh); // color the faces of the generated mesh using a bit of custom code
  shape = createPShapeFromHemesh(mesh, false); // store the HE_Mesh in a PShape for fast display on the GPU
}

void draw() {
  background(255); // clear the background
  perspective(PI/3.0, (float) width/height, 1, 1000000); // wide clipping planes
  lights(); // add general Processing lights
  translate(width/2, height/2); // center the shape on screen
  rotateY(frameCount * 0.01); // rotate around the Y axis
  shape(shape); // display the PShape
}

// Turn a string into a 3D HE_Mesh
HE_Mesh createHemeshFromString(String s) {
  
  // Geomerative
  RMesh rmesh = font.toGroup(s).toMesh(); // create a 2D mesh from a text
  rmesh.translate(-rmesh.getWidth()/2, rmesh.getHeight()/2); // center the mesh

  // Geomerative & Hemesh
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

  // Hemesh
  // Creating a quality extruded 3D HE_Mesh in 4 steps
  
  // 1. create the base 3D HE_Mesh from the triangles of the 2D text shape
  // (at this point you basically have a 2D text shape stored in a 3D HE_Mesh)
  HE_Mesh tmesh = new HE_Mesh(new HEC_FromTriangles().setTriangles(triangles));
  
  // 2. extrude the base mesh by a certain distance
  // (at this point you have an extruded shape, but it is open on the side where the original 2D base shape was!)
  tmesh.modify(new HEM_Extrude().setDistance(100));
  
  // 3. add the flipped faces to the extruded base mesh
  // (at this point we add the flipped faces to closes the mesh, the flipping ensures correct, outward normals) 
  tmesh.add(new HE_Mesh(new HEC_FromTriangles().setTriangles(trianglesFlipped)));
  
  // 4. create a quality internal structure (useful for the mesh manipulations in subsequent examples)
  tmesh.clean();
  
  // Done! Return the HE_Mesh...
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

// store the geometry from a HE_Mesh in a PShape for quick display on the GPU
PShape createPShapeFromHemesh(HE_Mesh mesh, boolean perVertexNormals) {
  mesh.triangulate(); // ensure it's triangles only

  // get all the shape data from the HE_Mesh
  int[][] facesHemesh = mesh.getFacesAsInt();
  float[][] verticesHemesh = mesh.getVerticesAsFloat();
  HE_Face[] faceArray = mesh.getFacesAsArray();
  WB_Coord normal = null;
  WB_Coord[] vertexNormals = null;
  if (perVertexNormals) { vertexNormals = mesh.getVertexNormals(); }

  // create a PShape from the HE_Mesh shape data
  PShape shape = createShape();
  shape.beginShape(TRIANGLES);
  shape.stroke(0, 125);
  shape.strokeWeight(0.5);
  for (int i=0; i<facesHemesh.length; i++) {
    if (!perVertexNormals) { normal = faceArray[i].getFaceNormal(); }
    shape.fill(faceArray[i].getLabel());
    for (int j = 0; j < 3; j++) {
      int index = facesHemesh[i][j];
      float[] vertexHemesh = verticesHemesh[index];
      if (perVertexNormals) { normal = vertexNormals[index]; }
      shape.normal(normal.xf(), normal.yf(), normal.zf());
      shape.vertex(vertexHemesh[0], vertexHemesh[1], vertexHemesh[2]);
    }
  }
  shape.endShape();
  
  // return the PShape
  return shape;
}

