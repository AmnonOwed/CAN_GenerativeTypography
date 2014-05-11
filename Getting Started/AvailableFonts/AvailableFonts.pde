
/*
 * This sketch can provide you with the list of fonts
 * on your computer that is available to Processing.
 * Set the boolean 'saveFontNames' to either:
 * FALSE > prints the list of available fonts to the Processing console (black area at the bottom of the PDE)
 * TRUE  > creates a text file with the list of available fonts in the specified folder / file
 */

boolean saveFontNames = false; // toggle this to either print to console or save to a specified file 

void setup() {
  if (saveFontNames) {
    selectOutput("Select output folder & filename", "availableFonts");
  } else {
    printArray(PFont.list());
    exit();
  }
}

void availableFonts(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    saveStrings(selection.getAbsolutePath(), PFont.list());
  }
  exit();
}

