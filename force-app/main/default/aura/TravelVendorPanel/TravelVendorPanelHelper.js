({

    getFilteredItems : function (component) {
        component.find('spinner').show();

        communityService.executeAction(component, 'getFilteredItems', {
            'ctpId' : component.get('v.recordId'),
            'ssIds' : component.get('v.selectedManuallySSIds'),
            'countryCodes' : component.get('v.countryCodes'),
            'vendors' : component.get('v.selectedVendorIds')
        }, function(data) {
            component.set('v.vendorItems', data);
            console.log('vendorItems ', JSON.stringify(data));
            component.find('spinner').hide();
        })
    },

});