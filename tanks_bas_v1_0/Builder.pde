public enum buildMode{
  walls,
  air
}

class Builder{
  
  buildMode mode = buildMode.air;
    
  void manageInput(){
    if(mousePressed && (mouseButton == RIGHT)){
      int index = nl.getCellPosition(mouseX, mouseY);
      switch(mode){
        case walls:
        System.out.println("walls");
        nl.cells[index].isWalkable = false;
        break;
        case air:
        nl.cells[index].isWalkable = true;
        break;
      }
     }
  }
}
