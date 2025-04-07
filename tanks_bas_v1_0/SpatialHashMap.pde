class SpatialhashMap{
 
  HashMap<Integer, PVector> spatialMap;
  
  private int mwidth;
  private int mheight;
  
  SpatialhashMap(int p_width, int p_height){
     mwidth = p_width;
     mheight = p_height;
     
     
     
     
  }

}




class Cell{
 
  PVector pos;
  boolean isWalkable = true;
  
  Cell(PVector position, boolean walkable){
      pos = position;
      isWalkable = walkable;
  }
  
}



class NavLayout {
 
  
    int minRec = 25;
    int size = 0;
    int mwidth = 0;
    int mheight = 0;

   
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
            fill(green, 50);
          }else{
            fill(red, 50);
          }    
     
          square(p.pos.x, p.pos.y, minRec);
          fill(color(0, 0, 0),100);
          //text(i, p.pos.x,p.pos.y + 25); 
      }   
  }
  
  int getCellPosition(float x, float y){
   
    int newX = floor(x/(mwidth/minRec));
    int newY = floor(y/(mheight/minRec));
    
    return newY * (mheight/25) + newX;
    
  }
  
  void updateNavLayout(){
    strokeWeight(1);
    fill(color(0,128,100), 100);
    int x = 455;
    int y = 305;
    int diameter = 100;
    circle(x, y,diameter);
    
    
         
    
         
    //försök hitta MAX Y MAX X och MIN X MIN Y alltsåå hörn av en rectangle fråon längst upp til vänster till längst ner till höger
    
    float xOri = x - diameter/2;
    float yOri = y - diameter/2;
    
    int distX =  floor((x + (diameter/2))/minRec) - floor(xOri/minRec);
    int distY =  floor((y + (diameter/2))/minRec) - floor(yOri/minRec);
  
    System.out.println(floor((x + (diameter/2))/minRec));
    System.out.println(floor(xOri/minRec));
  

    int[] cellValues = new int[distX*distY];

     
     
     for(int i = 0; i < distY; i++){     
         int index = i*distY;
         for(int j = 0; j < distX; j++){
             cellValues[index + j] = floor((yOri+i*minRec)/minRec) * (mheight/minRec) + floor((xOri+j*minRec)/minRec);
         }
     }
     
  
     for(int i = 0; i < distX*distY; i++){
      
          
        if(cellValues[i] > size || cellValues[i] < 0){
            return;
        }
        cells[cellValues[i]].isWalkable = false;
          
     }
   
    
  }
  
}
