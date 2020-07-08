({
    getcheckScheduledMaintenance : function(component, event, helper) 
    {
        var action = component.get("c.checkScheduledMaintenance");
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            if (state === "SUCCESS") 
            {
                if(response.getReturnValue() == true)
                {
                    component.set("v.isUnderMaintanceForm", false);
                    component.set("v.isUnderMaintance", true);
                }
                else
                {
                    component.set("v.isUnderMaintanceForm", true);
                    component.set("v.isUnderMaintance", false);
                }
            }
            else 
            {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
})