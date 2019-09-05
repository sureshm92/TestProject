/**
 * Created by Admin on 8/28/2019.
 */

({
    doInit : function (component, event, helper) {
        component.find('spinner').show();

        communityService.executeAction(component, 'getInitData', {
            'ctpId' : component.get('v.recordId')
        }, function(data) {
            console.log(JSON.stringify(data.vendors));
            component.set('v.vendorItems', data.vendorItems);
            component.set('v.vendors', data.vendors);
            component.set('v.initialized', true);

            component.find('spinner').hide();
            console.log(JSON.stringify(component.get('v.vendors')));
        })

    },

    getFilteredSS : function (component, event, helper) {
        helper.getFilteredItems(component);
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

    onAddTravelVendor: function(component, event, controller) {
        console.log(JSON.stringify(component.get('v.vendors')));
        console.log('here!');
        let newVendor = component.find('addTravelVendor').get('v.record');
        let vendorIds = component.get('v.selectedVendorIds');
        let vendors = component.get('v.vendors');
        console.log('1');
        vendorIds.push(newVendor.Id);
        console.log('2');
        console.log(newVendor);
        console.log(vendors);
        vendors.push(newVendor);
        console.log('3');
        console.log(vendorIds);
        component.set('v.selectedVendorIds', vendorIds);
        console.log('4');
        component.set('v.vendors', vendors);
        console.log('5');
        helper.getFilteredItems(component);

    },

    showModal : function(component, event, helper) {
        component.find('customModal').show();
    },

    closeModal: function (component, event, helper) {
        const recId = component.get('v.visitPlanId');
        component.find('customModal').hide();
    },

    submitForm: function (component, event, helper) {
        component.find('addTravelVendor').submitForm();
    },

    doSave : function(component, event, controller) {
        component.find('spinner').show();

        let vendorItems = component.get('v.vendorItems');
        let allSettings = [];
        for (let i = 0; i < vendorItems.length; i++) {
            allSettings.push(vendorItems[i]['vendorSettings']);
        }

        communityService.executeAction(component, 'saveData', {
            'ctpId' : component.get('v.recordId'),
            'settings' : allSettings
        }, function() {
            component.find('spinner').hide();
        })
    }

});