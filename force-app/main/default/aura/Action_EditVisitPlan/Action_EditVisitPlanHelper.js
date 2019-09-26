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

    callRemote: function (component, vpId, needClone) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getVisitPlanWrapper', {
            planId: vpId
        }, function (response) {
            let wrapper = JSON.parse(response);
            let plan = wrapper.plan;
            let visits = wrapper.visits;
            if(needClone) {
                plan.Id = null;
                for(let i = 0; i < visits.length; i++) visits[i].Id = null;
            }
            component.set('v.plan', plan);
            component.set('v.visits', visits);
            component.set('v.iconDetails', wrapper.iconDetails);

            component.find('spinner').hide();
        });
    }
});