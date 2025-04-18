
public enum Teams{
  red,
  blue
}

class Team  {
  
  
  
  Cell[] cellInformation;
  
  NavLayout nav;
    
  
  int size;
  
  
  PVector position;
  int mwidth = 150;
  int mheight = 350;
  color teamColor;
  Teams team;
  
  Team(color teamColor, PVector pos, Teams team){
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
  }
  
  Team(color teamColor, PVector pos, Teams team, NavLayout nav){
    this.position = pos;
    this.teamColor = teamColor;
    this.team = team;
    this.nav = nav;
  }
  
  void setInformationSize(int size){
    cellInformation = new Cell[size];
    this.size = size;
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
  
  // Används inte, men bör ligga här. 
  void displayHomeBase() {
      fill(teamColor, 50);    // Base Team 1(blue) 
      rect(position.x, position.y, mwidth, mheight);
  }
  
  void display() {
    displayHomeBase();
  }
}
