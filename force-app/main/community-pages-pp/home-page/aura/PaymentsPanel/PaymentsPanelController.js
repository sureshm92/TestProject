/**
 * Created by Olga Skrynnikova on 12/20/2019.
 */

({
    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getPaymentData', null, function (response) {
            component.set('v.href', response.href);
            component.set('v.initData', response);
            component.set('v.initialized', true);
        }, null, function () {
            component.find('spinner').hide();
        });
    },
});