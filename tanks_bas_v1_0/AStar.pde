
class AStar{
  
  
  LinkedList<GraphNode> path;
  boolean hasPath = false;
  int pathSize = 0;
  
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
    ArrayList<Node> closedList = new ArrayList<Node>();
   
    
    Node startNode = new Node(0, EuclideanDistance(start, goal), start);
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
          Node neighbour = new Node(lowestValueNode.pathCost + dist(p.x, p.y, lowestValueNode.position.x,lowestValueNode.position.y), ManhattanDistance(p, goal), p);
          System.out.println("PathCost:  " +neighbour.pathCost);
          if(closedList.contains(neighbour) || !nl.cells[neighbourIndex].isWalkable ){
             continue;
          }
          neighbour.parent = lowestValueNode;
          openList.add(neighbour, neighbour.sum);
       
      }
      
      
    
    }
    //System.out.println(closedList);
    return false;
    


  }
  
  void draw(){
      if(!hasPath){
        return;
      }
      for(int i = 0; i < astar.path.size(); i++){
        Vector2D point = new Vector2D(astar.path.get(i).x() ,astar.path.get(i).y());
        fill(color(0,0,0), 100);
        if(i+1 < astar.path.size()){
          Vector2D next = new Vector2D(astar.path.get(i+1).x() ,astar.path.get(i+1).y());
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
  
  //Calculated the heuristic function using the Manhattan Distance
  float ManhattanDistance(PVector current, PVector goal){
    return abs(current.x - goal.x) + abs(current.y - goal.y);
  }
  
  //Calculated the heuristic function using the Euclidean Distance
  float EuclideanDistance(PVector current, PVector goal){
    return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y,2));
  }
  
}
