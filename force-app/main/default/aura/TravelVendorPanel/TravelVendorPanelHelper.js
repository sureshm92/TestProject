({

    getFilteredItem : function (component, helper) {
        component.find('spinner').show();
        let vendors = component.get('v.selectedVendors');
        if (vendors.length > 0) {
            communityService.executeAction(component, 'getFilteredItems', {
                'ctpId': component.get('v.recordId'),
                'ssIds': component.get('v.selectedManuallySSIds'),
                'countryCodes': component.get('v.countryCodes'),
                'vendorIds': helper.getVendorIds(component.get('v.selectedVendors'))
            }, function (data) {
                component.set('v.vendorItems', data);
                component.find('spinner').hide();
            })
        } else {
            component.set('v.selectedByCountrySSIds', '');
            component.set('v.countryCodes', '');
            component.set('v.selectedManuallySSIds', '');
            component.set('v.selectedCountryCodes', '');
            component.set('v.vendorItems', []);
            communityService.executeAction(component, 'getFilteredItems', {
            }, function () {
                component.set('v.selectedVendors', []);
                component.find('spinner').hide();
            })
        }
    },

    getVendorIds : function (vendors) {
        let vendorIds = [];
        for (let i = 0; i < vendors.length; i++) {
            vendorIds.push(vendors[i].Id);
        }
        return vendorIds;
    },

    markSettingsIsManual : function (settings, manualSSIds) {
        if (manualSSIds !== null && manualSSIds !== undefined)
        for (let i = 0; i < settings.length; i++) {
            if (manualSSIds.includes(settings[i].Study_Site__c)) {
                settings[i].Is_Manual__c = true;
            }
        }
    }

});