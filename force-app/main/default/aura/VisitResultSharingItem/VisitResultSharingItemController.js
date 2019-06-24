/**
 * Created by Leonid Bartenev
 */
({
    doCountryChanged: function (component, event, hepler) {
        var visitResult = component.get('v.visitResult');
        if(!visitResult.countryCodes){
            visitResult.countryMode = false;
            visitResult.type = 'All';
            component.set('v.visitResult', visitResult);
        }
    },

    doTypeChanged: function (component, event, helper) {
        var visitResult = component.get('v.visitResult');
        visitResult.countryMode = visitResult.type === 'Countries';
        component.set('v.visitResult', visitResult);
        component.find('countryLookup').focus();
    },

    doCloseCountryMode: function (component, event, helper) {
        var visitResult = component.get('v.visitResult');
        visitResult.countryCodes = null;
        visitResult.countryMode = false;
        visitResult.type = 'All';
        component.set('v.visitResult', visitResult);
    }

})