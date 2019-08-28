/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    doInit: function (component, event, helper) {
        if (component.get("v.hasDefault") === true) {
            let message = component.get('v.message');
            let htmlMessage = message.replace(new RegExp('\\n', 'g'), '<br/>');
            component.set('v.htmlMessage', htmlMessage);
        }
    },

    show: function (component, event, helper) {
        component.find('popup').show();
        helper.checkOnShowMore(component, event);
    },

    hide: function (component, event, helper) {
        component.find('popup').cancel();
    },

    showAllVendors: function (component, event, helper) {
        component.set("v.isShowMore", true);
    },

    doSuccess: function (component, event, helper) {
        helper.redirectToUrl(component,event)
    },

});