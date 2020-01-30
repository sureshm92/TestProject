/**
 * Created by dmytro.fedchyshyn on 08.07.2019.
 */

({
    toggleOptIn: function (component, event) {

        if (communityService.isInitialized()) {
            communityService.executeAction(component, 'changeOptInOnTrue', {
                    contactId: component.get("v.contactId")
                }, function (returnValue) {
                component.set("v.isOptIn", returnValue);
                component.set('v.optInChanged', true);
                component.set("v.showModal", false);
            });
        }
    },
});