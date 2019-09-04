/**
 * Created by Admin on 8/28/2019.
 */

({
    doInit : function (component, event, helper) {
        component.find('spinner').show();

        communityService.executeAction(component, 'getInitData', {
            'ctpId' : component.get('v.recordId')
        }, function(data) {
            component.set('v.vendorItems', data.vendorItems);
            component.set('v.countryCodes', data.countryCodes);
            component.set('v.vendors', data.vendors);
            component.set('v.initialized', true);

            component.find('spinner').hide();
        })

    },

    getFilteredSS : function (component, event, helper) {
        component.find('spinner').show();

        communityService.executeAction(component, 'getFilteredItems', {
            'ctpId' : component.get('v.recordId'),
            'ssIds' : component.get('v.selectedManuallySSIds'),
            'countryCodes' : component.get('v.countryCodes'),
            'vendors' : component.get('v.vendors')
        }, function(data) {
            component.set('v.vendorItems', data);

            console.log('vendorItems ', JSON.stringify(data));
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

    onNewVendor: function(component, event, controller) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "TravelVendor__c"
        });
        createRecordEvent.fire();
    },

    doSave : function(component, event, controller) {

    }

});