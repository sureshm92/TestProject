/**
 * Created by Igor Malyuta on 25.09.2019.
 */

({
    createVPMode: function (component) {
        component.set('v.plan', {
            sobjectType: 'Visit_Plan__c'
        });
        component.set('v.visits', []);
    },

    callRemote: function (component, method, vpId) {
        component.find('spinner').show();
        communityService.executeAction(component, method, {
            planId: vpId
        }, function (response) {
            let wrapper = JSON.parse(response);
            component.set('v.plan', wrapper.plan);
            component.set('v.visits', wrapper.visits);

            component.find('spinner').hide();
        });
    }
});