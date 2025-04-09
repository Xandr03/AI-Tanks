
class AStar{
  
  
  LinkedList<GraphNode> path;
  boolean hasPath = false;
  int pathSize = 0;
  
  public ArrayList<Node> closedList = new ArrayList<Node>();
  public ArrayList<Node> visited = new ArrayList<Node>();
  
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
    
    @Override public String toString(){
      String s = "X: " + position.x + " Y: " + position.y;
      return s;
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
    closedList = new ArrayList<Node>();
    visited = new ArrayList<Node>();
    
    Node startNode = new Node(0, ManhattanDistance(start, goal), start);
    openList.add(startNode, startNode.sum);
    while(!openList.isEmpty()){
    
      Node lowestValueNode = openList.poll();
      int index = nl.getCellPosition(lowestValueNode.position);
      if(!nl.cells[index].isWalkable){
        continue;
      }
      closedList.add(lowestValueNode);
      
     
      if(nl.getCellPosition(lowestValueNode.position) == nl.getCellPosition(goal)){       
        this.path = reconstructPath(lowestValueNode);     
        hasPath = true;
        return true;
      }
      
      Cell currentCell = nl.cells[index];
      
      for(int i = 0; i < currentCell.neighboures.size(); i++){
          int neighbourIndex = currentCell.neighboures.get(i);
        
         
          if(neighbourIndex > nl.size - 1 || neighbourIndex < 0 ){continue;}
          
          PVector p = nl.cells[neighbourIndex].pos;
         
      
          Node neighbour = new Node(abs(lowestValueNode.pathCost + dist(p.x, p.y, lowestValueNode.position.x,lowestValueNode.position.y))/nl.minRec, ManhattanDistance(p, goal), p);
          System.out.println("PathCost:  " +neighbour.pathCost);
          if(closedList.contains(neighbour) || !nl.cells[neighbourIndex].isWalkable ){
             continue;
          }
          visited.add(neighbour);
          neighbour.parent = lowestValueNode;
          openList.add(neighbour, neighbour.sum);
          
          
      }
  
      
      
    
    }
    
    return false;
    


  }
  
  void draw(){
      blendMode(REPLACE);
      textSize(15);
      if(!hasPath){
        return;
      }
      
      for(int i = 0; i < visited.size(); i++){
          Vector2D point = new Vector2D(visited.get(i).position.x ,visited.get(i).position.y);
          blendMode(REPLACE);
          fill(color(255,222,33), 100);
          circle((float)point.x, (float)point.y, 10);
      }  
      


     for(int i = 0; i < closedList.size(); i++){
        Vector2D point = new Vector2D(closedList.get(i).position.x ,closedList.get(i).position.y);
        fill(color(255,0,0), 100);
        circle((float)point.x, (float)point.y, 10);

      }  

      for(int i = 0; i < path.size(); i++){
        Vector2D point = new Vector2D(path.get(i).x() ,path.get(i).y());
        fill(color(0,255,0), 100);
        if(i+1 < path.size()){
          Vector2D next = new Vector2D(path.get(i+1).x() ,path.get(i+1).y());
          line((float)point.x, (float)point.y, (float)next.x, (float)next.y);
        }
        circle((float)point.x, (float)point.y, 10);
        
      
      }  
      
 
  }
  
  LinkedList<GraphNode> reconstructPath(Node current){
    
    LinkedList<GraphNode> path = new LinkedList<>();
    int id = 0;
    while(current != null){
      path.addFirst(new GraphNode(id++,current.position.x, current.position.y));
      current = current.parent;
    }
  
    return path;
  }
  
  float distance(PVector current, PVector other){
    return abs(dist(current.x, current.y, other.x, other.y));
  }
  
  //Calculated the heuristic function using the Manhattan Distance
  float ManhattanDistance(PVector current, PVector goal){
    return abs(current.x- goal.x) + abs(current.y - goal.y);
  }
  
  //Calculated the heuristic function using the Euclidean Distance
  float EuclideanDistance(PVector current, PVector goal){
    return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y,2));
  }
  
}
