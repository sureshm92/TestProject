/**
 * Created by Admin on 8/28/2019.
 */

({
    doInit : function (component, event, helper) {
        component.find('spinner').show();

        communityService.executeAction(component, 'getInitData', {
            'ctpId' : component.get('v.recordId')
        }, function(data) {
            component.set('v.ssItems', data.studySiteItems);
            component.set('v.countryCodes', data.countryCodes);
            component.set('v.languages', data.languages);
            component.set('v.initialized', true);

            component.find('spinner').hide();
        })

    },

    getFilteredSS : function (component, event, helper) {
        component.find('spinner').show();

        communityService.executeAction(component, 'getFilteredItems', {
            'ctpId' : component.get('v.recordId'),
            'ssIds' : component.get('v.selectedSSIds'),
            'countryCodes' : component.get('v.countryCodes'),
            'vendors' : component.get('v.vendors')
        }, function(data) {
            component.set('v.ssItems', data.studySiteItems);

            component.find('spinner').hide();
        })
    },

    whenCountryFilterChanged : function (component, event, helper) {
        let filterType = component.get('v.countryFilterType');
        if(filterType === 'filter'){
            setTimeout(
                $A.getCallback(function () {
                    component.find('countryLookup').focus();
                }), 100
            );
        }
    },

    doSave : function(component, event, controller) {

    }

});