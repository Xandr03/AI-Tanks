







public enum TaskID{
   ATTACK_ACT,
   MOVETOTARGET,
   FLANK,
   MOVECLOSETOTARGET,
   MOVEATDISTANCE,
   FLANKTHETARGET
}

public enum OperatorID{
   OPERATOR_FIRE,
   OPERATOR_MOVE,
   OPERATOR_ROTATE,
}





public class planner {

  planner() {
  }


  void Search() {
  }
}


public abstract class Action { //Operator
  

  
  public OperatorID op;
  Action(OperatorID op){this.op = op;}

  public abstract boolean preCondition(State state);

  public abstract boolean effect(State state);
}


//Should hold a list of OperatorIDs
public abstract class HighLevelAction{ //Task

  HighLevelAction()
  public ArrayList<ArrayList<Action>> refinements;
  public abstract ArrayList<Action> getRefinments(State s);
}

//Base State Class
public class HTNState {
  Team team;
  HTNState(Team team) {
    this.team = team;
  }
}

//Hold the state data needed to check when a team attacks
//To check health and availability
public class AttackingState extends HTNState {
  
  AttackingState(Team team) {
    super(team);
    
  }
}

//Hold the state data needed to check when a team attacks
//To check areas to explore
public class ExploreState extends HTNState {
  NavLayout grid;
  ExploreState(Team team) {
    super(team);
    this.grid = team.nav;
  }
}

public  class AttackHLA extends HighLevelAction {


  public  boolean preCondition(State state) {
    return true;
  }

  public  boolean effect(State state) {
    return true;
  }

  public ArrayList<Action> getRefinments(State s) {
    return new ArrayList<Action>();
  }


  private class MoveToTarget extends Action {

    Tank tank;
    Tank target;
    MoveToTarget(Tank t, Tank target) {
      this.tank = t;
      this.target = target;
    }

    public  boolean preCondition(State state) {
      //Check health and if to low dont let this tank move to close to target
      return true;
    }

    public  boolean effect(State state) {
      //Closer to target
      return true;
    }
  }
}
