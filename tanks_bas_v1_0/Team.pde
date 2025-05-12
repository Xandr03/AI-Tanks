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
    } 
    else {
      tank.tankState.tstate.isInTraffic = true;
      tanks.put(tank, new TrafficTank(tank));
      updateTrafficTank(tank);
    }

    checkLowestTank();
  }

  void leaveTraffic(Tank tank) {
    TrafficTank trafficTank = tanks.get(tank);
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

    if (tank.tankState.tstate.isObscured || tank.tankState.hitPoints == 2) {
      trafficTank.facingTank = 0;
      trafficTank.crossingTank = 0;
      return;
    }

    for (Tank t : keySet) {
      trafficTank.facingTank = isFacingTank(tank, t);
      trafficTank.crossingTank = isCrossingTank(tank, t);
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

    Tank mainTank = currentPriorityTank;
    if (mainTank == null) {
      return;
    }
    for (Tank t : tanks.keySet()) {
      strokeWeight(5);
      line(t.position.x, t.position.y, mainTank.position.x, mainTank.position.y);
    }
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
    if(et == null){return;}
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

  Team(color teamColor, PVector pos, Teams team) {
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
    WorldState = new HTNState(this);
  }

  int addTank(Tank t) {
    tanks[size] = t;
    return size++;
  }
  /*
  public void getTrafficPrio(int id, int otherID) {
   
   if (id < 0 ||otherID < 0) {
   return;
   }
   
   Tank tank = tanks[id];
   
   if (tm.tanks.peek() == tank) {
   tank.tankState.tstate.priority = 0;
   } else {
   tank.tankState.tstate.priority = 1;
   }
   
   
   
   
   int prio= tank.tankState.tstate.priority;
   int otherPrio = other.tankState.tstate.priority;
   if(prio < 0 && otherPrio == 0){
   tank.tankState.tstate.priority = 1;
   return;
   }
   if(prio < 0 && otherPrio < 0){
   tank.tankState.tstate.priority = 0;
   other.tankState.tstate.priority = 1;
   return;
   }
   tank.tankState.tstate.priority = 0;
   other.tankState.tstate.priority = 1;
   
   }
   
   
   public void sendForcedTrafficPrio(int id, int otherID, int selfPrio, int otherPrio) {
   tanks[id].tankState.tstate.priority = selfPrio;
   tanks[otherID].tankState.tstate.priority = otherPrio;
   }
   */
   
  void sendEnemyKilled(int id){
    EnemyTank et = WorldState.enemyTanks[id];
    if(et == null){return;}
    for(Tank t: tanks){
      if(t == null || t.tankState.astate.enemyTarget == null){continue;}
      if(t.tankState.astate.enemyTarget.id == et.id){
        et.removeAsTarget(t);
      }
    }
    WorldState.enemyTanks[et.id] = null;
  }

  void sendEnemySpotted(Tank sender, Tank spotted) {
    if(spotted.tankState.isDead){
      return;
    }
    WorldState.enemyTanks[spotted.ID] = new EnemyTank(spotted.ID, spotted.tankState.hitPoints, spotted.position);
    EnemyTank et = WorldState.enemyTanks[spotted.ID];
    
    Tank mostFittingTank = null;
    float currentMinDist = Integer.MAX_VALUE;
    for (Tank t : tanks) {
      if(t == null){continue;}
      float value = t.bid(sender, et);
      if (value == Integer.MIN_VALUE) {
        et.addAsTarget(t);
      }
      if (value < currentMinDist && t != sender) {
        currentMinDist = value;
        mostFittingTank = t;
      }
    }
    if (mostFittingTank != null) {
      et.addAsTarget(mostFittingTank);
    }
  }



  Team(color teamColor, PVector pos, Teams team, NavLayout nav) {
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
    this.nav = nav;
    WorldState = new HTNState(this);
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
  }
}
