class PriorityQueue<T>{

    private class Node<T>{
      
      
      
      Node(){
      }
      Node<T> next;
      T value;
    }
    int size;
    
    Node<T> start = new Node<T>();
    
    ArrayList<T> queue;
    
    PriorityQueue(){}
 
    void add(T element, float prio){
      Node<T> newNode = new Node<T>();
       
  
    
    }
     
    boolean isEmpty(){   
      return size <= 0;
    }
    
    T poll(){    
       return start.value;
    }
  
 

}
