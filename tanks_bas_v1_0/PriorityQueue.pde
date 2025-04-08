class PriorityQueue<T>{

    private class Node<T>{   
      Node(T e, float prio){
       this.value = e;
       this.prio = prio;
       this.next = null;
      }
      
      Node<T> next;
      T value;
      float prio;
    }
    int size;
    
    Node<T> head = new Node<T>(null,Integer.MAX_VALUE);
    
    ArrayList<T> queue;
    
    PriorityQueue(){}
 
    void add(T element, float prio){
      Node<T> newNode = new Node<T>(prio);      
      Node<T> current = head;   
      while(!(newNode.prio < current.prio)){        
        if(current.next == null){
          current.next = newNode;
          size++;
          return;
        }           
          current = current.next;          
      }  
        
    }
      
      
           
    public boolean isEmpty(){   
      return size <= 0;
    }
    
    public T poll(){    
      if(head.next == null){
         return head.value;       
      }
      head = head.next;
      return head.value;
    }
      
}

  
