({

    getFilteredItems : function (component, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getFilteredItems', {
            'ctpId' : component.get('v.recordId'),
            'ssIds' : component.get('v.selectedManuallySSIds'),
            'countryCodes' : component.get('v.countryCodes'),
            'vendorIds' : helper.getVendorIds(component.get('v.vendors'))
        }, function(data) {
            console.log(data);
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
    }

});