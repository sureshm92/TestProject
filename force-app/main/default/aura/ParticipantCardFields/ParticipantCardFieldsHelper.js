/**
 * Created by user on 26-Dec-19.
 */

({
    checkInvite: function (component, myId) {
        var action = component.get("c.checkInvited");
        action.setParams({"id" : myId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "ERROR"){
                
            }
            if (state === "SUCCESS") {
                component.set("v.invited", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    }
    
});