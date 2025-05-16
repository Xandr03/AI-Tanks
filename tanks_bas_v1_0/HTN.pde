//Alexander Bakas alba5453
Planner planner = new Planner();


//Klass för hålla i world state
public class HTNState {

  TankState tank = new TankState();
  boolean IsWorldPeacefull = true;
  int enemiesLeft = 3;
  RegionManager rm;

  EnemyTank[] enemyTanks = new EnemyTank[3];

  HTNState(Team team) {
    this.rm = team.nav.rm;
  }

  HTNState(HTNState state) {
    this.rm = new RegionManager(state.rm);
    this.IsWorldPeacefull = state.IsWorldPeacefull;
    this.enemiesLeft = state.enemiesLeft;
  }
  HTNState(HTNState state, TankState tankState) {
    this.rm = new RegionManager(state.rm);
    this.IsWorldPeacefull = state.IsWorldPeacefull;
    this.enemiesLeft = state.enemiesLeft;
    this.tank = new TankState(tankState);
  }

  HTNState(HTNState state, TankState tankState, Tank tank) {
    this.rm = new RegionManager(state.rm);
    this.IsWorldPeacefull = state.IsWorldPeacefull;
    this.enemiesLeft = state.enemiesLeft;
    this.tank = new TankState(tankState, tank);
    for (int i = 0; i < 3; i++) {
      this.enemyTanks[i] = new EnemyTank(state.enemyTanks[i], tank);
    }
  }
}

// enum för en Actions state om den, failar, lyckas eller fortfarande kör.
public enum execState {
  Success,
    Pending,
    Failed
}

// Plan runner är klassen som kör för varje separat tanks plan
public class Plan_runner {

  //lista av actions att köra
  LinkedList<Action> sequence = new LinkedList<>();

  //nuvarande körande task
  Action runningTask;

  // ägaren av plan runner
  Tank owner;

  Plan_runner(Tank tank) {
    this.owner = tank;
  }

  //kör igenom sekvensen utav actions
  void update(float deltaTime) {

    //om det inte finns en task att köra, hitta en ny plan
    if (runningTask == null && sequence != null && sequence.isEmpty()) {
      HTNState tankWorldState = new HTNState(owner.team.WorldState, owner.tankState, owner);
      setTasks(planner.Search(new BeTank(), tankWorldState));
      return;
    }
    //om nuvarande körande task lyckas så gör nästa action
    if (runningTask.state == execState.Success) {
      this.sequence.pop();
      runningTask = this.sequence.peek();
      return;
    }
    //om nuvarande körande tasl misslyckas plannera om en ny plan
    if (runningTask.state == execState.Failed) {
      HTNState tankWorldState = new HTNState(owner.team.WorldState, owner.tankState, owner);
      setTasks(planner.Search(new BeTank(), tankWorldState));
      System.out.println("ID: "+ owner.ID + this.toString());
      return;
    }

    //kör task
    runningTask.execute(owner, deltaTime);
  }

  void setTasks(LinkedList<Action> sequence) {
    this.sequence = sequence;
    runningTask = this.sequence.peek();
  }

  public String toString() {
    StringBuilder sb = new StringBuilder();
    for (Action action : sequence) {
      sb.append("  [").append(action.taskName).append("] ");
    }
    return sb.toString();
  }
}

//huvud klassen för att kunna plannera planner för alla agenter
public class Planner {

  //search går igenom problemet och hittar en lösnings
  public LinkedList<Action> Search(HighLevelAction problem, HTNState state) {

    //initilize the state and frontier
    HTNState initialState = state;
    LinkedList<BaseAction> frontier = new LinkedList<>();
    frontier.addAll(problem.getRefinments(state));


    LinkedList<Action> prefix = new LinkedList<>();


    while (!frontier.isEmpty()) {

      //Get the FIFO in frontier
      BaseAction plan = frontier.pop();
      HighLevelAction hla = null;


      //om plan är en hla sätt hla till plan
      if (plan instanceof HighLevelAction) {
        hla = (HighLevelAction)plan;
      }

      //om hla == null så är det en action
      if (hla == null) {
        Action a = (Action)plan;
        //testa om handlingen är tillåten att köras
        if (a.preCondition(initialState)) {
          prefix.add(a);
          //utge effekt på initial state
          initialState = a.effect(initialState);
        }
        continue;
      }
      //om det är en hla så refine för en sekvens utav actions
      frontier.addAll(refine(hla, initialState));
    }
    return prefix;
  }

  ArrayList<BaseAction> refine(HighLevelAction hla, HTNState state) {
    return hla.getRefinments(state);
  }
}

//Bas klass för Actions och HighLevelAction
public class BaseAction {
  String taskName = "NO NAME";
}


//Action klass
public abstract class Action extends BaseAction implements Comparable<BaseAction> { //Operator / primitive Action

  //Actions nuvarande state
  execState state = execState.Pending;

  @Override public int compareTo(BaseAction otherNode) {
    return -1;
  }

  public abstract boolean preCondition(HTNState state);

  public abstract HTNState effect(HTNState state);

  public abstract void execute(Tank tank, float deltaTime);
}

//Refinment klass för att få ut sekvenser av actions
public class Refinment {

  ArrayList<BaseAction> tasks;
  Predicate<HTNState> preCondition;

  Refinment(Predicate<HTNState> preCondition, ArrayList<BaseAction> tasks) {
    this.tasks = tasks;
    this.preCondition = preCondition;
  }
}


//HighLevelAction klassen håller i
public  class HighLevelAction extends BaseAction implements Comparable<BaseAction> {

  @Override public int compareTo(BaseAction other) {
    if (other instanceof Action) {
      return 1;
    }
    if (other instanceof HighLevelAction) {
      HighLevelAction HLAOther = (HighLevelAction)other;
      if (this.refinments.size() < HLAOther.refinments.size()) {
        return -1;
      }
      return 1;
    }
    return 0;
  }


  //lista av potentiella refinments
  public ArrayList<Refinment> refinments = new ArrayList<>();


  public ArrayList<BaseAction> getRefinments(HTNState s) {

    ArrayList<BaseAction> actionsToReturn = new ArrayList<>();
    //gå igen tillgängliga refinments och see om de är tillåtna att användas
    for (Refinment a : refinments) {

      if (a.preCondition.test(s)) {
        actionsToReturn.addAll(a.tasks);
      }
    }
    return actionsToReturn;
  }
}

//BeTank är den högsta HLA i domänen och beskriver hur en tank ska betee sig
public class BeTank extends HighLevelAction {

  BeTank() {
    taskName = "BeTank";

    //Skapar listor av actions och skapar refinments av dem, med conditions

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new AttackHLA()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new ExploreHLA()));

    ArrayList<BaseAction> tasks3 = new ArrayList<>();
    tasks3.addAll(Arrays.asList(new TrafficHLA()));


    //TrafficHLA
    refinments.add(new Refinment(
      s -> s.tank.tstate.isInTraffic == true && s.tank.hitPoints > 1,
      tasks3
      ));

    //ExploreHLA
    refinments.add(new Refinment(
      s -> (s.tank.tstate.isInTraffic == false || s.tank.tstate.hasPriority == true) &&
      s.tank.astate.isAttacking == false && s.tank.hitPoints > 1 && s.tank.tstate.cantGo == false,

      tasks2
      ));

    //AttackHLA
    refinments.add(new Refinment(
      state -> state.tank.astate.isAttacking,
      tasks1
      ));
  }
}

//En HLA för att ta hand om Traffic
public class TrafficHLA extends HighLevelAction {

  TrafficHLA() {
    taskName = "TrafficHLA";

    //Skapar listor av actions och skapar refinments av dem, med conditions

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new CheckTraffic()));

    //CheckTraffic
    refinments.add(new Refinment(
      s -> true,
      tasks1
      ));
  }
}

//En HLA för att hantera traffic
public class CheckTraffic extends HighLevelAction {
  CheckTraffic() {
    taskName = "CheckTraffic";

    //Skapar listor av actions och skapar refinments av dem, med conditions

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Yield()));

    ArrayList<BaseAction> tasks3 = new ArrayList<>();
    tasks3.addAll(Arrays.asList(new BackUp()));

    ArrayList<BaseAction> tasks4 = new ArrayList<>();
    tasks4.addAll(Arrays.asList(new RePlanRoute()));



    //Replan route
    refinments.add(new Refinment(
      s -> s.tank.tstate.cantGo && s.tank.tstate.hasPriority && s.tank.hitPoints > 1,
      tasks4
      ));

    //BackUp
    refinments.add(new Refinment(
      s -> s.tank.isFriendlyClose && s.tank.tstate.closestDist <= MAXMOVEAWAYDISTANCE && s.tank.tstate.hasPriority == false && s.tank.hitPoints > 1,
      tasks3
      ));


    //Yield
    refinments.add(new Refinment(
      s -> (s.tank.isFriendlyClose && s.tank.tstate.hasPriority == false && s.tank.tstate.closestDist > MAXMOVEAWAYDISTANCE),
      tasks2
      ));
  }
}

//en action för att planera en ny route
public class RePlanRoute extends Action {
  RePlanRoute() {
    taskName = "RePlanRoute";
  }

  public boolean preCondition(HTNState s) {
    return true;
  }

  public HTNState effect(HTNState s) {
    return s;
  }

  public void execute(Tank tank, float deltaTime) {
    System.out.println("--------------REPLAN---------------");

    if (GS.computePath(tank, tank.tankState.destination, tank.team.nav, GeneralSearch.ASTAR)) {
      tank.AP().pathSetRoute(GS.path);
    }

    state = execState.Success;
  }
}

//en action för att backa up
public class BackUp extends Action {

  BackUp() {
    taskName = "BackUp";
  }
  public boolean preCondition(HTNState s) {
    return true;
  }

  public HTNState effect(HTNState s) {
    s.tank.isBackingUp = true;
    return s;
  }

  public void execute(Tank tank, float deltaTime) {

    tank.tankState.tstate.isInTraffic = true;

    for (TankData other : tank.tankState.tstate.otherTanks) {

      if (other.tank.tankState.tstate.hasPriority) {
        tank.AP().pathOn();
        tank.AP().pathRoute().clear();
        Vector2D potentialDest = tank.getGoodDirection(other.pos);
        tank.AP().pathAddToRoute(new Vector2D[]{potentialDest});
        tank.tankState.isBackingUp = true;
        state = execState.Success;
      }
    }

    state = execState.Success;
  }
}

//en HLA action för att avvakta
public class Yield extends HighLevelAction {

  Yield() {
    taskName = "Yield";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new Stop(), new Wait()));

    refinments.add(new Refinment(
      s -> s.tank.tstate.hasPriority == false && (s.tank.tstate.closestDist <= MAXSTOPDISTANCE && s.tank.tstate.closestDist >= MAXMOVEAWAYDISTANCE ) && s.tank.tstate.isInTraffic,
      tasks1
      ));
  }
}

//en actions för att stanna
public class Stop extends Action {
  Stop() {
    taskName = "Stop";
  }

  public boolean preCondition(HTNState s) {
    return !s.tank.isBackingUp && !s.tank.isStopped;
  }

  public HTNState effect(HTNState s) {
    s.tank.isStopped = true;
    return s;
  }

  public void execute(Tank tank, float deltaTime) {
    tank.velocity(0, 0);
    tank.AP().pathOff();
    tank.AP().pathRoute().clear();
    tank.tankState.isStopped = true;
    state = execState.Success;
  }
}

//en action för att vänta
public class Wait extends Action {

  Wait() {
    taskName = "Wait";
  }

  public boolean preCondition(HTNState s) {
    return !s.tank.isWaiting;
  }

  public HTNState effect(HTNState s) {
    s.tank.isWaiting = true;
    return s;
  }

  public void execute(Tank tank, float deltaTime) {
    tank.tankState.isWaiting = true;
    tank.waitTimer = 3;
    state = execState.Success;
  }
}


//en action för att vara idle
public class Idle extends Action {

  Idle() {
    taskName = "Idle";
  }

  public boolean preCondition(HTNState s) {
    return true;
  }

  public HTNState effect(HTNState s) {
    s.tank.isIdle = true;
    return s;
  }

  public void execute(Tank tank, float deltaTime) {
    tank.velocity(0, 0);
    tank.AP().pathOff();
    state = execState.Success;
  }
}



// en HLA för att explorera 
public class ExploreHLA extends HighLevelAction {

  ExploreHLA() {
    taskName = "ExploreHLA";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList( new ExploreMap()));
    
    //Explore Map
    refinments.add(new Refinment(
      state -> state.rm.RegExProc >= 100.0f,
      tasks1
      ));


    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new ExploreRegion()));
    
    //Explore Region
    refinments.add(new Refinment(
      state -> state.rm.RegExProc < 100.0f,
      tasks2
      ));
  }
}

//en HLA för att explorera kartan
public class ExploreMap extends HighLevelAction {

  ExploreMap() {
    taskName = "ExploreMap";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new WalkAround()));
    refinments.add(new Refinment(
      s -> (s.IsWorldPeacefull && s.tank.isWaiting == false),
      tasks1
      ));
  }
}


//en HLA för att explorera Regioner
public class ExploreRegion extends HighLevelAction {
  ExploreRegion() {
    //System.out.println("*** ExploreRegion");
    taskName = "ExploreRegion";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new PickRegion(), new Rotate(), new MoveToRegion(), new SearchRegion()));

    refinments.add(new Refinment(
      s -> (s.IsWorldPeacefull && s.tank.isWaiting == false),
      tasks1
      ));
  }
}

//en action för att rotera till regionen
public class RotateToRegion extends Action {
  RotateToRegion() {
    taskName = "RotateToRegion";
  }

  public boolean preCondition(HTNState s) {
    return true;
  }

  public HTNState effect(HTNState s) {
    s.tank.isRotating = true;
    return s;
  }

  public void execute(Tank tank, float deltaTime) {

    System.out.println("RotateToRegion");
    tank.tankState.isRotating = tank.RotateToDest();
    state = execState.Success;
  }
}

//en action för att välja region
public class PickRegion extends Action {

  PickRegion() {
    taskName = "PickRegion";
  }

  public boolean preCondition(HTNState state) {
    return state.rm.RegExProc < 100.0f && (state.tank.regionState.state == RegionStatus.NONE || state.tank.regionState.state == RegionStatus.Explored);
  }

  public HTNState effect(HTNState state) {
    HTNState newState = state;
    newState.rm.RegExProc = (newState.rm.RegionsExplored + 1)/9;
    newState.tank.regionState.occupied = false;
    return newState;
  }

  public void execute(Tank tank, float deltaTime) {

    Region oldRegion =  tank.tankState.regionState;
    if (oldRegion != null) {
      oldRegion.occupied = false;
      oldRegion.claimed = false;
    }

    RegionManager rm = tank.team.nav.rm;
    tank.tankState.regionToExplore = rm.getAvailibleRegion(new PVector((float)tank.pos().x, (float)tank.pos().y));
    if (tank.tankState.regionToExplore < 0) {
      state = execState.Success;
      return;
    }
    tank.tankState.regionState = rm.regions[tank.tankState.regionToExplore];
    rm.setRegionClaimed(tank.tankState.regionToExplore, true);
    tank.tankState.regionDes = GridRegion.values()[tank.tankState.regionToExplore];
    tank.tankState.isSearchingRegion = false;
    state = execState.Success;
  }
}


//en action för att röra sig mot regionen
public class MoveToRegion extends Action {

  boolean pointSet = false;
  float time = 0;

  MoveToRegion() {
    taskName = "MoveToRegion";
  }


  public boolean preCondition(HTNState s) {
    return s.tank.regionCur != GridRegion.INV && s.tank.regionDes != GridRegion.INV && s.tank.regionCur != s.tank.regionDes && !s.tank.isNavigation;
  }

  public HTNState effect(HTNState state) {
    state.tank.isNavigation = true;
    return state;
  }

  public void execute(Tank tank, float deltaTime) {
    tank.AP().pathOn();
    if (tank.AP().pathRouteLength() <= 0) {
      if (GS.computePath(tank, tank.team.nav.rm.getRegion(tank.tankState.regionToExplore).regionMidPoint, tank.team.nav, GeneralSearch.GREEDY)) {
        tank.AP().pathSetRoute(GS.path);
        pointSet = true;
        state = execState.Success;
        tank.tankState.tstate.lastGoal = tank.team.nav.rm.getRegion(tank.tankState.regionToExplore).regionMidPoint;
        tank.tankState.destination = tank.team.nav.rm.getRegion(tank.tankState.regionToExplore).regionMidPoint;
        return;
      }
    }
    state = execState.Failed;
  }
}

//en HLA för att söka regionen
public class SearchRegion extends HighLevelAction {
  SearchRegion() {
    taskName = "SearchRegion";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new Rotate(), new MoveInRegion()));
    
    //rotate() and MoveInRegion()
    refinments.add(new Refinment(
      s -> s.tank.regionCur != GridRegion.INV &&  s.tank.regionDes != GridRegion.INV && s.tank.regionCur == s.tank.regionDes,
      tasks1));
  }
}

//en action för att röra sig inom en region
public class MoveInRegion extends Action {

  MoveInRegion() {
    taskName = "MoveInRegion";
  }

  public boolean preCondition(HTNState s) {
    return !s.tank.isNavigation;
  }

  public HTNState effect(HTNState s) {
    s.tank.isNavigation = true;
    return s;
  }

  float time = 0;


  public void execute(Tank tank, float deltaTime) {
    tank.tankState.isSearchingRegion = true;
    tank.AP().pathOn();
    tank.tankState.regionState.occupied = true;
    if (tank.AP().pathRouteLength() <= 0) {
      if (tank.tankState.regionToExplore < 0) {
        state = execState.Success;
        return;
      }
      GridRegion index = GridRegion.values()[tank.tankState.regionToExplore];


      if (GS.computeStep(tank, 150, index, tank.team.nav)) {
        tank.AP().pathSetRoute(GS.path);
        state = execState.Success;
        tank.tankState.tstate.lastGoal = new PVector((float)tank.AP().pathRoute().getLast().x(), (float)tank.AP().pathRoute().getLast().y());
        tank.tankState.destination = new PVector((float)tank.AP().pathRoute().getLast().x(), (float)tank.AP().pathRoute().getLast().y());
        return;
      }
    }
    state = execState.Success;
  }
}

//en action för att gå omkring
public class WalkAround extends Action {

  WalkAround() {
    taskName = "WalkAround";
  }

  public boolean preCondition(HTNState state) {
    return true;
  }

  public HTNState effect(HTNState state) {
    //TODO
    //regions explored functionality
    return state;
  }

  public void execute(Tank tank, float deltaTime) {
    if (tank.AP().pathRouteLength() <= 0) {
      if (GS.computeStep(tank, 200, GridRegion.INV, tank.team.nav)) {
        System.out.println("WalkAROUUNNND");
        tank.AP().pathSetRoute(GS.path);
        tank.tankState.tstate.lastGoal = new PVector((float)tank.AP().pathRoute().getLast().x(), (float)tank.AP().pathRoute().getLast().y());
        tank.tankState.destination = new PVector((float)tank.AP().pathRoute().getLast().x(), (float)tank.AP().pathRoute().getLast().y());
        state = execState.Success;
      }
    }
    state = execState.Success;
  }
}

//en HLA för att attakera en tank
public class AttackHLA extends HighLevelAction {
  AttackHLA() {
    taskName = "AttackHLA";


    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Rotate(), new Shoot()));
    
    //Rotate() and Shoot()
    refinments.add(new Refinment(
      s -> s.tank.hitPoints <= 1,
      tasks2
      ));

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveToTarget(), new Rotate(), new Shoot()));
    
    //MoveToTarget(), Rotate() and Shoot ()
    refinments.add(new Refinment(
      s -> s.tank.hitPoints > 1,
      tasks1
      ));
  }
}

//en HLA för att röra sig mot target
public class MoveToTarget extends HighLevelAction {

  MoveToTarget() {
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveCloseToTarget()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new MoveAtDistance()));

    //MoveCloseToTarget
    refinments.add(new Refinment(
      s -> s.tank.hitPoints >= 3,
      tasks1
      ));


    //MoveAtDistance
    refinments.add(new Refinment(
      s -> s.tank.hitPoints < 3 && s.tank.hitPoints > 1,
      tasks2
      ));
  }
}


//en HLA för att röra sig nära en Target
public class MoveCloseToTarget extends HighLevelAction {

  MoveCloseToTarget() {
    taskName = "MoveCloseToTarget";

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveEnemyTarget()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Stop(), new Wait()));

    //MoveEnemyTarget
    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist > CLOSEFIRERANGE,
      tasks1
      ));

    //Stop() and Wait()
    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist <= CLOSEFIRERANGE,
      tasks2
      ));
  }
}

//en HLA för att röra sig med en distance
public class MoveAtDistance extends HighLevelAction {

  MoveAtDistance() {
    taskName = "MoveAtDistance";

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveEnemyTarget()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new MoveAwayFromEnemy()));
    
    //MoveEnemyTarget
    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist > LONGFIRERANGE,
      tasks1
      ));

    //MoveAwayFromEnemy
    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist <= LONGFIRERANGE - 30,
      tasks2
      ));
  }
}

//en action för att röra sig ifrån target
public class MoveAwayFromEnemy extends Action {
  MoveAwayFromEnemy() {
    taskName = "MoveAwayFromEnemy";
  }
  public boolean preCondition(HTNState state) {
    return true;
  }

  public HTNState effect(HTNState state) {
    //Closer to target
    return state;
  }


  void execute(Tank tank, float deltaTime) {
    if (tank == null || tank.tankState.hitPoints <= 1) {
      state = execState.Success;
      return;
    }
    EnemyTank et = tank.tankState.astate.enemyTarget;
    if (et == null) {
      state = execState.Success;
      return;
    }
    tank.AP().pathOn();
    tank.AP().pathRoute().clear();
    Vector2D potentialDest = tank.getGoodDirection(et.lastKnownPosition);
    tank.AP().pathAddToRoute(new Vector2D[]{potentialDest});
    tank.tankState.isBackingUp = true;
    state = execState.Success;
  }
}


//en action för att röra sig till target
class MoveEnemyTarget extends Action {

  MoveEnemyTarget() {
    taskName = "MoveEnemyTarget";
  }


  public boolean preCondition(HTNState state) {
    return true;
  }

  public HTNState effect(HTNState state) {
    //Closer to target
    return state;
  }

  void execute(Tank tank, float deltaTime) {
    if (tank == null || tank.tankState.hitPoints <= 1) {
      state = execState.Success;
      return;
    }
    if (tank.tankState.astate.enemyTarget == null) {
      state = execState.Success;
      return;
    }

    PVector otherPos = tank.tankState.astate.enemyTarget.lastKnownPosition;
    if (GS.computePath(tank, otherPos, tank.team.nav, GeneralSearch.ASTAR)) {
      tank.AP().pathSetRoute(GS.path);
    }
    state = execState.Success;
  }
}

//en action för att rotera
class Rotate extends Action {

  Rotate() {
    taskName = "Rotate";
  }

  public boolean preCondition(HTNState state) {
    return true;
  }

  public HTNState effect(HTNState state) {
    //Closer to target
    return state;
  }

  void execute(Tank tank, float deltaTime) {
    if (tank == null) {
      return;
    }

    if (tank.tankState.astate.isAttacking) {
      tank.tankState.astate.isAligned = tank.turret.rotateTurret(tank.tankState.astate.enemyTarget.lastKnownPosition, deltaTime);
    } else {
      tank.turret.rotateHeading(tank.heading);
    }


    state = execState.Success;
  }
}

//en action för att skjuta
class Shoot extends Action {

  Shoot() {
    taskName = "Shoot";
  }

  public boolean preCondition(HTNState state) {
    return state.tank.astate.isReloading == false && state.tank.astate.enemyTarget.dist <= LONGFIRERANGE + 15;
  }

  public HTNState effect(HTNState state) {
    //Closer to target
    return state;
  }

  void execute(Tank tank, float deltaTime) {

    if (tank == null) {
      state = execState.Success;
      return;
    }

    if (!tank.tankState.astate.isAligned) {
      state = execState.Success;
      return;
    }

    PVector start = tank.position;
    PVector end =  new PVector(tank.turret.forwardVector.x, tank.turret.forwardVector.y);

    end = end.mult(300);

    for (Tank t : tank.team.tanks) {
      if (t == null ||t == tank) {
        continue;
      }

      if (CollisionChecker.lineCircle(start.x, start.y, end.x, end.y, t.position.x, t.position.y, 50)) {
        state = execState.Success;
        return;
      }
    }

    bm.CreateBullet(tank.position, tank.turret.forwardVector, 100.0f, tank);
    tank.tankState.astate.isReloading = true;
    state = execState.Success;
  }
}

//en action för att ladda om 
class Reload extends Action {
  Reload() {
    taskName = "Reload";
  }

  public boolean preCondition(HTNState state) {

    return true;
  }

  public HTNState effect(HTNState state) {
    //Closer to target
    return state;
  }

  void execute(Tank tank, float deltaTime) {

    state = execState.Success;
  }
}
