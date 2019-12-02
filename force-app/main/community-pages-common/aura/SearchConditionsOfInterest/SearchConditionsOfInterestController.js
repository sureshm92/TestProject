/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        debugger;
        let copy = Object.assign([],component.get('v.conditionsOfInterest'));
        component.set('v.conditionsOfInterestTemp', copy);
        helper.valueChange(component, event, helper);
    },

    show: function (component, event, helper) {
        helper.valueChange(component, event, helper);
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
                }), 500
            );
        }
    },

    handleChange: function (component, event, helper) {
        helper.changeCheckBox(component, event);
    },

    doCancel: function (component, event, helper) {
        component.find('searchModal').hide();
        let arr = [];
        component.set('v.displayedItems', arr);
        component.find('searchInput').set('v.value', '');
    },

    doSave: function (component, event, helper) {
        helper.saveElement(component);
    }

})