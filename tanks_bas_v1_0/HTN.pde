/*
public static class IDGEN {
 
 public static int currentID = 0;
 public static int getID() {
 return currentID++;
 }
 }
 
 
 public enum TaskID {
 ATTACK_ACT,
 MOVETOTARGET,
 FLANK,
 MOVECLOSETOTARGET,
 MOVEATDISTANCE,
 FLANKTHETARGET
 }
 
 public enum OperatorID {
 OPERATOR_FIRE,
 OPERATOR_MOVE,
 OPERATOR_ROTATE,
 }
 
 
 public static class HTNLibrary {
 
 static void add(Action a, TaskID id) {
 }
 
 static void combine(Action a, HighLevelAction hla) {
 hla.refinments.add(a);
 }
 }
 */



Planner planner = new Planner();


public class HTNState {

  TankState tank = new TankState();
  Team team;
  boolean IsWorldPeacefull = true;
  int enemiesLeft = 3;
  RegionManager rm;

  EnemyTank[] enemyTanks = new EnemyTank[3];

  //Regions


  HTNState(Team team) {
    this.team = team;
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

public enum execState {
  Success,
    Pending,
    Failed
}

public class Plan_runner {

  LinkedList<Action> sequence = new LinkedList<>();

  boolean isDone = true;


  Plan_runner secondaryPlanner; //For Handling Breaking and yielding

  Action runningTask;

  Tank owner;
  Plan_runner(Tank tank) {
    this.owner = tank;
  }

  boolean hasTask() {
    return !sequence.isEmpty();
  }

  void update(float deltaTime) {
    //System.out.println("update");
    if (runningTask == null && sequence != null && sequence.isEmpty()) {
      HTNState tankWorldState = new HTNState(owner.team.WorldState, owner.tankState, owner);

      setTasks(planner.Search(new BeTank(), tankWorldState));
      System.out.println("ID: "+ owner.ID + this.toString());
      return;
    }
    if (runningTask.state == execState.Success) {
      this.sequence.pop();
      runningTask = this.sequence.peek();
      return;
    }
    if (runningTask.state == execState.Failed) {
      HTNState tankWorldState = new HTNState(owner.team.WorldState, owner.tankState, owner);
      setTasks(planner.Search(new BeTank(), tankWorldState));
      System.out.println("ID: "+ owner.ID + this.toString());
      return;
    }
    //System.out.println("runner update execute");
    runningTask.execute(owner, deltaTime);
  }

  void setTasks(LinkedList<Action> sequence) {
    this.sequence = sequence;
    runningTask = this.sequence.peek();
  }

  public String toString() {
    StringBuilder sb = new StringBuilder();

    if (sequence.isEmpty()) {
      sb.append("  (No tasks in sequence)\n");
    } else {
      int index = 0;
      for (Action action : sequence) {
        sb.append("  [").append(action.taskName);
        sb.append("] ");
      }
    }

    return sb.toString();
  }
}

public class Planner {

  public LinkedList<Action> Search(HighLevelAction problem, HTNState state) {
    HTNState initialState = state;
    LinkedList<BaseAction> frontier = new LinkedList<>();

    frontier.addAll(problem.getRefinments(state));

    //Multiple solutions
    //ArrayList<Plan> solutions = new ArrayList<>();

    LinkedList<Action> prefix = new LinkedList<>();

    while (!frontier.isEmpty()) {
      //System.out.println("Planning While");
      BaseAction plan = frontier.pop();
      HighLevelAction hla = null;
      System.out.println("Task Poped " + plan.taskName);
      if (plan instanceof HighLevelAction) {
        hla = (HighLevelAction)plan;
      }

      //HTNState outcome = getPotentialState(initialState, prefix);
      if (hla == null) {
        Action a = (Action)plan;
        if (a.preCondition(initialState)) {
          System.out.println("  Planning added " + a.taskName);
          prefix.add(a);
          initialState = a.effect(initialState);
        }
        continue;
      }
      frontier.addAll(refine(hla, initialState));
    }
    return prefix;
  }

  ArrayList<BaseAction> refine(HighLevelAction hla, HTNState state) {
    return hla.getRefinments(state);
  }


  HTNState getPotentialState(HTNState initialState, LinkedList<Action> actions) {

    HTNState newState = initialState;
    for (Action act : actions) {
      newState = act.effect(newState);
    }
    return newState;
  }
}
public class BaseAction { //Operator
  String taskName = "NO NAME";
}

public abstract class Action extends BaseAction implements Comparable<BaseAction> { //Operator / primitive Action

  execState state = execState.Pending;

  @Override public int compareTo(BaseAction otherNode) {
    return -1;
  }
  public abstract boolean preCondition(HTNState state);

  public abstract HTNState effect(HTNState state);

  public abstract void execute(Tank tank, float deltaTime);
}


public class Refinment {

  ArrayList<BaseAction> tasks;
  Predicate<HTNState> preCondition;

  Refinment(Predicate<HTNState> preCondition, ArrayList<BaseAction> tasks) {
    this.tasks = tasks;
    this.preCondition = preCondition;
  }
}


//Should hold a list of OperatorIDs
public  class HighLevelAction extends BaseAction implements Comparable<BaseAction> { //Task

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



  public ArrayList<Refinment> refinments = new ArrayList<>();
  public ArrayList<BaseAction> getRefinments(HTNState s) {

    ArrayList<BaseAction> actionsToReturn = new ArrayList<>();
    for (Refinment a : refinments) {

      if (a.preCondition.test(s)) {
        actionsToReturn.addAll(a.tasks);
      }
    }
    return actionsToReturn;
  }
}

public class BeTank extends HighLevelAction {

  BeTank() {
    taskName = "BeTank";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new AttackHLA()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Rotate(), new ExploreHLA()));

    ArrayList<BaseAction> tasks3 = new ArrayList<>();
    tasks3.addAll(Arrays.asList(new Rotate(), new TrafficHLA()));

    ArrayList<BaseAction> tasks4 = new ArrayList<>();
    tasks4.addAll(Arrays.asList(new Idle()));

    //Idle
    /*
    refinments.add(new Refinment(
     state -> state.tank.hitPoints <= 1,
     tasks4
     ));
     */

    //TrafficHLA
    refinments.add(new Refinment(
      s -> s.tank.tstate.isInTraffic == true && s.tank.isIdle == false,
      tasks3
      ));

    //ExploreHLA
    refinments.add(new Refinment(
      s -> (s.tank.tstate.isInTraffic == false || s.tank.tstate.hasPriority == true) &&
      s.tank.astate.isAttacking == false && s.tank.isIdle == false && s.tank.tstate.cantGo == false,

      tasks2
      ));

    //AttackHLA
    refinments.add(new Refinment(
      state -> state.tank.astate.isAttacking,
      tasks1
      ));
  }
}

public class TrafficHLA extends HighLevelAction {

  TrafficHLA() {
    taskName = "TrafficHLA";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new CheckTraffic()));

    refinments.add(new Refinment(
      s -> true,
      tasks1
      ));
  }
}


public class CheckTraffic extends HighLevelAction {
  CheckTraffic() {
    taskName = "CheckTraffic";

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Yield()));

    ArrayList<BaseAction> tasks3 = new ArrayList<>();
    tasks3.addAll(Arrays.asList(new BackUp()));

    ArrayList<BaseAction> tasks4 = new ArrayList<>();
    tasks4.addAll(Arrays.asList(new RePlanRoute()));


    refinments.add(new Refinment(
      s -> s.tank.tstate.cantGo && s.tank.tstate.hasPriority,
      tasks4
      ));

    //BackUp
    refinments.add(new Refinment(
      s -> s.tank.isFriendlyClose && s.tank.tstate.closestDist <= MAXMOVEAWAYDISTANCE && s.tank.tstate.hasPriority == false,
      tasks3
      ));


    //Yield
    refinments.add(new Refinment(
      s -> (s.tank.isFriendlyClose && s.tank.tstate.hasPriority == false && s.tank.tstate.closestDist > MAXMOVEAWAYDISTANCE),
      tasks2
      ));
  }
}

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
        //System.out.println("SHOULD BE BACKING UP ID: " + tank.ID);
        tank.AP().pathOn();
        tank.AP().pathRoute().clear();
        Vector2D potentialDest = tank.getGoodDirection(other.pos);
        if (tank.tankState.tstate.isObscured) {
          other.tank.replan(tank);
        }
        tank.AP().pathAddToRoute(new Vector2D[]{potentialDest});
        tank.tankState.isBackingUp = true;
        state = execState.Success;
        return;
      }

      /*
      PVector direction = VecMath.direction((float)tank.pos().x, (float)tank.pos().y, (float)other.pos().x, (float)other.pos().y);
       float angle = VecMath.dotAngle(new PVector((float)tank.heading().x, (float)tank.heading().y), VecMath.normalize(direction));
       float dist = dist((float)tank.pos().x, (float)tank.pos().y, (float)other.pos().x, (float)other.pos().y);
       
       if (dist <= 80 && angle > 0) {
       tank.velocity(tank.heading().x * -1 * 30, tank.heading().y * -1 * 30);
       return;
       }
       */
    }

    state = execState.Success;
  }
}


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
    // System.out.println("-----------------------------STOP--------------------------------- ID " + tank.ID  +  " Backing UP: "+  tank.tankState.isBackingUp);
    //tank.tankState.tstate.isInTraffic = true;
    tank.tankState.isStopped = true;
    state = execState.Success;
  }
}

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




public class ExploreHLA extends HighLevelAction {

  ExploreHLA() {
    taskName = "ExploreHLA";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList( new ExploreMap()));
    refinments.add(new Refinment(
      state -> state.rm.RegExProc >= 100.0f,
      tasks1
      ));


    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new ExploreRegion()));
    refinments.add(new Refinment(
      state -> state.rm.RegExProc < 100.0f,
      tasks2
      ));
  }
}

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



public class ExploreRegion extends HighLevelAction {
  ExploreRegion() {
    //System.out.println("*** ExploreRegion");
    taskName = "ExploreRegion";
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new PickRegion(), new MoveToRegion(), new SearchRegion()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new PickRegion(), new RotateToRegion()));

    refinments.add(new Refinment(
      s -> (s.IsWorldPeacefull && s.tank.isWaiting == false),
      tasks1
      ));


    /*
    refinments.add(new Refinment(
     s -> (s.IsWorldPeacefull && s.tank.isStopped),
     tasks2
     ));
     */
  }
}


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
    state = execState.Success;
  }
}

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

public class SearchRegion extends HighLevelAction {
  SearchRegion() {
    taskName = "SearchRegion";
    //System.out.println("*** SearchRegion");
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveInRegion()));
    refinments.add(new Refinment(
      s -> s.tank.regionCur != GridRegion.INV &&  s.tank.regionDes != GridRegion.INV && s.tank.regionCur == s.tank.regionDes,
      tasks1));
  }
}

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
    //System.out.println("MoveInRegion Cur: "+ tank.tankState.regionCur +" Des: " + tank.tankState.regionDes);
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

//Tank position compared to Region and calculate if they have been in there for over 10 seconds
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

public class AttackHLA extends HighLevelAction {
  AttackHLA() {
    taskName = "AttackHLA";


    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Idle(), new Rotate(), new Shoot()));
    refinments.add(new Refinment(
      s -> s.tank.hitPoints <= 1,
      tasks2
      ));

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveToTarget(), new Rotate(), new Shoot()));
    refinments.add(new Refinment(
      s -> true,
      tasks1
      ));
  }
}

public class MoveToTarget extends HighLevelAction {

  MoveToTarget() {
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveCloseToTarget()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new MoveAtDistance()));

    //Refinement 1
    refinments.add(new Refinment(
      s -> true,
      tasks1
      ));


    //Refinemnt 2
    refinments.add(new Refinment(
      s -> s.tank.hitPoints < 3,
      tasks2
      ));
  }
}



public class MoveCloseToTarget extends HighLevelAction {

  MoveCloseToTarget() {
    taskName = "MoveCloseToTarget";

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveEnemyTarget()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Stop(), new Wait()));

    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist > CLOSEFIRERANGE,
      tasks1
      ));

    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist <= CLOSEFIRERANGE,
      tasks2
      ));
  }
}


public class MoveAtDistance extends HighLevelAction {

  MoveAtDistance() {
    taskName = "MoveAtDistance";

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveEnemyTarget()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new MoveAwayFromEnemy()));

    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist > LONGFIRERANGE,
      tasks1
      ));

    refinments.add(new Refinment(
      s -> s.tank.astate.enemyTarget.dist <= LONGFIRERANGE,
      tasks2
      ));
  }
}

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
    if (tank == null) {
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

class Shoot extends Action {

  Shoot() {
    taskName = "Shoot";
  }

  public boolean preCondition(HTNState state) {
    return state.tank.astate.isReloading == false && state.tank.astate.enemyTarget.dist <= LONGFIRERANGE;
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
