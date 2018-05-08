class MazeRecord {
  int hite;
  int wide;
  MazeNode start;
  MazeNode end;
  MazeNode[][] nodes;

  MazeRecord(int h, int w, int startX, int startY, int endX, int endY, boolean[][] vWalls, boolean[][] hWalls) {
    hite = h;
    wide = w;
    nodes = new MazeNode[h][w];

    for ( int i = 0; i < h; i++ ) {
      for (int j = 0; j < w; j++ ) {
        nodes[i][j] = new MazeNode();
      }
    }

    //setup vertical links
    for (int row = 1; row < h; row++) {
      for (int col = 0; col < w; col++) {
        MazeNode top = nodes[row - 1][col];
        MazeNode bot = nodes[row][col];
        boolean val = !hWalls[row][col];
        bot.up = new MazeLink(top, val);
        top.down = new MazeLink(bot, val);
      }
    }

    //setup horizontal links
    for (int row = 0; row < h; row++) {
      for (int col = 1; col < w; col++) {
        MazeNode left = nodes[row][col - 1];
        MazeNode right = nodes[row][col];
        boolean val = !vWalls[row][col];
        left.right = new MazeLink(right, val);
        right.left = new MazeLink(left, val);
      }
    }

    start = nodes[startY][startX];
    end = nodes[endY][endX];
  }

  boolean isValid() {
    boolean val = recValid(start);
    for (MazeNode[] col : nodes) {
      for (MazeNode n : col) {
        n.seen = false;
      }
    }
    return val;
  }

  void printInfo() {
    for (int i = 0; i < hite; i++) {
      for (int j = 0; j < wide; j++) {
        print("" + i + "," + j + " ");
        MazeNode n = nodes[i][j];
        if (n.up == null) {
          print("n");
        } else if (n.up.ok) {
          print("u");
        } else {
          print(" ");
        }

        if (n.down == null) {
          print("n");
        } else if (n.down.ok) {
          print("d");
        } else {
          print(" ");
        }

        if (n.right == null) {
          print("n");
        } else if (n.right.ok) {
          print("r");
        } else {
          print(" ");
        }

        if (n.left == null) {
          print("n");
        } else if (n.left.ok) {
          print("l");
        } else {
          print(" ");
        }
        print("\t");
      }
      println();
    }
  }

  boolean recValid(MazeNode m) {

    if (m == end) {
      return true;
    } else if (m.seen) {
      return false;
    } else {
      m.seen = true;
      boolean upG, downG, rightG, leftG;
      if (m.up != null && m.up.ok) {
        upG = recValid(m.up.pair);
      } else {
        upG = false;
      }
      
      if (m.down != null && m.down.ok) {
        downG = recValid(m.down.pair);
      } else {
        downG = false;
      }

      if (m.right != null && m.right.ok) {
        rightG = recValid(m.right.pair);
      } else {
        rightG = false;
      }

      if (m.left != null && m.left.ok) {
        leftG = recValid(m.left.pair);
      } else {
        leftG = false;
      }
      return upG || rightG || downG || leftG;
    }
  }

  class MazeNode {
    MazeLink up;
    MazeLink down;
    MazeLink right;
    MazeLink left;
    boolean seen;

    MazeNode() {
      seen = false;
      up = null;
      down = null;
      right = null;
      left = null;
    }
  }

  class MazeLink {
    MazeNode pair;
    boolean ok;

    MazeLink() {
      this(null, false);
    }

    MazeLink(MazeNode p, boolean b) {
      ok = b;
      pair = p;
    }
  }
}
