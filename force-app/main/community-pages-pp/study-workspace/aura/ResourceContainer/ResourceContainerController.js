(
    {
        doInit : function (component, event, helper) {

            if (communityService.isInitialized()) {
                communityService.executeAction(component, 'getNoTAMessage', {}, function (returnValue) {
                    component.set("v.noTAMessage", returnValue);
                });
            }
        },
    }
)