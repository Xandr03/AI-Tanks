
class AStar{
  
  
  LinkedList<GraphNode> path;
  LinkedList<Cell> path2;
  boolean hasPath = false;
  int pathSize = 0;
  
  public Node[] closedList;
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
      if(round(this.sum) > round(otherNode.sum)){
        return 1;
      }
      if(round(this.sum) < round(otherNode.sum)){
        return -1;
      }
      return 0; 
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
        boolean bPos = this.position.x == otherNode.position.x && this.position.y == otherNode.position.y;
        boolean bSum = this.sum == otherNode.sum;
        return bPos;
    } 
    


  }
  
  boolean computePath(PVector start, PVector goal, NavLayout nl){
  
    if(!nl.cells[nl.getCellPosition(goal)].isWalkable) {return false;}
    //open list contains cells that has not been searched.
    //lowest cost first 
    PriorityQueue<Node> openList = new PriorityQueue<Node>();
    //Closed list containt the cells that have already been explored
    closedList = new Node[nl.size];
    visited = new ArrayList<Node>();
    
    
    PVector newGoal = nl.cells[nl.getCellPosition(goal)].pos;
    
    Node startNode = new Node(0, EuclideanDistance(start, newGoal), start);
    openList.add(startNode);
    while(!openList.isEmpty()){
    
      //System.out.println(openList.peek().sum);
      Node lowestValueNode = openList.poll();
      int index = nl.getCellPosition(lowestValueNode.position);
      if(!nl.cells[index].isWalkable){
        continue;
      }
      closedList[index] = lowestValueNode;
      
     
      if(nl.getCellPosition(lowestValueNode.position) == nl.getCellPosition(newGoal)){       
        Node gn = new Node(lowestValueNode.pathCost, lowestValueNode.heuristicCost, goal);
        gn.parent = lowestValueNode.parent;
        this.path = reconstructPath(gn, nl.minRec);    
        this.path2 = reconstructPathCell(gn, nl.minRec);
        hasPath = true;
        return true;
      }
      
      Cell currentCell = nl.cells[index];
     
      
      for(int i = 0; i < currentCell.neighboures.size(); i++){
          int neighbourIndex = currentCell.neighboures.get(i);
          
         
          if(neighbourIndex > nl.size - 1 || neighbourIndex < 0 ){continue;}
          
          PVector p = nl.cells[neighbourIndex].pos;
         
          float gAcc = lowestValueNode.pathCost + abs(dist(p.x, p.y, lowestValueNode.position.x,lowestValueNode.position.y))/nl.minRec;
          float heurCost = EuclideanDistance(p, newGoal);
          Node neighbour = new Node(gAcc, heurCost, p);
          neighbour.parent = lowestValueNode;
          if(!nl.cells[neighbourIndex].isWalkable ){
             continue;
          }          
          if(neighbour.equals(closedList[neighbourIndex])){
            continue;
          }
          visited.add(neighbour);
          
          openList.add(neighbour);
          
          
      }
  
      
      
    
    }
    
    return false;
    


  }
  
  
  
  boolean computeKnowablePath(PVector start, PVector goal, NavLayout nl, Tank t){
  
    if(!t.team.nav.cells[t.team.nav.getCellPosition(goal)].isWalkable) {return false;}
    //open list contains cells that has not been searched.
    //lowest cost first 
    PriorityQueue<Node> openList = new PriorityQueue<Node>();
    //Closed list containt the cells that have already been explored
    closedList = new Node[t.team.nav.size];
    visited = new ArrayList<Node>();
    
    
    PVector newGoal = t.team.nav.cells[t.team.nav.getCellPosition(goal)].pos;
    
    Node startNode = new Node(0, EuclideanDistance(start, newGoal), start);
    openList.add(startNode);
    while(!openList.isEmpty()){
    
     
      Node lowestValueNode = openList.poll();
      int index = t.team.nav.getCellPosition(lowestValueNode.position);
      System.out.println(index);
      if(t.team.nav.cells[index] == null){continue;};
      
      if(!t.team.nav.cells[index].isWalkable){
        continue;
      }
      closedList[index] = lowestValueNode;
      
     
      if(t.team.nav.getCellPosition(lowestValueNode.position) == t.team.nav.getCellPosition(newGoal)){       
        Node gn = new Node(lowestValueNode.pathCost, lowestValueNode.heuristicCost, goal);
        gn.parent = lowestValueNode.parent;
        this.path = reconstructPath(gn, t.team.nav.minRec);     
        hasPath = true;
        return true;
      }
      
      Cell currentCell = t.team.nav.cells[index];
     
      
      for(int i = 0; i < currentCell.neighboures.size(); i++){
          int neighbourIndex = currentCell.neighboures.get(i);
          
          if(t.team.nav.cells[neighbourIndex] == null){continue;};
         
          if(neighbourIndex > t.team.nav.size - 1 || neighbourIndex < 0 ){continue;}
          
          PVector p = t.team.nav.cells[neighbourIndex].pos;
          circle(p.x, p.y, 10);
         
          float gAcc = lowestValueNode.pathCost + abs(dist(p.x, p.y, lowestValueNode.position.x,lowestValueNode.position.y))/t.team.nav.minRec;
          float heurCost = EuclideanDistance(p, newGoal);
          Node neighbour = new Node(gAcc, heurCost, p);
          neighbour.parent = lowestValueNode;
          if(!t.team.nav.cells[neighbourIndex].isWalkable ){
             continue;
          }          
          if(neighbour.equals(closedList[neighbourIndex])){
            continue;
          }
          visited.add(neighbour);
          
          openList.add(neighbour);
          
          
      }
  
      
      
    
    }
    
    return false;
    


  }
  
  //Weighted based on discovery
  boolean computeStep(PVector start, float discoverGoal, int maxSteps, NavLayout nl){
  
  
       //open list contains cells that has not been searched.
    //lowest cost first 
    PriorityQueue<Node> openList = new PriorityQueue<Node>(Collections.reverseOrder());
    //Closed list containt the cells that have already been explored
    closedList = new Node[nl.size];
    visited = new ArrayList<Node>();
    
    float totalDiscoveryCost = 0;
    int acceptCount = 0;
    
    Node startNode = new Node(0, discovery(totalDiscoveryCost, 0), start);
    openList.add(startNode);
    while(!openList.isEmpty()){
    
      
      System.out.println(openList.peek().sum);
      Node lowestValueNode = openList.poll();
      if(acceptCount > 0){
         maxSteps--;
      }
      
      int index = nl.getCellPosition(lowestValueNode.position);
      if(!nl.cells[abs(index)].isWalkable){
        continue;
      }
      closedList[index] = lowestValueNode;
      
     
      if(totalDiscoveryCost >= discoverGoal || maxSteps <= 0){       
        this.path = reconstructPath(lowestValueNode, nl.minRec);     
        hasPath = true;
        return true;
      }
      
      Cell currentCell = nl.cells[abs(index)];
     
      
      for(int i = 0; i < currentCell.neighboures.size(); i++){
          int neighbourIndex = currentCell.neighboures.get(i);
        
           
          if(neighbourIndex > nl.size - 1 || neighbourIndex < 0 ){continue;}
          
          PVector p = nl.cells[neighbourIndex].pos;
         
          float gAcc = lowestValueNode.pathCost + abs(dist(p.x, p.y, lowestValueNode.position.x,lowestValueNode.position.y))/nl.minRec;
          float heurCost = discovery(totalDiscoveryCost, nl.cells[neighbourIndex].getDiscovery());
          Node neighbour = new Node(0, heurCost, p);
          totalDiscoveryCost += neighbour.sum;
          neighbour.parent = lowestValueNode;
          if(!nl.cells[neighbourIndex].isWalkable || nl.cells[neighbourIndex].disc <= 0 ){
             continue;
          }
          if(neighbour.equals(closedList[neighbourIndex])){
            continue;
          }
          acceptCount++;
          visited.add(neighbour);
          
          openList.add(neighbour);
          
          
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
      /*
      for(int i = 0; i < visited.size(); i++){
          Vector2D point = new Vector2D(visited.get(i).position.x ,visited.get(i).position.y);
          blendMode(REPLACE);
          fill(color(255,222,33), 100);
          circle((float)point.x, (float)point.y, 10);
        //fill(color(0,0,0), 100);
        // text("g " +round(visited.get(i).pathCost)+ " h" + round(visited.get(i).heuristicCost)+ " = "+ round(visited.get(i).sum), (float)point.x +10, (float)point.y);
      }  
      

    
     for(int i = 0; i < closedList.size(); i++){
        Vector2D point = new Vector2D(closedList.get(i).position.x ,closedList.get(i).position.y);
        fill(color(255,0,0), 100);
        circle((float)point.x, (float)point.y, 10);
          
       
      }  

      */
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
  
  LinkedList<GraphNode> reconstructPath(Node current, int cellSize){
    
    LinkedList<GraphNode> path = new LinkedList<>();
    int id = 0;
    while(current != null){
      path.addFirst(new GraphNode(id++,current.position.x, current.position.y));
      current = current.parent;
    }
  
    return path;
  }
  
  LinkedList<Cell> reconstructPathCell(Node current, int cellSize){
    
    LinkedList<Cell> p = new LinkedList<>();
    int id = 0;
    while(current != null){
      p.addFirst(new Cell(current.position, false));
      current = current.parent;
    }
  
    return p;
  }
  
  float distance(PVector current, PVector other){
    return abs(dist(current.x, current.y, other.x, other.y));
  }
  
  //Calculated the heuristic function using the Manhattan Distance
  float ManhattanDistance(PVector current, PVector goal){
    
    return abs(current.x - goal.x) + abs(current.y - goal.y);
  }
  
  float discovery(float total, float extra){  
    return extra;
  }
  
  //Calculated the heuristic function using the Euclidean Distance
  float EuclideanDistance(PVector current, PVector goal){
     return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y, 2));
  }
  

  
}
