



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
  HTNState(Team team, Tank tank) {
    this.team = team;
    this.tank = tank;
  }
}

public enum execState {
  Success,
    Pending,
    Failed
}

public class Plan {

  LinkedList<Action> sequence;
}

public class planner {

  execState Search(HighLevelAction problem, Tank tank, Team team) {
    HTNState initialState = new HTNState(team, tank);
    PriorityQueue<BaseAction> frontier = new PriorityQueue<>();

    frontier.addAll(problem.getRefinments(state));

    //ArrayList<Plan> solutions = new ArrayList<>();

    LinkedList<Action> prefix = new LinkedList<>();



    while (!frontier.isEmpty()) {

      BaseAction plan = frontier.poll();
      HighLevelAction hla = null;
      if (plan instanceof HighLevelAction) {
        hla = (HighLevelAction)plan;
      }

      HTNState outcome = getPotentialState(initialState, prefix);
      if (hla == null) {
        if ()
        }
      }


      return execState.Failed;
  }


  HTNState getPotentialState(HTNState intialState, LinkedList<Action> actions) {

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

  Action() {
  }
  @Override public int compareTo(BaseAction otherNode) {
    return -1;
  }
  public abstract boolean preCondition(HTNState state);

  public abstract HTNState effect(HTNState state);

  public abstract void execute();
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

  public ArrayList<BaseAction> refinments;
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
    refinments.add(new AttackHLA());
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
    return true;
  }

  void execute() {
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
    return true;
  }

  void execute() {
  }
}
