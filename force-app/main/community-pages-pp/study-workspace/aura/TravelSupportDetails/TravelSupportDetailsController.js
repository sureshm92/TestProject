/**
 * Created by Yulia Yakushenkova on 1/21/2020.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        component.set('v.initialized', false);
        communityService.executeAction(component, 'getTitleFiltered', {},
            function (response) {
                var opts = [{value: "All", label: "All"}];
                if (!response) {
                    component.set('v.initialized', true);
                    component.set('v.options', opts);
                } else {
                    for (var i = 0; i < response.length; i++) {
                        opts.push({
                            value: response[i],
                            label: response[i]
                        });
                    }
                    component.set('v.options', opts);
                    $A.enqueueAction(component.get('c.getTravels'));
                }
            });
        $A.enqueueAction(component.get('c.getAvailableVendors'));
        component.find('spinner').hide();
    },

    getTravels: function (component, event, helper) {
        communityService.executeAction(component, 'getParticipantTravels', {
                'travelMode': component.get('v.travelMode')
            },
            function (response) {
                component.set('v.travelWrapper', response);
                component.set('v.initialized', true);
            },
            function (err) {
                if (err && err[0].message) {
                    console.log(err[0].message);
                }
            });
    },

    getAvailableVendors: function (component, event, helper) {
        communityService.executeAction(component, 'getVendors', {},
            function (response) {
                component.set('v.vendors', response);
            },
            function (err) {
                if (err && err[0].message) {
                    console.log(err[0].message);
                }
            });
    }
});