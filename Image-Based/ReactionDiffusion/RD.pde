
/*
 * Class that handles the following:
 * - 2D reaction-diffusion simulation
 * - Setting division rates with a PImage / PGraphics
 * - Getting the result of the simulation as a custom-colored PImage
 */

class RD {
  int w, h;          // 2D dimensions
  int arrayLength;   // Array length for all arrays (w * h)
  float[] A, An, Ad; // Substance A (value, next value, diffusion rate)
  float[] B, Bn, Bd; // Substance B (value, next value, diffusion rate)
  int[][] N;         // Neighbour references for diffusion method (4 in 2D: left, right, up, down)
  float[] F;         // Feed rates (2)
  float[] K;         // Kill rates (2)
  float[] D;         // Division rates
  PImage image;      // Visual output

  RD(int w, int h) {
    this.w = w;
    this.h = h;
    arrayLength = w * h;
    setupNeighbourMap();
    setupDefaults();
    image = createImage(w, h, RGB);
  }

  // Creates a neighbor map for neighbour lookup acceleration
  void setupNeighbourMap() {
    N = new int[arrayLength][4];
    for (int i=0;i<w;i++) {
      for (int j=0;j<h;j++) {
        int p = i + j*w;
        if (i == 0)     N[p][0] = p + (w-1);    else N[p][0] = p - 1;
        if (i == w - 1) N[p][1] = p - (w-1);    else N[p][1] = p + 1;
        if (j == 0)     N[p][2] = p + w*(h-1);  else N[p][2] = p - w;
        if (j == h - 1) N[p][3] = p - w*(h-1);  else N[p][3] = p + w;
      }
    }
  }

  // Setup arrays and default values
  void setupDefaults() {
    A  = new float[arrayLength];
    An = new float[arrayLength];
    Ad = new float[arrayLength];

    B  = new float[arrayLength];
    Bn = new float[arrayLength];
    Bd = new float[arrayLength];

    F  = new float[2];
    K  = new float[2];

    D = new float[arrayLength];

    for (int i=0;i<arrayLength;i++) {
      A[i] = An[i] = 1.0f;
      B[i] = Bn[i] = 0.0f;

      Ad[i] = 0.5f;
      Bd[i] = 0.25f;
    }
  }
  
  void setFeedRates(float f0, float f1) {
    F[0] = f0;
    F[1] = f1;
  }

  void setKillRates(float k0, float k1) {
    K[0] = k0;
    K[1] = k1;
  }

  void step(int numSteps) {
    for (int i=0; i<numSteps; i++) {
      diffusion();
      reaction();
    }
  }

  // Diffusion method (makes use of a neighbour map for speedup)
  void diffusion() {
    for (int i=0;i<w;i++) {
      for (int j=0;j<h;j++) {
        int p = i+j*w;
        int[] P = N[p];
        An[p] = A[p] + Ad[p] * ((A[P[0]] + A[P[1]] + A[P[2]] + A[P[3]] - 4*A[p] ) / 4.0f);
        Bn[p] = B[p] + Bd[p] * ((B[P[0]] + B[P[1]] + B[P[2]] + B[P[3]] - 4*B[p] ) / 4.0f);
      }
    }
    // after calculating next matrix, set it as current matrix
    A = An;
    B = Bn;
  }

  // Reaction method (Gray-Scott)
  void reaction() {
    for (int i=0;i<w;i++) {
      for (int j=0;j<h;j++) {
        int p = i + j*w;
        float a = A[p];
        float b = B[p];
        float ab2 = a * b * b;
        // use the division rate to determine this cells feed and kill rate
        float feedRate = D[p] * F[0] + (1-D[p]) * F[1];
        float killRate = D[p] * K[0] + (1-D[p]) * K[1];
        A[p] = A[p] - ab2 + feedRate * ( 1.0f - a );
        B[p] = B[p] + ab2 - (feedRate + killRate) * b;
      }
    }
  }

  // randomly set substance values to kickstart the simulation
  void kickstart(int num) {
    for (int i=0; i<num; i++) {
      B[int(random(arrayLength))] = 1.0f;
    }
  }
  
  // set the division rates based on the ALPHA (!) values of the input image
  void setImage(PImage input) {
    input.copy().resize(w, h); // resize input image to simulation dimensions
    for (int i=0;i<arrayLength;i++) {
      int a = (input.pixels[i] >> 24) & 0xFF; // bitshift alpha
      D[i] = a / 255.0;
    }
  }
  
  // return the visual output of the simulation
  PImage getImage(color c1, color c2) {
    image.loadPixels();
    for (int i=0; i<image.pixels.length; i++) {
      image.pixels[i] = lerpColor(c1, c2, rd.A[i] * rd.A[i]);
    }
    image.updatePixels();
    return image;
  }
}

