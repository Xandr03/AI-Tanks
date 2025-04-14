class Sensor {

  int frontSight = 2;
  int behindSight = 1;
  
  Tank owner;

  ArrayList<Integer> frontSightArray = new ArrayList<>();


  Sensor(Tank owner, int frontSight, int behindSight) {
    this.frontSight = frontSight;
    this.behindSight = behindSight;
    this.owner = owner;
    GenerateFrontSightArray();
  }

  void GenerateFrontSightArray() {

    int[] front = new int[]{-nl.mwidth/nl.minRec + 1
      , 1
      , nl.mwidth/nl.minRec + 1};

    for (int i = 0; i < 3; i++) {
      int currentCell = front[i];
      for (int j = 1; j < frontSight; j++) {
        frontSightArray.add(currentCell+j);
      }
    }
  }
  
  
  void checkFront(){
     float angle = PApplet.atan2((float)owner.heading().x, (float)owner.heading().y);
    for(int i = 0; i < frontSightArray.size(); i++){ 
      int index = abs(nl.getCellPosition((float)owner.pos().x, (float)owner.pos().y)+ frontSightArray.get(i));   
      System.out.println(index);
      if(nl.isValidIndex(index)){
        owner.cellsVisited[index] = nl.getCell(index);  
      }
      
    }
  
  }
}
