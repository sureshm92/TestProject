({

    getFilteredItem : function (component, helper) {
        component.find('spinner').show();

        this.unCheckAllVendorCheckBoxes(component);

            communityService.executeAction(component, 'getFilteredItems', {
                'ctpId': component.get('v.recordId'),
                'ssIds': component.get('v.selectedByStudySite'),
                'countryCodes': component.get('v.selectedByCountry'),
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
                'countryCodes': component.get('v.selectedByCountry'),
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
    },

    checkOnIsManualStudySites: function (studySites, vendorItem) {
        if (studySites != null && studySites != undefined) {
            let haveStudySiteId = studySites.includes(vendorItem.studySite.Id);
            if (haveStudySiteId) {
                vendorItem.vendorSettings.forEach(function (item) {
                    item.Is_Manual__c = true
                });
            }
        }
    },

    checkOnIsSelectedByCountry: function (countries, vendorItem) {
        if (countries != null && countries !== undefined) {
            let haveBillingCountryCode = countries.includes(vendorItem.studySite.Site__r.BillingCountryCode);
            if (haveBillingCountryCode) {
                vendorItem.vendorSettings.forEach(function (item) {
                    item.By_Country__c = true;
                });
            }
        }
    },

    uncheckAllCheckBoxForVendorSettings: function (vendorItems, allSettings) {
        vendorItems.forEach(function (vendorItem) {
            vendorItem.vendorSettings.forEach(function (item) {
                item.Is_Manual__c = false;
                item.By_Country__c = false;
            });
            allSettings = allSettings.concat(vendorItem.vendorSettings);
        });
        return allSettings;
    },

    showAlert: function (title, message, type) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    columnCheckboxStateChange: function (component, event) {
        let target = event.getSource().get('v.label');
        let checked = event.getSource().get('v.value');
        let items = component.get('v.vendorItems');
        items.forEach(function (item) {
            let settings = item.vendorSettings;
            settings.forEach(function (setting) {
                if (setting.TravelVendor__c === target) {
                    setting.isEnable__c = checked;
                }
            });
        });
        component.set('v.vendorItems', items);
    }
});