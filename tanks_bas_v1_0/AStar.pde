
class AStar{
  
  
  ArrayList<Vector2D> path;
  
   class Node implements Comparable<Node>{
    
    float pathCost;
    float heuristicCost;
    float sum;
    PVector position;
    Node parent;
    
    
    Node(float pathCost, float heuristicCost, PVector position){
      this.pathCost = pathCost;
      this.heuristicCost = heuristicCost;
      this.sum = pathCost + heuristicCost;
      this.position = position;
      this.parent = null;
    }
   
   
    @Override public int compareTo(Node otherNode){
      if(this.equals(otherNode)){
        return 0;
      }
      if(dist(0,0, this.position.x, this.position.y) < dist(0,0, otherNode.position.x, otherNode.position.y)){
        return -1;
      }
      return 1; 
    }
    
    
    @Override public boolean equals(Object other){  
        if(other == null){return false;}
        if(this == other) { return true;}
        if(!(other instanceof Node)){
          return false;
        }  
        Node otherNode = (Node)other;
        return this.position.equals(otherNode.position);
    } 

  }
  
  boolean computePath(PVector start, PVector goal, NavLayout nl){

    //open list contains cells that has not been searched.
    //lowest cost first 
    PriorityQueue<Node> openList = new PriorityQueue<Node>();
    //Closed list containt the cells that have already been explored
    ArrayList<Node> closedList = new ArrayList<Node>();
   
    
    Node startNode = new Node(0, ManhattanDistance(start, goal), start);
    openList.add(startNode, startNode.sum);
    while(!openList.isEmpty()){
    
      Node lowestValueNode = openList.poll();
      int index = nl.getCellPosition(lowestValueNode.position);
      closedList.add(lowestValueNode);
      
      
      if(lowestValueNode.position.equals(goal)){       
        this.path = reconstructPath(lowestValueNode);     
        return true;
      }
      
      for(int i = 0; i < 8; i++){
          PVector p = nl.cells[nl.neighbours[i] + index].pos;
          Node neighbour = new Node(lowestValueNode.pathCost + 1, ManhattanDistance(p, goal), p);
 
          if(closedList.contains(neighbour) || !nl.cells[nl.neighbours[i] + index].isWalkable ){
             continue;
          }
          neighbour.parent = lowestValueNode;
          openList.add(neighbour, neighbour.sum);
       
      }
      
      
    
    }
    return false;
    


  }
  
  ArrayList<Vector2D> reconstructPath(Node current){
    
    ArrayList<Vector2D> path = new ArrayList<>();;
    
    while(current != null){
      path.add(new Vector2D(current.position.x, current.position.y));
      current = current.parent;
    }
    return path;
  }
  
  //Calculated the heuristic function using the Manhattan Distance
  float ManhattanDistance(PVector current, PVector goal){
    return abs(current.x - goal.x) + abs(current.y - goal.y);
  }
  
  //Calculated the heuristic function using the Euclidean Distance
  float EuclideanDistance(PVector current, PVector goal){
    return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y,2));
  }
  
}
