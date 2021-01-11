({
    doInit : function(component, event, helper)  {
        communityService.executeAction(component, 'getInitData', {
            recId : component.get("v.recordId")
            
        }, function (returnValue) {
            console.log('test' +JSON.stringify(returnValue));  
            
            if(returnValue) {
                 component.set("v.warning", true);
               /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "warning",
                    "mode": "sticky",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire(); */
            }
            
        });
        
    },
    close : function(component, event, helper)  {
        component.set("v.warning", false);
    },
        
})