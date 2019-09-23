/**
 * Created by Admin on 8/28/2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();

        communityService.executeAction(component, 'getInitData', {
            'ctpId': component.get('v.recordId')
        }, function (data) {
            if (data.vendorItems.length > 0) {
                component.set('v.vendorItems', data.vendorItems);
                component.set('v.selectedVendors', data.vendors);
                component.set('v.selectedByCountry', data.countryCodes);
                component.set('v.selectedByStudySite', data.selectedSSIds);
                component.set('v.initialized', true);

                component.find('spinner').hide();
            } else {
                communityService.executeAction(component, 'getAllData', {
                    'ctpId': component.get('v.recordId')
                }, function (data) {
                    component.set('v.vendorItems', data.vendorItems);
                    component.set('v.selectedVendors', data.vendors);

                    component.set('v.initialized', true);
                });

                component.find('spinner').hide();
            }
        })
    },

    addVendor: function (component, event, helper) {
        helper.addVendor(component, helper);
    },

    getFilteredSS: function (component, event, helper) {
        helper.getFilteredItem(component, helper);
    },


    onAddTravelVendor: function (component, event, helper) {
        let newVendor = component.find('addTravelVendor').get('v.record');
        let vendors = component.get('v.selectedVendors');
        vendors.push(newVendor);
        component.set('v.selectedVendors', vendors);
        helper.addVendor(component, helper);
        component.find('customModal').hide();
    },

    showModal: function (component, event, helper) {
        component.find('customModal').show();
    },

    closeModal: function (component, event, helper) {
        component.find('customModal').hide();
    },

    submitForm: function (component, event, helper) {
        component.find('addTravelVendor').submitForm();
    },

    doSave: function (component, event, helper) {
        component.find('spinner').show();

        let vendorItems = component.get('v.vendorItems');
        let allSettings = [];
        let studySites = component.get('v.selectedByStudySite');
        let countries = component.get('v.selectedByCountry');

        let isAnyLookUpSelected = studySites || countries;

        if (isAnyLookUpSelected) {
            vendorItems.forEach(function (vendorItem) {
                helper.checkOnIsManualStudySites(studySites, vendorItem);
                helper.checkOnIsSelectedByCountry(countries, vendorItem);
                allSettings = allSettings.concat(vendorItem.vendorSettings);
            });
        } else {
            allSettings = helper.uncheckAllCheckBoxForVendorSettings(vendorItems, allSettings);
        }
        communityService.executeAction(component, 'saveData', {
            'ctpId': component.get('v.recordId'),
            'settings': allSettings
        }, function () {
            component.find('spinner').hide();
            helper.showAlert("Success!", 'Successfully saved.', 'success')
        })
    },

    navToRecord: function (component, event, helper) {
        let target = event.target;
        let rowIndex = target.getAttribute("data-ssid");
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": rowIndex,
            "slideDevName": "Related",
            "isredirect": 'true'
        });
        navEvt.fire();
    },

    columnCheckboxStateChange: function (component, event, helper) {
        helper.columnCheckboxStateChange(component,event);
    }
})