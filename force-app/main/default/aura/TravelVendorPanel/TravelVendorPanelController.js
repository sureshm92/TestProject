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
            component.set('v.vendors', data.vendors);
            component.set('v.countryCodes', data.countrycodes);
            component.set('v.initialized', true);

            component.find('spinner').hide();
        })

    },

    getFilteredSS : function (component, event, helper) {
        helper.getFilteredItems(component, helper);
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

    onAddTravelVendor: function(component, event, helper) {
        let newVendor = component.find('addTravelVendor').get('v.record');
        let vendors = component.get('v.vendors');
        vendors.push(newVendor);
        component.set('v.vendors', vendors);
        helper.getFilteredItems(component, helper);
        component.find('customModal').hide();
    },

    showModal : function(component, event, helper) {
        component.find('customModal').show();
    },

    closeModal: function (component, event, helper) {
        component.find('customModal').hide();
    },

    submitForm: function (component, event, helper) {
        component.find('addTravelVendor').submitForm();
    },

    doSave : function(component, event, helper) {
        component.find('spinner').show();

        let vendorItems = component.get('v.vendorItems');
        let allSettings = [];
        for (let i = 0; i < vendorItems.length; i++) {
            allSettings = allSettings.concat(vendorItems[i].vendorSettings);
        }

        communityService.executeAction(component, 'saveData', {
            'ctpId' : component.get('v.recordId'),
            'settings' : allSettings
        }, function() {
            component.find('spinner').hide();
        })
    }

});