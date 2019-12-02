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
    }

})