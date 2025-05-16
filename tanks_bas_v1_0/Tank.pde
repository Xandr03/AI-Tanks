//Alexander Bakas alba5453

TankPatroleState tankPatroleState = new TankPatroleState();

TankReturnToBaseState tankReturnToBaseState = new TankReturnToBaseState();
TankGlobalState tankGlobalState = new TankGlobalState();
TankIdleState idle = new TankIdleState();


final float MAXALLOWEDISTANCE =  80 ;
final float MAXSTOPDISTANCE = 80;
final float MAXMOVEAWAYDISTANCE = 75 ;
final float FIELWOFVIEW = 180;
final float FRONTVIEW = 5.0f;
final float CROSSINGVIEW = 90.0f/2.0f;
final float VIEWDISTANCE = 200;

final float CLOSEFIRERANGE = 100;
final float LONGFIRERANGE = 200;


public class TankData {
  final PVector pos;
  final int id;
  final Tank tank;
  final int priority;

  TankData(PVector pos, int id, Tank tank, int priority) {
    this.tank = tank;
    this.pos = pos;
    this.id = id;
    this.priority = priority;
  }
}



public class TrafficState {

  boolean isInTraffic = false;

  boolean cantGo = false;

  boolean isObscured = false;

  boolean isInTheWay = false;

  PVector lastGoal = new PVector();

  float closestDist = Integer.MAX_VALUE;

  ArrayList<TankData> otherTanks = new ArrayList<>();

  //Sends to tank in the way to yield meaning backing up and moving away
  boolean haveToYield = false;

  int priority = -1;

  boolean hasPriority = false;

  TrafficState() {
  }

  TrafficState(TrafficState state) {
    this.isInTraffic = state.isInTraffic;
    this.isInTheWay = state.isInTheWay;

    for (TankData d : state.otherTanks) {
      this.otherTanks.add(d);
    }

    this.haveToYield = state.haveToYield;
    this.priority = state.priority;
    this.lastGoal = state.lastGoal;
    this.closestDist = state.closestDist;
    this.hasPriority = state.hasPriority;
    this.cantGo = state.cantGo;
  }
}



public class AttackingState {


  boolean isReloading = false;
  boolean isAligned = false;
  boolean hasShoot = false;
  boolean isAttacking = false;

  EnemyTank enemyTarget = null;

  float bestTargetDistance = Integer.MAX_VALUE;

  AttackingState() {
  }

  AttackingState(AttackingState state, final Tank tank) {
    this.isReloading = state.isReloading;
    this.isAligned = state.isAligned;
    this.hasShoot = state.hasShoot;
    this.bestTargetDistance = state.bestTargetDistance;
    this.isAttacking = state.isAttacking;
    this.enemyTarget = new EnemyTank(state.enemyTarget, tank);
  }
}

public class TankState {

  boolean isNavigation = false;
  boolean isEnemyInRange = false;
  boolean isFriendlyClose = false;
  boolean hasRegion = false;

  boolean isSearchingRegion = false;

  boolean isBackingUp = false;

  boolean isShouldWait = false;

  boolean isDead = false;

  boolean isIdle = false;
  boolean isStopped = false;
  boolean isWaiting = false;
  boolean isRotating = false;
  TrafficState tstate = new TrafficState();
  AttackingState astate = new AttackingState();

  boolean movingToRegion = false;

  GridRegion regionDes = GridRegion.INV;
  GridRegion regionCur = GridRegion.INV;

  Region regionState = null;

  PVector destination = new PVector();

  int regionToExplore = -1;
  int hitPoints = 3;

  PVector tankPosition = new PVector();

  TankState() {
  }

  TankState(TankState state) {
    this.isNavigation = state.isNavigation;
    this.hitPoints = state.hitPoints;
    this.regionToExplore = state.regionToExplore;

    this.isEnemyInRange = state.isEnemyInRange;
    this.isFriendlyClose = state.isFriendlyClose;
    this.isShouldWait = state.isShouldWait;

    this.isBackingUp = state.isBackingUp;
    this.isIdle = state.isIdle;
  }

  TankState(TankState state, Tank tank) {
    //System.out.println("CREATE TANK STATE");
    this.isNavigation = state.isNavigation;
    this.hitPoints = state.hitPoints;
    this.regionToExplore = state.regionToExplore;

    this.isEnemyInRange = state.isEnemyInRange;
    this.isFriendlyClose = state.isFriendlyClose;
    this.hasRegion = state.hasRegion;
    this.tankPosition = new PVector((float)tank.pos().x, (float)tank.pos().y);

    this.regionState = new Region(state.regionState);
    this.regionCur = tank.team.nav.getCell(tankPosition).region;
    this.regionDes = state.regionDes;
    //this.destination = state.destination;
    this.isShouldWait = state.isShouldWait;
    this.tstate = new TrafficState(state.tstate);
    this.isBackingUp = state.isBackingUp;

    this.astate = new AttackingState(state.astate, tank);
    this.isStopped = state.isStopped;
    this.isRotating = state.isRotating;
    this.isWaiting = state.isWaiting;
    this.destination = state.destination;
    this.isIdle = state.isIdle;
    this.isSearchingRegion = state.isSearchingRegion;
  }
}



class Tank extends Vehicle {




  //Store Nodes it has visited

  TankState tankState = new TankState();

  PVector acceleration;
  PVector velocity;
  PVector position;

  PVector heading;

  PVector startpos;
  String name;
  PImage img;
  color col;
  float diameter;

  float speed;
  float maxspeed;

  int state;
  boolean isInTransition;

  Team team;
  Team oposition;


  Turret turret;

  float sensArea = 50;


  final int ID;

  Plan_runner runner;

  float waitTimer = 0;
  float reloadTimer = 3;

  //Array of notable item or enemies to update the team base knowledge

  ArrayList<Cell> reportCells = new ArrayList<>();

  Sensor sensor;


  Path path = new Path();



  //======================================
  Tank(String _name, PVector _startpos, float _size, Team team, Team oposition ) {
    super(new Vector2D(_startpos.x, _startpos.y), 25, new Vector2D(0, 0), 30, new Vector2D(0, 1), 1, 1, 100);
    println("*** Tank.Tank()");
    this.name         = _name;
    this.diameter     = _size;
    this.col          = team.teamColor;
    this.team = team;
    this.position = _startpos;
    this.heading = new PVector((float)this.heading().x, (float)this.heading().y);

    this.startpos     = new PVector(_startpos.x, _startpos.y);

    this.velocity     = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);

    this.speed        = 0;
    this.maxspeed     = 20;
    this.isInTransition = false;

    Domain tankDomain = new Domain(25, 25, 775, 775);
    this.worldDomain(tankDomain, SBF.REBOUND);
    turret = new Turret(this, new PVector(0, 1));
    sensor = new Sensor(this, 2, 1);
    this.path.owner = this;
    this.oposition = oposition;

    runner = new Plan_runner(this);
    tankState.tankPosition = _startpos;
    this.ID = team.addTank(this);
    this.AP().pathOn();
  }

  public void report() {
    team.report(reportCells);
    reportCells = new ArrayList<Cell>();
  }
  
  void clear(){
    sensor.clear();
  }


  Vector2D getGoodDirection(PVector other) {

    NavLayout nl = team.nav;
    Cell c = this.team.nav.getCell(position);

    PVector direction =VecMath.direction(position.x, position.y, other.x, other.y);
    float bestAngle = Integer.MAX_VALUE;
    Vector2D bestPos = null;
    for (int n : c.neighboures) {
      Cell oCell = nl.getCell(n);
      PVector cellPos = oCell.pos;
      PVector cellDir = VecMath.direction(position.x, position.y, cellPos.x, cellPos.y);
      float angle = VecMath.dot(cellDir.normalize(), direction.normalize());
      //System.out.print(" Angle: [" +angle + "] ");
      if (oCell.isWalkable && (oCell.occupier == null || oCell.occupier == this) && !oCell.multiOcc && angle < bestAngle) {
        this.tankState.tstate.isObscured = false;
        //System.out.println("--------- Cell To Move To: " + new Vector2D(cellPos.x, cellPos.y).toString());
        bestPos = new Vector2D(cellPos.x, cellPos.y);
        bestAngle = angle;
      }
    }
    //System.out.println("Did not Find Good Direction");
    if (bestPos == null) {
      this.tankState.tstate.isObscured = true;
      return new Vector2D(position.x, position.y);
    }

    return bestPos;
  }

  public boolean isInTheWay(PVector pos, PVector heading) {
    PVector direction = VecMath.normalize(VecMath.direction(pos.x, pos.y, position.x, position.y));
    float angle = VecMath.dotAngle(direction, heading);
    if (dist(pos.x, pos.y, position.x, position.y) <= MAXALLOWEDISTANCE && angle > 0) {
      return true;
    }
    return false;
  }


  void reload(float deltaTime) {
    if (tankState.astate.isReloading) {
      reloadTimer -= deltaTime;
      if (reloadTimer <= 0) {
        tankState.astate.isReloading = false;
        reloadTimer = 3;
      }
    }
  }

  boolean RotateToDest() {
    if (this.tankState.destination == null) {
      return false;
    }
    PVector v = VecMath.normalize(VecMath.direction((float)this.pos().x, (float)this.pos().y, this.tankState.destination.x, this.tankState.destination.y));
    System.out.println("----------------ROTATE-------------------");
    this.heading(v.x, v.y);
    return false;
  }


  void wait(float deltaTime) {
    if (this.tankState.isWaiting) {
      waitTimer -= deltaTime;
      if (waitTimer <= 0 || tankState.tstate.hasPriority) {
        this.tankState.isStopped = false;
        this.tankState.isWaiting = false;
      }
    }
  }

  public float bid(Tank tank, EnemyTank et) {
    float dist =  dist(this.position.x, this.position.y, et.lastKnownPosition.x, et.lastKnownPosition.y);
    if (tank.tankState.hitPoints <= 1 && dist < tank.tankState.astate.enemyTarget.dist + 45) {
      return Integer.MIN_VALUE;
    }
    //Return max tank has max value
    if (tank.tankState.astate.enemyTarget != null && tank.tankState.astate.enemyTarget.dist < dist && et.id != tank.tankState.astate.enemyTarget.id) {
      return Integer.MAX_VALUE;
    }
    return dist;
  }

  public boolean EnemyInVision() {

    boolean found = false;
    for (int i = 0; i < oposition.size; i++) {
      if (oposition.tanks[i] == null ) {
        continue;
      }
      PVector opTank = new PVector((float)oposition.tanks[i].pos().x, (float)oposition.tanks[i].pos().y);
      int angle = round(VecMath.dotAngle(new PVector((float)heading().x, (float)heading().y), VecMath.normalize(VecMath.direction((float)heading().x, (float)heading().y, opTank.x, opTank.y))));
      float dist = dist((float)pos().x, (float)pos().y, opTank.x, opTank.y);
      if (angle> 5 && dist <= 200) {
        Cell enemyCell = new Cell(team.nav.getCell(team.nav.getCellPosition(opTank)).pos, true);
        enemyCell.isEnemyNearby = true;
        reportCells.add(enemyCell);
        found = true;
      }
    }
    return found;
  }

  public void setIdle() {
    this.FSM().changeState(idle);
  }
  public void returnToBase() {
    this.FSM().changeState(tankReturnToBaseState);
  }

  public void setPatrole() {
    this.FSM().changeState(tankPatroleState);
  }
  //======================================
  void checkEnvironment() {
    println("*** Tank.checkEnvironment()");

    borders();
  }

  void checkNode() {
    sensor.checkFront();
  }

  void checkForCollisions(Tank sprite) {
    moveTo(new Vector2D(400, 400));
  }

  void checkForCollisions(PVector vec) {
    checkEnvironment();
  }

  boolean checkEnemyBoundry(PVector pos) {
    if (team.team == Teams.red) {
      return blue.checkBoundry(pos);
    }
    return red.checkBoundry(pos);
  }

  // Följande är bara ett exempel
  void borders() {
    float r = diameter/2;
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  void update(double deltaTime, World world) {
    super.update(deltaTime, world);
    this.position.x = (float)this.pos().x;
    this.position.y = (float)this.pos().y;
    this.heading.x = (float)this.heading().x;
    this.heading.y = (float)this.heading().y;
    this.tankState.regionCur = this.team.nav.getCell(new PVector((float)pos().x, (float)pos().y)).region;
    sensor.checkSurrounding();

    runner.update((float)deltaTime);

    wait((float)deltaTime);
    reload((float)deltaTime);

    if (this.AP().pathRouteLength() <= 0) {
      tankState.isNavigation = false;
    }
  }

  void death() {
    if (runner != null) {
      runner.runningTask = null;
      runner.sequence = null;
      this.runner = null;
    }

    this.tankState.isDead = true;
    this.team.tankKilled(this);
    world.death(this, 0);
  }

  void doDamage(Tank damager) {
    if (damager.team == this.team) {
      return;
    }
    this.tankState.hitPoints -=1;
    if (tankState.hitPoints == 1) {
      this.AP().pathRoute().clear();
      this.AP().pathOff();
      this.velocity(0, 0);
      this.team.removeFromTraffic(this);
    }
    if (tankState.hitPoints <= 0) {
      damager.team.sendEnemyKilled(this.ID);
      this.death();
    }

    team.sendEnemySpotted(this, damager);
  }


  //======================================
  void moveForward() {
    println("*** Tank.moveForward()");

    if (this.velocity.x < this.maxspeed) {
      this.velocity.x += 0.01;
    } else {
      this.velocity.x = this.maxspeed;
    }
  }

  void moveBackward() {
    println("*** Tank.moveBackward()");

    if (this.velocity.x > -this.maxspeed) {
      this.velocity.x -= 0.01;
    } else {
      this.velocity.x = -this.maxspeed;
    }
  }

  void stopMoving() {
    println("*** Tank.stopMoving()");

    // hade varit finare med animering!
    this.velocity.x = 0;
  }

  //======================================
  void action(String _action) {
    println("*** Tank.action()");

    switch (_action) {
    case "move":
      moveForward();
      break;
    case "reverse":
      moveBackward();
      break;
    case "turning":
      break;
    case "stop":
      stopMoving();
      break;
    }
  }



  //======================================
  //Här är det tänkt att agenten har möjlighet till egna val.

  void update() {
    println("*** Tank.update()");


    switch (state) {
    case 0:
      // still/idle
      action("stop");
      break;
    case 1:
      action("move");
      break;
    case 2:
      action("reverse");

      break;
    }

    this.position.add(velocity);
  }
}


public class Turret {
  Tank owner;

  PVector forwardVector;

  float currentAngle;

  Turret(Tank owner, PVector forwardVector) {
    this.forwardVector = forwardVector;
    this.owner = owner;
  }

  void rotateHeading(PVector heading) {

    float crossProduct = forwardVector.x * heading.y - forwardVector.y * heading.x;

    if (dist(heading.x, heading.y, forwardVector.x, forwardVector.y) <= 0.1) {
      return;
    }

    if (crossProduct < 0) {
      PVector v = new PVector(cos(radians(-TURRETROTATIONSPEED)), sin(radians(-TURRETROTATIONSPEED)));
      PVector w = new PVector(-sin(radians(-TURRETROTATIONSPEED)), cos(radians(-TURRETROTATIONSPEED)));

      PVector x = new PVector(v.x * forwardVector.x, v.y * forwardVector.x);
      PVector y = new PVector(w.x * forwardVector.y, w.y * forwardVector.y);

      forwardVector = x.add(y);
    } else {

      PVector v = new PVector(cos(radians(TURRETROTATIONSPEED)), sin(radians(TURRETROTATIONSPEED)));
      PVector w = new PVector(-sin(radians(TURRETROTATIONSPEED)), cos(radians(TURRETROTATIONSPEED)));

      PVector x = new PVector(v.x * forwardVector.x, v.y * forwardVector.x);
      PVector y = new PVector(w.x * forwardVector.y, w.y * forwardVector.y);

      forwardVector = x.add(y);
    }



    //forwardVector = forwardVector.lerp(heading, 1).normalize();
  }

  boolean rotateTurret(PVector destination, float deltaTime) {
    PVector direction = VecMath.normalize(VecMath.direction(owner.position.x, owner.position.y, destination.x, destination.y));
    float crossProduct = forwardVector.x * direction.y - forwardVector.y * direction.x;

    if (dist(direction.x, direction.y, forwardVector.x, forwardVector.y) <= 0.1) {
      return true;
    }

    if (crossProduct < 0) {
      PVector red = new PVector(cos(radians(-3)), sin(radians(-3)));
      PVector green = new PVector(-sin(radians(-3)), cos(radians(-3)));

      PVector x = new PVector(red.x * forwardVector.x, red.y * forwardVector.x);
      PVector y = new PVector(green.x * forwardVector.y, green.y * forwardVector.y);

      forwardVector = x.add(y);
    } else {

      PVector red = new PVector(cos(radians(3)), sin(radians(3)));
      PVector green = new PVector(-sin(radians(3)), cos(radians(3)));

      PVector x = new PVector(red.x * forwardVector.x, red.y * forwardVector.x);
      PVector y = new PVector(green.x * forwardVector.y, green.y * forwardVector.y);

      forwardVector = x.add(y);
    }
    return false;
    //PVector direction = VecMath.normalize(VecMath.direction(owner.position.x, owner.position.y, destination.x, destination.y));
    //forwardVector = forwardVector.lerp(direction, radians(3) * deltaTime).normalize();
  }
}

public class TankPic extends PicturePS {

  int base;
  float size;

  public TankPic(PApplet app, float size, int base) {
    super(app);
    this.size = size;
    this.base = base;
  }

  public TankPic(PApplet app, float size) {
    this(app, size, color(255, 169, 19));
  }


  public void draw(BaseEntity user, float posX, float posY, float velX,
    float velY, float headX, float headY, float etime) {

    Tank t = null;
    if (user instanceof Tank) {
      t = (Tank)user;
    }

    // Draw and hints that are specified and relevant
    if (hints != 0) {
      Hints.hintFlags = hints;
      Hints.draw(app, user, velX, velY, headX, headY);
    }
    // Determine the angle the tank is heading
    float turretangle = PApplet.atan2(t.turret.forwardVector.y, t.turret.forwardVector.x);
    float bodyAngle = PApplet.atan2(headY, headX);



    pushStyle();
    pushMatrix();


    

    fill(base);
    strokeWeight(1);
    translate(posX, posY);

    imageMode(CENTER);

    rotate(bodyAngle);

    fill(base, 100);
    ellipse(0, 0, size, size);
    line(0, 0, 0+25, 0);
    line(0, 0, -25, 0);




    //kanontornet





    float procentage = t.tankState.hitPoints/3.0f;

    strokeWeight(1);
    fill(base, 255);
    ellipse(0, 0, size/2, size/2);

    rotate(-bodyAngle);
    rotate(turretangle);
    strokeWeight(3);
    float cannon_length = size/1.5;
    line(0, 0, cannon_length, 0);
    strokeWeight(1);
    rotate(-turretangle);
    fill(#B7B5B5, 255);
    rect(-size/2, -40, 50, 5);

    fill(#F53B3B, 255);
    rect(-size/2, -40, 50*procentage, 5);

    textSize(20);
    fill(#000000, 255);
    textAlign(CENTER);
    text(t.ID, 0, -45);

    imageMode(CORNER);



    //strokeWeight(1);
    //fill(230);
    //rect(0+25, 0-25, 100, 40);
    //fill(30);
    //textSize(15);
    //text(this.name +"\n( " + this.position.x + ", " + this.position.y + " )", 25+5, -5-5);

    popMatrix();
    popStyle();
    

  }
}
