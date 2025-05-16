//Alexander Bakas alba5453
public enum Teams {
  red,
    blue
}


class TrafficTank implements Comparable<TrafficTank> {
  int crossingTank = 0;
  int facingTank = 0;
  Tank owner;

  TrafficTank(Tank owner) {
    this.owner = owner;
  }

  TrafficTank(int crossing, int facing) {
    this.crossingTank = crossing;
    this.facingTank = facing;
  }

  @Override public int compareTo(TrafficTank other) {
    PVector destination = owner.tankState.destination;
    if (other.owner == null) {
      return 1;
    }
    PVector otherDestination = other.owner.tankState.destination;

    int destLength = Integer.MAX_VALUE;
    int otherDestLength = Integer.MAX_VALUE;

    if (destination != null) {
      destLength = round(destination.mag());
    }

    if (otherDestination != null) {
      otherDestLength = round(otherDestination.mag());
    }

    int sum = crossingTank + facingTank + destLength;
    int otherSum = other.facingTank + other.crossingTank + otherDestLength;
    if (sum > otherSum) {
      return 1;
    }
    if (sum < otherSum ) {
      return -1;
    }
    return 0;
  }
}

class TrafficManager {

  private Map<Tank, TrafficTank> tanks = new HashMap<>();

  Tank currentPriorityTank = null;

  void updateValues(Tank tank) {
    //tank.tankState.tstate.hasPriority = true;
    if (tanks.containsKey(tank)) {
      //System.out.println("ALREADY CONTAINS");
      updateTrafficTank(tank);
    } else {
      tank.tankState.tstate.isInTraffic = true;
      tanks.put(tank, new TrafficTank(tank));
      updateTrafficTank(tank);
    }

    checkLowestTank();
  }

  void leaveTraffic(Tank tank) {
    tanks.remove(tank);
    tank.tankState.tstate.isInTraffic = false;
    tank.tankState.tstate.hasPriority = false;
    if (tank == currentPriorityTank) {
      tank.tankState.tstate.hasPriority = false;
      currentPriorityTank = null;
    }
  }

  private void updateTrafficTank(Tank tank) {
    Set<Tank> keySet = tanks.keySet();
    TrafficTank trafficTank = tanks.get(tank);

    if (tank.tankState.tstate.isObscured || tank.tankState.hitPoints == 2 || tank.tankState.hitPoints > 1) {
      trafficTank.facingTank = 0;
      trafficTank.crossingTank = 0;
      return;
    }
    if (tank.tankState.isSearchingRegion) {
      trafficTank.facingTank = Integer.MAX_VALUE;
      trafficTank.crossingTank =  Integer.MAX_VALUE;
      return;
    }

    for (Tank t : keySet) {
      trafficTank.facingTank += isFacingTank(tank, t);
      trafficTank.crossingTank += isCrossingTank(tank, t);
    }
  }


  void checkLowestTank() {
    Set<Tank> keySet = tanks.keySet();
    TrafficTank lowestTank = null;
    for (Tank t : keySet) {
      TrafficTank tank = tanks.get(t);
      if (lowestTank == null) {
        lowestTank = tank;
      }
      if (tank.compareTo(lowestTank) <= -1) {
        lowestTank = tank;
      }
    }

    if (lowestTank != null && lowestTank.owner != null) {
      if (currentPriorityTank != null) {
        currentPriorityTank.tankState.tstate.hasPriority = false;
      }
      currentPriorityTank = lowestTank.owner;
      currentPriorityTank.tankState.tstate.hasPriority = true;
    }
  }

  int isFacingTank(Tank tank, Tank other) {
    if (tank.sensor.isInFront(tank, other)) {
      if (other.tankState.destination != null) {
        return round(other.tankState.destination.mag());
      }
      return Integer.MAX_VALUE;
    }
    return 0;
  }



  int isCrossingTank(Tank tank, Tank other) {
    if (tank.sensor.isCrossingTank(tank, other)) {
      if (other.tankState.destination != null) {
        return round(other.tankState.destination.mag());
      }
      return Integer.MAX_VALUE;
    }
    return 0;
  }

  void draw() {
    pushStyle();
    Tank mainTank = currentPriorityTank;
    if (mainTank == null) {
      return;
    }
    for (Tank t : tanks.keySet()) {
      strokeWeight(5);
      line(t.position.x, t.position.y, mainTank.position.x, mainTank.position.y);
    }
    popStyle();
  }

  void clear() {
    tanks.clear();
  }
}



public class EnemyTank {
  PVector lastKnownPosition;
  int hitPoints = 3;
  int focusCount = 0;
  float dist;
  int id;


  EnemyTank(int id, int hitPoints, PVector lkp) {
    this.id = id;
    this.hitPoints = hitPoints;
    this.lastKnownPosition = lkp;
  }

  EnemyTank(EnemyTank et, Tank tank) {
    if (et == null) {
      return;
    }
    this.lastKnownPosition = et.lastKnownPosition;
    this.hitPoints = et.hitPoints;
    this.focusCount = et.focusCount;
    this.dist = dist(et.lastKnownPosition.x, et.lastKnownPosition.y, tank.position.x, tank.position.y);
    this.id = et.id;
  }

  void addAsTarget(Tank tank) {
    this.focusCount += 1;
    tank.tankState.astate.isAttacking = true;
    tank.tankState.astate.enemyTarget = new EnemyTank(this, tank);
  }

  void removeAsTarget(Tank tank) {
    this.focusCount -= 1;
    tank.tankState.astate.isAttacking = false;
    tank.tankState.astate.enemyTarget = null;
  }
}




class Team {


  TrafficManager tm = new TrafficManager();

  NavLayout nav;

  HTNState WorldState;

  PVector position;
  int mwidth = 150;
  int mheight = 350;
  color teamColor;
  Teams team;

  Tank[] tanks = new Tank[3];

  int size = 0;

  StatsWindowManager swm;

  Team(color teamColor, PVector pos, Teams team) {
    System.out.println("*** Team " + team);
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
    WorldState = new HTNState(this);
    swm = new StatsWindowManager(80, 60, new PVector(10, 10));
  }

  Team(color teamColor, PVector pos, Teams team, NavLayout nav) {
    System.out.println("*** Team " + team);
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
    this.nav = nav;
    WorldState = new HTNState(this);
    swm = new StatsWindowManager(90, 60, new PVector(40, height - 60));
  }

  int addTank(Tank t) {
    tanks[size] = t;
    swm.add(new StatsWindow(t));
    return size++;
  }

  void sendEnemyKilled(int id) {
    EnemyTank et = WorldState.enemyTanks[id];
    if (et == null) {
      return;
    }
    for (Tank t : tanks) {
      if (t == null || t.tankState.astate.enemyTarget == null) {
        continue;
      }
      if (t.tankState.astate.enemyTarget.id == et.id) {
        et.removeAsTarget(t);
      }
    }
    WorldState.enemyTanks[et.id] = null;
  }


  void removeFromTraffic(Tank tank) {
    tm.leaveTraffic(tank);
  }

  void sendEnemySpotted(Tank sender, Tank spotted) {
    if (spotted.tankState.isDead) {
      return;
    }
    WorldState.enemyTanks[spotted.ID] = new EnemyTank(spotted.ID, spotted.tankState.hitPoints, spotted.position);
    EnemyTank et = WorldState.enemyTanks[spotted.ID];



    if (sender == null) {
      return;
    }

    et.addAsTarget(sender);
    Tank mostFittingTank = null;
    float currentMinDist = Integer.MAX_VALUE;

    for (Tank t : tanks) {
      if (t == null || t == sender) {
        continue;
      }
      float value = t.bid(sender, et);
      if (value == Integer.MIN_VALUE) {
        et.addAsTarget(t);
      }
      if (value < currentMinDist) {
        currentMinDist = value;
        mostFittingTank = t;
      }
    }
    if (mostFittingTank != null) {
      et.addAsTarget(mostFittingTank);
    }
  }



  public boolean checkBoundry(PVector other) {

    if (other.x > position.x && other.x < position.x + mwidth) {
      if (other.y > position.y && other.y < position.y + mheight) {
        return true;
      }
      return false;
    }
    return false;
  }

  void report(ArrayList<Cell> cells) {
    for (int i = 0; i < cells.size(); i++) {
      Cell c = cells.get(i);
      if (c.isEnemyNearby) {
        reportEnemy(c.pos);
        continue;
      }
      if (c.isEnemyBase) {
        reportBase();
        continue;
      }
    }
  }

  void reportEnemy(PVector center) {
    int[] enemyCells = nav.getCellRecArea(10, 10, center);
    for (int i = 0; i < 10*10; i++) {
      nav.cells[enemyCells[i]].isEnemyNearby = true;
    }
  }

  void reportBase() {
    PVector center;
    if (team == Teams.blue) {
      center = new PVector(red.position.x + 75, blue.position.y + 125 );
    } else {
      center = new PVector(blue.position.x + 75, blue.position.y + 125 );
    }
    int[] enemyCells = nav.getCellRecArea(10, 20, new PVector(center.x, center.y));
    for (int i = 0; i < 10*20; i++) {
      if (nav.isValidIndex(enemyCells[i])) {
        nav.cells[enemyCells[i]].isEnemyBase = true;
      }
    }
  }

  // Används inte, men bör ligga här.
  void displayHomeBase() {
    fill(teamColor, 50);    // Base Team 1(blue)
    rect(position.x, position.y, mwidth, mheight);
  }

  void display(float deltaTime) {
    tm.checkLowestTank();
    nav.updateNavLayout(world, deltaTime);
    displayHomeBase();
    tm.draw();
    //swm.displayWindows();
  }


  void tankKilled(Tank tank) {
    tanks[tank.ID] = null;
    size--;
    if (size <= 0) {
      resetWorld();
    }
  }


  void teamReset() {
    for (Tank t : tanks) {
      if (t == null) {
        continue;
      }

      t.clear();
      t = null;
    }
    swm.clear();
    tm.clear();
  }
}

public class StatsWindowManager {

  PVector position;

  ArrayList<StatsWindow> windows = new ArrayList<>();

  float mwidth;
  float mheight;

  StatsWindowManager(float mwidth, float mheight, PVector position) {
    this.mwidth = mwidth;
    this.mheight = mheight;
    this.position = position;
  }

  void add(StatsWindow sw) {
    sw.offset = windows.size() * mwidth * 1.2;
    windows.add(sw);
  }


  void displayWindows() {


    push();


    translate(position.x, position.y);

    textAlign(LEFT);
    for (StatsWindow sw : windows) {
      sw.display(mwidth, mheight);
    }

    pop();
  }

  void clear() {
    windows.clear();
  }
}

public class StatsWindow {

  float offset;

  Tank owner;

  StatsWindow(Tank owner) {
    this.owner = owner;
  }

  void display(float mwidth, float mheight) {
    if (owner == null) {
      return;
    }

    float newOffset = offset + 10;

    TankState tankState = owner.tankState;
    EnemyTank et = tankState.astate.enemyTarget;
    fill(#F0EBEB);
    rect(offset, 0, mwidth, mheight, 10);


    textSize(10);
    fill(#E53131);
    text("ID: " + owner.ID, newOffset, 20);
    text("PosX "+ round(owner.position.x) + " PosY " + round(owner.position.y), newOffset, 30);
    text("HitPoints: " + owner.tankState.hitPoints, newOffset, 40);
    if (et == null) {
      text("Target: null", newOffset, 50);
    } else {
      text("Target: " + et.id, newOffset, 50);
    }
    if (owner.runner != null) {
      text("Tasks: " + owner.runner.toString(), newOffset, 60);
    }
  }
}
