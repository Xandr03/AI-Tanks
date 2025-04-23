public class TankPatroleState extends State{
  
  

  public void enter(BaseEntity base){
   if(base instanceof Vehicle){
     Vehicle v = (Vehicle)base;
     //v.AP().wanderOn().wanderFactors(60, 30, 20);
     //v.AP().obstacleAvoidOn();
     //v.AP().separationOn();
     //v.AP().separationWeight(70); 
   }  
  }
  
  public void execute(BaseEntity base, double deltaTime, World world){

    if(base instanceof Tank){
      
      Tank t = (Tank)base;
    
      if(t.checkEnemyBoundry((new PVector((float)base.pos().x, (float)base.pos().y))) && t.EnemyInVision() ){
        Cell enemyBaseCell = new Cell(new PVector(0,0),false);
        enemyBaseCell.isEnemyBase = true;
        t.reportCells.add(enemyBaseCell);
        t.returnToBase();
      }
      if(t.AP().pathRouteLength() <= 0){
        if(bFS.computeStep(new PVector((float)t.pos().x, (float)t.pos().y), 100, t.team)){
          t.velocity(new Vector2D(0,0));
          //t.AP().pathSetRoute(bFS.path);
        }
      }
       
    }
  }
  
  public void exit(BaseEntity base){
  
  }
  
  public boolean onMessage(BaseEntity base, Telegram tgram){
    return false;
  }

}

public class TankObserving extends State{
  
  float time;
  TankReturnToBaseState  toSwitch;
  
  TankObserving(float time, TankReturnToBaseState toSwitch){
    super();
    this.time = time;
    this.toSwitch = toSwitch;
  }

  public void enter(BaseEntity base){    
      if(base instanceof Tank){
        Tank t = (Tank)base;
        t.velocity(new Vector2D(0,0));
        t.AP().wanderOff();
        t.AP().pathOff();
      }
  }
  
  public void execute(BaseEntity base, double deltaTime, World world){
  
    time -= 1*deltaTime;
    if(time <= 0){
      base.FSM().changeState(toSwitch);
      System.out.println("GO HOME");
    }
  
  }
  
  public void exit(BaseEntity base){
  
  }
  
  public boolean onMessage(BaseEntity base, Telegram tgram){
    return false;
  }

}

public class TankReturnToBaseState extends State{

  @Override
  public void enter(BaseEntity base){
  
    if(base instanceof Tank){
      Tank t = (Tank)base;
      if(bFS.computeKnowablePath(new PVector((float)t.pos().x, (float)t.pos().y), t.startpos ,null, t)){
        t.AP().pathSetRoute(bFS.path);
        t.AP().obstacleAvoidOff();
      }
    }
  
  }
  @Override
  public void execute(BaseEntity base, double deltaTime, World world){
    if(base instanceof Tank){
       
      Tank t = (Tank)base;
      
      if(t.AP().pathRouteLength() <= 0){

        t.FSM().changeState(tankPatroleState);
        
        t.report();
      }

       
    }
  
  }
  @Override
  public void exit(BaseEntity base){
  
  }
  
  @Override
  public boolean onMessage(BaseEntity base, Telegram tgram){
    return false;
  }

}

public class TankIdleState extends State{

  public void enter(BaseEntity base){
  
  
  }
  
  public void execute(BaseEntity base, double deltaTime, World world){
  
  
  }
  
  public void exit(BaseEntity base){
  
  }
  
  public boolean onMessage(BaseEntity base, Telegram tgram){
    return false;
  }

}

public class TankGlobalState extends State{
  
  TankGlobalState(){super();}

  public void enter(BaseEntity base){
  
  
  }
  
  public void execute(BaseEntity base, double deltaTime, World world){
      if(base instanceof Tank){
      
      Tank t = (Tank)base;
      t.checkNode();
       
    }
  
  }
  
  public void exit(BaseEntity base){
  
  }
  
  public boolean onMessage(BaseEntity base, Telegram tgram){
    return false;
  }

}
