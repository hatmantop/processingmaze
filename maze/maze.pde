int blocksize = 35;
int blockgap = 5;
int w = 8;
int h = 8;
int offset = 100;
int selStartX;
int selStartY;
boolean startSelect;

int selEndX;
int selEndY;
boolean endSelect;

boolean[][] vWalls;
boolean[][] hWalls;

void setup() {
  size(500, 500);
  background(255);
  vWalls = new boolean[h][w+1];
  hWalls = new boolean[h+1][w];
  selStartX = -1;
  selStartY = -1;
  selEndX = -1;
  selEndY = -1;
}

void draw() {
  background(255);
  fill(200);
  noStroke();

  // draw vWalls;
  for (int i = 0; i < h; i++) {
    for (int j = 0; j < w + 1; j++) {
      int xPos = offset + j * (blocksize + blockgap) - blockgap;
      int yPos = offset + i * (blocksize + blockgap);
      if (vWalls[i][j]) {
        fill(0);
      } else {
        if (mouseX >= xPos && mouseX <= xPos + blockgap && mouseY >= yPos && mouseY <= yPos + blocksize) {
          fill(125, 30, 30);
        } else {
          fill(200);
        }
      }
      rect(xPos, yPos, blockgap, blocksize);
    }
  }

  fill(0, 0, 255);
  for (int i = 0; i < h + 1; i++) {
    for (int j = 0; j < w; j++) {
      int xPos = offset + j * (blocksize + blockgap);
      int yPos = offset + i * (blocksize + blockgap) - blockgap;
      if (hWalls[i][j]) {
        fill(0);
      } else {
        if (mouseX >= xPos && mouseX <= xPos + blocksize && mouseY >= yPos && mouseY <= yPos + blockgap) {
          fill(125, 30, 30);
        } else {
          fill(200);
        }
      }
      rect(xPos, yPos, blocksize, blockgap);
    }
  }
  if (selStartX >= 0) {
    fill(0, 255, 0);
    rect(offset + selStartX * (blocksize + blockgap), offset + selStartY * (blocksize + blockgap), blocksize, blocksize);
  }
  if (selEndX >= 0) {
    fill(255, 0, 0);
    rect(offset + selEndX * (blocksize + blockgap), offset + selEndY * (blocksize + blockgap), blocksize, blocksize);
  }
}

void mousePressed() {
  if (startSelect || endSelect) {
    for (int i = 0; i < h; i++) {
      for (int j = 0; j < w; j++) {
        int xPos = offset + j * (blocksize + blockgap);
        int yPos = offset + i * (blocksize + blockgap);
        if (mouseX >= xPos && mouseX <= xPos + blocksize && mouseY >= yPos && mouseY <= yPos + blocksize) {
          println("in block");
          int row = (mouseY - offset) / (blocksize + blockgap);
          int col = (mouseX - offset) / (blocksize + blockgap);
          println("row: " + row);
          println("col: " + col);
          if(startSelect) {
            selStartX = col;
            selStartY = row;
          } else {
            selEndX = col;
            selEndY = row;
          } 
        }
      }
    }
  } else {
    //println("clicked");
    for (int i = 0; i < h + 1; i++) {
      for (int j = 0; j < w; j++) {
        int xPos = offset + j * (blocksize + blockgap);
        int yPos = offset + i * (blocksize + blockgap) - blockgap;
        if (mouseX >= xPos && mouseX <= xPos + blocksize && mouseY >= yPos && mouseY <= yPos + blockgap) {
          println("hWall");
          int col = (mouseX - offset) / (blocksize + blockgap);
          int row = (mouseY - offset + blockgap) / (blocksize + blockgap);
          println("row: " + row);
          println("col: " + col);
          hWalls[row][col] = !hWalls[row][col];
          return;
        }
      }
    }
    for (int i = 0; i < h; i++) {
      for (int j = 0; j < w + 1; j++) {
        int xPos = offset + j * (blocksize + blockgap) - blockgap;
        int yPos = offset + i * (blocksize + blockgap);
        if (mouseX >= xPos && mouseX <= xPos + blockgap && mouseY >= yPos && mouseY <= yPos + blocksize) {
          println("vWall");
          int col = (mouseX - offset + blockgap) / (blocksize + blockgap);
          int row = (mouseY - offset) / (blocksize + blockgap);
          println("row: " + row);
          println("col: " + col);
          vWalls[row][col] = !vWalls[row][col];
        }
      }
    }
  }
}

void keyPressed() {
  if (key == 'g') {
    println("constructing maze...");
    if(selStartX < 0 || selEndX < 0) {
      println("select a start and end");
      return;
    }
    MazeRecord m = new MazeRecord(h, w, selStartX, selStartY, selEndX, selEndY, vWalls, hWalls);
    println("" + m.isValid());
    m.printInfo();
  } else if (key == 's') {
    startSelect = !startSelect;
    endSelect = false;
    if (startSelect) {
      println("Select start mode ON");
    } else {
      println("Select start mode OFF");
    }
  } else if (key == 'e') {
    endSelect = !endSelect;
    startSelect = false;
    if (endSelect) {
      println("Select end mode ON");
    } else {
      println("Select end mode OFF");
    }
  } else if (key == 'w') {
    startSelect = false;
    endSelect = false;
    println("Wall mode ON");
  }
}
