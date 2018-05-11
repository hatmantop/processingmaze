class MazeViz extends MazeRecord {

  int[][] path;
  Set<MazeNode> vizSet;
  boolean backTrace;
  MazeNode current;

  MazeViz(int h, int w, int startX, int startY, int endX, int endY, boolean[][] vWalls, boolean[][] hWalls) {
    super(h, w, startX, startY, endX, endY, vWalls, hWalls);  
    path = null;
    backTrace = false;
    current = null;
  }

  public void startDijkstra() {
    path = new int[hite][wide];
    for (int i = 0; i < hite; i++) {
      for (int j = 0; j < wide; j++) {
        path[i][j] = 0;
      }
    }
    resetNodes();
    vizSet = new HashSet<MazeNode>();
    for (MazeNode[] c : nodes) {
      for (MazeNode n : c) {
        vizSet.add(n);
      }
    }
    start.distance = 0;
    current = getLowestDist(vizSet);
  }

  public int[][] step() {
    if (path == null || vizSet == null) {
      throw new IllegalStateException("path: " + path + "\nvisSet:" + vizSet);
    }

    if (backTrace) {
      if (current != null) {
        path[current.y][current.x] = 1;
        current = current.back;
      }
      return path;
    } else {
      MazeNode smallest = getLowestDist(vizSet);
      vizSet.remove(smallest);
      path[smallest.y][smallest.x] = 2;

      if (smallest == end) {
        current = smallest;
        backTrace = true;
        for (int i = 0; i < hite; i++) {
          for (int j = 0; j < wide; j++) {
            path[i][j] = 0;
          }
        }
        return path;
      }

      Set<MazeLink> neebs = new HashSet<MazeLink>();
      neebs.add(smallest.up);
      neebs.add(smallest.down);
      neebs.add(smallest.right);
      neebs.add(smallest.left);
      neebs.removeAll(Collections.singleton(null));

      for (MazeLink ml : neebs) {
        if (ml.ok) {
          MazeNode connect = ml.pair;
          path[connect.y][connect.x] = 3;
          int alt = smallest.distance + 1;
          if (alt < connect.distance) {
            path[connect.y][connect.x] = 4;
            connect.distance = alt;
            connect.back = smallest;
          }
        }
      }
    }

    return path;
  }

  public void endDijkstra() {
    resetNodes();
    vizSet = null;
    path = null;
    backTrace = false;
    current = null;
  }

  public int[][] path() {
    return path;
  }
}