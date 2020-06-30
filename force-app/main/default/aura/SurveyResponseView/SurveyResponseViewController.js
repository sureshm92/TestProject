({  
    doInit : function(component, event, helper) 
    {
        debugger;
        var peId = component.get("v.pe.Id");
        var action = component.get("c.getSurveyResponse");
        action.setParams({ peId : peId });
        action.setCallback(this, function(response) 
                           {
                               component.set('v.surveyresponse', JSON.parse(response.getReturnValue()));
                           });
    
        $A.enqueueAction(action);
    }
})