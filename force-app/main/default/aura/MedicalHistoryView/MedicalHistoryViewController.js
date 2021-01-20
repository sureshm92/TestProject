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
    openModel : function(component, event, helper){       
        var peId = component.get("v.pe.Id");
        var action = component.get("c.getMedicalHistory");
        action.setParams({ peId : peId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') 
            {
                var responseData = JSON.parse(response.getReturnValue());                
                if (responseData.attachments[0].ContentSize < 11534336 ) //In Bytes(in binary)
                {                  
                    component.set('v.openmodel',true);
                } 
                else 
                {
                    component.set('v.openmodel',false);
                    helper.showToast(component, event, helper );
                }
            }   
        });
        $A.enqueueAction(action);
    },
    
    closeModal:function(component,event,helper){    
        component.set('v.openmodel',false);
        },

        
})