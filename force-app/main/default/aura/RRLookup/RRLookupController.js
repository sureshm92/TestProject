({
    debug : function(component, event, controller) {
        let recordId = component.find('field').get('v.value');

        communityService.executeAction(component, 'getRecord', {
            'recordId' : component.get('v.recordId')
        }, function(data) {
            component.set('v.vendorItems', data.vendorItems);
            component.set('v.countryCodes', data.countryCodes);
            component.set('v.vendors', data.vendors);
            component.set('v.initialized', true);

            component.find('spinner').hide();
        })
    }
});