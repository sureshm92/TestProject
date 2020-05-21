/**
 * Created by Leonid Bartenev
 */

({
    doUpdateValue: function (component, event, helper) {
        let visitResult = component.get('v.visitResult');
        component.set('v.showResult', visitResult.type !== 'Disabled');
    },

    doChangedByUser: function (component, event, helper) {
        let showResult = component.get('v.showResult');
        let visitResult = component.get('v.visitResult');
        let globalCountries = component.get('v.globalCountries');
        let globalType = component.get('v.globalType');

        if (showResult) {
            visitResult.countryCodes = globalCountries;
            visitResult.type = globalType;
        } else {
            visitResult.countryCodes = '';
            visitResult.type = 'Disabled';
        }

        component.set('v.visitResult', visitResult);
        component.getEvent('onChange').fire();
    }
});