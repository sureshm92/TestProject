({
    SearchHelper: function(component, event) {
         component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.fetchParticipantEnrollment");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                 alert(response.getReturnValue());
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                               
              component.set("v.searchResult", storeResponse); 
                
            }else if (state === "INCOMPLETE") {
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    }
                } else {
                    //alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})