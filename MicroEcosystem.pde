// PostFX can be installed from Processing directly in the Sketch tab
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import java.util.*;

PostFX fx;
Palette palette;

Cells cells;
Viruses viruses;

PVector center; // Center of the screen

void setup() {
  size(1000, 1000, P3D);
  frameRate(60);
  smooth(8);
  
  center = new PVector(width * 0.5, height * 0.5);
  palette = new Palette();
  palette.loadPalette("palette_boreal");  // Loading a custom palette

  cells = new Cells();
  viruses = new Viruses();
  
  fx = new PostFX(this);
}

void draw() {
  background(0);

  cells.run();
  viruses.run();

  fx.render().brightPass(0.1).blur(3,0.8).bloom(0.1, 30, 10).compose();

  // If either of the team wins, we stop the simulation
  if ( cells.cells.size() == 0 || viruses.viruses.size() == 0 ) {
    exit();
  }
}
