public enum buildMode{
  walls,
  air
}

class Builder{
  
  buildMode mode = buildMode.air;
    
  void manageInput(){
    if(mousePressed && (mouseButton == RIGHT)){
      int index = red.nav.getCellPosition(mouseX, mouseY);
      switch(mode){
        case walls:
        System.out.println("walls");
        red.nav.cells[index].isWalkable = false;
        break;
        case air:
        red.nav.cells[index].isWalkable = true;
        break;
      }
     }
  }
}
