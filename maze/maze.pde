final int blocksize = 35;
final int blockgap = 5;
int w;
int h;
int offset;
int selStartX;
int selStartY;
boolean startSelect;
color bg = color(120,120,120);

int selEndX;
int selEndY;
boolean endSelect;

boolean vis;
MazeViz v;

boolean[][] vWalls;
boolean[][] hWalls;

int[][] path;

void setup() {
  size(1000, 1000);
  background(bg);
  w = (width-blockgap)/(blocksize + blockgap);
  h = (height-blockgap)/(blocksize + blockgap);
  offset = ((width - ((blocksize + blockgap) * w + blockgap)) / 2) + blockgap;
  //offset = blockgap;
  vWalls = new boolean[h][w+1];
  hWalls = new boolean[h+1][w];
  path = null;
  selStartX = -1;
  selStartY = -1;
  selEndX = -1;
  selEndY = -1;
  vis = false;
  v = null;
}

void draw() {
  background(bg);
  fill(200);
  noStroke();
  fill(82, 186, 234);
  rect(offset - blockgap, offset - blockgap, blockgap + w * (blocksize + blockgap), blockgap + h * (blocksize + blockgap));
  if (vis) {
    path = v.step();
  }
  drawPath();
  drawMaze();
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
          if (startSelect) {
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
    if (selStartX < 0 || selEndX < 0) {
      println("select a start and end");
      return;
    }
    MazeRecord m = new MazeRecord(h, w, selStartX, selStartY, selEndX, selEndY, vWalls, hWalls);
    boolean res = m.isValid();
    println("" + res);
    m.printInfo();
    if (res) {
      path = m.findPath();
    }
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
  } else if (key == 'c') {
    println("clearing");
    clear();
  } else if (key == 'r') {
    generateMazeRecursive(false);
  } else if (key == 'f') {
    //displayFoundPath();
  } else if (key == 'v') {
    println("vis");
    doVis();
  }
}

void doVis() {

  if (selStartX < 0 || selEndX < 0) {
    println("select a start and end");
    return;
  }
  vis = true;
  v = new MazeViz(h, w, selStartX, selStartY, selEndX, selEndY, vWalls, hWalls);
  v.startDijkstra();
  path = v.path();
}

void clear() {
  path = null;
  vis = false;
  if (v != null) {
    v.endDijkstra();
    v = null;
  }
  for (int i = 0; i < h; i++) {
    for (int j = 0; j < w + 1; j++) {
      vWalls[i][j] = false;
    }
  }
  for (int i = 0; i < h + 1; i++) {
    for (int j = 0; j < w; j++) {
      hWalls[i][j] = false;
    }
  }
  selStartX = -1;
  selStartY = -1;
  selEndX = -1;
  selEndY = -1;
}

void generateMazeRecursive(boolean rand) {
  clear();
  if (rand) {
    recGenHelpRand(0, w, 0, h);
  } else {
    boolean start = (int) random(2) == 1;
    recGenHelpNoRand(0, w, 0, h, start);
  }
  selStartX = (int) random(w);
  selStartY = (int) random(h);
  selEndX = (int) random(w);
  selEndY = (int) random(h);
  while (selStartX == selEndX && selStartY == selEndY) {
    selEndX = (int) random(w);
    selEndY = (int) random(h);
  }
}

void recGenHelpNoRand(int leftX, int rightX, int upY, int botY, boolean horz) {
  if (rightX - leftX <= 1) {
    horz = true;
  } else if (botY - upY <= 1) {
    horz = false;
  }

  if (horz) {
    if (botY - upY <= 1) {
      return;
    }
    int row = (int) random(upY + 1, botY);
    for (int i = leftX; i < rightX; i++) {
      hWalls[row][i] = true;
    }
    int colGap = (int) random(leftX, rightX);
    hWalls[row][colGap] = false;
    recGenHelpNoRand(leftX, rightX, upY, row, !horz);
    recGenHelpNoRand(leftX, rightX, row, botY, !horz);
  } else {
    if (rightX - leftX <= 1) {
      return;
    }
    int col = (int) random(leftX + 1, rightX);
    for (int i = upY; i < botY; i++) {
      vWalls[i][col] = true;
    }
    int rowGap = (int) random(upY, botY);
    vWalls[rowGap][col] = false;
    recGenHelpNoRand(leftX, col, upY, botY, !horz);
    recGenHelpNoRand(col, rightX, upY, botY, !horz);
  }
}


void recGenHelpRand(int leftX, int rightX, int upY, int botY) {
  /*
  println("leftX: " + leftX);
   println("rightX: " + rightX);
   println("upY: " + upY);
   println("botY: " + botY);
   */

  boolean horz = ((int) random(2) == 1);
  if (rightX - leftX <= 1) {
    horz = true;
  } else if (botY - upY <= 1) {
    horz = false;
  }

  if (horz) {
    if (botY - upY <= 1) {
      return;
    }
    int row = (int) random(upY + 1, botY);
    for (int i = leftX; i < rightX; i++) {
      hWalls[row][i] = true;
    }
    int colGap = (int) random(leftX, rightX);
    hWalls[row][colGap] = false;
    recGenHelpRand(leftX, rightX, upY, row);
    recGenHelpRand(leftX, rightX, row, botY);
  } else {
    if (rightX - leftX <= 1) {
      return;
    }
    int col = (int) random(leftX + 1, rightX);
    for (int i = upY; i < botY; i++) {
      vWalls[i][col] = true;
    }
    int rowGap = (int) random(upY, botY);
    vWalls[rowGap][col] = false;
    recGenHelpRand(leftX, col, upY, botY);
    recGenHelpRand(col, rightX, upY, botY);
  }
}

void export() {
  
}

void load() {
}

void drawPath() {
  if (path != null) {
    for (int i = 0; i < h; i ++) {
      for (int j = 0; j < w; j++) {
        if (path[i][j] == 1) {
          fill(255, 255, 0);
        } else if (path[i][j] == 2) {
          fill(125, 231, 120);
        } else if (path[i][j] == 3) {
          fill(20, 55, 80);
        } else if (path[i][j] == 4) {
          fill(123, 54, 20);
        } else {
          noFill();
        }
        rect(offset + j * (blocksize + blockgap), offset + i * (blocksize + blockgap), blocksize, blocksize);
      }
    }
  } else { 
    println("path is null");
  }
}

void drawMaze() {


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
          fill(100, 186, 255);
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
          fill(100, 186, 255);
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