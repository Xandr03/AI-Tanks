// Följande kan användas som bas inför uppgiften.
// Syftet är att sammanställa alla varabelvärden i scenariet.
// Variabelnamn har satts för att försöka överensstämma med exempelkoden.
// Klassen Tank är minimal och skickas mer med som koncept(anrop/states/vektorer).


//IDE USE THE BUILT IN VEHICLE EXPLORATION MODULE AND THEN A* to find way back home


//TODO
//Nodes need collision check so it dosent walk in to areas its not allowed to


import game2dai.entities.*;
import game2dai.entityshapes.ps.*;
import game2dai.maths.*;
import game2dai.*;
import game2dai.entityshapes.*;
import game2dai.fsm.*;
import game2dai.steering.*;
import game2dai.utils.*;
import game2dai.graph.*;
import java.util.*;
import java.awt.event.KeyEvent;

boolean left, right, up, down;
boolean mouse_pressed;

PImage tree_img;
PVector tree1_pos, tree2_pos, tree3_pos;

Tree[] allTrees   = new Tree[3];
Tank[] allTanks   = new Tank[6];

// Team0
color team0Color;
PVector team0_tank0_startpos;
PVector team0_tank1_startpos;
PVector team0_tank2_startpos;
Tank tank0, tank1, tank2; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//

// Team1
color team1Color;
PVector team1_tank0_startpos;
PVector team1_tank1_startpos;
PVector team1_tank2_startpos;
Tank tank3, tank4, tank5;

int tank_size;

boolean gameOver;
boolean pause;

World world;

StopWatch sw;

Vehicle mover0;

NavLayout nl;

 
AStar astar = new AStar();

Team red;
Team blue;


Builder builder = new Builder();

//======================================
void setup() 
{
  
  //set variables
  frameRate(60);
  size(800, 800);
  nl = new NavLayout(775, 775, 25, 25, 25); //<>//
  
  world = new World(width, height);
  sw = new StopWatch();
  blue  = new Team(#004AFF, new PVector(width - 151, height - 351), Teams.blue, nl.size);
  red = new Team(#F22020, new PVector(0,0), Teams.red, nl.size);
  up             = false;
  down           = false;
  mouse_pressed  = false;
  
  gameOver       = false;
  pause          = true;
 
  
  // Trad
  allTrees[0] = new Tree(230, 600);
  allTrees[1] = new Tree(280, 230);
  allTrees[2] = new Tree(530, 520);
  
  world.add(allTrees[0]);
  world.add(allTrees[1]);
  world.add(allTrees[2]);
  
  BitmapPic treeImage = new BitmapPic(this, "tree01_v2.png");
  
  allTrees[0].renderer(treeImage);
  allTrees[1].renderer(treeImage);
  allTrees[2].renderer(treeImage);
 
  
  tank_size = 50;
  
  // Team0
  team0Color  = color(204, 50, 50);             // Base Team 0(red)
  team0_tank0_startpos  = new PVector(50, 50);
  team0_tank1_startpos  = new PVector(50, 150);
  team0_tank2_startpos  = new PVector(50, 250);
  
  // Team1
  team1Color  = color(0, 150, 200);             // Base Team 1(blue)
  team1_tank0_startpos  = new PVector(width-50, height-250);
  team1_tank1_startpos  = new PVector(width-50, height-150);
  team1_tank2_startpos  = new PVector(width-50, height-50);

  
  mover0 = new Vehicle(
      new Vector2D(width/2, height/2), // position
      15,                              // collision radius
     new Vector2D(15, 15),            // velocity
      40,                              // maximum speed
      new Vector2D(1, 1),              // heading
      1,                               // mass
      0.5,                             // turning rate
      200                              // max force
  );
  // What does this mover look like
  ArrowPic view = new ArrowPic(this);
  // Show collision and movement hints
  view.showHints(Hints.HINT_COLLISION | Hints.HINT_HEADING | Hints.HINT_VELOCITY);
  // Add the renderer to our MovingEntity
  mover0.renderer(view);
  // Constrain movement
  Domain d = new Domain(60, 60, width-60, height-60);
  mover0.worldDomain(d, SBF.REBOUND);
  // Finally we want to add this to our game domain
  world.add(mover0);
  
    //tank0_startpos = new PVector(50, 50);

    
  TankPic blueTank = new TankPic(this, 50, team0Color);
  blueTank.showHints(Hints.HINT_COLLISION | Hints.HINT_HEADING | Hints.HINT_VELOCITY);
  

  tank0 = new Tank("tank0", team0_tank0_startpos,tank_size, red );
  tank1 = new Tank("tank1", team0_tank1_startpos,tank_size, red );
  tank2 = new Tank("tank2", team0_tank2_startpos,tank_size, red );
  
  tank0.renderer(blueTank);
  tank1.renderer(blueTank);
  tank2.renderer(blueTank);

  
  TankPic redTank = new TankPic(this, 50, team1Color);
  redTank.showHints(Hints.HINT_COLLISION | Hints.HINT_HEADING | Hints.HINT_VELOCITY);
  tank3 = new Tank("tank3", team1_tank0_startpos,tank_size, blue );
  tank4 = new Tank("tank4", team1_tank1_startpos,tank_size, blue );
  tank5 = new Tank("tank5", team1_tank2_startpos,tank_size, blue );
 
  tank3.renderer(redTank);
  tank4.renderer(redTank);
  tank5.renderer(redTank);
  
  world.add(tank0);
  world.add(tank1);
  world.add(tank2);
  world.add(tank3);
  world.add(tank4);
  world.add(tank5);

  
   allTanks[0] = tank0;           
   // Symbol samma som index!
 
   allTanks[1] = tank1;
   allTanks[2] = tank2;
   allTanks[3] = tank3;
   allTanks[4] = tank4;
   allTanks[5] = tank5;
   
   allTanks[0].setPatrole();
   
  
  sw.reset();
  nl.updateNavLayout(world);
  

}

void draw()
{
  noCursor();
  double elapsedtime = sw.getElapsedTime();
  world.update(elapsedtime);
  background(200);
  
  nl.draw();
  blue.display();
  red.display();

  
  checkForInput(); // Kontrollera inmatning.
  builder.manageInput();
  if (!gameOver && !pause) {
    
    // UPDATE LOGIC
    updateTanksLogic();
    
    // CHECK FOR COLLISIONS
    checkForCollisions();
  
  }
  
 
  // UPDATE DISPLAY 
  displayHomeBase();

  displayGUI(); 

 
  world.draw(elapsedtime);
  astar.draw();

}

//======================================
void checkForInput() {
  
      if(mousePressed && (mouseButton == LEFT)){
      
        int index = nl.getCellPosition(mouseX, mouseY); 
        circle(mouseX, mouseY, 5);
        System.out.println("Is "+ index + " Walkable [" + nl.cells[index].pos+ "]"+ nl.cells[index].isWalkable);
           
        if(astar.computePath(new PVector((float)allTanks[0].pos().x, (float)allTanks[0].pos().y), new PVector(mouseX, mouseY), nl)){
           allTanks[0].AP().pathSetRoute(astar.path);
        }
      
      }

  
      if (up) {
        if (!pause && !gameOver) {
          tank0.state=1; // moveForward
        }
      } else 
      if (down) {
        if (!pause && !gameOver) {
          tank0.state=2; // moveBackward
        }
      }
      
      if (right) {
      } else 
      if (left) {
      }
      
      if (!up && !down) {
        tank0.state=0;
      }
}

//======================================
void updateTanksLogic() {
  for (Tank tank : allTanks) {
    tank.update();
  }

}

void checkForCollisions() {
  //println("*** checkForCollisions()");
  for (Tank tank : allTanks) {
    tank.checkForCollisions(tank1);
    tank.checkForCollisions(new PVector(width, height));
  }
}

//======================================
// Följande bör ligga i klassen Team
void displayHomeBase() {

}

void displayGUI() {
  if (pause) {
    textSize(36);
    fill(30);
    text("...Paused! (\'p\'-continues)\n(upp/ner-change velocity)", width/1.7-100, height/2.5);
  }
  
  if (gameOver) {
    textSize(36);
    fill(30);
    text("Game Over!", width/2-100, height/2);
  }  
}

//======================================
void keyPressed() {
  System.out.println("keyPressed!");

    if (key == CODED) {
      switch(keyCode) {
      case LEFT:
        left = true;
        break;
      case RIGHT:
        right = true;
        break;
      case UP:
        up = true;
        break;
      case DOWN:
        down = true;
        break;
      case KeyEvent.VK_1:
        System.out.println("Key 1");
        builder.mode = buildMode.air;
        break;
      case KeyEvent.VK_2:
        System.out.println("Key 2");
        builder.mode = buildMode.walls;
        break;
      }
    }else{
     switch(keyCode) {
      case KeyEvent.VK_1:
        System.out.println("Key 1");
        builder.mode = buildMode.air;
        break;
      case KeyEvent.VK_2:
        System.out.println("Key 2");
        builder.mode = buildMode.walls;
        break;
      }
    
    }

}

void keyReleased() {
  System.out.println("keyReleased!");
    if (key == CODED) {
      switch(keyCode) {
      case LEFT:
        left = false;
        break;
      case RIGHT:
        right = false;
        break;
      case UP:
        up = false;
        //tank0.stopMoving();
        break;
      case DOWN:
        down = false;
        //tank0.stopMoving();
        break;
      }
      
    }
    
    if (key == 'p') {
      pause = !pause;
    }
}

void mouseClicked()
{

 /*
  if(astar.computeStep(new PVector((float)allTanks[0].pos().x, (float)allTanks[0].pos().y), 1000, 10, nl)){
     allTanks[0].AP().pathSetRoute(astar.path);
  }
 */
}

// Mousebuttons
void mousePressed() {
  
  
  mouse_pressed = true;
  
}
