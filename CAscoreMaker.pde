
import arb.soundcipher.*;

CA ca;   // An instance object to describe the Wolfram basic Cellular Automata
SCScore score = new SCScore();
SoundCipher sc = new SoundCipher(this);
float[] scale = sc.BLUES;

float scaleMapper(int pitch, float[] mode) {
  int octave = (pitch / (mode.length + 1)) * 12;  
  int offset = round(mode[(pitch - 1) % (mode.length)]);
  
  return offset + octave;
}


void setup() {
  size(640, 980);
  int[] ruleset = {0,0,0,1,1,0,1,0};    // An initial rule system
  ca = new CA(ruleset, 255, 150, 255, 1);                 // Initialize CA
  background(0);
}

void draw() {
  ca.render();    // Draw the CA
  ca.renderAudio();
  ca.generate();  // Generate the next level
  
  if(ca.generation >= 284) {
    float[] pitches = {0};
    score.addChord(285, 3, 1, pitches, 100,1 ,1 ,64);
    score.play();
    score.writeMidiFile("/Users/Abe/Documents/CA_song/output.midi");
    stop();
  }
}

void mousePressed() {
  if(mouseButton == LEFT){

  } else if (mouseButton == RIGHT) { 
    background(0);
    ca.randomize();
    ca.restart(false);
  }  
}



class CA {

  int[] cells;     // An array of 0s and 1s 
  int generation;  // How many generations?
  int scl;         // How many pixels wide/high is each cell?

  int[] rules;     // An array to store the ruleset, for example {0,1,1,0,1,1,0,1}
  
  //color of automaton render
  int red;
  int green;
  int blue;

  int octave;
  
  
  CA(int[] r, int re, int gr, int bl, int oct) {
    octave = oct;
    red = re;
    green = gr;
    blue = bl;
    rules = r;
      scl = 3;
    cells = new int[64];
    restart(false);
  }
  
  // Set the rules of the CA
  void setRules(int[] r) {
    rules = r;
  }
  
  // Make a random ruleset
  void randomize() {
    for (int i = 0; i < 8; i++) {
      rules[i] = int(random(2));
    }
  }
  
  // Reset to generation 0
  // not relevant for my application
  void restart(boolean pause) {
    for (int i = 0; i < cells.length; i++) {
      cells[i] = 0;
    }
    if(!pause)
      cells[32] = 1;    // starting at 30 produces symmetric sirpinski, starting at 1 produces serpentine
    generation = 0;
  }

  // The process of creating the new generation
  void generate() {
    // First we create an empty array for the new values
    int[] nextgen = new int[cells.length];
    // For every spot, determine new state by examing current state, and neighbor states
    // Ignore edges that only have one neighor
    for (int i = 1; i < cells.length-1; i++) {
      int left = cells[i-1];   // Left neighbor state
      int me = cells[i];       // Current state
      int right = cells[i+1];  // Right neighbor state
      nextgen[i] = executeRules(left,me,right); // Compute next generation state based on ruleset
    }
    // Copy the array into current value
    for (int i = 1; i < cells.length-1; i++) {
      cells[i] = nextgen[i];
    }
    //cells = (int[]) nextgen.clone();
    generation++;
  }
  
  // This is the easy part, just draw the cells, fill 255 for '1', fill 0 for '0'
  void render() {
    for (int i = 0; i < cells.length; i++) {
      if (cells[i] == 1) {
        fill(red, green, blue);
      } else { 
        fill(0);
      }
      noStroke();
      rect(i*scl,generation*scl, scl,scl);
    }
  }
  
  void renderAudio() {
    FloatList pitches = new FloatList();
    for (int i = 0; i < cells.length; i++) {
      if (cells[i] == 1) {
        pitches.append(scaleMapper(i + 10, scale));
      }
    }        //every generation is a third of a second //    as generation increases, so does dynamic
    score.addChord(generation / ((sin(generation / 150.0) + 1) / 1.33), 3, 1, pitches.array(), 30 + (generation / 4.0),1 ,1 ,64);
  }
  
  // Implementing the Wolfram rules
  // Could be improved and made more concise, but here we can explicitly see what is going on for each case
  int executeRules (int a, int b, int c) {
    if (a == 1 && b == 1 && c == 1) { return rules[0]; }
    if (a == 1 && b == 1 && c == 0) { return rules[1]; }
    if (a == 1 && b == 0 && c == 1) { return rules[2]; }
    if (a == 1 && b == 0 && c == 0) { return rules[3]; }
    if (a == 0 && b == 1 && c == 1) { return rules[4]; }
    if (a == 0 && b == 1 && c == 0) { return rules[5]; }
    if (a == 0 && b == 0 && c == 1) { return rules[6]; }
    if (a == 0 && b == 0 && c == 0) { return rules[7]; }
    return 0;
  }
  
  // The CA is done if it reaches the bottom of the screen
  boolean half() {
    if (generation > (height/scl) / 2) {
       return true;
    } else {
       return false;
    }
  }
}