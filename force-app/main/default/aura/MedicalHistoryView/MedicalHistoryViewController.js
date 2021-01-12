({  
    doInit : function(component, event, helper) {
        var peId = component.get("v.pe.Id");
        var action = component.get("c.getMedicalHistory");
		component.set('v.subDomain', communityService.getSubDomain());
        action.setParams({ peId : peId });
        action.setCallback(this, function(response) 
                           {
                               component.set('v.medicalHistory', JSON.parse(response.getReturnValue()));
                           });
        $A.enqueueAction(action);
    },
  	openModel : function(component, event, helper) {
        component.set("v.openmodel",true);
    },
    
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('editDialog');
        var cmpBack = component.find('overlay');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set('v.openmodel',false);
        },

        
})