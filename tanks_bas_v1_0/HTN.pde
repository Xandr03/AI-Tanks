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
  Tank tank;
  Team team;
  boolean IsWorldPeacefull = true;
  int enemiesLeft = 3;
  RegionManager rm;

  //Regions

  HTNState(Team team, Tank tank) {
    this.team = team;
    this.tank = tank;
  }

  HTNState(Team team) {
    this.team = team;
    this.rm = team.nav.rm;
  }

  HTNState(HTNState state) {
    this.rm = new RegionManager(state.rm);
    this.IsWorldPeacefull = state.IsWorldPeacefull;
    this.enemiesLeft = state.enemiesLeft;

    //DELETE LATER
    this.team = state.team;
    this.tank = state.tank;
  }
}

public enum execState {
  Success,
    Pending,
    Failed
}

public class Plan_runner {

  LinkedList<Action> sequence = new LinkedList<>();

  Action runningTask;

  Tank owner;
  Plan_runner(Tank tank) {
    this.owner = tank;
  }

  void update(float deltaTime) {
    //System.out.println("update");
    if (runningTask == null && sequence.isEmpty()) {
      HTNState tankWorldState = new HTNState(owner.team.WorldState);
      tankWorldState.tank = owner;
      setTasks(planner.Search(new BeTank(), tankWorldState));
      return;
    }
    if (runningTask.state == execState.Success) {
      this.sequence.pop();
      runningTask = this.sequence.peek();
      return;
    }
    if (runningTask.state == execState.Failed) {
      HTNState tankWorldState = new HTNState(owner.team.WorldState);
      tankWorldState.tank = owner;
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
    HTNState initialState = new HTNState(state);
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

    refinments.add(new Refinment(
      state -> true,
      tasks1
      ));

    refinments.add(new Refinment(
      state -> true,
      tasks2
      ));
  }
}



public class ExploreHLA extends HighLevelAction {

  ExploreHLA() {
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new ExploreRegion()));
    refinments.add(new Refinment(
      state -> true,
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

    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new PickRegion(), new MoveToRegion(), new SearchRegion()));

    refinments.add(new Refinment(
      s -> s.IsWorldPeacefull,
      tasks1
      ));
  }
}

public class PickRegion extends Action {

  public boolean preCondition(HTNState state) {
    return state.rm.RegExProc < 100.0f;
  }

  public HTNState effect(HTNState state) {
    HTNState newState = state;
    newState.rm.RegExProc = (newState.rm.RegionsExplored + 1)/9;
    return state;
  }

  public void execute(Tank tank, float deltaTime) {
    RegionManager rm = tank.team.nav.rm;
    tank.regionToExplore = rm.getAvailibleRegion(new PVector((float)tank.pos().x, (float)tank.pos().y));
    if (tank.regionToExplore < 0) {
      state = execState.Failed;
      return;
    }
    rm.setRegionOccupied(tank.regionToExplore, true);
    state = execState.Success;
  }
}

public class MoveToRegion extends Action {

  boolean pointSet = false;
  float time = 0;

  public boolean preCondition(HTNState state) {
    return state.rm.RegExProc < 100.0f;
  }

  public HTNState effect(HTNState state) {

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
      if (GS.computePath(new PVector((float)tank.pos().x, (float)tank.pos().y), tank.team.nav.rm.getRegion(tank.regionToExplore).regionMidPoint, tank.team.nav, GeneralSearch.ASTAR)) {
        tank.AP().pathSetRoute(GS.path);
        pointSet = true;
      }
    }
  }
}

public class SearchRegion extends HighLevelAction {
  SearchRegion() {
    ArrayList<BaseAction> tasks1 = new ArrayList<>();
    tasks1.addAll(Arrays.asList(new MoveInRegion()));
    refinments.add(new Refinment(
      s -> true,
      tasks1));
  }
}



public class MoveInRegion extends Action {
  public boolean preCondition(HTNState state) {
    return state.rm.RegExProc < 100.0f;
  }

  public HTNState effect(HTNState state) {
    return state;
  }

  float time = 0;


  public void execute(Tank tank, float deltaTime) {

    time += deltaTime* 1;
    if (time >= 10) {
      state = execState.Success;
    }

    if (tank.AP().pathRouteLength() <= 0) {
      if (GS.computeStep(new PVector((float)tank.pos().x, (float)tank.pos().y), 100, GridRegion.values()[tank.regionToExplore], tank.team.nav)) {
        tank.AP().pathSetRoute(GS.path);
      }
    }
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
      s -> s.tank.hitPoints <= 1,
      tasks1
      ));

    //Refinemnt 2
    refinments.add(new Refinment(
      s -> s.tank.hitPoints > 1,
      tasks2
      ));
  }
}

public class MoveAtDistance extends Action {

  public boolean preCondition(HTNState state) {
    if (state.tank.hitPoints <= 1) {
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
    if (state.tank.hitPoints <= 1) {
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
