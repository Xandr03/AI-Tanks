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
    if (runningTask == null && sequence.isEmpty()) {
      HTNState tankWorldState = new HTNState(owner.team.WorldState, owner.tankState, owner);

      setTasks(planner.Search(new BeTank(), tankWorldState));
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
      return;
    }
    //System.out.println("runner update execute");
    runningTask.execute(owner, deltaTime);
  }

  void setTasks(LinkedList<Action> sequence) {
    this.sequence = sequence;
    runningTask = this.sequence.peek();
  }
}

public class Planner {

  public LinkedList<Action> Search(HighLevelAction problem, HTNState state) {
    //System.out.println("Planning");
    HTNState initialState = state;
    System.out.println("");
    LinkedList<BaseAction> frontier = new LinkedList<>();

    frontier.addAll(problem.getRefinments(state));

    //Multiple solutions
    //ArrayList<Plan> solutions = new ArrayList<>();

    LinkedList<Action> prefix = new LinkedList<>();

    while (!frontier.isEmpty()) {
      //System.out.println("Planning While");
      BaseAction plan = frontier.pop();
      HighLevelAction hla = null;
      if (plan instanceof HighLevelAction) {
        hla = (HighLevelAction)plan;
      }

      //HTNState outcome = getPotentialState(initialState, prefix);
      if (hla == null) {
        Action a = (Action)plan;
        if (a.preCondition(initialState)) {
          //System.out.println("Planning add action");
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
      /*
      if (a instanceof Action) {
       Action action = (Action)a;
       if (action.preCondition(s)) {
       actionsToReturn.add(action);
       }
       }
       if (a instanceof HighLevelAction) {
       actionsToReturn.add(a);
       }
       */
    }
    return actionsToReturn;
  }
}

//Base State Class


/*
//Hold the state data needed to check when a team attacks
 //To check health and availability
 public class AttackingState extends HTNState {
 
 Tank target;
 boolean isTargetVisibble;
 
 
 AttackingState(Team team, Tank tank) {
 super(team, tank);
 }
 
 
 
 }
 
 
 //Hold the state data needed to check when a team attacks
 //To check areas to explore
 public class ExploreState extends HTNState {
 NavLayout grid;
 ExploreState(Team teamm, Tank tank) {
 super(team);
 this.grid = team.nav;
 }
 }
 */

public class BeTank extends HighLevelAction {

  BeTank() {
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new AttackHLA()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new ExploreHLA()));

    ArrayList<BaseAction> tasks3 = new ArrayList<>();
    tasks3.addAll(Arrays.asList(new TrafficHLA()));

    refinments.add(new Refinment(
      state -> true,
      tasks3
      ));

    refinments.add(new Refinment(
      state -> !state.IsWorldPeacefull && state.tank.isEnemyInRange,
      tasks1
      ));


    refinments.add(new Refinment(
      state -> state.IsWorldPeacefull && !state.tank.isEnemyInRange,
      tasks2
      ));
  }
}




public class TrafficHLA extends HighLevelAction {

  TrafficHLA() {
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
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new CheckSurronding()));

    ArrayList<BaseAction> tasks2 = new ArrayList<>();
    tasks2.addAll(Arrays.asList(new Break(), new BackUp(), new Yield()));

    refinments.add(new Refinment(
      s -> s.tank.isFriendlyClose || s.tank.isEnemyInRange,
      tasks2
      ));

    refinments.add(new Refinment(
      s -> true,
      tasks1
      ));
  }
}



public class CheckSurronding extends Action {

  CheckSurronding() {
    taskName = "CheckSurronding";
  }

  public boolean preCondition(HTNState s) {
    return true;
  }

  public HTNState effect(HTNState s) {
    return s;
  }

  public void execute(Tank tank, float deltaTime) {
    tank.sensor.checkFront();
    ArrayList<Tank> others = tank.sensor.CheckAreaDetection();
    tank.tankState.isEnemyInRange  = false;
    tank.tankState.isFriendlyClose = false;
    tank.tankState.tstate.otherTanks = new ArrayList<>();

    for (Tank t : others) {
      if (t.team != tank.team) {
        tank.tankState.isEnemyInRange  = true;
      } else {
        tank.tankState.isFriendlyClose = true;
      }
      tank.tankState.tstate.otherTanks.add(new TankData(new PVector((float)t.pos().x, (float)t.pos().x), t.ID, t));
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
    return s;
  }

  public void execute(Tank tank, float deltaTime) {

    for (Tank other : tank.team.tanks) {
      PVector direction = VecMath.direction((float)tank.pos().x, (float)tank.pos().y, (float)other.pos().x, (float)other.pos().y);
      float angle = VecMath.dotAngle(new PVector((float)tank.heading().x, (float)tank.heading().y), VecMath.normalize(direction));
      float dist = dist((float)tank.pos().x, (float)tank.pos().y, (float)other.pos().x, (float)other.pos().y);

      if (dist <= 80 && angle > 0) {
        tank.velocity(tank.heading().x * -1 * 30, tank.heading().y * -1 * 30);
        return;
      }
    }
    state = execState.Success;
  }
}

public class Break extends Action {

  Break() {
    taskName = "Breaking";
  }

  public boolean preCondition(HTNState s) {
    return true;
  }

  public HTNState effect(HTNState s) {
    return s;
  }

  public void execute(Tank tank, float deltaTime) {

    state = execState.Success;
  }
}

public class Yield extends Action {

  Yield() {
    taskName = "Yielding";
  }

  public boolean preCondition(HTNState s) {
    return true;
  }

  public HTNState effect(HTNState s) {
    return s;
  }

  public void execute(Tank tank, float deltaTime) {
    state = execState.Success;
  }
}





public class ExploreHLA extends HighLevelAction {

  ExploreHLA() {
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new ExploreRegion()));
    refinments.add(new Refinment(
      state -> !state.tank.isNavigation,
      tasks1
      ));
  }
}

public class ExploreMap extends HighLevelAction {

  ExploreMap() {
    //refinments.add(new WalkAround());
  }
}


public class ExploreRegion extends HighLevelAction {
  ExploreRegion() {
    System.out.println("*** ExploreRegion");
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new PickRegion(), new MoveToRegion(), new SearchRegion()));

    refinments.add(new Refinment(
      s -> true,
      tasks1
      ));
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
      state = execState.Failed;
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
    return s.tank.regionCur != GridRegion.INV && s.tank.regionDes != GridRegion.INV && s.tank.regionCur != s.tank.regionDes;
  }

  public HTNState effect(HTNState state) {
    state.tank.isNavigation = true;
    return state;
  }

  public void execute(Tank tank, float deltaTime) {

    if (tank.AP().pathRouteLength() <= 0) {
      if (GS.computePath(new PVector((float)tank.pos().x, (float)tank.pos().y), tank.team.nav.rm.getRegion(tank.tankState.regionToExplore).regionMidPoint, tank.team.nav, GeneralSearch.GREEDY)) {
        tank.AP().pathSetRoute(GS.path);
        pointSet = true;
        state = execState.Success;
        return;
      }
    }
    state = execState.Failed;
  }
}

public class SearchRegion extends HighLevelAction {
  SearchRegion() {
    System.out.println("*** SearchRegion");
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

  public boolean preCondition(HTNState state) {
    return true;
  }

  public HTNState effect(HTNState state) {
    state.tank.isNavigation = true;
    return state;
  }

  float time = 0;


  public void execute(Tank tank, float deltaTime) {
    //System.out.println("MoveInRegion Cur: "+ tank.tankState.regionCur +" Des: " + tank.tankState.regionDes);
    tank.tankState.regionState.occupied = true;
    if (tank.AP().pathRouteLength() <= 0) {
      if (GS.computeStep(new PVector((float)tank.pos().x, (float)tank.pos().y), 150, GridRegion.values()[tank.tankState.regionToExplore], tank.team.nav)) {
        tank.AP().pathSetRoute(GS.path);
        state = execState.Success;
        return;
      }
    }
    state = execState.Failed;
  }
}



//Tank position compared to Region and calculate if they have been in there for over 10 seconds
public class WalkAround extends Action {

  boolean pointSet = false;
  float time = 0;

  public boolean preCondition(HTNState state) {
    return state.IsWorldPeacefull;
  }

  public HTNState effect(HTNState state) {
    //TODO
    //regions explored functionality
    return state;
  }

  public void execute(Tank tank, float deltaTime) {
    time += deltaTime* 1;
    if (time >= 30) {
      state = execState.Failed;
    }

    if (tank.AP().pathRouteLength() <= 0) {
      if (pointSet) {
        state = execState.Success;
        return;
      }
      if (GS.computeStep(new PVector((float)tank.pos().x, (float)tank.pos().y), 100, GridRegion.values()[tank.ID], tank.team.nav)) {
        tank.AP().pathSetRoute(GS.path);
        pointSet = true;
      }
    }
  }
}

public class AttackHLA extends HighLevelAction {
  AttackHLA() {
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveToTarget()));
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
      s -> s.tank != null && s.tank.hitPoints <= 1,
      tasks1
      ));

    //Refinemnt 2
    refinments.add(new Refinment(
      s -> s.tank != null && s.tank.hitPoints > 1,
      tasks2
      ));
  }
}

public class MoveAtDistance extends Action {

  public boolean preCondition(HTNState state) {
    if (true) {
      return true;
    }
    return false;
  }

  public  HTNState effect(HTNState state) {
    //Closer to target
    return state;
  }

  void execute(Tank tank, float deltaTime) {
  }
}

public class MoveCloseToTarget extends Action {

  public boolean preCondition(HTNState state) {
    if (true) {
      return false;
    }
    return true;
  }

  public HTNState effect(HTNState state) {
    //Closer to target
    return state;
  }

  void execute(Tank tank, float deltaTime) {
  }
}
