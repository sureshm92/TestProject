/**
 * Created by Yulia Yakushenkova on 1/21/2020.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        component.set('v.initialized', false);
        var opts = [
            {value: "All", label: "All"},
            {value: "Confirmed", label: $A.get("$Label.c.Home_Page_Travel_Support_Filter_Confirmed")},
            {value: "Declined", label: $A.get("$Label.c.Home_Page_Travel_Support_Filter_Declined")},
            {value: "Pending", label: $A.get("$Label.c.Home_Page_Travel_Support_Filter_Pending") }
        ];
        component.set('v.options', opts);
        $A.enqueueAction(component.get('c.getTravels'));
        $A.enqueueAction(component.get('c.getAvailableVendors'));
        component.find('spinner').hide();
    },

    getTravels: function (component, event, helper) {
        communityService.executeAction(component, 'getParticipantTravels', {
                'visitMode': component.get('v.travelMode')
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