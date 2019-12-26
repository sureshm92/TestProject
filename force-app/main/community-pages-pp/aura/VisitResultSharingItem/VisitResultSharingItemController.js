/**
 * Created by Leonid Bartenev
 */
({
    doCountryChanged: function (component, event, hepler) {
        var visitResult = component.get('v.visitResult');
        if(component.get('v.globalType') === 'Disabled') return;
        if(!visitResult.countryCodes || (!component.get('v.countries') && component.get('v.globalType') !== 'All')){
            visitResult.type = 'All';
            component.set('v.visitResult', visitResult);
        }
    },

    doTypeChanged: function (component, event, helper) {
        var visitResult = component.get('v.visitResult');
        if(visitResult.type === 'Countries' || visitResult.type === 'Countries_Disabled') {
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
        if(globalType !== 'Disabled') return;

        var visitResult = component.get('v.visitResult');
        visitResult.countryCodes = null;
        visitResult.type = globalType;
        component.set('v.visitResult', visitResult);
    }
});