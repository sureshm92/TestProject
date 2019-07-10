/**
 * Created by dmytro.fedchyshyn on 08.07.2019.
 */

({
    toggleOptIn: function (component, event) {
        let contactId = component.get("v.contactId");
        if (communityService.isInitialized()) {
            communityService.executeAction(component, 'changeOptInOnTrue', {contactId: contactId}, function (returnValue) {
                component.set("v.isOptIn", true);
                component.set("v.showModal", false);
            });
        }
    },
});