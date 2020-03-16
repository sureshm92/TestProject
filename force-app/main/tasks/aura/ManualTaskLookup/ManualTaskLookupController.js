/**
 * Created by user on 04.03.2019.
 */
({
    lookupSearch : function(component, event, helper) {
        var objType = component.get('v.objType');

        var action;
        switch (objType) {
            case 'therapeutic' :
                action = component.get('c.searchTherapeutic');
                break;

            case 'study' :
                action = component.get('c.searchStudy');
                break;

            case 'countries' :
                action = component.get('c.searchCountries');
                break;

            case 'site' :
                action = component.get('c.searchSite');
                break;

            default:
                action = component.get('c.searchSponsor');
        }

        component.find('lookup').search(action);
    },

    clearErrorsOnChange: function(component, event, helper) {
        const selection = component.get('v.selection');
        const errors = component.get('v.errors');

        if (selection.length && errors.length) {
            component.set('v.errors', []);
        }
    },

    clearSelection: function(component, event, helper) {
        component.set('v.selection', []);
    }
})