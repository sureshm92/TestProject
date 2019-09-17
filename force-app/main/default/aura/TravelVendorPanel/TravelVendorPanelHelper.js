({

    getFilteredItem : function (component, helper) {
        component.find('spinner').show();
            communityService.executeAction(component, 'getFilteredItems', {
                'ctpId': component.get('v.recordId'),
                'ssIds': component.get('v.selectedManuallySSIds'),
                'countryCodes': component.get('v.countryCodes'),
                'vendorIds': helper.getVendorIds(component.get('v.selectedVendors'))
            }, function (data) {
                component.set('v.vendorItems', data);
                component.find('spinner').hide();
            })
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
    },

    addVendor : function (component, helper) {
        component.find('spinner').show();
        let item =  component.get('v.vendorItems');
        let ssIds = [];
        item.forEach(function (i) {
            ssIds.push(i.studySite.Id);
        });
        let vendors = helper.getVendorIds(component.get('v.selectedVendors'));
            communityService.executeAction(component, 'getFilteredItems', {
                'ctpId': component.get('v.recordId'),
                'ssIds': ssIds.join(';'),
                'countryCodes': component.get('v.countryCodes'),
                'vendorIds': vendors !== null ? vendors : null
            }, function (data) {
                component.set('v.vendorItems', data);
                component.find('spinner').hide();
            })
    },

});