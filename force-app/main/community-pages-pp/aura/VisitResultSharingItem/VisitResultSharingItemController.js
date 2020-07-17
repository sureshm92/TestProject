/**
 * Created by Leonid Bartenev
 */

({
    doInit: function (component, event, helper) {
        let visitResult = component.get('v.visitResult');
        component.set('v.previousType', visitResult.type);
    },

    doUpdateValue: function (component, event, helper) {
        let previousType = component.get('v.previousType');
        let visitResult = component.get('v.visitResult');
        if(previousType !== visitResult.type) {
            component.set('v.renderLookup', false);
            component.set('v.previousType', visitResult.type);
            component.set('v.renderLookup', true);
        }

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
    },

    doCountryChanged: function (component, event, helper) {
        let visitResult = component.get('v.visitResult');
        if(!visitResult.countryCodes){
            visitResult.type = 'All';
            component.set('v.visitResult', visitResult);
        }
    },

    doTypeChanged: function (component, event, helper) {
        let visitResult = component.get('v.visitResult');
        if(visitResult.type === 'Countries' || visitResult.type === 'Countries_Disabled') {
            component.find('countryLookup').focus();
        }
    },

    doCloseCountryMode: function (component, event, helper) {
        let visitResult = component.get('v.visitResult');
        visitResult.countryCodes = null;
        visitResult.type = 'All';
        component.set('v.visitResult', visitResult);
    }
});