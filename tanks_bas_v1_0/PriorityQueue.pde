//Alexander Bakas alba5453
class PrioritysQueue<T>{

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
    
    Node<T> head = null;
    
    ArrayList<T> queue;
    
    PrioritysQueue(){}
 
    void add(T element, float prio){
      Node<T> newNode = new Node<T>(element, prio);    
      if(head == null){
        head = newNode;
        size++;
        return;
      } 
    
      Node<T> current = head.next;   
      Node<T> last = head;
      
      for(int i = 0; i < size; i++){
      
        if(current == null || newNode.prio < current.prio ){        
          newNode.next = current;
          last.next = newNode;
          size++;
          return;
        }
         
      } 
              
    }
                
    public boolean isEmpty(){   
      return size <= 0;
    }
    
    public T poll(){    
      if(head != null){
         T tempValue = head.value;
         head = head.next;
         size--;
         System.out.println(tempValue);
         return tempValue;       
      }
      return null;
    }
      
}

  
