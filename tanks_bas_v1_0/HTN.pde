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
public class HTNState {
  Tank tank;
  Team team;
  boolean IsWorldPeacefull = true;
  //Regions

  HTNState(Team team, Tank tank) {
    this.team = team;
    this.tank = tank;
  }
  
  HTNState(Team team){
    this.team = team;
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
      setTasks(Planner.Search(new BeTank(), owner.team.WorldState));
      return;
    }
    if (runningTask.state == execState.Success) {
      this.sequence.pop();
      runningTask = this.sequence.peek();
      return;
    }
    if (runningTask.state == execState.Failed) {
       setTasks(Planner.Search(new BeTank(), owner.team.WorldState));
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

public static class Planner {

  public static LinkedList<Action> Search(HighLevelAction problem, HTNState state) {
    //System.out.println("Planning");
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

  static ArrayList<BaseAction> refine(HighLevelAction hla, HTNState state) {
    return hla.getRefinments(state);
  }


  static HTNState getPotentialState(HTNState initialState, LinkedList<Action> actions) {

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

  public ArrayList<BaseAction> refinments = new ArrayList<>();
  public ArrayList<BaseAction> getRefinments(HTNState s) {
    ArrayList<BaseAction> actionsToReturn = new ArrayList<>();
    for (BaseAction a : refinments) {

      if (a instanceof Action) {
        Action action = (Action)a;
        if (action.preCondition(s)) {
          actionsToReturn.add(action);
        }
      }
      if (a instanceof HighLevelAction) {
        actionsToReturn.add(a);
      }
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
    //refinments.add(new AttackHLA());
    refinments.add(new ExploreHLA());
  }
}


public class ExploreHLA extends HighLevelAction {

  ExploreHLA() {
    refinments.add(new ExploreMap());
  }
}

public class ExploreMap extends HighLevelAction {

  ExploreMap() {
    refinments.add(new WalkAround());
  }
}

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
    if(time >= 30){state = execState.Failed;}
 
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
      refinments.add(new MoveToTarget());
    }
  }

  public class MoveToTarget extends HighLevelAction {

    MoveToTarget() {
      refinments.add(new MoveCloseToTarget());
      refinments.add(new MoveAtDistance());
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
