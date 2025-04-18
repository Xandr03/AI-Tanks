


public class Cell{
 
  public PVector pos;
  public boolean isWalkable = true;
  public float disc = 100;
  
  public float EnemyDistance = 0;
  
  
  float getDiscovery(){
    float tempDisc = disc;
    disc -= 25;
    return tempDisc;
  }
  
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
    
    int xOffset = 0;
    int yOffset = 0;
    
    
    public int[] neighbours;
                              
                             
   
  Cell[] cells;
  
  NavLayout(int pwidth, int pheight, int cellSize){
    this.minRec = cellSize;
    mheight = pheight;
    mwidth = pwidth;
    size = (pwidth/minRec) * (pheight/minRec);
    cells = new Cell[size];
    GenerateLayout();
    
  }
  
  NavLayout(int pwidth, int pheight, int xOffset, int yOffset, int cellSize){
    this.minRec = cellSize;
    mheight = floor(pheight);
    mwidth = floor(pwidth);
    size = floor(pwidth/minRec) * floor(pheight/minRec);
    System.out.println(floor(pwidth/minRec) * floor(pheight/minRec));
    cells = new Cell[size];
    this.xOffset = xOffset;
    this.yOffset = yOffset;
    neighbours = new int[] {(-mwidth/minRec + 1), (-mwidth/minRec), (-mwidth/minRec - 1), -1, 1, (mwidth/minRec - 1), (mwidth/minRec), (mwidth/minRec + 1)};
    //{(-mwidth/minRec + 1), (-mwidth/minRec), (-mwidth/minRec - 1), -1, 1, (mwidth/minRec - 1), (mwidth/minRec), (mwidth/minRec + 1)};
    GenerateLayout();
    
  }
  
  void GenerateLayout(){
    
       for(int i = 0; i < mheight/minRec; i++){    
           int gheight = i*((mheight/minRec));
           for(int j = 0; j < mwidth/minRec; j++){  
               PVector pos = new PVector(j*minRec + xOffset, i*minRec + yOffset);
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
   
      
      noStroke();
      color green = color(0,128,0);
      color red = color(205,28,24);
      rectMode(CENTER);
      textSize(10);
     
      circle(350, 350,5);
      Cell c = cells[getCellPosition(mouseX, mouseY)];
      for(int i = 0; i < size; i++){
          Cell p = cells[i];    
          float reach = 100;
          float dist = dist(p.pos.x, p.pos.y, c.pos.x, c.pos.y);
          if(p.isWalkable){    
            
             stroke(max(0, 1 - dist/reach));
             strokeWeight(max(0, 1 - dist/reach));
             
             fill(#12FA36, 100 - dist);  
             rect(p.pos.x, p.pos.y, minRec,minRec);
             fill(#36E85E,max(30, 100 - dist));   
             rect(p.pos.x, p.pos.y, minRec,minRec);
            
          }else{
             strokeWeight(max(0, 1 - dist/reach));
             stroke(max(0, 1 - dist/reach));

             fill(red,max(30, 100 - dist));  
             rect(p.pos.x, p.pos.y, minRec,minRec);
          }    

          
          noStroke();
         
          
          fill(color(0, 0, 0),100);
          textAlign(CENTER);
          text(i, p.pos.x,p.pos.y); 
     
      } 
      DrawTank0PathsFound();
      blendMode(REPLACE);
      
      fill(color(0, 0, 0),100);
      textAlign(CENTER);
    
      fill(color(#1DF092),100);
      if(!c.isWalkable){fill(color(#F21818),100);}
      square(c.pos.x, c.pos.y,minRec*1.2);
      text(getCellPosition(mouseX, mouseY), c.pos.x,c.pos.y);

      blendMode(BLEND);

      rectMode(CORNER);
      strokeWeight(1);
      stroke(1);
      
  }
  
  
  void DrawTank0PathsFound(){
    Cell[] cs = allTanks[0].cellsVisited;
    for(int i = 0; i < size; i++){
      Cell p = cells[i];
      if(cs[i] == cells[i]){
        fill(#AE14FC,50);  
        rect(p.pos.x, p.pos.y, minRec,minRec);
      }
    
    }
  }
  
  
  public Cell getCell(int index){
    if(!isValidIndex(index)){
      return null;
    }
    return cells[index];
  }
  
  public boolean isValidIndex(int index){
    if(index > size - 1 || index < 0){
      return false;
    }
    return true;
  
  }
  
  
  int[] getCellRecArea(int w, int h, PVector centerPoint){
  
    int[] arr = new int[w*h];
    
    PVector tl = new PVector(centerPoint.x - (minRec * w), centerPoint.y -( minRec*h));
    
    int total = 0;
    for(int i = 0; i < h; i++){
      int index = getCellPosition(tl.x, tl.y) + i * mwidth/minRec;
      for(int j = 0; j < w; j++){
        arr[total] = index + j;
        total++;
      }
    }
    return arr;
  }
  
  
  int getCellPosition(float x, float y){
    
    
    //System.out.println("X : " + x + " Y : " + y);
    
    PVector fixed = new PVector(x, y);
   
    return getCellPosition(fixed);
    
  }
  
int getCellPosition(PVector vec){
    
    
    //System.out.println("X : " + vec.x + " Y : " + vec.y);
    
    PVector fixed = vec;

    if(fixed.x < 0 + xOffset){
      fixed.x = xOffset;
    }
    if(fixed.y < 0 + yOffset){
      fixed.y = yOffset;
    }
    if(fixed.x > mwidth){
      fixed.x = mwidth;
    }
    if(fixed.y > mheight){
      fixed.y = mheight;
    }
    
   
    int newX = floor((fixed.x - xOffset + (minRec/2))/minRec);
    int newY = floor((fixed.y - yOffset + (minRec/2))/minRec);
    
    //System.out.println("newX : " + newX + " newY : " + newY);
    
    return newY  * (mheight/minRec) + newX ;
    
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
