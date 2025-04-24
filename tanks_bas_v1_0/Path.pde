//Alexander Bakas alba5453
class Path{

  Tank owner;
  
  LinkedList<Cell> path = new LinkedList<>();

  Path(){

  }
  
  //1. Rotate until tank is aligen with a point 
  //2. Set velocity to move to that point 
  //3. When reached point stop
  //Repeat 1-3 till path is empty
  
  void SetPath(LinkedList<Cell> c){
    path = c;
  }
  void update(){
    
     if(pathPointReached()){
       path.poll();
       owner.velocity(0,0);
       System.out.println("Reachead point");
     }
     
     if(isAlignedToPoint()){
       System.out.println("Align To Point");
       PVector v = VecMath.normalize(VecMath.direction2D((float)owner.pos().x,(float)owner.pos().y, path.peek().pos.x, path.peek().pos.y));
       owner.velocity(v.x * owner.maxspeed, v.y *owner.maxspeed);
     }else{rotateOwner();}
  }
  
  
  boolean isAlignedToPoint(){
    if(path.isEmpty()){return false;}
    PVector pos = new PVector((float)owner.pos().x ,(float)owner.pos().y);
    int angle = round(VecMath.dotAngle(new PVector((float)owner.heading().x, (float)owner.heading().y), VecMath.normalize(VecMath.direction(pos.x, pos.y, path.peek().pos.x, path.peek().pos.y))));
    if( angle > 5 ){
       return true;
    } 
    return false;
   
  }
  
  void rotateOwner(){ 
     if(path.isEmpty()){return;}
     System.out.println(path.peekFirst());
     PVector v = VecMath.normalize(VecMath.direction2D((float)owner.pos().x,(float)owner.pos().y, path.peek().pos.x, path.peek().pos.y));
     System.out.println(v.toString());
     owner.heading(v.x *2  , v.y * 2);
  }
  
  boolean pathPointReached(){
    if(path.isEmpty()){return false;}
    float dist = dist(path.peek().pos.x, path.peek().pos.y, (float)owner.pos().x, (float)owner.pos().y);
    if(dist < 0 + 1){
      return true;
    }
    return false;
    
  }
  
  
  
}
