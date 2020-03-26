/**
 * Created by Leonid Bartenev
 */
({
    doCountryChanged: function (component, event, hepler) {
        var visitResult = component.get('v.visitResult');
        if(!visitResult.countryCodes){
            visitResult.type = 'All';
            component.set('v.visitResult', visitResult);
        }
    },

    doGlobalCountryChanged: function (component, event, hepler) {
        let visitResult = component.get('v.visitResult');
        let globalCountries = component.get('v.globalCountries');
        let globalType = component.get('v.globalType');

        if (globalType === 'Disabled') {
            return;
        }
        if (!visitResult.countryCodes || (!globalCountries && globalType !== 'All')) {
            visitResult.type = 'All';
        }
        if (globalCountries && (globalType !== 'All' || globalType !== 'Disabled')) {
            visitResult.type = 'Countries';
            visitResult.countryCodes = globalCountries;
        }
        component.set('v.visitResult', visitResult);
    },

    doTypeChanged: function (component, event, helper) {
        var visitResult = component.get('v.visitResult');
        if (visitResult.type === 'Countries' || visitResult.type === 'Countries_Disabled') {
            component.find('countryLookup').focus();
        }
    },

    doCloseCountryMode: function (component, event, helper) {
        var visitResult = component.get('v.visitResult');
        visitResult.countryCodes = null;
        visitResult.type = 'All';
        component.set('v.visitResult', visitResult);
    },

    doGlobalTypeChanged: function (component, event, helper) {
        var globalType = component.get('v.globalType');
        if (globalType !== 'Disabled') return;
        var visitResult = component.get('v.visitResult');
        visitResult.countryCodes = null;
        visitResult.type = globalType;
        component.set('v.visitResult', visitResult);
    }
});