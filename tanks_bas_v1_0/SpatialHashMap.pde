
class SpatialhashMap{
 
  HashMap<Integer, PVector> spatialMap;
  
  private int mwidth;
  private int mheight;
  
  SpatialhashMap(int p_width, int p_height){
     mwidth = p_width;
     mheight = p_height;
     
     
     
     
  }

}


  public class Cell{
   
    public PVector pos;
    public boolean isWalkable = true;
    
    //fix the neighobure so a a left side is connected to the right, with this it wrapes
    ArrayList<Integer> neighboures = new ArrayList<>();

    
    Cell(PVector position, boolean walkable){
        pos = position;
        isWalkable = walkable;
    }
  
  }





public class NavLayout{
 
  
    int minRec = 25;
    int size = 0;
    int mwidth = 0;
    int mheight = 0;
    
    float rounder = 10;
    
    
    public int[] neighbours ={(-width/minRec) + 1, -width/minRec, -width/minRec - 1,
                              -1, /*0*/  1, 
                              (width/minRec) - 1, width/minRec, width/minRec + 1};
                              
                              
                              
                           
    

   
  Cell[] cells;
  
  NavLayout(int pwidth, int pheight){
    mheight = pheight;
    mwidth = pwidth;
    size = (pwidth/minRec) * (pheight/minRec);
    cells = new Cell[size];
    GenerateLayout();
    
  }
  
  void GenerateLayout(){
    
       for(int i = 0; i < mheight/minRec; i++){    
           int gheight = i*(mheight/minRec);
           for(int j = 0; j < mwidth/minRec; j++){  
               PVector pos = new PVector(j*minRec, i*minRec);
               cells[gheight + j] = new Cell(pos, true);
           }
    
      }
      
      for(int i = 0; i < size; i++){
        
        for(int j = 0; j < 8; j++){
          int neighbourIndex = abs(i + neighbours[j]);
          if(neighbourIndex > size - 1 || neighbourIndex < 0 ){continue;}
          if(dist(cells[neighbourIndex].pos.x, cells[neighbourIndex].pos.y, cells[i].pos.x, cells[i].pos.y) < sqrt(pow(minRec, 2) + pow(minRec, 2)) + rounder){
            if(cells[i].neighboures.contains(neighbourIndex)){
              continue;
            }
            cells[i].neighboures.add(neighbourIndex);
          }      
        }
      
      }
    
  }
  
  
  void draw(){
   
      
      strokeWeight(1);
      color green = color(0,128,0);
      color red = color(205,28,24);
      
      textSize(10);
     
      circle(350, 350,5);
      for(int i = 0; i < size; i++){
          Cell p = cells[i];    
          if(p.isWalkable){
            fill(green, 35);
          }else{
            fill(red, 35);
          }    
          circle(p.pos.x, p.pos.y, 10);
          square(p.pos.x, p.pos.y, minRec);
          fill(color(0, 0, 0),100);
          //text(i, p.pos.x,p.pos.y + 25); 
      }   
      
  }
  
  int getCellPosition(float x, float y){
    
    
    //System.out.println("X : " + x + " Y : " + y);
   
    int newX = floor(x/minRec);
    int newY = floor(y/minRec);
    
    //System.out.println("newX : " + newX + " newY : " + newY);
    
    return newY * (mheight/minRec) + newX;
    
  }
  
int getCellPosition(PVector vec){
    
    
    //System.out.println("X : " + vec.x + " Y : " + vec.y);
   
    int newX = floor(vec.x/minRec);
    int newY = floor(vec.y/minRec);
    
    //System.out.println("newX : " + newX + " newY : " + newY);
    
    return newY * (mheight/minRec) + newX;
    
  }
  
  void updateNavLayout(World world){
    
    
     int ObstacleSize = world.getObstacles(0,0).size();
     Obstacle[] setOfOb = world.getObstacles(0,0).toArray(new Obstacle[ObstacleSize]);
    
    for(int i = 0; i < ObstacleSize; i++){
      
      float x = (float)setOfOb[i].pos().x;
      float y = (float)setOfOb[i].pos().y;
      float diameter = (float)setOfOb[i].colRadius();
      
      float xOri = x - diameter/2;
      float yOri = y - diameter/2;
      
      int distX =  floor((x + (diameter/2))/minRec) - floor(xOri/minRec);
      int distY =  floor((y + (diameter/2))/minRec) - floor(yOri/minRec);
    
      //System.out.println(floor((x + (diameter/2))/minRec));
      //System.out.println(floor(xOri/minRec));
  
      int[] cellValues = new int[distX*distY];
      
      for(int j = 0; j < size; j++){
      
          if(dist(x,y, cells[j].pos.x ,cells[j].pos.y ) <= diameter){
              cells[j].isWalkable = false;     
          }
      
      }
     
      
    }
  
  }
  
}
