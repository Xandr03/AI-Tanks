public static class CollisionChecker{

  
  public static boolean checkCollision(Tank tank, Tank other){
    float dist = dist((float)tank.pos().x, (float)tank.pos().y, (float)other.pos().x, (float)other.pos().y);
    float sumRadius = tank.sensArea + other.sensArea;
    if(dist <= sumRadius){
      return true;
    }
   return false;   
  }

}
