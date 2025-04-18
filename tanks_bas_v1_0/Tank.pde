

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
  
  
  Cell[] cellsVisited = new Cell[nl.size];
  
  //Array of notable item or enemies to update the team base knowledge
  
  Sensor sensor;
  
    
 
  //======================================  
  Tank(String _name, PVector _startpos, float _size, Team team ) {
    super(new Vector2D(_startpos.x, _startpos.y),25, new Vector2D(0,0), 40, new Vector2D(0, 1), 1, 100 ,200);
    println("*** Tank.Tank()");
    this.name         = _name;
    this.diameter     = _size;
    this.col          = team.teamColor;
    this.team = team;

    this.startpos     = new PVector(_startpos.x, _startpos.y);
    this.position     = new PVector(this.startpos.x, this.startpos.y);
    this.velocity     = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
    
    this.state        = 0; //0(still), 1(moving)
    this.speed        = 0;
    this.maxspeed     = 3;
    this.isInTransition = false;
    
    Domain tankDomain = new Domain(25, 25, 775, 775);
    this.worldDomain(tankDomain, SBF.REBOUND);
    this.addFSM();
    this.FSM().setGlobalState(tankGlobalState);
    this.FSM().changeState(idle);
    sensor = new Sensor(this, 2, 1);
  }
  
  public void setIdle(){
    this.FSM().changeState(idle);
  }
  public void returnToBase(){
    this.FSM().changeState(new TankObserving(3, tankReturnToBaseState));
  }
  
  public void setPatrole(){this.FSM().changeState(tankPatroleState);}
  //======================================
  void checkEnvironment() {
    println("*** Tank.checkEnvironment()");
    
    borders();
  }
  
  void checkNode(){
    sensor.checkFront();
  
  }
  
  void checkForCollisions(Tank sprite) {
    moveTo(new Vector2D(400, 400));
  }
  
  void checkForCollisions(PVector vec) {
    checkEnvironment();
  }
  
  boolean checkEnemyBoundry(PVector pos){
    if(team.team == Teams.red){
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
  
  void update(double deltaTime, World world){
    super.update(deltaTime, world);
    
  }
  
  
  //======================================
  void moveForward(){
    println("*** Tank.moveForward()");
    
    if (this.velocity.x < this.maxspeed) {
      this.velocity.x += 0.01;
    } else {
      this.velocity.x = this.maxspeed;  
    }
  }
  
  void moveBackward(){
    println("*** Tank.moveBackward()");
    
    if (this.velocity.x > -this.maxspeed) {
      this.velocity.x -= 0.01;
    } else {
      this.velocity.x = -this.maxspeed;  
    }
  }
  
  void stopMoving(){
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



public class TankPic extends PicturePS{
  
  int base;
  float size;
  
  public TankPic(PApplet app, float size, int base){
    super(app);
    this.size = size;
    this.base = base;
  
  }
  
  public TankPic(PApplet app, float size){
    this(app, size, color(255, 169, 19));
  }
  

  public void draw(BaseEntity user, float posX, float posY, float velX, 
  float velY, float headX, float headY, float etime){
    
    
    
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
