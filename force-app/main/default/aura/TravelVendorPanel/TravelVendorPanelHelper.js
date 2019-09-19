({

    getFilteredItem : function (component, helper) {
        component.find('spinner').show();

        this.unCheckAllVendorCheckBoxes(component);

            communityService.executeAction(component, 'getFilteredItems', {
                'ctpId': component.get('v.recordId'),
                'ssIds': component.get('v.selectedManuallySSIds'),
                'countryCodes': component.get('v.countryCodes'),
                'vendorIds': helper.getVendorIds(component.get('v.selectedVendors'))
            }, function (data) {
                if (data.length > 0) {
                    component.set('v.vendorItems', data);
                    component.find('spinner').hide();
                } else {
                    communityService.executeAction(component, 'getAllData', {
                        'ctpId': component.get('v.recordId')
                    }, function (data) {
                        component.set('v.vendorItems', data.vendorItems);
                        component.set('v.selectedVendors', data.vendors);
                        component.set('v.initialized', true);

                        component.find('spinner').hide();
                    });
                }
            });
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

        this.unCheckAllVendorCheckBoxes(component);

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

    unCheckAllVendorCheckBoxes : function(component, event){
        let vendorCheckBox = component.find('columnVendor');
        if (vendorCheckBox) {
            if (vendorCheckBox.length > 0) {
                vendorCheckBox.forEach(function (item) {
                    item.set('v.value', false)
                });
            } else {
                vendorCheckBox.set('v.value', false);
            }
        }
    }
});