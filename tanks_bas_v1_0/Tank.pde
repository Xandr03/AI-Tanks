//Alexander Bakas alba5453

TankPatroleState tankPatroleState = new TankPatroleState();

TankReturnToBaseState tankReturnToBaseState = new TankReturnToBaseState();
TankGlobalState tankGlobalState = new TankGlobalState();
TankIdleState idle = new TankIdleState();



class Tank extends Vehicle {




  //Store Nodes it has visited

  PVector acceleration;
  PVector velocity;
  PVector position;

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
  
  int hitPoints = 3;
  
  int ID;

  Plan_runner runner;
  
  int regionToExplore = 0;

  //Array of notable item or enemies to update the team base knowledge

  ArrayList<Cell> reportCells = new ArrayList<>();

  Sensor sensor;


  Path path = new Path();



  //======================================
  Tank(String _name, PVector _startpos, float _size, Team team, Team oposition ) {
    super(new Vector2D(_startpos.x, _startpos.y), 25, new Vector2D(0, 0), 30, new Vector2D(0, 1), 1, 10, 100);
    println("*** Tank.Tank()");
    this.name         = _name;
    this.diameter     = _size;
    this.col          = team.teamColor;
    this.team = team;

    this.startpos     = new PVector(_startpos.x, _startpos.y);

    this.velocity     = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);

    this.speed        = 0;
    this.maxspeed     = 20;
    this.isInTransition = false;

    Domain tankDomain = new Domain(25, 25, 775, 775);
    this.worldDomain(tankDomain, SBF.REBOUND);
    this.addFSM();
    this.FSM().setGlobalState(tankGlobalState);
    this.FSM().changeState(idle);

    sensor = new Sensor(this, 2, 1);
    this.path.owner = this;
    this.oposition = oposition;

    this.ID = team.addTank(this);
    runner = new Plan_runner(this);
  }

  public void report() {
    team.report(reportCells);
    reportCells = new ArrayList<Cell>();
  }

  public boolean EnemyInVision() {

    boolean found = false;
    for (int i = 0; i < oposition.size; i++) {

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
    
    runner.update((float)deltaTime);

    /*
    for (MovingEntity m : world.getMovers(this)) {
      if (m == this) {

        continue;
      }
      if (m instanceof Tank) {

        Tank v = (Tank)m;

        PVector direction = VecMath.direction((float)this.pos().x, (float)this.pos().y, (float)m.pos().x, (float)m.pos().y);
        float angle = VecMath.dotAngle(new PVector((float)this.heading().x, (float)this.heading().y), VecMath.normalize(direction));
        float dist = dist((float)this.pos().x, (float)this.pos().y, (float)m.pos().x, (float)m.pos().y);
        State otherState = v.FSM().getCurrentState();
        if (dist <= 60 && angle > 0) {
          if(otherState instanceof TankBreakAndWait && ((TankBreakAndWait)otherState).other == this) {
            this.FSM().changeState(tankPatroleState);
            continue;
          }
          this.FSM().changeState(new TankBreakAndWait(v));
        }
      }
    }
    */
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



    // Draw and hints that are specified and relevant
    if (hints != 0) {
      Hints.hintFlags = hints;
      Hints.draw(app, user, velX, velY, headX, headY);
    }
    // Determine the angle the tank is heading
    float angle = PApplet.atan2(headY, headX);



    pushStyle();
    pushMatrix();



    fill(base);
    strokeWeight(1);

    translate(posX, posY);

    imageMode(CENTER);

    fill(base, 100);
    ellipse(0, 0, size, size);
    rotate(angle);
    strokeWeight(1);
    line(0, 0, 0+25, 0);

    //kanontornet
    ellipse(0, 0, size/2, size/2);
    strokeWeight(3);
    float cannon_length = size/2;
    line(0, 0, cannon_length, 0);
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
