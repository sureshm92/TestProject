/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    doInit: function (component, event, helper) {
        helper.getAvailableVendors(component, event, helper);
        if (component.get("v.hasDefault") === true) {
            let message = component.get('v.message');
            let htmlMessage = message.replace(new RegExp('\\n', 'g'), '<br/>');
            component.set('v.htmlMessage', htmlMessage);
        }
    },
    show: function (component, event, helper) {
        component.set('v.showModal',true);
        component.find('popup').show();

    },
    hide: function (component, event, helper) {
        component.set('v.showModal',true);
        component.find('popup').cancel();
    },
    showAllVendors: function (component, event, helper) {
        component.set("v.hasDefault", false);
    },
});