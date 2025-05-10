//Alexander Bakas alba5453
public class TankPatroleState extends State {



  public void enter(BaseEntity base) {
    if (base instanceof Vehicle) {
      Vehicle v = (Vehicle)base;
      //v.AP().wanderOn().wanderFactors(60, 30, 20);
      //v.AP().obstacleAvoidOn();
      //v.AP().separationOn();
      //v.AP().separationWeight(70);2
      v.AP().pathOn();
    }
  }

  public void execute(BaseEntity base, double deltaTime, World world) {

    if (base instanceof Tank) {

      Tank t = (Tank)base;

      if (t.checkEnemyBoundry((new PVector((float)base.pos().x, (float)base.pos().y))) && t.EnemyInVision() ) {
        Cell enemyBaseCell = new Cell(new PVector(0, 0), false);
        enemyBaseCell.isEnemyBase = true;
        t.reportCells.add(enemyBaseCell);
        t.returnToBase();
      }
      if (t.AP().pathRouteLength() <= 0) {
        t.velocity(0,0);
        if (GS.computeStep(new PVector((float)t.pos().x, (float)t.pos().y), 100, GridRegion.B, t.team.nav)) {
          t.velocity(new Vector2D(0, 0));
          t.AP().pathSetRoute(GS.path);
        }
      }
    }
  }

  public void exit(BaseEntity base) {
  }

  public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}

public class TankObserving extends State {

  float time;
  TankPatroleState  toSwitch;

  TankObserving(float time, TankPatroleState toSwitch) {
    super();
    this.time = time;
    this.toSwitch = toSwitch;
  }

  public void enter(BaseEntity base) {
    if (base instanceof Tank) {
      Tank t = (Tank)base;
      t.velocity(0, 0);
      t.AP().wanderOff();
      t.AP().pathOff();
    }
  }

  public void execute(BaseEntity base, double deltaTime, World world) {

    time -= 1*deltaTime;
    if (time <= 0) {
      base.FSM().changeState(toSwitch);
      //System.out.println("GO HOME");
    }
  }

  public void exit(BaseEntity base) {
  }

  public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}

public class TankReturnToBaseState extends State {

  @Override
    public void enter(BaseEntity base) {

    if (base instanceof Tank) {
      Tank t = (Tank)base;
      if (GS.computeKnowledgePath(new PVector((float)t.pos().x, (float)t.pos().y), t.startpos, t.team.nav)) {
        t.AP().pathSetRoute(GS.path);
        t.AP().obstacleAvoidOff();
      }
    }
  }
  @Override
    public void execute(BaseEntity base, double deltaTime, World world) {
    if (base instanceof Tank) {

      Tank t = (Tank)base;

      if (t.AP().pathRouteLength() <= 0) {

        t.FSM().changeState(tankPatroleState);

        t.report();
        t.FSM().changeState(new TankObserving(3, tankPatroleState));
      }
    }
  }
  @Override
    public void exit(BaseEntity base) {
  }

  @Override
    public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}

public class TankIdleState extends State {

  public void enter(BaseEntity base) {
    if (base instanceof Tank) {
      Tank t = (Tank)base;
      t.velocity(0, 0);
    }
  }

  public void execute(BaseEntity base, double deltaTime, World world) {
  }

  public void exit(BaseEntity base) {
  }

  public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}

public class TankGlobalState extends State {

  TankGlobalState() {
    super();
  }

  public void enter(BaseEntity base) {
  }

  public void execute(BaseEntity base, double deltaTime, World world) {
    if (base instanceof Tank) {

      Tank t = (Tank)base;
      t.checkNode();
    }
  }

  public void exit(BaseEntity base) {
  }

  public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}

public class TankBreakAndWait extends State {

  TankBreakAndWait(Tank other) {
    super();
    this.other = other;
  }

  private Tank other;

  Tank waitignFor() {
    return other;
  }

  public void enter(BaseEntity base) {

    if (base instanceof Tank) {

      Tank t = (Tank)base;
      t.AP().pathOff();
      t.velocity(0, 0);

      State otherState = other.FSM().getCurrentState();
      if (otherState instanceof TankBreakAndWait && ((TankBreakAndWait)otherState).other == t) {
        t.FSM().changeState(tankPatroleState);
      }
    }
  }

  public void execute(BaseEntity base, double deltaTime, World world) {
    if (!(base instanceof Tank)) {
      return;
    }
    Tank t = (Tank)base;

    if (other instanceof Tank) {

      Tank v = (Tank)other;

      PVector direction = VecMath.direction((float)base.pos().x, (float)base.pos().y, (float)v.pos().x, (float)v.pos().y);
      float angle = VecMath.dotAngle(new PVector((float)t.heading().x, (float)t.heading().y), VecMath.normalize(direction));
      float dist = dist((float)base.pos().x, (float)base.pos().y, (float)v.pos().x, (float)v.pos().y);

      if (dist <= MAXALLOWEDISTANCE && angle > 0) {
        t.velocity(t.heading().x * -1 * 30, t.heading().y * -1 * 30);
        return;
      }

      t.FSM().changeState(tankPatroleState);
    }
  }

  public void exit(BaseEntity base) {
  }

  public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}

public class TankYield extends State {

  public void enter(BaseEntity base) {
    if (base instanceof Tank) {
      Tank t = (Tank)base;
      t.velocity(0, 0);
    }
  }

  public void execute(BaseEntity base, double deltaTime, World world) {
  }

  public void exit(BaseEntity base) {
  }

  public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}

public class TankReroute extends State {

  public void enter(BaseEntity base) {
    if (base instanceof Tank) {
      Tank t = (Tank)base;
      t.velocity(0, 0);
    }
  }

  public void execute(BaseEntity base, double deltaTime, World world) {
  }

  public void exit(BaseEntity base) {
  }

  public boolean onMessage(BaseEntity base, Telegram tgram) {
    return false;
  }
}
