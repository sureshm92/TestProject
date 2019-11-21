({

    getFilteredItem : function (component, helper) {
        component.find('spinner').show();

        this.unCheckAllVendorCheckBoxes(component);

        helper.enqueue(component, 'c.getFilteredItems', {
            'ctpId': component.get('v.recordId'),
            'ssIds': component.get('v.selectedByStudySite'),
            'countryCodes': component.get('v.selectedByCountry'),
            'vendorIds': helper.getVendorIds(component.get('v.selectedVendors')),
            'isFirstLoad': false
        }).then(function (data) {
                component.set('v.vendorItems', data);

                component.find('spinner').hide();
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            component.find('spinner').hide();
            console.log('error:', err[0].message);
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
        let page = component.get('v.currentPage');

        let item =  component.get('v.vendorItems');
        let ssIds = [];
        item.forEach(function (i) {
            ssIds.push(i.studySite.Id);
        });
        let vendors = helper.getVendorIds(component.get('v.selectedVendors'));

        helper.enqueue(component, 'c.getFilteredItems', {
            'ctpId': component.get('v.recordId'),
            'ssIds': ssIds.join(';'),
            'countryCodes': component.get('v.selectedByCountry'),
            'vendorIds': vendors !== null ? vendors : null
        }).then(function (data) {
            component.set('v.vendorItems', data);
            component.set('v.currentPage', page);

            component.find('spinner').hide();
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            component.find('spinner').hide();
            console.log('error:', err[0].message);
        });
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

    checkOnIsManualStudySites: function (studySites, countries, vendorItem) {
            let haveStudySiteId = !$A.util.isUndefinedOrNull(studySites) && studySites.includes(vendorItem.studySite.Id);
            let haveBillingCountryCode = !$A.util.isUndefinedOrNull(countries) && countries.includes(vendorItem.studySite.Site__r.BillingCountryCode);
            console.log('haveBillingCountryCode ' + haveBillingCountryCode);
                vendorItem.vendorSettings.forEach(function (item) {
                    item.Is_Manual__c = haveStudySiteId;
                    item.By_Country__c = haveBillingCountryCode;
                });
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
    }
});