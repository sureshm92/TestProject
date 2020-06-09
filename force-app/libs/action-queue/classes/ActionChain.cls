/**
 * Created by Leonid Bartenev
 */

public without sharing class ActionChain implements Queueable{
    
    private Action action;
    private ActionChain parent;
    private ActionChain next;
    
    public ActionChain(Action action){
        this.action = action;
    }
    
    public ActionChain next(Action action){
        ActionChain nextItem = new ActionChain(action);
        nextItem.parent = this;
        this.next = nextItem;
        return nextItem;
    }
    
    public void execute(QueueableContext qc) {
        ActionExecutor.execute(action);
        System.enqueueJob(next);
    }
    
    public void runChain(){
        ActionChain firstChainItem = this;
        while (firstChainItem.parent != null){
            firstChainItem = parent;
        }
        System.enqueueJob(firstChainItem);
    }
}