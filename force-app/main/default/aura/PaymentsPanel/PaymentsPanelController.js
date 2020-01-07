/**
 * Created by Olga Skrynnikova on 12/20/2019.
 */

({
    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getPaymentData', null, function(response) {
            component.set('v.initialized', true);
            component.find('spinner').hide();
        });
    },
});