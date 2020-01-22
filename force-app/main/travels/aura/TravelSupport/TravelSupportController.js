/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    doInit: function (component, event, helper) {
        helper.getAvailableVendors(component, event, helper);
        helper.transformToHtmlMessage(component, event);
    },

    show: function (component, event, helper) {
        helper.checkOnDisclaimer(component, event);
        component.set('v.showPopup', true);
        component.find('popup').show();
    },

    hide: function (component, event, helper) {
        component.find('popup').cancel();
        component.set('v.showPopup', false);
    },

    redirectToUrl: function (component, event, helper) {
        helper.redirectToUrl(component,event)
    },

    showDisclaimer: function (component, event, helper) {
        let vendor = component.get("v.selectedVendor");
        if (vendor.Disclosure__c){
            component.set('v.htmlMessage', vendor.Disclosure__c);
        }
        component.set("v.isShowDisclaimer", true);
    },

});