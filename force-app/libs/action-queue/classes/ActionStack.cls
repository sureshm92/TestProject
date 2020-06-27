/**
 * Created by Leonid Bartenev
 */

public without sharing class ActionStack {
    
    private ActionChain actionChain;
    
    public void add(Action action){
        if(actionChain == null){
            actionChain = new ActionChain(action);
        }else{
            actionChain = actionChain.next(action);
        }
    }
    
    public void run(){
        if(actionChain != null) actionChain.runChain();
    }
    
}