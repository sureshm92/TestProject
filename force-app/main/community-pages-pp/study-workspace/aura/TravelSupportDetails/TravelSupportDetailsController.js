/**
 * Created by Yulia Yakushenkova on 1/21/2020.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        component.set('v.initialized', false);
        communityService.executeAction(component, 'getTravelVendors', {
                //'travelMode': component.get('v.travelMode')
                clientId: '12345',
                clientSecret: '12345',
                isHomePage : false
            },
            function (response) {
                component.set('v.travelWrapper', response);
                console.log('response ' + response);
                let opts = [{value: 'All', label: $A.get("$Label.c.Home_Page_VisitTab_Filter_Show_All")}];
                // for (let i = 0; i < response.length; i++)
                //     opts.push({
                //         value: response[i].title,
                //         label: response[i].title
                //     });
                component.set('v.options', opts);
                component.set('v.initialized', true);
            });
        $A.enqueueAction(component.get('c.getAvailableVendors'));
        component.find('spinner').hide();
    },

    getAvailableVendors: function (component, event, helper) {
        communityService.executeAction(component, 'getAvailableVendorsForSS', {},
            function (response) {component.set('v.vendors', response);});
    }
});