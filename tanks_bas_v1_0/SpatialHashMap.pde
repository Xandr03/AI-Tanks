//Alexander Bakas alba5453



color[] colorMap = new color[]{(#D5F041), (#FA3AE1), (#D5F041), (#FA3AE1), (#D5F041), (#FA3AE1), (#D5F041), (#FA3AE1), (#D5F041)};

public enum GridRegion {

  TL(0), T(1), TR(2),
    ML(3), M(4), MR(5),
    BL(6), B(7), BR(8),
   INV(-1);

  int GridValue;

  GridRegion(int GridValue) {
    this.GridValue = GridValue;
  }

  int getValue() {
    return GridValue;
  }

  void setValue(int value) {
    this.GridValue = value;
  }
}


public enum RegionStatus {
    Explored,
    Danger,
    Unexplored,
    NONE
}

class Region {

  String name = "";
  boolean isClaimed = false;
  boolean occupied = false;
  boolean claimed = false;
  RegionStatus state = RegionStatus.Unexplored;
  float timeLast = 0;
  PVector regionMidPoint;

  float holdTime = 0;

  Region(String name) {
    this.name = name;
  }

  Region() {
  }

  Region(Region r) {
    if (r == null) {
      regionMidPoint = new PVector(0,0);      
      state = RegionStatus.NONE;
      return;
    }
    this.name = r.name;
    this.occupied = r.occupied;
    this.timeLast = r.timeLast;
    this.state = r.state;
    this.isClaimed = r.isClaimed;
    this.regionMidPoint = r.regionMidPoint;
  }

  boolean isRegionUnchecked(float deltaTime) {
    if (occupied || state == RegionStatus.Unexplored) {
      return false;
    }
    timeLast += deltaTime;
    if (timeLast >= 60) {
      return true;
    }
    return false;
  }

  boolean regionExploring(float deltaTime) {
    if (occupied && state == RegionStatus.Unexplored) {
      holdTime += deltaTime;
      if (holdTime >= 20) {
        state = RegionStatus.Explored;
        holdTime = 0;
        return true;
      }
    }
    return false;
  }

  void refresh() {
    state = RegionStatus.Unexplored;
    timeLast = 0;
  }
}

class RegionManager {

  private Region[] regions = new Region[]{new Region("TOP LEFT"), new Region("TOP"), new Region("TOP RIGHT"),
    new Region("MIDDLE LEFT"), new Region("MIDDLE"), new Region("MIDDLE RIGHT"),
    new Region("BOTTOM LEFT"), new Region("BOTTOM"), new Region("BOTTOM RIGHT")};


  float RegExProc = 0;
  int RegionsExplored = 0;

  int frame;

  RegionManager(int value) {
    System.out.println("**** RegionManager");
    for (int i = 1; i <= 3; i++) {
      int index = i*3;
      for (int j = 1; j <= 3; j++) {
        int x = (value * j) - (value/2);
        int y = ((value* i)) - (value/2);
        System.out.println("X:"+ x+ " Y: " + y);
        regions[(index-3 + j-1)].regionMidPoint = new PVector(x, y);
      }
    }
  }

  RegionManager(RegionManager rm) {
    if (rm == null) {
      return;
    };
    System.out.println("**** RegionManager Copy");
    regions = new Region[rm.regions.length];
    for (int i = 0; i < 9; i++) {
      this.regions[i] = new Region(rm.regions[i]);
    }
    this.RegionsExplored = rm.RegionsExplored;
    this.RegExProc = rm.RegExProc;
  }

  void update(float deltaTime) {
    /*
    if (!(frame == 20)) {
     frame++;
     return;
     }
     frame = 0;
     */
    for (int i = 0; i < 9; i++) {
      if (regions[i].isRegionUnchecked(deltaTime)) {
        regions[i].refresh();
        RegionsExplored -= 1;
      }
      if (regions[i].regionExploring(deltaTime)) {
        RegionsExplored++;
      }
    }
    RegExProc = RegionsExplored/9;
  }

  int getAvailibleRegion(PVector pos) {

    float closestDist = Integer.MAX_VALUE;
    int closestRegion = -1;
    for (int i = 0; i < regions.length; i++) {

      float dist = dist(pos.x, pos.y, regions[i].regionMidPoint.x, regions[i].regionMidPoint.y);
      if (dist < closestDist && (!regions[i].claimed && regions[i].state == RegionStatus.Unexplored)) {
        closestDist = dist;
        closestRegion = i;
      }
    }
    return closestRegion;
  }


  Region getRegion(int index) {
    if (index < 0) {
      return regions[0];
    }
    return regions[min(index, 8)];
  }

  void setRegionClaimed(int index, boolean b) {
    Region r = getRegion(index);
    r.claimed = b;
  }

  void setRegionDanger(int index) {
    Region r = getRegion(index);
    r.state = RegionStatus.Danger;
  }

  /*
  void setRegionVisited(int index) {
   Region r = getRegion(index);
   r.state = RegionStatus.Explored;
   RegionsExplored++;
   }
   */
}


public class Cell {

  public PVector pos;
  public GridRegion region;
  public boolean visited = false;
  public boolean isWalkable = true;


  public float EnemyDistance = 0;
  public boolean isEnemyNearby = false;
  public boolean isEnemyBase = false;


  public double timeSinceLastVisit = 0;

  //fix the neighobure so a a left side is connected to the right, with this it wrapes
  ArrayList<Integer> neighboures = new ArrayList<>();


  Cell(PVector position, boolean walkable) {
    pos = position;
    isWalkable = walkable;
  }
}





public class NavLayout {


  int minRec = 25;
  int size = 0;
  int mwidth = 0;
  int mheight = 0;

  float rounder = 10;

  int xOffset = 0;
  int yOffset = 0;


  public int[] neighbours;


  public ArrayList<Integer> tankOnCells = new ArrayList<>(3*3*6);

  RegionManager rm;


  Cell[] cells;

  NavLayout(int pwidth, int pheight, int cellSize) {
    System.out.println("*** NavLayout");
    this.minRec = cellSize;
    mheight = pheight;
    mwidth = pwidth;
    size = (pwidth/minRec) * (pheight/minRec);
    cells = new Cell[size];
    GenerateLayout();
    rm = new RegionManager(mwidth);
  }

  NavLayout(int pwidth, int pheight, int xOffset, int yOffset, int cellSize) {
    System.out.println("*** NavLayout");
    this.minRec = cellSize;
    mheight = floor(pheight);
    mwidth = floor(pwidth);
    size = floor(pwidth/minRec) * floor(pheight/minRec);
    //System.out.println(floor(pwidth/minRec) * floor(pheight/minRec));
    cells = new Cell[size];
    this.xOffset = xOffset;
    this.yOffset = yOffset;
    neighbours = new int[] {(-mwidth/minRec + 1), (-mwidth/minRec), (-mwidth/minRec - 1), -1, 1, (mwidth/minRec - 1), (mwidth/minRec), (mwidth/minRec + 1)};
    rm = new RegionManager(mwidth/3);
    //{(-mwidth/minRec + 1), (-mwidth/minRec), (-mwidth/minRec - 1), -1, 1, (mwidth/minRec - 1), (mwidth/minRec), (mwidth/minRec + 1)};
    GenerateLayout();
  }

  void GenerateLayout() {

    for (int i = 0; i < mheight/minRec; i++) {
      int gheight = i*((mheight/minRec));
      for (int j = 0; j < mwidth/minRec; j++) {
        PVector pos = new PVector(j*minRec + xOffset, i*minRec + yOffset);
        cells[gheight + j] = new Cell(pos, true);
        cells[gheight + j].region = getCellRegion(pos);
      }
    }

    for (int i = 0; i < size; i++) {

      for (int j = 0; j < 8; j++) {
        int neighbourIndex = abs(i + neighbours[j]);
        if (neighbourIndex > size - 1 || neighbourIndex < 0 ) {
          continue;
        }
        if (dist(cells[neighbourIndex].pos.x, cells[neighbourIndex].pos.y, cells[i].pos.x, cells[i].pos.y) < sqrt(pow(minRec, 2) + pow(minRec, 2)) + rounder) {
          if (cells[i].neighboures.contains(neighbourIndex)) {
            continue;
          }
          cells[i].neighboures.add(neighbourIndex);
        }
      }
    }
  }


  GridRegion getCellRegion(PVector pos) {
    float regionHeight = mheight/3;
    float regionWidth = mwidth/3;

    PVector fixed = pos;

    int newX = floor((fixed.x - (minRec/2))/regionWidth);
    int newY = floor((fixed.y - (minRec/2))/regionHeight);



    int value = newY  * (3) + newX ;

    return GridRegion.values()[min(value, 8)];
  }


  void draw() {


    noStroke();
    color green = color(0, 128, 0);
    color red = color(205, 28, 24);
    rectMode(CENTER);
    textSize(10);

    circle(350, 350, 5);
    Cell c = cells[getCellPosition(mouseX, mouseY)];
    for (int i = 0; i < size; i++) {
      Cell p = cells[i];
      float reach = 100;
      float dist = dist(p.pos.x, p.pos.y, c.pos.x, c.pos.y);
      float time = (float)((p.timeSinceLastVisit - sw.getRunTime())/sw.getRunTime());
      if (p.isWalkable) {

        stroke(max(0, 1 - dist/reach));
        strokeWeight(max(0, 1 - dist/reach));

        fill(#9CF5ED, 100 - dist);
        rect(p.pos.x, p.pos.y, minRec, minRec);
        fill(color(colorMap[p.region.getValue()]), max(30, 100 - dist));
        rect(p.pos.x, p.pos.y, minRec, minRec);
      } else {
        strokeWeight(max(0, 1 - dist/reach));
        stroke(max(0, 1 - dist/reach));

        fill(red, max(30, 100 - dist));
        rect(p.pos.x, p.pos.y, minRec, minRec);
      }


      noStroke();


      fill(color(0, 0, 0), 100);
      textAlign(CENTER);
      text(i, p.pos.x, p.pos.y);
    }
    DrawTank0PathsFound();
    blendMode(REPLACE);

    fill(color(0, 0, 0), 100);
    textAlign(CENTER);

    fill(color(#1DF092), 100);
    if (!c.isWalkable) {
      fill(color(#F21818), 100);
    }

    square(c.pos.x, c.pos.y, minRec*1.2);
    text(getCellPosition(mouseX, mouseY), c.pos.x, c.pos.y);

    blendMode(BLEND);

    rectMode(CORNER);
    strokeWeight(1);
    stroke(1);
  }


  void DrawTank0PathsFound() {

    for (int i = 0; i < size; i++) {
      Cell p = cells[i];
      if (p.isEnemyNearby || p.isEnemyBase) {
        fill(#F01616, 100);
        rect(p.pos.x, p.pos.y, minRec, minRec);
        continue;
      }

      if (cells[i].visited) {
        float time = (float)((sw.getRunTime() - p.timeSinceLastVisit)/sw.getRunTime());

        fill(#AE14FC, 100 - 100*time);
        rect(p.pos.x, p.pos.y, minRec, minRec);
      }
    }
  }


  public Cell getCell(int index) {
    if (!isValidIndex(index)) {
      return null;
    }
    return cells[index];
  }

  public Cell getCell(PVector pos) {
    int index = getCellPosition(pos);
    if (!isValidIndex(index)) {
      return null;
    }
    return cells[index];
  }


  public boolean isValidIndex(int index) {
    if (index > size - 1 || index < 0) {
      return false;
    }
    return true;
  }


  int[] getCellRecArea(int w, int h, PVector centerPoint) {

    int[] arr = new int[w*h];

    PVector tl = new PVector(centerPoint.x - (minRec * w/2), centerPoint.y -( minRec*h/2));

    int total = 0;
    for (int i = 0; i < h; i++) {
      //int index = getCellPosition(tl.x, tl.y) + i * mwidth/minRec;
      PVector pos = new PVector(tl.x, tl.y + i * minRec);
      for (int j = 0; j < w; j++) {
        int n = getCellPosition(new PVector(pos.x + j * minRec, pos.y));
        if (isValidIndex(n)) {
          arr[total] = n;
          total++;
        }
      }
    }
    return arr;
  }

  void getCellRecArea(int w, int h, PVector centerPoint, Consumer<Cell> cellCon) {

    PVector tl = new PVector(centerPoint.x - (minRec * w), centerPoint.y -( minRec*h));

    for (int i = 0; i < h; i++) {
      int index = getCellPosition(tl.x, tl.y) + i * mwidth/minRec;
      PVector pos = new PVector(tl.x, tl.y + i * mwidth/minRec);
      for (int j = 0; j < w; j++) {
        int n = getCellPosition(new PVector(pos.x + j * minRec, pos.y));
        if (isValidIndex(n)) {
          cellCon.accept(getCell(index));
        }
      }
    }
  }


  int getCellPosition(float x, float y) {


    //System.out.println("X : " + x + " Y : " + y);

    PVector fixed = new PVector(x, y);

    return getCellPosition(fixed);
  }

  int getCellPosition(PVector vec) {


    //System.out.println("X : " + vec.x + " Y : " + vec.y);

    PVector fixed = vec;

    if (fixed.x < 0 + xOffset) {
      fixed.x = xOffset;
    }
    if (fixed.y < 0 + yOffset) {
      fixed.y = yOffset;
    }
    if (fixed.x > mwidth) {
      fixed.x = mwidth;
    }
    if (fixed.y > mheight) {
      fixed.y = mheight;
    }


    int newX = floor((fixed.x - (minRec/2))/minRec);
    int newY = floor((fixed.y - (minRec/2))/minRec);

    //System.out.println("newX : " + newX + " newY : " + newY);

    return newY  * (mheight/minRec) + newX ;
  }

  void updateNavLayout(World world, float deltaTime) {


    int ObstacleSize = world.getObstacles(0, 0).size();
    Obstacle[] setOfOb = world.getObstacles(0, 0).toArray(new Obstacle[ObstacleSize]);

    rm.update(deltaTime);
    //gå igenom alla tanks sätta ett rött område förutom den första

    for (int i : tankOnCells) {
      cells[i].isWalkable = true;
    }
    tankOnCells = new ArrayList(3*3*6);


    Set<Integer> keys = World.allEntities.keySet();

    for (Integer v : keys) {

      BaseEntity base = World.allEntities.get(v);
      if (base instanceof Tank) {

        Tank t = (Tank)base;
        if (t == allTanks[0]) {
          continue;
        }
        int[] list = getCellRecArea(3, 3, new PVector((float)t.pos().x, (float)t.pos().y));

        for (int i = 0; i < 3*3; i++) {
          cells[list[i]].isWalkable = false;
          tankOnCells.add(list[i]);
        }
      }
    }



    for (int i = 0; i < ObstacleSize; i++) {

      float x = (float)setOfOb[i].pos().x;
      float y = (float)setOfOb[i].pos().y;
      float diameter = (float)setOfOb[i].colRadius();

      float xOri = x - diameter/2;
      float yOri = y - diameter/2;

      int distX =  floor((x + (diameter/2))/minRec) - floor(xOri/minRec);
      int distY =  floor((y + (diameter/2))/minRec) - floor(yOri/minRec);

      //System.out.println(floor((x + (diameter/2))/minRec));
      //System.out.println(floor(xOri/minRec));

      int[] cellValues = new int[distX*distY];

      for (int j = 0; j < size; j++) {

        if (dist(x, y, cells[j].pos.x, cells[j].pos.y ) <= diameter) {
          cells[j].isWalkable = false;
        }
      }
    }
  }
}
