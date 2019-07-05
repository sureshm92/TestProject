(
    {
        doInit: function(component, event, helper) {

            if (!component.get("v.isOptIn") && communityService.isInitialized()) {
                communityService.executeAction(component, 'getLinkForModalWindow', {}, function (returnValue) {
                    component.set("v.optInBody", returnValue);
                });
            }
        },

        openOptInModal: function (component, event, helper) {
             component.set("v.showModal", true);
        },

        changeOptIn: function (component, event, helper) {

            let contactId = component.get("v.contactId");
            if (communityService.isInitialized()) {
                communityService.executeAction(component, 'changeOptInOnTrue',
                {
                    contactId: contactId
                }, function (returnValue) {
                    component.set("v.isOptIn", true);
                    component.set("v.showModal", false);
                });
            }
        },
    }
)