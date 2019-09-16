({

    doInit : function(component, event, helper) {
        if (!component.get('v.initialized')) {
            component.set('v.initialized', true);
            helper.fillInitTaps(component);
        }
    },

    doSearch : function(component, event, helper) {
        helper.doSearch(component);
    },

    onFocus : function(component, event, helper) {
        component.set('v.showDropdown', true);
        helper.doSearch(component);
    },

    onBlur :function(component, event, helper) {
        setTimeout(function () {
            component.set('v.showDropdown', false);
        }, 150)
    },

    handleSelection : function(component, event, helper) {
        helper.handleSelection(component, event, helper);
        component.set('v.showDropdown', false);
    },

    updateSearchResults : function(component, event, helper) {
        helper.updateSearchResults(component);
        helper.removeUncheckedTaps(component);
    }

});