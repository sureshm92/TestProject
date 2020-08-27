({
	save : function(component, event, helper) {
		 var action = component.get("c.createServiceResource");
       var selectedRecord =  component.get('v.selectedRecord');
        if(selectedRecord) {
        action.setParams({
            "uId": selectedRecord.value
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
              
                
                
               var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type": "success",
                "message": "Resource record has been created successfully"
            });
            toastEvent.fire();
            }
            var res = response.getReturnValue();
              var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "lightning/r/ServiceResource/" + res + "/view",
                });
                urlEvent.fire();
          
          
        });
        }else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "waring!",
                "type": "warning",
                "message": "Please select PI"
            });
            toastEvent.fire();
        }
         
        $A.enqueueAction(action);
	},
    back : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");                           
                            urlEvent.setParams({
                                "url": "/lightning/o/ServiceResource/list", 
                                "isredirect":true
                            });
                            urlEvent.fire();
    }
})