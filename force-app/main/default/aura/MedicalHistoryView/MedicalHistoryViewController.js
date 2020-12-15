({  
    doInit : function(component, event, helper) 
    {
        var peId = component.get("v.pe.Id");
        var action = component.get("c.getMedicalHistory");
        action.setParams({ peId : peId });
        action.setCallback(this, function(response) 
                           {
                               component.set('v.medicalHistory', JSON.parse(response.getReturnValue()));
                           });
        $A.enqueueAction(action);
    },
})