//Alexander Bakas alba5453
//Röda områden är bara väldigt dyra

class GeneralSearch {

  //Konstanta värden för val av sökning metod
  static final int ASTAR = 100;
  static final int GREEDY = 101;
  static final int DIJKSTRA = 102;
  static final int BREADTH = 103;


  //lista med pathen
  LinkedList<GraphNode> path;


  boolean hasPath = false;


  public Node[] reached;
  public ArrayList<Node> visited = new ArrayList<Node>();

  //Innre Node class för all data en nod behöver innehålla
  class Node implements Comparable<Node> {

    float pathCost;
    float heuristicCost;
    float sum;
    PVector position;
    int id;
    Node parent;


    Node(float pathCost, float heuristicCost, PVector position) {
      this.pathCost = pathCost;
      this.heuristicCost = heuristicCost;
      this.sum = pathCost + heuristicCost;
      this.position = position;
      this.parent = null;
    }

    Node(int id, float pathCost, float heuristicCost, PVector position) {
      this.pathCost = pathCost;
      this.heuristicCost = heuristicCost;
      this.sum = pathCost + heuristicCost;
      this.position = position;
      this.parent = null;
      this.id = id;
    }



    @Override public int compareTo(Node otherNode) {
      if (round(this.sum) > round(otherNode.sum)) {
        return 1;
      }
      if (round(this.sum) < round(otherNode.sum)) {
        return -1;
      }
      return 0;
    }

    @Override public String toString() {
      String s = "X: " + position.x + " Y: " + position.y;
      return s;
    }


    @Override public boolean equals(Object other) {
      if (other == null) {
        return false;
      }
      if (this == other) {
        return true;
      }
      if (!(other instanceof Node)) {
        return false;
      }
      Node otherNode = (Node)other;
      boolean bPos = this.position.x == otherNode.position.x && this.position.y == otherNode.position.y;
      boolean bSum = this.sum == otherNode.sum;
      return bPos;
    }
  }


  //Räkna ut en path från Start och Goal för vald söknings metod
  boolean computePath(PVector start, PVector goal, NavLayout nl, int SearchType) {

    //om målet inte går att nå return flase
    if (!nl.cells[nl.getCellPosition(goal)].isWalkable) {
      return false;
    }
    //nodeQueue innehåller node som ska sökas igenom, prioritet är lägsta först
    PriorityQueue<Node> nodeQueue = new PriorityQueue<Node>();
    //reached listan innehåller noder som redan har blivit utforskade
    reached = new Node[nl.size];

    //omvandla coordinater till grid coordinater
    PVector goalPosition = nl.cells[nl.getCellPosition(goal)].pos;

    //Skapa star noden och lägg till i queue
    Node startNode = new Node(0, EuclideanDistance(start, goalPosition), start);
    nodeQueue.add(startNode);

    //så långe nodeQueue har en node att ta så ska den köra
    while (!nodeQueue.isEmpty()) {

      //Skapa current node och cell
      Node currentNode = nodeQueue.poll();
      int index = nl.getCellPosition(currentNode.position);
      Cell currentCell = nl.cells[index];

      //om noden är målet så reconstruera pathen
      if (nl.getCellPosition(currentNode.position) == nl.getCellPosition(goalPosition)) {
        Node gn = new Node(currentNode.pathCost, currentNode.heuristicCost, goal);
        gn.parent = currentNode.parent;
        this.path = reconstructPath(gn, nl.minRec);
        hasPath = true;
        return true;
      }

      //Gå igenom all grannar till noden
      for (int i = 0; i < currentCell.neighboures.size(); i++) {
        int neighbourIndex = currentCell.neighboures.get(i);

        if (!nl.isValidIndex(neighbourIndex)) {
          continue;
        }

        //få position från cell
        PVector p = nl.cells[neighbourIndex].pos;

        //räkna ut path kostnad beroedn på om maan har A* eller Dijkstra
        float gAcc = g(currentNode, p, SearchType);
        //räkna ut heuristik kostnad kostnad beroedn på om man har A* eller GREEDY
        float heurCost = h(p, goalPosition, SearchType);

        //Skapa gran nod
        Node neighbour = new Node(gAcc, heurCost, p);
        neighbour.parent = currentNode;

        //om man inte kan gå på gran noden så gå till nästa granne
        if (!nl.cells[neighbourIndex].isWalkable ) {
          neighbour.sum = Integer.MAX_VALUE;
        }
        //om man inte nåt noden förut eller om den ny har bättre kostnad så sätt reached och lägg till i queue
        if (reached[neighbourIndex] == null || reached[neighbourIndex].sum > neighbour.sum) {
          reached[neighbourIndex] = neighbour;
          nodeQueue.add(neighbour);
        }
      }
    }

    return false;
  }

  float g(Node parent, PVector child, int SearchType) {
    if (SearchType != DIJKSTRA && SearchType != ASTAR) {
      return 0;
    }
    float gAcc = parent.pathCost + abs(dist(child.x, child.y, parent.position.x, parent.position.y));
    return gAcc;
  }

  float h(PVector posNode, PVector posGoal, int SearchType) {
    if (SearchType != ASTAR && SearchType != GREEDY) {
      return 0;
    }
    return EuclideanDistance(posNode, posGoal);
  }



  boolean computeKnowledgePath(PVector start, PVector goal, NavLayout nl) {

    //om målet inte går att nå return flase
    if (!nl.cells[nl.getCellPosition(goal)].isWalkable) {
      return false;
    }
    //nodeQueue innehåller node som ska sökas igenom, prioritet är lägsta först
    PriorityQueue<Node> nodeQueue = new PriorityQueue<Node>();

    //reached listan innehåller noder som redan har blivit utforskade
    reached = new Node[nl.size];

    //omvandla coordinater till grid coordinater
    PVector goalPosition = nl.cells[nl.getCellPosition(goal)].pos;

    //Skapa gran nod
    Node startNode = new Node(0, EuclideanDistance(start, goalPosition), start);
    nodeQueue.add(startNode);

    //så långe nodeQueue har en node att ta så ska den köra
    while (!nodeQueue.isEmpty()) {

      //Skapa current node och cell
      Node currentNode = nodeQueue.poll();
      int index = nl.getCellPosition(currentNode.position);
      Cell currentCell = nl.cells[index];


      //om noden är målet så reconstruera pathen
      if (nl.getCellPosition(currentNode.position) == nl.getCellPosition(goalPosition)) {
        Node gn = new Node(currentNode.pathCost, currentNode.heuristicCost, goal);
        gn.parent = currentNode.parent;
        this.path = reconstructPath(gn, nl.minRec);
        hasPath = true;
        return true;
      }

      //Gå igenom all grannar till noden
      for (int i = 0; i < currentCell.neighboures.size(); i++) {
        int neighbourIndex = currentCell.neighboures.get(i);

        //Kollar om index är valid och om tanken vet om området
        if (!nl.isValidIndex(neighbourIndex) || !nl.cells[neighbourIndex].visited) {
          continue;
        }

        //få position från cell
        PVector p = nl.cells[neighbourIndex].pos;

        //räkna ut path kostnad beroende på A*
        float gAcc = g(currentNode, p, 100);
        //räkna ut heuristik kostnad kostnad beroende på A*
        float heurCost = h(p, goalPosition, 100);

        //Skapa Granne
        Node neighbour = new Node(gAcc, heurCost, p);
        neighbour.parent = currentNode;

        //Kolla om man kan gå på cellen
        if (!nl.cells[neighbourIndex].isWalkable ) {
           neighbour.sum = Integer.MAX_VALUE;
        }
        //om man inte nåt noden förut eller om den ny har bättre kostnad så sätt reached och lägg till i queue
        if (reached[neighbourIndex] == null || reached[neighbourIndex].sum > neighbour.sum) {
          reached[neighbourIndex] = neighbour;
          nodeQueue.add(neighbour);
        }
      }
    }

    return false;
  }

  //Weighted based on discovery
  boolean computeStep(PVector start, float distance, GridRegion region,NavLayout nl) {


    //nodeQueue innehåller node som ska sökas igenom, prioritet är lägsta först6
    PriorityQueue<Node> nodeQueue = new PriorityQueue<Node>();

    //reached listan innehåller noder som redan har blivit utforskade
    reached = new Node[nl.size];

    //Skapa gran nod
    Node startNode = new Node(0, 0, start);
    nodeQueue.add(startNode);

    //så långe nodeQueue har en node att ta så ska den köra
    while (!nodeQueue.isEmpty()) {


      //Skapa current node och cell
      Node currentNode = nodeQueue.poll();
      int index = nl.getCellPosition(currentNode.position);
      Cell currentCell = nl.cells[abs(index)];

      //om distanse från start och nuvarande node är större eller lika med de distanses som ges reconstruerea path
      if (dist(start.x, start.y, currentNode.position.x, currentNode.position.y) >= distance && currentCell.region == region) {
        this.path = reconstructPath(currentNode, nl.minRec);
        hasPath = true;
        return true;
      }

      //Gå igenom all grannar till noden
      for (int i = 0; i < currentCell.neighboures.size(); i++) {

        int neighbourIndex = currentCell.neighboures.get(i);
        Cell c = nl.getCell(neighbourIndex);
        
        if(currentCell.region == region && c.region != region){continue;}
        //if(!c.isWalkable){continue;}
        //Kolla om cell är valid och om tanken verklige får gå på cellen
   

        //få position från cell
        PVector p = nl.cells[neighbourIndex].pos;
        //path costnaden beror på distanse från start
        float gAcc = currentNode.pathCost + abs(dist(p.x, p.y, currentNode.position.x, currentNode.position.y))/nl.minRec;
        //om den cellen redan blivit besökt för lägg till på path kostnaden
        if (nl.getCell(neighbourIndex).visited) {
          gAcc *= 1.5;
        }

        //Heurisitksa funktionen beror på hur länge sedan någpn tank i laget gick besökte noden
        double heurCost = nl.cells[neighbourIndex].timeSinceLastVisit -  sw.getRunTime()  + random(10);

        //Skapa granne
        Node neighbour = new Node(neighbourIndex, gAcc, (float)heurCost, p);
        neighbour.parent = currentNode;
        if (!nl.isValidIndex(neighbourIndex) || (!c.isWalkable || c.isEnemyNearby || c.isEnemyBase) ) {
          neighbour.sum = Integer.MAX_VALUE;
        }

        //om man inte nåt noden förut eller om den ny har bättre kostnad så sätt reached och lägg till i queue
        if (reached[neighbourIndex] == null || reached[neighbourIndex].sum > neighbour.sum) {
          reached[neighbourIndex] = neighbour;
          nodeQueue.add(neighbour);
        }
      }
    }

    return false;
  }

  void draw() {
    blendMode(REPLACE);
    textSize(15);
    if (!hasPath) {
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
     */

    for (int i = 0; i < 31*31; i++) {
      if (reached[i] == null) {
        continue;
      }
      Vector2D point = new Vector2D(reached[i].position.x, reached[i].position.y);
      fill(color(255, 0, 0), 100);
      circle((float)point.x, (float)point.y, 10);
    }


    for (int i = 0; i < path.size(); i++) {
      Vector2D point = new Vector2D(path.get(i).x(), path.get(i).y());
      fill(color(0, 255, 0), 100);
      if (i+1 < path.size()) {
        Vector2D next = new Vector2D(path.get(i+1).x(), path.get(i+1).y());
        line((float)point.x, (float)point.y, (float)next.x, (float)next.y);
      }
      circle((float)point.x, (float)point.y, 10);
    }
  }


  //Konstruera path
  LinkedList<GraphNode> reconstructPath(Node current, int cellSize) {

    LinkedList<GraphNode> path = new LinkedList<>();
    int id = 0;
    //konstruera med hjälp av att gå uigenom nuvarande nod till man når null
    while (current != null) {
      path.addFirst(new GraphNode(id++, current.position.x, current.position.y));
      current = current.parent;
    }

    return path;
  }

  //Metod för att får en path genom breadth First Search
  boolean BreadthFirstSearch(PVector start, PVector goal, NavLayout nl) {

    //Kolla om man kan gå på vald nod
    if (!nl.cells[nl.getCellPosition(goal)].isWalkable) {
      return false;
    }

    //nodeQueue innehåller node som ska sökas igenom, är FIFO
    LinkedList<Node> nodeQueue = new LinkedList<Node>();

    //reached listan innehåller noder som redan har blivit utforskade
    reached = new Node[nl.size];

    //omvandla coordinater till grid coordinater från mål position
    PVector goalPositon = nl.cells[nl.getCellPosition(goal)].pos;


    //Skapa start nod
    Node startNode = new Node(0, 0, start);
    nodeQueue.add(startNode);

    //så långe nodeQueue har en node att ta så ska den köra
    while (!nodeQueue.isEmpty()) {

      //Skapa current node och cell
      Node currentNode = nodeQueue.poll();
      int index = nl.getCellPosition(currentNode.position);
      Cell currentCell = nl.cells[index];
    
      //Gå igenom all grannar till noden
      for (int i = 0; i < currentCell.neighboures.size(); i++) {
        int neighbourIndex = currentCell.neighboures.get(i);
        if (!nl.isValidIndex(neighbourIndex)) {
          continue;
        }
        
        //få grannens cell position
        PVector p = nl.cells[neighbourIndex].pos;
        if (!nl.cells[neighbourIndex].isWalkable ) {
          continue;
        }
        //kolla noden har redan blivit besökt
        if (reached[neighbourIndex] != null) {
          continue;
        }
        //Skapa granen
        Node neighbour = new Node(0, 0, p);
        neighbour.parent = currentNode;

        //oom Grannen är lika med målet så reconstruera en ny path
        if (nl.getCellPosition(neighbour.position) == nl.getCellPosition(goalPositon)) {
          Node gn = new Node(0, 0, goal);
          gn.parent = neighbour.parent;
          this.path = reconstructPath(gn, nl.minRec);
          hasPath = true;
          return true;
        }
        //Lägg til granne i reached och FIFO linklistan
        reached[neighbourIndex] = neighbour;
        nodeQueue.add(neighbour);
      }
    }

    return false;
  }


  float distance(PVector current, PVector other) {
    return abs(dist(current.x, current.y, other.x, other.y));
  }

  //Calculated the heuristic function using the Manhattan Distance
  float ManhattanDistance(PVector current, PVector goal) {

    return abs(current.x - goal.x) + abs(current.y - goal.y);
  }

  float discovery(float total, float extra) {
    return extra;
  }

  //Calculated the heuristic function using the Euclidean Distance
  float EuclideanDistance(PVector current, PVector goal) {
    return sqrt(pow(current.x - goal.x, 2) + pow(current.y - goal.y, 2));
  }


  LinkedList<Cell> path2;
}
