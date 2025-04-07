


class Object extends BaseEntity {
  
  Object(){ObjectHolder.add(this);}
  Object(String nam, Vector2D pos, float diameter){
    super(nam, pos, diameter);
    ObjectHolder.add(this);
  }
  
}


static class ObjectHolder{
  static ArrayList<Object> Holder = new ArrayList<Object>();
  
  
  static void add(Object obj){
      if(obj != null){
        Holder.add(obj);
        System.out.println("Object Created");
      }else{
        System.out.println("Object Failed to Be Created");
      }
  }
  
  
}
