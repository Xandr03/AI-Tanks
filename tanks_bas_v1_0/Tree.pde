//Alexander Bakas alba5453
class Tree extends Obstacle {
  
  PVector position;
  String  name; 
  PImage  img;
  float   diameter;
  
  //**************************************************
  Tree(int _posx, int _posy) {
    super(new Vector2D( _posx, _posy), 0);
    this.img       = loadImage("tree01_v2.png");
    this.diameter  = this.img.width/2;
    colRadius(diameter);
    this.name      = "tree";
    this.position  = new PVector(_posx, _posy);
   
  }

  //**************************************************
  
  void checkCollision() {
    
  }
}
