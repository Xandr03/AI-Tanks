
public class CircleBox{
  PVector pos;
  float area;
  
  CircleBox(PVector pos, float area){
    this.pos = pos;
    this.area = area;
  }
}

public static class CollisionChecker{
  
  
  

  
  public static boolean checkCollision(Tank tank, Tank other){
    float dist = dist((float)tank.pos().x, (float)tank.pos().y, (float)other.pos().x, (float)other.pos().y);
    float sumRadius = tank.sensArea + other.sensArea;
    if(dist <= sumRadius){
      return true;
    }
   return false;   
  }
  
   public static boolean checkCollision(CircleBox tank, CircleBox other){
    float dist = dist((float)tank.pos.x, (float)tank.pos.y, (float)other.pos.x, (float)other.pos.y);
    float sumRadius = tank.area + other.area;
    if(dist <= sumRadius){
      return true;
    }
   return false;   
  }

}
