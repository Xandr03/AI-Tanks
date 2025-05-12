//Alexander Bakas alba5453
class Sensor {

  int frontSight = 2;
  int behindSight = 1;

  Tank owner;




  ArrayList<Integer> frontSightArray = new ArrayList<>();

  ArrayList<Tank> possibleCollisions = new ArrayList<>();


  Sensor(Tank owner, int frontSight, int behindSight) {
    this.frontSight = frontSight;
    this.behindSight = behindSight;
    this.owner = owner;
    GenerateFrontSightArray();
  }

  void GenerateFrontSightArray() {

    int[] front = new int[]{-owner.team.nav.mwidth/owner.team.nav.minRec + 1
      , 1
      , owner.team.nav.mwidth/owner.team.nav.minRec + 1};

    for (int i = 0; i < 3; i++) {
      int currentCell = front[i];
      for (int j = 1; j < frontSight; j++) {
        frontSightArray.add(currentCell+j);
      }
    }
  }


  void checkFront() {
    int parentIndex = owner.team.nav.getCellPosition((float)owner.pos().x, (float)owner.pos().y);

    Cell c = owner.team.nav.cells[parentIndex];
    for (int i = 0; i < c.neighboures.size(); i++) {
      int index =  c.neighboures.get(i);
      //System.out.println(index);
      if (owner.team.nav.isValidIndex(index)) {
        owner.team.nav.cells[index].visited = true;
        owner.team.nav.cells[index].timeSinceLastVisit = sw.getRunTime() * 1.5;
      }
    }
  }


  ArrayList<Tank> CheckAreaDetection() {

    possibleCollisions = new ArrayList<>();
    owner.tankState.isEnemyInRange = false;
    for (MovingEntity me : world.getMovers(owner, owner.sensArea)) {
      if (me == owner) {
        continue;
      }
      if (me instanceof Tank) {
        Tank other = (Tank)me;
        if (CollisionChecker.checkCollision(owner, other)) {
          possibleCollisions.add(other);
        }
      }
    }
    return possibleCollisions;
  }


  void checkSurrounding() {

    owner.sensor.checkFront();
    ArrayList<Tank> others = owner.sensor.CheckAreaDetection();
    owner.tankState.isEnemyInRange  = false;
    owner.tankState.isFriendlyClose = false;
    owner.tankState.tstate.otherTanks = new ArrayList<>();

    owner.tankState.tstate.haveToYield = false;
    owner.tankState.tstate.isInTheWay = false;
    owner.tankState.tstate.cantGo = false;
    owner.tankState.isBackingUp = false;
    float closestDist = Integer.MAX_VALUE;
    if (owner.tankState.tstate.closestDist <= MAXALLOWEDISTANCE) {
      checkPriority();
    }

    /*
    if (tank.tankState.tstate.closestDist > MAXALLOWEDISTANCE ) {
     tank.team.tm.leaveTraffic(tank);
     tank.tankState.tstate.closestDist = closestDist;
     state = execState.Success;
     return;
     }
     */

    for (Tank t : others) {
      PVector tankPos = new PVector((float)t.pos().x, (float)t.pos().y);
      PVector otherDirection = VecMath.normalize(VecMath.direction(owner.position.x, owner.position.y, tankPos.x, tankPos.y));


      float angle = VecMath.dotAngle(otherDirection, owner.heading);
      if (t.team != owner.team) {
        owner.tankState.isEnemyInRange  = true;
        owner.team.WorldState.enemyTanks[t.ID] = new TankData(tankPos, t.ID, t, -1);
        return;
      } else {
        owner.tankState.isFriendlyClose = true;
        float dist = dist(tankPos.x, tankPos.y, (float)owner.pos().x, (float)owner.pos().y);
        if (dist < closestDist) {
          closestDist = dist;
        }
        /*
        if (tank.tankState.tstate.hasPriority == false && tank.isInTheWay(tankPos, new PVector((float)t.heading().x, (float)t.heading().y))) {
         tank.tankState.tstate.isInTheWay = true;
         }
         */
        if (dist(tankPos.x, tankPos.y, owner.position.x, owner.position.y) <= MAXMOVEAWAYDISTANCE && angle >= CROSSINGVIEW && owner.tankState.tstate.hasPriority) {
          owner.tankState.tstate.cantGo = true;
        }
      }
      owner.tankState.tstate.otherTanks.add(new TankData(tankPos, t.ID, t, t.tankState.tstate.priority));
    }

    if (owner.tankState.tstate.closestDist > MAXALLOWEDISTANCE ) {
      owner.team.tm.leaveTraffic(owner);
      owner.tankState.tstate.closestDist = closestDist;
      return;
    }

    owner.tankState.tstate.closestDist = closestDist;
  }


  void checkPriority() {
    owner.team.tm.updateValues(owner);
  }


  boolean isInFront(Tank tank, Tank other) {
    PVector direction = VecMath.normalize(VecMath.direction(tank.position.x, tank.position.y, other.position.x, other.position.y));
    float angle = VecMath.dotAngle(direction, tank.heading);
    if (dist(tank.position.x, tank.position.y, other.position.x, other.position.y) <= MAXALLOWEDISTANCE && angle <= FRONTVIEW) {
      return true;
    }
    return false;
  }

  boolean isCrossingTank(Tank tank, Tank other) {
    PVector direction = VecMath.normalize(VecMath.direction(tank.position.x, tank.position.y, other.position.x, other.position.y));
    float angle = VecMath.dotAngle(direction, tank.heading);
    if (dist(tank.position.x, tank.position.y, other.position.x, other.position.y) <= MAXALLOWEDISTANCE && angle <= CROSSINGVIEW) {
      return true;
    }
    return false;
  }
}
