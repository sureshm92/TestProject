/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

({
    doInit: function (component, event, helper) {
        helper.valueChange(component, event, helper);
    },

    show: function (component) {
        component.find('searchModal').show();
    },

    hide: function(component, event, helper) {
        component.find('searchModal').hide();
    },

    bulkSearch: function (component, event, helper) {
        var bypass = component.get('v.bypass');
        if (bypass) {
            return;
        } else {
            component.set('v.bypass', true);
            window.setTimeout(
                $A.getCallback(function () {
                    helper.valueChange(component, event, helper);
                }), 200
            );
        }
    },

    handleChange: function (component, event, helper) {
        helper.changeCheckBox(component, event);
    },

    doClose: function (component, event, helper) {
        component.find('searchModal').hide();
        component.set('v.displayedRefNetworks', []);
        component.find('searchInput').set('v.value', '');
    }
});