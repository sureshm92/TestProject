/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    doInit: function (component, event, helper) {
        helper.getAvailableVendors(component, event, helper);
    },
    redirectToLink: function (component, event, helper) {
        helper.redirectToUrla(component, event, helper);
    },
});