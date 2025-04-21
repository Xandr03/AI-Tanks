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

    int[] front = new int[]{-owner.team.nav.mwidth/owner.team.nav.minRec + 1
      , 1
      , owner.team.nav.mwidth/owner.team.nav.minRec + 1};

    for (int i = 0; i < 3; i++) {
      int currentCell = front[i];
      for (int j = 1; j < frontSight; j++) {
        frontSightArray.add(currentCell+j);
      }
    }
  }
  
  
  void checkFront(){
    int parentIndex = owner.team.nav.getCellPosition((float)owner.pos().x, (float)owner.pos().y);

    Cell c = owner.team.nav.cells[parentIndex];
    for(int i = 0; i < c.neighboures.size(); i++){ 
      int index =  c.neighboures.get(i);
      System.out.println(index);
      if(owner.team.nav.isValidIndex(index)){
        owner.team.nav.cells[index].visited = true;
        owner.team.nav.cells[index].timeSinceLastVisit = sw.getRunTime();
      }
      
    }
  
  }
}
