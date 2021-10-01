/**
 * Created by Yulia Yakushenkova on 1/29/2020.
 */

({
    doInit: function (component, event, helper) {
        if (communityService) {
            component.find('spinner').show();
            console.log('In init');
            //helper.getTravelVendorsRemotely(component, '12345', '12345');
            communityService.executeAction(
                component,
                'getTravelVendors',
                {
                    clientId: '12345',
                    clientSecret: '12345',
                    isHomePage: true
                },
                function (response) {
                    console.log('response' + JSON.stringify(response));
                    component.set('v.initialized', true);
                    component.set('v.travelWrapper', response);
                },
                null,
                function () {
                    component.find('spinner').hide();
                }
            );
            component.find('spinner').hide();
        }
    }
});
