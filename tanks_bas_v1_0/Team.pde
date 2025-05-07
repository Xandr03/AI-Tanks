//Alexander Bakas alba5453
public enum Teams{
  red,
  blue
}

class Team  {
  
  
  NavLayout nav;
    
  HTNState WorldState;
  
  PVector position;
  int mwidth = 150;
  int mheight = 350;
  color teamColor;
  Teams team;
  
 Tank[] tanks = new Tank[3];
  
  int size = 0;
  
  Team(color teamColor, PVector pos, Teams team){
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
    WorldState = new HTNState(this);
  }
  
  int addTank(Tank t){
    tanks[size] = t;
    return size++;
  }
  
  Team(color teamColor, PVector pos, Teams team, NavLayout nav){
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
    this.nav = nav;
    WorldState = new HTNState(this);
  }
  
  public boolean checkBoundry(PVector other){
    
    if(other.x > position.x && other.x < position.x + mwidth){
      if(other.y > position.y && other.y < position.y + mheight){
        return true;
      }
      return false;
    }
    return false;
  }
  
  void report(ArrayList<Cell> cells){
    for(int i = 0; i < cells.size(); i++){
       Cell c = cells.get(i);
       if(c.isEnemyNearby){
         reportEnemy(c.pos);
         continue;
       }
       if(c.isEnemyBase){
         reportBase();
         continue;
       }
    }
  }
  
  void reportEnemy(PVector center){
    int[] enemyCells = nav.getCellRecArea(10,10, center);
    for(int i = 0; i < 10*10; i++){
      nav.cells[enemyCells[i]].isEnemyNearby = true;
    }
  }
  
  void reportBase(){
    PVector center;
    if(team == Teams.blue){
      center = new PVector(red.position.x + 75 ,blue.position.y + 125 );
    }
    else{center = new PVector(blue.position.x + 75,blue.position.y + 125 );}
    int[] enemyCells = nav.getCellRecArea(10,20, new PVector(center.x, center.y));
    for(int i = 0; i < 10*20; i++){
      if(nav.isValidIndex(enemyCells[i])){
       nav.cells[enemyCells[i]].isEnemyBase = true;
      }
    }
  
  }
  
  // Används inte, men bör ligga här. 
  void displayHomeBase() {
      fill(teamColor, 50);    // Base Team 1(blue) 
      rect(position.x, position.y, mwidth, mheight);
  }
  
  void display() {
    nav.updateNavLayout(world);
    displayHomeBase();
  }
}
